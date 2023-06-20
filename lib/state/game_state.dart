import "dart:collection";
import "dart:io";
import "dart:math" as math;

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/data_structures/box.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";
import "package:twenty_fourty_eight/shared/typedef.dart";

enum MenuState {
  openMenu,
  closeMenu,
}

class GameState with ChangeNotifier {
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

  final List2<AnimatedTile> _grid;
  final Queue<AnimatedTile> _toAdd;

  bool _actionIsUnlocked;
  int _scoreBuffer;

  GameState([this.gridY = defaultGridY, this.gridX = defaultGridX])
      : score = 0,
        addedScore = const Box<int>(0),
        displayMenu = false,
        _scoreBuffer = 0,
        _actionIsUnlocked = true,
        _toAdd = Queue<AnimatedTile>(),
        _grid = <List<AnimatedTile>>[
          for (int y = 0; y < gridY; ++y)
            <AnimatedTile>[
              for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0),
            ],
        ];

  Iterable<AnimatedTile> get flattenedGrid => _grid.expand((List<AnimatedTile> r) => r);
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
    for (var AnimatedTile(:int y, :int x) in flattenedGrid) {
      _grid[y][x].value = 0;
    }

    _startGame();
    _alert();
  }

  void registerAnimationController(TickerProvider provider) {
    controller = AnimationController(vsync: provider, duration: animationDuration)
      ..addStatusListener((AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          while (_toAdd.isNotEmpty) {
            var AnimatedTile(:int y, :int x, :int value) = _toAdd.removeFirst();

            _grid[y][x].value = value;
          }
          for (AnimatedTile tile in flattenedGrid) {
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

  void changeDimensions(int gridY, int gridX) {
    this.gridY = gridY;
    this.gridX = gridX;

    _resetGrid();
    _startGame();

    _alert();
  }

  bool canSwipeLeft() => _grid.any(_canSwipe);
  bool canSwipeRight() => _grid.reversedRows.any(_canSwipe);
  bool canSwipeUp() => _grid.columns.any(_canSwipe);
  bool canSwipeDown() => _grid.columns.reversedRows.any(_canSwipe);
  bool canSwipeAnywhere() => canSwipeUp() || canSwipeDown() || canSwipeLeft() || canSwipeRight();

  void swipeUp() => _swipe(() => _grid.columns.forEach(_mergeTiles));
  void swipeDown() => _swipe(() => _grid.columns.reversedRows.forEach(_mergeTiles));
  void swipeLeft() => _swipe(() => _grid.forEach(_mergeTiles));
  void swipeRight() => _swipe(() => _grid.reversedRows.forEach(_mergeTiles));

  String get runLengthEncoding {
    StringBuffer buffer = StringBuffer("$gridY;$gridX::");

    List<AnimatedTile> tiles = flattenedGrid.toList();
    for (int i = 0; i < tiles.length; ++i) {
      int count = 1;
      while (i + 1 < tiles.length && tiles[i].value == tiles[i + 1].value) {
        ++count;
        ++i;
      }
      buffer.write("${tiles[i].value}:$count");
      if (i < tiles.length - 1) {
        buffer.write(";");
      }
    }

    return buffer.toString();
  }

  static List2<AnimatedTile> parseRunLengthEncoding(String encoding) {
    var [String dimensionEncoding, String bodyEncoding] = encoding.split("::");
    var [int gridY, int gridX] = dimensionEncoding.split(";").map(int.parse).toList();

    List2<AnimatedTile> grid = <List<AnimatedTile>>[];
    List<String> splitEncoding = bodyEncoding.split(";");

    int i = 0;

    List<AnimatedTile> buffer = <AnimatedTile>[];
    for (var [int value, int count] in splitEncoding.map((String v) => v.split(":").map(int.parse).toList())) {
      for (int j = 0; j < count; ++j, ++i) {
        var (int y, int x) = (i ~/ gridY, i % gridX);

        buffer.add(AnimatedTile((y: y, x: x), value));
        if (x == gridX - 1) {
          grid.add(buffer);
          buffer = <AnimatedTile>[];
        }
      }
    }

    return grid;
  }

  static bool collectionEqual(List2<AnimatedTile> left, List2<AnimatedTile> right) {
    for (int y = 0; y < left.length && y < right.length; ++y) {
      for (int x = 0; x < left[y].length && x < right[y].length; ++x) {
        if (left[y][x].value != right[y][x].value) {
          return false;
        }
      }
    }
    return true;
  }

  static int randomTileNumber() => switch (random.nextDouble()) {
        <= 0.125 => 4,
        _ => 2,
      };

  static int powerOfTwo(int gridY, int y, int x) => math.pow(2, y * gridY + x + 1).floor();

  void _keyEventListener(KeyEvent event) {
    switch (event.logicalKey) {
      /// UP
      case LogicalKeyboardKey.arrowUp when canSwipeUp():
        swipeUp();

      /// DOWN
      case LogicalKeyboardKey.arrowDown when canSwipeDown():
        swipeDown();

      /// LEFT
      case LogicalKeyboardKey.arrowLeft when canSwipeLeft():
        swipeLeft();

      /// RIGHT
      case LogicalKeyboardKey.arrowRight when canSwipeRight():
        swipeRight();

      /// DEBUGS
      case LogicalKeyboardKey.numpad0 when isDebug:
        _fail();

      /// DEBUGS
      case LogicalKeyboardKey.numpad1 when isDebug:
        stdout.writeln(collectionEqual(_grid, parseRunLengthEncoding(runLengthEncoding)));
    }
  }

  void _verticalDragListener(DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dy) {
      /// Swipe Up
      case < -200 when canSwipeUp():
        swipeUp();

      /// Swipe Down
      case > 200 when canSwipeDown():
        swipeDown();
    }
  }

  void _horizontalDragListener(DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dx) {
      /// Swipe Left
      case < -200 when canSwipeLeft():
        swipeLeft();

      /// Swipe Right
      case > 200 when canSwipeRight():
        swipeRight();
    }
  }

  void _resetGrid() {
    _grid.clear();

    for (int y = 0; y < gridY; ++y) {
      _grid.add(<AnimatedTile>[for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0)]);
    }
  }

  void _startGame() {
    score = 0;

    _actionIsUnlocked = true;
    List<AnimatedTile> shuffledTiles = flattenedGrid.toList()..shuffle();
    for (var AnimatedTile(:int y, :int x) in shuffledTiles.take(2)) {
      _grid[y][x].value = randomTileNumber();
    }
    // for (var AnimatedTile(:int y, :int x) in shuffledTiles.skip(1)) {
    //   _grid[y][x].value = powerOfTwo(gridY, y, x);
    // }

    for (AnimatedTile tile in flattenedGrid) {
      tile.resetAnimations();
    }
  }

  void _fail() {
    for (var AnimatedTile(:int y, :int x) in flattenedGrid) {
      _grid[y][x].value = powerOfTwo(gridY, y, x);
    }

    _alert();
  }

  void _addNewTile() {
    List<AnimatedTile> empty = flattenedGrid //
        .where((AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isEmpty) {
      return;
    }

    var AnimatedTile(:int y, :int x) = empty.first;
    int chosen = randomTileNumber();
    _grid[y][x].value = chosen;

    _toAdd.add(AnimatedTile((y: y, x: x), chosen)..appear(controller));
  }

  void _swipe(void Function() action) {
    /// If the swipe actions are locked, then we ignore it.
    if (!_actionIsUnlocked) {
      return;
    }

    action();
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
  bool _canSwipe(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      AnimatedTile? query = tiles.skip(i + 1).skipWhile((AnimatedTile t) => t.value == 0).firstOrNull;

      if (query != null && (tiles[i].value == 0 || query.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  /// Merges [tiles] towards the left.
  /// i.e: [2, 0, 0, 8] -> [2, 8, 0, 0]
  void _mergeTiles(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      /// We get the sublist from [i], disregarding zeros until the first nonzero.
      List<AnimatedTile> toCheck = tiles
          .sublist(i) //
          .skipWhile((AnimatedTile tile) => tile.value == 0)
          .toList();

      /// If this happens, then the rest of the list from the right of [i]
      ///   are all zeros, so we don't have to do anything now.
      if (toCheck.isEmpty) {
        return;
      }

      AnimatedTile target = toCheck.first;

      AnimatedTile? merge = toCheck //
          .skip(1)
          .where((AnimatedTile tile) => tile.value != 0)
          .firstOrNull;

      if (merge case AnimatedTile(:int value) when value != target.value) {
        merge = null;
      }

      if (tiles[i].value == 0 || merge != null) {
        var AnimatedTile(:int x, :int y) = tiles[i];
        var AnimatedTile(:int value) = target;

        /// Animate the tile at position t.
        target.moveTo(controller, x, y);

        /// If we are *confirmed* to be merging two tiles, then:
        if (merge != null) {
          /// Increase the resulting value of the target,
          value *= 2;

          /// Do some animations.
          merge.moveTo(controller, x, y);
          merge.bounce(controller);
          merge.changeNumber(controller, value);

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
      }
    }
  }

  void _addScore(int value) {
    _scoreBuffer += value;
  }
}
