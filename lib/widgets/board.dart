import "dart:collection";

import "package:flutter/material.dart";
import "package:twenty_fourty_eight/data_structures/tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";

class Board extends StatelessWidget {
  const Board({
    required this.controller,
    required this.divisionSize,
    required this.boardPadding,
    required this.flattenedGrid,
    required this.toAdd,
    super.key,
  });

  final AnimationController controller;
  final double divisionSize;
  final double boardPadding;
  final Iterable<Tile> flattenedGrid;
  final Queue<Tile> toAdd;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
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
    );
  }

  static Color tileBackgroundColor(int number) => switch (number) {
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
}
