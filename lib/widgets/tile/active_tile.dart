import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";
import "package:twenty_fourty_eight/widgets/tile/game_tile.dart";

class ActiveTile extends StatelessWidget  {
  const ActiveTile({
    required this.animatedValue,
    required this.scale,
    super.key,
  });
  const ActiveTile.dummy({
    required this.animatedValue,
    super.key,
  }) : scale = 1.0;

  final int animatedValue;
  final double scale;

  @override
  Widget build(BuildContext context) {
    var (Color backgroundColor, Color foregroundColor) = tileColor(animatedValue);

    return Transform.scale(
      scale: scale,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double parentHeight = constraints.constrainHeight();

          return Container(
            margin: EdgeInsets.all(parentHeight * GameTile.tileMarginRatio),
            decoration: roundRadius.copyWith(color: backgroundColor),
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: parentHeight * GameTile.textMarginRatio),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$animatedValue",
                    style: TextStyle(
                      color: foregroundColor,
                      fontSize: parentHeight * 45.percent,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static (Color, Color) tileColor(int number) => switch (number) {
        2 => const (Color.fromARGB(255, 238, 228, 220), grayText),
        4 => const (Color.fromARGB(255, 238, 225, 201), grayText),
        8 => const (Color.fromARGB(255, 243, 178, 122), whiteText),
        16 => const (Color.fromARGB(255, 246, 150, 100), whiteText),
        32 => const (Color.fromARGB(255, 247, 124, 95), whiteText),
        64 => const (Color.fromARGB(255, 247, 95, 59), whiteText),
        128 => const (Color.fromARGB(255, 237, 208, 115), whiteText),
        256 => const (Color.fromARGB(255, 237, 204, 98), whiteText),
        512 => const (Color.fromARGB(255, 237, 201, 80), whiteText),
        1024 => const (Color.fromARGB(255, 237, 197, 63), whiteText),
        2048 => const (Color.fromARGB(255, 237, 194, 46), whiteText),
        _ => const (Color.fromARGB(255, 60, 58, 51), whiteText),
      };
}
