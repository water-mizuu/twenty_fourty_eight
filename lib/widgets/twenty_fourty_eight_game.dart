import "dart:collection";
import "dart:math" as math;

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:twenty_fourty_eight/data_structures/tile.dart";
import "package:twenty_fourty_eight/shared.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

Color tileBackgroundColor(int number) => switch (number) {
      2 => const Color.fromARGB(255, 238, 228, 220),
      4 => const Color.fromARGB(255, 238, 225, 201),
      8 => const Color.fromARGB(255, 243, 178, 122),
      16 => const Color.fromARGB(255, 246, 150, 100),
      32 => const Color.fromARGB(255, 247, 124, 95),
      64 => const Color.fromARGB(255, 247, 95, 59),
      128 => const Color.fromARGB(255, 237, 208, 115),
      256 => const Color.fromARGB(255, 237, 204, 98),
      512 => const Color.fromARGB(255, 237, 201, 80),
      1024 => const Color.fromARGB(255, 237, 197, 63),
      2048 => const Color.fromARGB(255, 237, 194, 46),
      _ => const Color.fromARGB(255, 60, 58, 51),
    };

class TwentyFourtyEightGame extends StatefulWidget {
  const TwentyFourtyEightGame({super.key});

  @override
  State<TwentyFourtyEightGame> createState() => TwentyFourtyEightGameState();
}

class TwentyFourtyEightGameState extends State<TwentyFourtyEightGame> with TickerProviderStateMixin {
  static const Duration animationDuration = Duration(milliseconds: 250);
  static const double boardPadding = 4;

  late bool unlocked = true;

  late final List2<Tile> grid = <List<Tile>>[
    for (int y = 0; y < gridY; ++y)
      <Tile>[
        for (int x = 0; x < gridX; ++x) Tile(x, y, 0),
      ]
  ];
  late final Queue<Tile> toAdd = Queue<Tile>();
  late final AnimationController controller = new AnimationController(vsync: this, duration: animationDuration);
  late final FocusNode focusNode = new FocusNode();

  Iterable<Tile> get flattenedGrid => grid.expand((List<Tile> r) => r);

  @override
  void initState() {
    super.initState();

    controller.addStatusListener(controllerListener);
    // assignStartingValues();
    assignFailingValues();
    for (Tile tile in flattenedGrid) {
      tile.resetAnimations();
    }
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
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (BuildContext context, Widget? child) {
                          double tileSize = divisionSize - boardPadding * 0.5;

                          return Stack(
                            children: <Widget>[
                              for (var Tile(:int x, :int y) in flattenedGrid)
                                Positioned(
                                  left: x * tileSize,
                                  top: y * tileSize,
                                  width: tileSize,
                                  height: tileSize,
                                  child: Center(
                                    child: Container(
                                      width: tileSize * 0.95,
                                      height: tileSize * 0.95,
                                      decoration: roundRadius.copyWith(color: lightBrown),
                                    ),
                                  ),
                                ),
                              for (var Tile(
                                    animatedValue: Animation<int>(:int value),
                                    scale: Animation<double>(value: double scale),
                                    animatedX: Animation<double>(value: double animatedX),
                                    animatedY: Animation<double>(value: double animatedY),
                                  ) in flattenedGrid.followedBy(toAdd))
                                if (value != 0)
                                  Positioned(
                                    left: animatedX * tileSize,
                                    top: animatedY * tileSize,
                                    width: tileSize,
                                    height: tileSize,
                                    child: Center(
                                      child: Container(
                                        width: (tileSize * 0.95) * scale,
                                        height: (tileSize * 0.95) * scale,
                                        decoration: roundRadius.copyWith(color: tileBackgroundColor(value)),
                                        child: Center(
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                "$value",
                                                style: TextStyle(
                                                  color: value <= 4 ? greyText : Colors.white,
                                                  fontSize: (tileSize - 4 * 2) * scale * 4 / 9,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                            ],
                          );
                        },
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
      for (var Tile(:int y, :int x) in flattenedGrid) {
        grid[y][x].value = 0;
      }

      assignStartingValues();

      for (Tile tile in flattenedGrid) {
        tile.resetAnimations();
      }
    });
  }

  void assignStartingValues() {
    List<(int, int)> shuffledIndices = grid.indices.toList()..shuffle();
    for (var (int y, int x) in shuffledIndices.take(2)) {
      grid[y][x].value = randomTileNumber();
    }
  }

  void assignFailingValues() {
    List<Tile> allTiles = flattenedGrid.toList();
    for (int i = 0; i < allTiles.length - 1; ++i) {
      var Tile(:int y, :int x) = allTiles[i];
      grid[y][x].value = math.pow(2, i + 1).toInt();
    }
  }

  void controllerListener(AnimationStatus status) {
    if (status case AnimationStatus.completed) {
      while (toAdd.isNotEmpty) {
        var Tile(:int y, :int x, :int value) = toAdd.removeFirst();
        grid[y][x].value = value;
      }
      for (Tile tile in flattenedGrid) {
        tile.resetAnimations();
      }

      setState(() {
        controller.reset();
        unlocked = true;
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
    List<Tile> empty = flattenedGrid.where((Tile tile) => tile.value == 0).toList()..shuffle();

    if (empty.isEmpty) {
      return;
    }

    var Tile(:int y, :int x) = empty.first;
    int chosen = randomTileNumber();
    grid[y][x].value = chosen;

    toAdd.add(Tile(x, y, chosen)..appear(controller));
  }

  void swipe(void Function() action) {
    /// If the swipe actions are locked, then we ignore it.
    if (!unlocked) {
      return;
    }

    setState(() {
      action();
      addNewTile();
      unlocked = false;
      controller.forward(from: 0);
    });
  }

  bool get canSwipeAnywhere => canSwipeUp || canSwipeDown || canSwipeLeft || canSwipeRight;

  bool get canSwipeLeft => grid.any(canSwipe);
  bool get canSwipeRight => grid.reversedRows.any(canSwipe);
  bool get canSwipeUp => grid.columns.any(canSwipe);
  bool get canSwipeDown => grid.columns.reversedRows.any(canSwipe);

  bool canSwipe(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      Iterable<Tile> query = tiles.skip(i + 1).skipWhile((Tile t) => t.value == 0);

      if (query.isNotEmpty && (tiles[i].value == 0 || query.first.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  void swipeUp() {
    swipe(() => grid.columns.forEach(mergeTiles));
  }

  void swipeDown() {
    swipe(() => grid.columns.reversedRows.forEach(mergeTiles));
  }

  void swipeLeft() {
    swipe(() => grid.forEach(mergeTiles));
  }

  void swipeRight() {
    swipe(() => grid.reversedRows.forEach(mergeTiles));
  }

  void mergeTiles(List<Tile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      /// We get the sublist from [i], disregarding zeros until the first nonzero.
      List<Tile> toCheck = tiles
          .sublist(i) //
          .skipWhile((Tile tile) => tile.value == 0)
          .toList();

      /// If this happens, then the rest of the list from the right of [i]
      ///   are all zeros, so we don't have to do anything now.
      if (toCheck.isEmpty) {
        return;
      }

      Tile target = toCheck.first;

      Tile? merge = toCheck //
          .skip(1)
          .where((Tile tile) => tile.value != 0)
          .firstOrNull;

      if (merge case Tile(:int value) when value != target.value) {
        merge = null;
      }

      if (tiles[i].value == 0 || merge != null) {
        var Tile(:int x, :int y) = tiles[i];
        var Tile(:int value) = target;

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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>("unlocked", unlocked));
    properties.add(IterableProperty<List<Tile>>("grid", grid));
    properties.add(IterableProperty<Tile>("toAdd", toAdd));
    properties.add(DiagnosticsProperty<AnimationController>("controller", controller));
    properties.add(DiagnosticsProperty<FocusNode>("focusNode", focusNode));
    properties.add(IterableProperty<Tile>("flattenedGrid", flattenedGrid));
    properties.add(DiagnosticsProperty<bool>("canSwipeAnywhere", canSwipeAnywhere));
    properties.add(DiagnosticsProperty<bool>("canSwipeLeft", canSwipeLeft));
    properties.add(DiagnosticsProperty<bool>("canSwipeRight", canSwipeRight));
    properties.add(DiagnosticsProperty<bool>("canSwipeUp", canSwipeUp));
    properties.add(DiagnosticsProperty<bool>("canSwipeDown", canSwipeDown));
  }
}
