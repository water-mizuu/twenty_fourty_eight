import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";
import "package:twenty_fourty_eight/widgets/tile/active_tile.dart";

class TopRow extends StatelessWidget {
  const TopRow({
    required this.tileSize,
    super.key,
  });

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const AspectRatio(
          aspectRatio: 1,
          child: ActiveTile.dummy(animatedValue: 2048),
        ),
        Scoreboard(width: tileSize),
      ],
    );
  }
}
