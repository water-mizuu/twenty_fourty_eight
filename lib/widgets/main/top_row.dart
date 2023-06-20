import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/active_tile.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  @override
  Widget build(BuildContext context) {
    int gridX = context.select((GameState state) => state.gridX);

    double height = Sizes.tileSize * (1 + GameTile.tileMarginRatio);
    double width = Sizes.tileSize * (gridX + GameTile.tileMarginRatio);

    return SizedBox(
      height: height,
      width: width,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1,
            child: ActiveTile.dummy(animatedValue: 2048),
          ),
          Scoreboard(),
        ],
      ),
    );
  }
}
