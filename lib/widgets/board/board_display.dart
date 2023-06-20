import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_background.dart";
import "package:twenty_fourty_eight/widgets/board/board_game.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

class BoardDisplay extends StatelessWidget {
  const BoardDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    int gridY = context.select((GameState state) => state.gridY);
    int gridX = context.select((GameState state) => state.gridX);

    double height = Sizes.tileSize * gridY;
    double width = Sizes.tileSize * gridX;

    return Container(
      padding: EdgeInsets.all(GameTile.tileMarginRatio * Sizes.tileSize / 2),
      decoration: roundRadius.copyWith(color: CustomColors.darkBrown),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: <Widget>[
            const BoardBackground(),
            const BoardGame(),
            Positioned(
              height: height,
              width: width,
              child: const GameOver(),
            ),
          ],
        ),
      ),
    );
  }
}
