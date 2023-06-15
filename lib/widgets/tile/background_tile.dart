import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/tile/game_tile.dart";

class BackgroundTile extends StatelessWidget with GameTile {
  const BackgroundTile({
    required this.y,
    required this.x,
    required this.tileSize,
    super.key,
  });

  final int y;
  final int x;

  @override
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: roundRadius.copyWith(color: lightBrown),
    );
  }
}
