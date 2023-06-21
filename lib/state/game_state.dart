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
        _toAdd = Queue<AnimatedTile>(),
        _persistingData = <(int, int), (int, String, Queue<MoveAction>)>{},
        _grid = <List<AnimatedTile>>[
          for (int y = 0; y < gridY; ++y)
            <AnimatedTile>[
              for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0),
            ],
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

  final Queue<AnimatedTile> _toAdd;
  // Stores the (score, runLengthEncoding)s of the saved grids.
  final Map<(int, int), (int, String, Queue<MoveAction>)> _persistingData;

  List2<AnimatedTile> _grid;
  bool _actionIsUnlocked;
  int _scoreBuffer;
  Queue<MoveAction> _actionHistory;

  Iterable<AnimatedTile> get flattenedGrid => _grid.expand((final List<AnimatedTile> r) => r);
  Iterable<AnimatedTile> get renderTiles => flattenedGrid.followedBy(_toAdd);

  ValueChanged<KeyEvent> get keyListener => _keyEventListener;
  (GestureDragEndCallback, GestureDragEndCallback) get dragEndListeners =>
      (_verticalDragListener, _horizontalDragListener);

  @override
  void dispose() {
    controller.dispose();
    _grid.clear();
    _toAdd.clear();

    super.dispose();
  }

  void reset() {
    // Nullify
    _persistingData.remove((gridY, gridX));
    _loadGrid();
    _alert();
  }

  void registerAnimationController(final TickerProvider provider) {
    controller = AnimationController(vsync: provider, duration: animationDuration)
      ..addStatusListener((final AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          while (_toAdd.isNotEmpty) {
            final AnimatedTile(:int y, :int x, :int value) = _toAdd.removeFirst();

            _grid[y][x].value = value;
          }
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

    _alert();
  }

  bool canSwipeLeft() => _grid.any(_canSwipe);

  bool canSwipeRight() => _grid.reversedRows.any(_canSwipe);

  bool canSwipeUp() => _grid.columns.any(_canSwipe);

  bool canSwipeDown() => _grid.columns.reversedRows.any(_canSwipe);

  bool canSwipeAnywhere() => canSwipeUp() || canSwipeDown() || canSwipeLeft() || canSwipeRight();

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
          for (int y = 0; y < gridY; ++y) //
            <AnimatedTile>[for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0)]
        ];
        this._actionHistory = Queue<MoveAction>();

        for (final AnimatedTile tile in (flattenedGrid.toList()..shuffle()).take(2)) {
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

    _alert();
  }

  void _addNewTile() {
    final List<AnimatedTile> empty = flattenedGrid //
        .where((final AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isEmpty) {
      return;
    }

    final AnimatedTile(:int y, :int x) = empty.first;
    final int chosen = randomTileNumber();
    _grid[y][x].value = chosen;

    _toAdd.add(AnimatedTile((y: y, x: x), chosen)..appear(controller));
  }

  void _swipe(final Direction direction) {
    /// If the swipe actions are locked, then we ignore it.
    if (!_actionIsUnlocked) {
      return;
    }

    switch (direction) {
      case Direction.up:
        _grid.columns.forEach(_mergeTiles);
      case Direction.down:
        _grid.columns.reversedRows.forEach(_mergeTiles);
      case Direction.left:
        _grid.forEach(_mergeTiles);
      case Direction.right:
        _grid.reversedRows.forEach(_mergeTiles);
    }
    _addNewTile();
    _actionIsUnlocked = false;
    controller.forward(from: 0);

    _alert();
  }

  void _alert() {
    score += _scoreBuffer;
    addedScore = Box<int>(_scoreBuffer);
    notifyListeners();
    _scoreBuffer = 0;
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

  /// Merges [tiles] towards the left.
  /// i.e: [2, 0, 0, 8] -> [2, 8, 0, 0]
  void _mergeTiles(final List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      /// We get the sublist from [i], disregarding zeros until the first nonzero.
      final List<AnimatedTile> toCheck = tiles
          .skip(i) //
          .skipWhile((final AnimatedTile tile) => tile.value == 0)
          .toList();

      /// If this happens, then the rest of the list from the right of [i]
      ///   are all zeros, so we don't have to do anything now.
      if (toCheck.isEmpty) {
        return;
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
        var AnimatedTile(:int value) = target;

        /// Animate the tile at position t.
        target.moveTo(controller, x, y);

        /// If we are *confirmed* to be merging two tiles, then:
        if (merge != null) {
          /// Increase the resulting value of the target,
          value *= 2;

          /// Do some animations.
          merge
            ..moveTo(controller, x, y)
            ..bounce(controller)
            ..changeNumber(controller, value)

            /// Change the value of the merged tile,
            ..value = 0;

          /// And the last animation
          target.changeNumber(controller, 0);

          _addScore(value);
        }

        /// Update their values after the update.
        /// Sequence is important here, because there are cases when target == tiles[i].
        target.value = 0;
        tiles[i].value = value;
      }
    }
  }

  void _addScore(final int value) {
    _scoreBuffer += value;
  }
}
