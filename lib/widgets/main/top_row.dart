import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/board_dimensions.dart";
import "package:twenty_fourty_eight/widgets/board/tile/active_tile.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  @override
  Widget build(BuildContext context) {
    var BoardDimensions(:double tileSize) = context.watch<BoardDimensions>();

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
