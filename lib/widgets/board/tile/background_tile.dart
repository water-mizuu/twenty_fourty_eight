import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";

class BackgroundTile extends StatelessWidget {
  const BackgroundTile({
    required this.y,
    required this.x,
    super.key,
  });

  final int y;
  final int x;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => Container(
          margin: EdgeInsets.all(constraints.constrainHeight() * GameTile.tileMarginRatio),
          decoration: roundRadius.copyWith(color: CustomColors.lightBrown),
        ),
      );
}
