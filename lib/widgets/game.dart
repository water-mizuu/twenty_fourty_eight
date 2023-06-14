import "dart:collection";
import "dart:math" as math;

import "package:flutter/material.dart";
import 'package:twenty_fourty_eight/data_structures/animated_tile.dart';
import "package:twenty_fourty_eight/shared.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/board.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => GameState();
}

class GameState extends State<Game> with TickerProviderStateMixin {
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const double boardPadding = 4;

  late bool actionIsUnlocked;
  late num score;

  late final List2<AnimatedTile> grid;
  late final Queue<AnimatedTile> toAdd;
  late final AnimationController controller;
  late final FocusNode focusNode;

  Iterable<AnimatedTile> get flattenedGrid => grid.expand((List<AnimatedTile> r) => r);

  @override
  void initState() {
    super.initState();

    actionIsUnlocked = true;

    grid = <List<AnimatedTile>>[
      for (int y = 0; y < gridY; ++y)
        <AnimatedTile>[
          for (int x = 0; x < gridX; ++x) AnimatedTile(x, y, 0),
        ]
    ];
    toAdd = Queue<AnimatedTile>();
    focusNode = FocusNode();
    controller = AnimationController(vsync: this, duration: animationDuration) //
      ..addStatusListener(controllerListener);

    startGame();
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    grid.clear();
    toAdd.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Size(:double width, :double height) = MediaQuery.of(context).size;
    int determinant = math.max(gridY, gridX);
    double constraint = math.min(width, height);

    double divisionSize = constraint / determinant;
    double gridSizeY = divisionSize * gridY;
    double gridSizeX = divisionSize * gridX;

    return Scaffold(
      backgroundColor: tan,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Stack(
              children: <Widget>[
                Container(
                  height: gridSizeY,
                  width: gridSizeX,
                  padding: const EdgeInsets.all(boardPadding),
                  decoration: roundRadius.copyWith(color: darkBrown),
                  child: KeyboardListener(
                    focusNode: focusNode,
                    onKeyEvent: keyboardListener,
                    child: GestureDetector(
                      onVerticalDragEnd: verticalDragListener,
                      onHorizontalDragEnd: horizontalDragListener,
                      child: Board(
                        controller: controller,
                        divisionSize: divisionSize,
                        boardPadding: boardPadding,
                        flattenedGrid: flattenedGrid,
                        toAdd: toAdd,
                      ),
                    ),
                  ),
                ),
                if (!canSwipeAnywhere) GameOver(gridSizeY, gridSizeX, reset),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static int randomTileNumber() {
    return switch (random.nextDouble()) {
      <= 0.25 => 4,
      _ => 2,
    };
  }

  void reset() {
    setState(() {
      for (var AnimatedTile(:int y, :int x) in flattenedGrid) {
        grid[y][x].value = 0;
      }

      startGame();
    });
  }

  void startGame() {
    score = 0;

    List<(int, int)> shuffledIndices = grid.indices.toList()..shuffle();
    for (var (int y, int x) in shuffledIndices.take(2)) {
      grid[y][x].value = randomTileNumber();
    }

    /// Code for testing tiles & failure.
    // List<Tile> allTiles = flattenedGrid.toList();
    // for (int i = 0; i < allTiles.length - 1; ++i) {
    //   var Tile(:int y, :int x) = allTiles[i];
    //   grid[y][x].value = math.pow(2, i + 1).toInt();
    // }

    for (AnimatedTile tile in flattenedGrid) {
      tile.resetAnimations();
    }
  }

  void controllerListener(AnimationStatus status) {
    if (status case AnimationStatus.completed) {
      while (toAdd.isNotEmpty) {
        var AnimatedTile(:int y, :int x, :int value) = toAdd.removeFirst();

        grid[y][x].value = value;
      }
      for (AnimatedTile tile in flattenedGrid) {
        tile.resetAnimations();
      }

      setState(() {
        controller.reset();
        actionIsUnlocked = true;
      });
    }
  }

  void keyboardListener(KeyEvent event) {
    /// 4294968068 -> UP
    /// 4294968065 -> DOWN
    /// 4294968066 -> LEFT
    /// 4294968067 -> RIGHT

    switch (event.logicalKey.keyId % 100) {
      /// UP
      case 68 when canSwipeUp:
        swipeUp();

      /// DOWN
      case 65 when canSwipeDown:
        swipeDown();

      /// LEFT
      case 66 when canSwipeLeft:
        swipeLeft();

      /// RIGHT
      case 67 when canSwipeRight:
        swipeRight();
    }
  }

  void verticalDragListener(DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dy) {
      /// Swipe Up
      case < -200 when canSwipeUp:
        swipeUp();

      /// Swipe Down
      case > 200 when canSwipeDown:
        swipeDown();
    }
  }

  void horizontalDragListener(DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dx) {
      /// Swipe Left
      case < -200 when canSwipeLeft:
        swipeLeft();

      /// Swipe Right
      case > 200 when canSwipeRight:
        swipeRight();
    }
  }

  void addNewTile() {
    List<AnimatedTile> empty = flattenedGrid //
        .where((AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isEmpty) {
      return;
    }

    var AnimatedTile(:int y, :int x) = empty.first;
    int chosen = randomTileNumber();
    grid[y][x].value = chosen;

    toAdd.add(AnimatedTile(x, y, chosen)..appear(controller));
  }

  void swipe(void Function() action) {
    /// If the swipe actions are locked, then we ignore it.
    if (!actionIsUnlocked) {
      return;
    }

    setState(() {
      action();
      addNewTile();
      actionIsUnlocked = false;
      controller.forward(from: 0);
    });
  }

  bool get canSwipeAnywhere => canSwipeUp || canSwipeDown || canSwipeLeft || canSwipeRight;

  bool get canSwipeLeft => grid.any(canSwipe);
  bool get canSwipeRight => grid.reversedRows.any(canSwipe);
  bool get canSwipeUp => grid.columns.any(canSwipe);
  bool get canSwipeDown => grid.columns.reversedRows.any(canSwipe);

  /// Returns a [bool] indicating whether [tiles] can be swiped to left
  ///   from the following conditions:
  /// ```txt
  /// 1. the row has trailing zeros, i.e [0, 2, *, *]
  /// 2. the row has a merge, i.e [2, 2, *, *]
  /// ```
  bool canSwipe(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      AnimatedTile? query = tiles.skip(i + 1).skipWhile((AnimatedTile t) => t.value == 0).firstOrNull;

      if (query != null && (tiles[i].value == 0 || query.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  void swipeUp() => swipe(() => grid.columns.forEach(mergeTiles));
  void swipeDown() => swipe(() => grid.columns.reversedRows.forEach(mergeTiles));
  void swipeLeft() => swipe(() => grid.forEach(mergeTiles));
  void swipeRight() => swipe(() => grid.reversedRows.forEach(mergeTiles));

  /// Merges [tiles] towards the left.
  /// i.e: [2, 0, 0, 8] -> [2, 8, 0, 0]
  void mergeTiles(List<AnimatedTile> tiles) {
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
        }

        /// Update their values after the update.
        /// Sequence is important here, because there are cases when target == tiles[i].
        target.value = 0;
        tiles[i].value = value;
      }
    }
  }
}
