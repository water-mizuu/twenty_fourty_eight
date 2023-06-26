import "dart:async";
import "dart:collection";
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

typedef Listeners = (GestureDragUpdateCallback, GestureDragUpdateCallback);

class GameState with ChangeNotifier {
  GameState([int? gridY, int? gridX])
      : gridY = gridY ?? sharedPreferences.getInt(Keys.gridY) ?? _defaultGridY,
        gridX = gridX ?? sharedPreferences.getInt(Keys.gridX) ?? _defaultGridX,
        addedScore = const Box<int>(0),
        isMenuDisplayed = false,
        _scoreBuffer = 0,
        _actionIsUnlocked = true,
        _ghost = Queue<AnimatedTile>(),
        _forcedAllowed = true {
    this._activeSpecificGridData = SpecificGridData.base(this.gridY, this.gridX);
  }

  static const int maxGridX = 8;
  static const int maxGridY = 8;
  static const int minGridX = 2;
  static const int minGridY = 2;

  // Why Box<int> instead of int? Because when we change the value to a value
  //  with the same number (but we changed it), the framework does not count it as a change.
  // Basically, we want it to update each _alert(), and alerting the same value twice in a row
  //  will not alert the listeners.
  Box<int> addedScore;

  late final AnimationController controller;

  /// Flags that affect UI.
  bool isMenuDisplayed;

  bool get isResetHighlighted => !canSwipeAnywhere();

  int gridX;
  int gridY;

  static const Duration animationDuration = Duration(milliseconds: 300);
  static const int _backtrackLimit = 1;
  static const int _defaultGridX = 4;
  static const int _defaultGridY = 4;

  bool _actionIsUnlocked;
  late SpecificGridData _activeSpecificGridData;
  bool _forcedAllowed;
  final Queue<AnimatedTile> _ghost;
  int _scoreBuffer;

  @override
  void dispose() {
    controller.dispose();
    _grid.clear();
    _ghost.clear();

    super.dispose();
  }

  Iterable<AnimatedTile> get flattenedGrid => _grid.expand((List<AnimatedTile> r) => r);

  Iterable<AnimatedTile> get renderTiles => flattenedGrid.followedBy(_ghost);

  ValueChanged<KeyEvent> get keyListener => _keyEventListener;

  int get score => _activeSpecificGridData.score;

  set score(int score) => _activeSpecificGridData.score = score;

  AnimatedTile get topTile => _activeSpecificGridData.topTile;

  Listeners get dragEndListeners => (_verticalDragListener, _horizontalDragListener);

  void start() {
    _forcedAllowed = true;

    switch (sharedPreferences.getString(_key)) {
      case String data:
        this._activeSpecificGridData = SpecificGridData.fromString(data);
      case null:
        this._activeSpecificGridData = SpecificGridData.create(gridY, gridX);
        for (AnimatedTile tile in (flattenedGrid.toList()..shuffle()).take(2)) {
          tile.value = randomTileNumber();
          if (tile.value > topTile.value) {
            topTile.value = tile.value;
          }
        }
    }

    for (AnimatedTile tile in flattenedGrid) {
      tile
        ..resetAnimations()
        ..appear(controller);
    }

    topTile
      ..resetAnimations()
      ..appear(controller);

    controller.forward(from: 0.0);
    notifyListeners();
  }

  Future<void> resetGame() async {
    // Nullify
    await sharedPreferences.remove(_key);
    start();
  }

  Future<void> resetAllGridData() async {
    for (int y = minGridY; y <= maxGridY; ++y) {
      for (int x = minGridX; x <= maxGridX; ++x) {
        if (_keyOf(y, x) case String key when sharedPreferences.containsKey(key)) {
          await sharedPreferences.remove(_keyOf(y, x));
        }
      }
    }
    start();
  }

  void registerAnimationController(TickerProvider provider) {
    controller = AnimationController(vsync: provider, duration: animationDuration)
      ..addStatusListener((AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          _ghost.clear();
          for (AnimatedTile tile in flattenedGrid) {
            tile
              ..show(controller)
              ..resetAnimations();
          }
          topTile
            ..show(controller)
            ..resetAnimations();

          controller.reset();
          _actionIsUnlocked = true;
        }
      });
  }

  void openMenu() {
    isMenuDisplayed = true;

    notifyListeners();
  }

  void closeMenu() {
    isMenuDisplayed = false;

    notifyListeners();
  }

  Future<void> changeDimensions(int gridY, int gridX) async {
    await _saveGrid();

    if (this.gridY == gridY && this.gridX == gridX) {
      return;
    }

    await Future.wait(<Future<void>>[
      sharedPreferences.setInt(Keys.gridY, this.gridY = gridY),
      sharedPreferences.setInt(Keys.gridX, this.gridX = gridX),
    ]);

    start();
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

  int get _backtrackCount => _activeSpecificGridData.backtrackCount;

  set _backtrackCount(int count) => _activeSpecificGridData.backtrackCount = count;

  List2<AnimatedTile> get _grid => _activeSpecificGridData.grid;

  Queue<MoveAction> get _actionHistory => _activeSpecificGridData.actionHistory;

  String get _key => _keyOf(gridY, gridX);

  bool _canSwipeLeft() => _grid.any(_canSwipe);

  bool _canSwipeRight() => _grid.reversedRows.any(_canSwipe);

  bool _canSwipeUp() => _grid.columns.any(_canSwipe);

  bool _canSwipeDown() => _grid.columns.reversedRows.any(_canSwipe);

  static String _keyOf(int gridY, int gridX) => "GRID[$gridY;$gridX]";

  Future<void> _keyEventListener(KeyEvent event) async {
    if (event is KeyUpEvent) {
      return;
    }

    switch (event.logicalKey) {
      /// UP
      case LogicalKeyboardKey.arrowUp when _canSwipeUp():
        await _swipe(Direction.up);

      /// DOWN
      case LogicalKeyboardKey.arrowDown when _canSwipeDown():
        await _swipe(Direction.down);

      /// LEFT
      case LogicalKeyboardKey.arrowLeft when _canSwipeLeft():
        await _swipe(Direction.left);

      /// RIGHT
      case LogicalKeyboardKey.arrowRight when _canSwipeRight():
        await _swipe(Direction.right);

      /// DEBUGS
      case LogicalKeyboardKey.numpad0 when isDebug:
        _fail();

      /// DEBUGS
      case LogicalKeyboardKey.numpad1 when isDebug:
        _backtrack();

      /// DEBUGS
      case LogicalKeyboardKey.numpad2 when isDebug && _actionHistory.isNotEmpty:
        if (kDebugMode) {
          MoveAction first = _actionHistory.first;
          MoveAction copy = MoveAction.fromString(MoveAction.encode(first));

          print(first);
          print(copy);
          print(first.toString() == copy.toString());
        }

      /// DEBUGS
      case LogicalKeyboardKey.numpad3 when isDebug && _actionHistory.isNotEmpty && kDebugMode:
        if (kDebugMode) {
          print("ONE: ${_activeSpecificGridData.encode()}");
          print("TWO: ${SpecificGridData.fromString(_activeSpecificGridData.encode()).encode()}");
          print("");
        }

      /// DEBUGS
      case LogicalKeyboardKey.numpad4 when isDebug:
        break;
    }
  }

  Future<void> _verticalDragListener(DragUpdateDetails details) async {
    switch (details.primaryDelta) {
      case null:
        break;

      /// Swipe Up
      case < -1.6 when _canSwipeUp():
        await _swipe(Direction.up);

      /// Swipe Down
      case > 1.6 when _canSwipeDown():
        await _swipe(Direction.down);
    }
  }

  Future<void> _horizontalDragListener(DragUpdateDetails details) async {
    switch (details.primaryDelta) {
      case null:
        break;

      /// Swipe Left
      case < -1.6 when _canSwipeLeft():
        await _swipe(Direction.left);

      /// Swipe Right
      case > 1.6 when _canSwipeRight():
        await _swipe(Direction.right);
    }
  }

  Future<void> _saveGrid() async {
    await sharedPreferences.setString(_key, _activeSpecificGridData.encode());
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
      for (AnimatedTile chosenTile in empty.take(switch (random.nextDouble()) { < 0.01 => 2, _ => 1 })) {
        var AnimatedTile(:int y, :int x) = chosenTile;
        int chosenValue = randomTileNumber();
        chosenTile.value = chosenValue;
        newTiles.add((y: y, x: x, value: chosenValue));

        _ghost.add(AnimatedTile((y: y, x: x), chosenValue)..appear(controller));
      }
    }

    return newTiles;
  }

  Future<void> _swipe(Direction direction) async {
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

              if (value > topTile.value) {
                topTile
                  ..changeNumber(controller, value)
                  ..bounce(controller)
                  ..value = value;
              }

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

    await _saveGrid();
    unawaited(controller.forward(from: 0.0));
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
