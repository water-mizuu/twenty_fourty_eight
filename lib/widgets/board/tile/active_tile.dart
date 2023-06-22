import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";

class ActiveTile extends StatelessWidget {
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

  static (Color, Color) _tileColor(int number) => switch (number) {
        2 => const (CustomColors.tile2, CustomColors.grayText),
        4 => const (CustomColors.tile4, CustomColors.grayText),
        8 => const (CustomColors.tile8, CustomColors.whiteText),
        16 => const (CustomColors.tile16, CustomColors.whiteText),
        32 => const (CustomColors.tile32, CustomColors.whiteText),
        64 => const (CustomColors.tile64, CustomColors.whiteText),
        128 => const (CustomColors.tile128, CustomColors.whiteText),
        256 => const (CustomColors.tile256, CustomColors.whiteText),
        512 => const (CustomColors.tile512, CustomColors.whiteText),
        1024 => const (CustomColors.tile1024, CustomColors.whiteText),
        2048 => const (CustomColors.tile2048, CustomColors.whiteText),
        _ => const (CustomColors.tileSuper, CustomColors.whiteText),
      };

  @override
  Widget build(BuildContext context) {
    var (Color backgroundColor, Color foregroundColor) = _tileColor(animatedValue);

    return Transform.scale(
      scale: scale,
      child: Container(
        height: Sizes.tileSize,
        margin: const EdgeInsets.all(Sizes.tileSize * GameTile.tileMarginRatio),
        decoration: roundRadius.copyWith(color: backgroundColor),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: Sizes.tileSize * GameTile.textMarginRatio),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "$animatedValue",
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: Sizes.tileSize * 0.45,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
