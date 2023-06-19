import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/board_dimensions.dart";
import "package:twenty_fourty_eight/widgets/board/board_background.dart";
import "package:twenty_fourty_eight/widgets/board/board_game.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

class BoardDisplay extends StatelessWidget {
  const BoardDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    var BoardDimensions(
      :double gridHeight,
      :double gridWidth,
      :double tileSize,
    ) = context.watch<BoardDimensions>();

    return Container(
      padding: EdgeInsets.all(GameTile.tileMarginRatio * tileSize / 2),
      decoration: roundRadius.copyWith(color: darkBrown),
      child: Stack(
        children: <Widget>[
          const BoardBackground(),
          const BoardGame(),
          Positioned(
            height: gridHeight,
            width: gridWidth,
            child: const GameOver(),
          ),
        ],
      ),
    );
  }
}
