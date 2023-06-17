import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/tile/game_tile.dart";

class BackgroundTile extends StatelessWidget with GameTile {
  const BackgroundTile({
    required this.y,
    required this.x,
    super.key,
  });

  final int y;
  final int x;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Container(
        margin: EdgeInsets.all(constraints.constrainHeight() * tileMarginRatio),
        decoration: roundRadius.copyWith(color: lightBrown),
      );
    });
  }
}
