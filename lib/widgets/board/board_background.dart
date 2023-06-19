import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/data_structures/board_dimensions.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/background_tile.dart";

class BoardBackground extends StatelessWidget {
  const BoardBackground({super.key});

  @override
  Widget build(BuildContext context) {
    var BoardDimensions(:double tileSize) = context.watch<BoardDimensions>();

    return Stack(
      children: <Widget>[
        for (var AnimatedTile(:int y, :int x) in context.select((GameState state) => state.flattenedGrid)) //
          Positioned(
            top: y * tileSize,
            left: x * tileSize,
            width: tileSize,
            height: tileSize,
            child: Center(
              child: BackgroundTile(y: y, x: x),
            ),
          ),
      ],
    );
  }
}
