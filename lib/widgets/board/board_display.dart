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
  Widget build(final BuildContext context) {
    final int gridY = context.select((final GameState state) => state.gridY);
    final int gridX = context.select((final GameState state) => state.gridX);

    final double height = Sizes.tileSize * gridY;
    final double width = Sizes.tileSize * gridX;

    return Container(
      padding: const EdgeInsets.all(GameTile.tileMarginRatio * Sizes.tileSize / 2),
      decoration: roundRadius.copyWith(color: CustomColors.darkBrown),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: <Widget>[
            const BoardBackground(),
            const BoardGame(),
            Positioned(
              height: height * 1.01,
              width: width * 1.01,
              child: const GameOver(),
            ),
          ],
        ),
      ),
    );
  }
}
