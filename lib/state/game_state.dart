import "dart:collection";
import "dart:io";
import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/data_structures/box.dart";
import "package:twenty_fourty_eight/data_structures/move_action.dart";
import "package:twenty_fourty_eight/data_structures/specific_grid_data.dart";
import "package:twenty_fourty_eight/enum/direction.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";
import "package:twenty_fourty_eight/shared/typedef.dart";

class GameState with ChangeNotifier {
  GameState([this.gridY = _defaultGridY, this.gridX = _defaultGridX])
      : addedScore = const Box<int>(0),
        displayMenu = false,
        _scoreBuffer = 0,
        _actionIsUnlocked = true,
        _ghost = Queue<AnimatedTile>(),
        _persistingData = <(int, int), SpecificGridData>{},
        _activeSpecificGridData = SpecificGridData.empty(),
        _forcedAllowed = true;

  static const int _backtrackLimit = 1;
  static const int _defaultGridY = 4;
  static const int _defaultGridX = 4;
  static const Duration _animationDuration = Duration(milliseconds: 300);

  late final AnimationController controller;

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

  /// Flags that affect UI.
  bool displayMenu;

  final Queue<AnimatedTile> _ghost;
  final Map<(int, int), SpecificGridData> _persistingData;

  bool _actionIsUnlocked;
  int _scoreBuffer;

  SpecificGridData _activeSpecificGridData;

  bool _forcedAllowed;

  Iterable<AnimatedTile> get flattenedGrid => _grid.expand((List<AnimatedTile> r) => r);
  Iterable<AnimatedTile> get renderTiles => flattenedGrid.followedBy(_ghost);

  ValueChanged<KeyEvent> get keyListener => _keyEventListener;

  int get score => _activeSpecificGridData.score;
  set score(int score) => _activeSpecificGridData.score = score;

  int get topTileValue => _activeSpecificGridData.topTile;
  set topTileValue(int topTile) => _activeSpecificGridData.topTile = topTile;

  int get _backtrackCount => _activeSpecificGridData.backtrackCount;
  set _backtrackCount(int count) => _activeSpecificGridData.backtrackCount = count;

  List2<AnimatedTile> get _grid => _activeSpecificGridData.grid;
  Queue<MoveAction> get _actionHistory => _activeSpecificGridData.actionHistory;

  (GestureDragUpdateCallback, GestureDragUpdateCallback) get dragEndListeners =>
      (_verticalDragListener, _horizontalDragListener);

  @override
  void dispose() {
    controller.dispose();
    _grid.clear();
    _ghost.clear();

    super.dispose();
  }

  void reset() {
    _forcedAllowed = true;

    // Nullify
    _persistingData.remove((gridY, gridX));
    _loadGrid();
    notifyListeners();
  }

  void registerAnimationController(TickerProvider provider) {
    controller = AnimationController(vsync: provider, duration: _animationDuration)
      ..addStatusListener((AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          _ghost.clear();
          for (AnimatedTile tile in flattenedGrid) {
            tile
              ..show(controller)
              ..resetAnimations();
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

  void changeDimensions(int gridY, int gridX) {
    _saveGrid();

    this.gridY = gridY;
    this.gridX = gridX;

    _loadGrid();
    notifyListeners();
  }

  bool canSwipeAnywhere() =>
      (!isDebug || _forcedAllowed) && (_canSwipeUp() || _canSwipeDown() || _canSwipeLeft() || _canSwipeRight());

  void backtrack() {
    if (canBacktrack()) {
      _backtrack();
    }
  }

  bool canBacktrack() => _actionHistory.isNotEmpty && _backtrackCount < _backtrackLimit;

  static int randomTileNumber() => switch (random.nextDouble()) {
        <= 0.125 => 4,
        _ => 2,
      };

  static int powerOfTwo(int gridY, int y, int x) => math.pow(2, y * gridY + x + 1).floor();

  bool _canSwipeLeft() => _grid.any(_canSwipe);

  bool _canSwipeRight() => _grid.reversedRows.any(_canSwipe);

  bool _canSwipeUp() => _grid.columns.any(_canSwipe);

  bool _canSwipeDown() => _grid.columns.reversedRows.any(_canSwipe);

  static String _runLengthEncoding(List2<AnimatedTile> tiles) {
    StringBuffer buffer = StringBuffer("${tiles[0].length}::");

    List<AnimatedTile> flattenedTiles = tiles.expand((List<AnimatedTile> v) => v).toList();
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

  static List2<AnimatedTile> _parseRunLengthEncoding(String encoding) {
    var [String dimensionEncoding, String bodyEncoding] = encoding.split("::");
    int gridX = int.parse(dimensionEncoding);

    List2<AnimatedTile> grid = <List<AnimatedTile>>[];
    List<String> splitEncoding = bodyEncoding.split(";");

    int i = 0;

    List<AnimatedTile> buffer = <AnimatedTile>[];
    for (var [int value, int count] in splitEncoding.map((String v) => v.split(":").map(int.parse).toList())) {
      for (int j = 0; j < count; ++j, ++i) {
        var (int y, int x) = (i ~/ gridX, i % gridX);

        buffer.add(AnimatedTile((y: y, x: x), value));
        if (x == gridX - 1) {
          grid.add(buffer);
          buffer = <AnimatedTile>[];
        }
      }
    }

    return grid;
  }

  static bool _collectionEqual(List2<AnimatedTile> left, List2<AnimatedTile> right) {
    for (int y = 0; y < left.length && y < right.length; ++y) {
      for (int x = 0; x < left[y].length && x < right[y].length; ++x) {
        if (left[y][x].value != right[y][x].value) {
          return false;
        }
      }
    }
    return true;
  }

  void _keyEventListener(KeyEvent event) {
    if (event is KeyUpEvent) {
      return;
    }

    switch (event.logicalKey) {
      /// UP
      case LogicalKeyboardKey.arrowUp when _canSwipeUp():
        _swipe(Direction.up);

      /// DOWN
      case LogicalKeyboardKey.arrowDown when _canSwipeDown():
        _swipe(Direction.down);

      /// LEFT
      case LogicalKeyboardKey.arrowLeft when _canSwipeLeft():
        _swipe(Direction.left);

      /// RIGHT
      case LogicalKeyboardKey.arrowRight when _canSwipeRight():
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

      /// DEBUGS
      case LogicalKeyboardKey.numpad3 when isDebug:
        if (_actionHistory.isNotEmpty) {
          MoveAction first = _actionHistory.first;
          MoveAction copy = MoveAction.fromString(MoveAction.encode(first));

          if (kDebugMode) {
            print(first);
            print(copy);
            print(first.toString() == copy.toString());
          }
        }

      /// DEBUGS
      case LogicalKeyboardKey.numpad4 when isDebug:
        if (_actionHistory.isNotEmpty) {
          SpecificGridData gridData = SpecificGridData(
            score,
            score,
            score,
            score,
            _grid,
            _actionHistory,
          );

          if (kDebugMode) {
            print("ONE: ${gridData.encode()}");
            print("TWO: ${SpecificGridData.fromString(gridData.encode()).encode()}");
            print("");
          }
        }
    }
  }

  void _verticalDragListener(DragUpdateDetails details) {
    switch (details.primaryDelta) {
      case null:
        break;

      /// Swipe Up
      case < -1.6 when _canSwipeUp():
        _swipe(Direction.up);

      /// Swipe Down
      case > 1.6 when _canSwipeDown():
        _swipe(Direction.down);
    }
  }

  void _horizontalDragListener(DragUpdateDetails details) {
    switch (details.primaryDelta) {
      case null:
        break;

      /// Swipe Left
      case < -1.6 when _canSwipeLeft():
        _swipe(Direction.left);

      /// Swipe Right
      case > 1.6 when _canSwipeRight():
        _swipe(Direction.right);
    }
  }

  void _saveGrid() {
    _persistingData[(gridY, gridX)] = _activeSpecificGridData;
  }

  void _loadGrid() {
    switch (_persistingData[(gridY, gridX)]) {
      case SpecificGridData data:
        this._activeSpecificGridData = data;
      case null:
        this._activeSpecificGridData = SpecificGridData.create(gridY, gridX);
        for (AnimatedTile tile in (flattenedGrid.toList()..shuffle()).take(2)) {
          tile.value = randomTileNumber();
        }
    }

    for (AnimatedTile tile in flattenedGrid) {
      tile.resetAnimations();
    }
  }

  void _fail() {
    _forcedAllowed = false;

    notifyListeners();
  }

  Set<Tile> _addNewTile() {
    Set<Tile> newTiles = <Tile>{};
    List<AnimatedTile> empty = flattenedGrid //
        .where((AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isNotEmpty) {
      var (AnimatedTile chosenTile && AnimatedTile(:int y, :int x)) = empty.first;
      int chosenValue = randomTileNumber();
      chosenTile.value = chosenValue;
      newTiles.add((y: y, x: x, value: chosenValue));

      _ghost.add(AnimatedTile((y: y, x: x), chosenValue)..appear(controller));
    }

    return newTiles;
  }

  void _swipe(Direction direction) {
    /// If the swipe actions are locked, then we ignore it.
    if (!_actionIsUnlocked) {
      return;
    }

    _forcedAllowed = true;
    _actionIsUnlocked = false;
    _backtrackCount = 0;

    _computation:
    {
      Iterable<List<AnimatedTile>> target = switch (direction) {
        Direction.up => _grid.columns,
        Direction.down => _grid.columns.reversedRows,
        Direction.left => _grid,
        Direction.right => _grid.reversedRows,
      };

      List<MergeAction> merges = <MergeAction>[];
      for (List<AnimatedTile> tiles in target) {
        /// SWIPE LEFT ALGORITHM
        for (int i = 0; i < tiles.length; ++i) {
          List<AnimatedTile> toCheck = tiles
              .skip(i) //
              .skipWhile((AnimatedTile tile) => tile.value == 0)
              .toList();

          /// If this happens, then the rest of the list from the right of [i]
          ///   are all zeros, so we don't have to do anything now.
          if (toCheck.isEmpty) {
            break;
          }

          AnimatedTile target = toCheck.first;

          AnimatedTile? merge = toCheck //
              .skip(1)
              .where((AnimatedTile tile) => tile.value != 0)
              .firstOrNull;

          if (merge != null && merge.value != target.value) {
            merge = null;
          }

          if (tiles[i].value == 0 || merge != null) {
            var AnimatedTile(:int x, :int y) = tiles[i];
            int value = target.value;

            /// Animate the tile at position t.
            target.hide(controller);

            AnimatedTile animatedTarget = AnimatedTile.from(target.tile) //
              ..moveTo(controller, x, y);

            /// If we are *confirmed* to be merging two tiles, then:
            if (merge != null) {
              /// Increase the resulting value of the target,
              value += merge.value;

              /// Do some animations.
              merge.hide(controller);
              _ghost.add(
                AnimatedTile.from(merge.tile)
                  ..moveTo(controller, x, y)
                  ..bounce(controller)
                  ..changeNumber(controller, value),
              );

              /// Change the value of the merged tile,
              merge.value = 0;

              /// And the last animation
              animatedTarget.changeNumber(controller, 0);

              _addScore(value);
            }

            _ghost.add(animatedTarget);

            /// Update their values after the update.
            /// Sequence is important here, because there are cases when target == tiles[i].
            target.value = 0;
            tiles[i].value = value;

            merges.add((target: target.tile, merge: merge?.tile, destination: tiles[i].tile));
          }
        }
      }
      Set<Tile> added = _addNewTile();

      score += _scoreBuffer;
      addedScore = Box<int>(_scoreBuffer);
      _actionHistory.addFirst(MoveAction(actions: merges, added: added, scoreDelta: _scoreBuffer));

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

    _forcedAllowed = true;
    _actionIsUnlocked = false;
    _backtrackCount += 1;

    _computation:
    {
      var MoveAction(:List<MergeAction> actions, :Set<Tile> added, :int scoreDelta) = _actionHistory.removeFirst();

      for (Tile tile in added) {
        _ghost.add(AnimatedTile.from(tile)..disappear(controller));
        _grid.at(tile)
          ..hide(controller)
          ..value = 0;
      }

      for (MergeAction action in actions.reversed) {
        switch (action) {
          case (:Tile target, merge: null, :Tile destination):
            int value = destination.value;

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
              ..hide(controller)
              ..value = 0;
            _grid.at(target)
              ..hide(controller)
              ..value = value;

          case (:Tile target, :Tile merge, :Tile destination):
            int value = destination.value ~/ 2;

            _ghost
              ..add(
                AnimatedTile.from(destination, value) //
                  ..unmoveTo(controller, target.x, target.y),
              )
              ..add(
                AnimatedTile.from(destination, value) //
                  ..unmoveTo(controller, merge.x, merge.y),
              )
              ..add(
                AnimatedTile.from(destination) //
                  ..debounce(controller)
                  ..unchangeNumber(controller, 0),
              );

            _grid.at(destination)
              ..hide(controller)
              ..value = 0;

            _grid.at(target)
              ..hide(controller)
              ..value = value;

            _grid.at(merge)
              ..hide(controller)
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
  bool _canSwipe(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      AnimatedTile? query = tiles.skip(i + 1).skipWhile((AnimatedTile t) => t.value == 0).firstOrNull;

      if (query != null && (tiles[i].value == 0 || query.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  void _addScore(int value) {
    _scoreBuffer += value;
  }
}
