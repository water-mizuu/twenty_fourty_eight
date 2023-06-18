import "package:flutter/material.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/tile/background_tile.dart";

class BoardBackground extends StatelessWidget {
  const BoardBackground({
    required this.state,
    required this.tileSize,
    super.key,
  });

  final GameState state;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        for (var AnimatedTile(:int y, :int x) in state.renderTiles) //
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
