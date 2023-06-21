import "dart:collection";
import "dart:io";
import "dart:math" as math;

import "package:flutter/material.dart" hide Action;
import "package:flutter/services.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/data_structures/box.dart";
import "package:twenty_fourty_eight/data_structures/move_action.dart";
import "package:twenty_fourty_eight/enum/direction.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";
import "package:twenty_fourty_eight/shared/typedef.dart";

enum MenuState {
  openMenu,
  closeMenu,
}

class GameState with ChangeNotifier {
  GameState([this.gridY = defaultGridY, this.gridX = defaultGridX])
      : score = 0,
        addedScore = const Box<int>(0),
        displayMenu = false,
        _scoreBuffer = 0,
        _actionIsUnlocked = true,
        _ghost = Queue<AnimatedTile>(),
        _persistingData = <(int, int), (int, String, Queue<MoveAction>)>{},
        // _grid = <List<AnimatedTile>>[
        //   for (int y = 0; y < gridY; ++y)
        //     <AnimatedTile>[
        //       for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0),
        //     ],
        // ],
        _grid = <List<AnimatedTile>>[
          for (int y = 0; y < gridY; ++y)
            <AnimatedTile>[
              for (int x = 0; x < gridX; ++x)
                AnimatedTile(
                  (y: y, x: x),
                  <List<int>>[
                    <int>[0, 0, 0, 0],
                    <int>[2, 0, 2, 2],
                    <int>[0, 0, 0, 0],
                    <int>[0, 0, 0, 2],
                  ][y][x],
                ),
            ]
        ],
        _actionHistory = Queue<MoveAction>();

  static const int defaultGridY = 4;
  static const int defaultGridX = 4;
  static const Duration animationDuration = Duration(milliseconds: 285);

  late final AnimationController controller;

  int score;
  // Why Box<int> instead of int? Because when we change the value to a value
  //  with the same number (but we changed it), the framework does not count it as a change.
  // Basically, we want it to update each _alert(), and alerting the same value twice in a row won't count.
  //
  // tl;dr:
  //  framework pov:
  //    value.set(3)
  //    value.set(3) // didn't change, so there's no need to update.
  //  what we want:
  //    value.set(3)
  //    value.set(3) // oh we called set, update its listeners.
  Box<int> addedScore;
  int gridY;
  int gridX;
  bool displayMenu;

  final Queue<AnimatedTile> _ghost;
  // Stores the (score, runLengthEncoding)s of the saved grids.
  final Map<(int, int), (int, String, Queue<MoveAction>)> _persistingData;

  List2<AnimatedTile> _grid;
  bool _actionIsUnlocked;
  int _scoreBuffer;
  Queue<MoveAction> _actionHistory;

  Iterable<AnimatedTile> get flattenedGrid => _grid.expand((final List<AnimatedTile> r) => r);
  Iterable<AnimatedTile> get renderTiles => flattenedGrid.followedBy(_ghost);

  ValueChanged<KeyEvent> get keyListener => _keyEventListener;
  (GestureDragEndCallback, GestureDragEndCallback) get dragEndListeners =>
      (_verticalDragListener, _horizontalDragListener);

  @override
  void dispose() {
    controller.dispose();
    _grid.clear();
    _ghost.clear();

    super.dispose();
  }

  void reset() {
    // Nullify
    _persistingData.remove((gridY, gridX));
    _loadGrid();
    notifyListeners();
  }

  void registerAnimationController(final TickerProvider provider) {
    controller = AnimationController(vsync: provider, duration: animationDuration)
      ..addStatusListener((final AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          _ghost.clear();
          for (final AnimatedTile tile in flattenedGrid) {
            tile.resetAnimations();
          }

          controller.reset();
          _actionIsUnlocked = true;
        }
      });
  }

  void openMenu() {
    displayMenu = true;

    notifyListeners();
  }

  void closeMenu() {
    displayMenu = false;

    notifyListeners();
  }

  void changeDimensions(final int gridY, final int gridX) {
    _saveGrid();

    this.gridY = gridY;
    this.gridX = gridX;

    _loadGrid();
    notifyListeners();
  }

  bool canSwipeLeft() => _grid.any(_canSwipe);

  bool canSwipeRight() => _grid.reversedRows.any(_canSwipe);

  bool canSwipeUp() => _grid.columns.any(_canSwipe);

  bool canSwipeDown() => _grid.columns.reversedRows.any(_canSwipe);

  bool canSwipeAnywhere() => canSwipeUp() || canSwipeDown() || canSwipeLeft() || canSwipeRight();

  void backtrack() => _backtrack();

  bool canBacktrack() => _actionHistory.isNotEmpty;

  static int randomTileNumber() => switch (random.nextDouble()) {
        <= 0.125 => 4,
        _ => 2,
      };

  static int powerOfTwo(final int gridY, final int y, final int x) => math.pow(2, y * gridY + x + 1).floor();

  static String _runLengthEncoding(final List2<AnimatedTile> tiles) {
    final StringBuffer buffer = StringBuffer("${tiles[0].length}::");

    final List<AnimatedTile> flattenedTiles = tiles.expand((final List<AnimatedTile> v) => v).toList();
    for (int i = 0; i < flattenedTiles.length; ++i) {
      int count = 1;
      while (i + 1 < flattenedTiles.length && flattenedTiles[i].value == flattenedTiles[i + 1].value) {
        ++count;
        ++i;
      }
      buffer.write("${flattenedTiles[i].value}:$count");
      if (i < flattenedTiles.length - 1) {
        buffer.write(";");
      }
    }

    return buffer.toString();
  }

  static List2<AnimatedTile> _parseRunLengthEncoding(final String encoding) {
    final [String dimensionEncoding, String bodyEncoding] = encoding.split("::");
    final int gridX = int.parse(dimensionEncoding);

    final List2<AnimatedTile> grid = <List<AnimatedTile>>[];
    final List<String> splitEncoding = bodyEncoding.split(";");

    int i = 0;

    List<AnimatedTile> buffer = <AnimatedTile>[];
    for (final [int value, int count] in splitEncoding.map((final String v) => v.split(":").map(int.parse).toList())) {
      for (int j = 0; j < count; ++j, ++i) {
        final (int y, int x) = (i ~/ gridX, i % gridX);

        buffer.add(AnimatedTile((y: y, x: x), value));
        if (x == gridX - 1) {
          grid.add(buffer);
          buffer = <AnimatedTile>[];
        }
      }
    }

    return grid;
  }

  static bool _collectionEqual(final List2<AnimatedTile> left, final List2<AnimatedTile> right) {
    for (int y = 0; y < left.length && y < right.length; ++y) {
      for (int x = 0; x < left[y].length && x < right[y].length; ++x) {
        if (left[y][x].value != right[y][x].value) {
          return false;
        }
      }
    }
    return true;
  }

  void _keyEventListener(final KeyEvent event) {
    if (event is KeyUpEvent) {
      return;
    }

    switch (event.logicalKey) {
      /// UP
      case LogicalKeyboardKey.arrowUp when canSwipeUp():
        _swipe(Direction.up);

      /// DOWN
      case LogicalKeyboardKey.arrowDown when canSwipeDown():
        _swipe(Direction.down);

      /// LEFT
      case LogicalKeyboardKey.arrowLeft when canSwipeLeft():
        _swipe(Direction.left);

      /// RIGHT
      case LogicalKeyboardKey.arrowRight when canSwipeRight():
        _swipe(Direction.right);

      /// DEBUGS
      case LogicalKeyboardKey.numpad0 when isDebug:
        _fail();

      /// DEBUGS
      case LogicalKeyboardKey.numpad1 when isDebug:
        stdout.writeln(_collectionEqual(_grid, _parseRunLengthEncoding(_runLengthEncoding(_grid))));

      /// DEBUGS
      case LogicalKeyboardKey.numpad2 when isDebug:
        _backtrack();
    }
  }

  void _verticalDragListener(final DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dy) {
      /// Swipe Up
      case < -200 when canSwipeUp():
        _swipe(Direction.up);

      /// Swipe Down
      case > 200 when canSwipeDown():
        _swipe(Direction.down);
    }
  }

  void _horizontalDragListener(final DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dx) {
      /// Swipe Left
      case < -200 when canSwipeLeft():
        _swipe(Direction.left);

      /// Swipe Right
      case > 200 when canSwipeRight():
        _swipe(Direction.right);
    }
  }

  void _saveGrid() {
    _persistingData[(gridY, gridX)] = (score, _runLengthEncoding(_grid), _actionHistory);
  }

  void _loadGrid() {
    switch (_persistingData[(gridY, gridX)]) {
      case (final int score, final String encoding, final Queue<MoveAction> actionHistory):
        this.score = score;
        this._grid = _parseRunLengthEncoding(encoding);
        this._actionHistory = actionHistory;
      case null:
        this.score = 0;
        this._grid = <List<AnimatedTile>>[
          for (int y = 0; y < gridY; ++y)
            <AnimatedTile>[
              for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0),
            ]
        ];
        this._actionHistory = Queue<MoveAction>();

        for (final AnimatedTile tile in (flattenedGrid.toList()..shuffle()).take(1)) {
          tile.value = randomTileNumber();
        }
    }

    for (final AnimatedTile tile in flattenedGrid) {
      tile.resetAnimations();
    }
  }

  void _fail() {
    for (final AnimatedTile(:int y, :int x) in flattenedGrid) {
      _grid[y][x].value = powerOfTwo(gridY, y, x);
    }

    notifyListeners();
  }

  Set<Tile> _addNewTile() {
    final Set<Tile> newTiles = <Tile>{};
    final List<AnimatedTile> empty = flattenedGrid //
        .where((final AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isNotEmpty) {
      final (AnimatedTile chosenTile && AnimatedTile(:int y, :int x)) = empty.first;
      final int chosenValue = randomTileNumber();
      chosenTile.value = chosenValue;
      newTiles.add((y: y, x: x, value: chosenValue));

      _ghost.add(AnimatedTile((y: y, x: x), chosenValue)..appear(controller));
    }

    return newTiles;
  }

  void _swipe(final Direction direction) {
    /// If the swipe actions are locked, then we ignore it.
    if (!_actionIsUnlocked) {
      return;
    }

    _actionIsUnlocked = false;

    _computation:
    {
      final Iterable<List<AnimatedTile>> target = switch (direction) {
        Direction.up => _grid.columns,
        Direction.down => _grid.columns.reversedRows,
        Direction.left => _grid,
        Direction.right => _grid.reversedRows,
      };

      final List<Merge> merges = <Merge>[];
      for (final List<AnimatedTile> tiles in target) {
        /// SWIPE LEFT ALGORITHM
        for (int i = 0; i < tiles.length; ++i) {
          /// We get the sublist from [i], disregarding zeros until the first nonzero.
          final List<AnimatedTile> toCheck = tiles
              .skip(i) //
              .skipWhile((final AnimatedTile tile) => tile.value == 0)
              .toList();

          /// If this happens, then the rest of the list from the right of [i]
          ///   are all zeros, so we don't have to do anything now.
          if (toCheck.isEmpty) {
            break;
          }

          final AnimatedTile target = toCheck.first;

          AnimatedTile? merge = toCheck //
              .skip(1)
              .where((final AnimatedTile tile) => tile.value != 0)
              .firstOrNull;

          if (merge case AnimatedTile(:final int value) when value != target.value) {
            merge = null;
          }

          if (tiles[i].value == 0 || merge != null) {
            final AnimatedTile(:int x, :int y) = tiles[i];
            int value = target.value;

            /// Animate the tile at position t.
            target.animate(controller);

            _ghost.add(
              AnimatedTile.from(target.tile) //
                ..moveTo(controller, x, y),
            );

            /// If we are *confirmed* to be merging two tiles, then:
            if (merge != null) {
              /// Increase the resulting value of the target,
              value *= 2;

              merge.animate(controller);

              /// Do some animations.
              _ghost.add(
                AnimatedTile.from(merge.tile)
                  ..moveTo(controller, x, y)
                  ..bounce(controller)
                  ..changeNumber(controller, value),
              );

              /// Change the value of the merged tile,
              merge.value = 0;

              /// And the last animation
              target.changeNumber(controller, 0);

              _addScore(value);
            }

            /// Update their values after the update.
            /// Sequence is important here, because there are cases when target == tiles[i].
            target.value = 0;
            tiles[i].value = value;

            merges.add((from: (target.tile, merge?.tile), to: tiles[i].tile));
          }
        }
      }
      final Set<Tile> added = _addNewTile();

      score += _scoreBuffer;
      addedScore = Box<int>(_scoreBuffer);
      _actionHistory.addFirst(MoveAction(merges: merges, added: added, scoreDelta: _scoreBuffer));

      _scoreBuffer = 0;
      break _computation;
    }

    controller.forward(from: 0.0);
    notifyListeners();
  }

  void _backtrack() {
    if (!_actionIsUnlocked || _actionHistory.isEmpty) {
      return;
    }

    _actionIsUnlocked = false;

    _computation:
    {
      final MoveAction(
        :List<Merge> merges,
        :Set<Tile> added,
        :int scoreDelta,
      ) = _actionHistory.removeFirst();

      for (final Tile tile in added) {
        _ghost.add(AnimatedTile.from(tile)..disappear(controller));
        _grid.at(tile)
          ..animate(controller)
          ..value = 0;
      }

      for (final Merge merge in merges.reversed) {
        switch (merge) {
          case (from: (final Tile target, null), to: final Tile destination):
            final int value = destination.value;

            _ghost
              ..add(
                AnimatedTile.from(destination) //
                  ..unmoveTo(controller, target.x, target.y)
                  ..unchangeNumber(controller, value),
              )
              ..add(
                AnimatedTile.from(target) //
                  ..unchangeNumber(controller, 0),
              );

            _grid.at(destination)
              ..resetAnimations()
              ..animate(controller)
              ..value = 0;
            _grid.at(target)
              ..resetAnimations()
              ..animate(controller)
              ..value = value;

          case (from: (final Tile target, final Tile merge), to: final Tile destination):
            final int value = destination.value ~/ 2;

            _ghost
              ..add(
                AnimatedTile.from(destination, value) //
                  ..debounce(controller)
                  ..unchangeNumber(controller, 0),
              )
              ..add(
                AnimatedTile.from(destination, value) //
                  ..unmoveTo(controller, target.x, target.y),
              )
              ..add(
                AnimatedTile.from(destination, value) //
                  ..unmoveTo(controller, merge.x, merge.y),
              );

            _grid.at(destination)
              ..resetAnimations()
              ..animate(controller)
              ..value = 0;

            _grid.at(target)
              ..resetAnimations()
              ..animate(controller)
              ..value = value;

            _grid.at(merge)
              ..resetAnimations()
              ..animate(controller)
              ..value = value;
        }
      }

      score -= scoreDelta;
      addedScore = Box<int>(-scoreDelta);
      break _computation;
    }

    controller.forward(from: 0.0);
    notifyListeners();
  }

  /// Returns a [bool] indicating whether [tiles] can be swiped to left
  ///   from the following conditions:
  /// ```txt
  /// 1. the row has trailing zeros, i.e [0, 2, *, *]
  /// 2. the row has a merge, i.e [2, 2, *, *]
  /// ```
  bool _canSwipe(final List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      final AnimatedTile? query = tiles.skip(i + 1).skipWhile((final AnimatedTile t) => t.value == 0).firstOrNull;

      if (query != null && (tiles[i].value == 0 || query.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  void _addScore(final int value) {
    _scoreBuffer += value;
  }
}
