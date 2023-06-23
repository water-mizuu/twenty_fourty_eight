import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/background_tile.dart";

class BoardBackground extends StatelessWidget {
  const BoardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    int gridY = context.select((GameState state) => state.gridY);
    int gridX = context.select((GameState state) => state.gridX);

    return Stack(
      children: <Widget>[
        for (int y = 0; y < gridY; ++y)
          for (int x = 0; x < gridX; ++x)
            Positioned(
              top: y * Sizes.tileSize,
              left: x * Sizes.tileSize,
              width: Sizes.tileSize,
              height: Sizes.tileSize,
              child: Center(
                child: BackgroundTile(y: y, x: x),
              ),
            ),
      ],
    );
  }
}
