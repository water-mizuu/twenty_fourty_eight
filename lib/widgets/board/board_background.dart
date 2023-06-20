import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/background_tile.dart";

class BoardBackground extends StatelessWidget {
  const BoardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        for (var AnimatedTile(:int y, :int x) in context.select((GameState state) => state.flattenedGrid)) //
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
