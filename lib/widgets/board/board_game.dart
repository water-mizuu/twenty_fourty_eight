import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_background.dart";
import "package:twenty_fourty_eight/widgets/tile/active_tile.dart";

class BoardGame extends StatelessWidget {
  const BoardGame({required this.tileSize, super.key});

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    GameState state = context.read<GameState>();

    return DecoratedBox(
      decoration: roundRadius.copyWith(color: darkBrown),
      child: Stack(
        children: <Widget>[
          BoardBackground(state: state, tileSize: tileSize),
          AnimatedBuilder(
            animation: state.controller,
            builder: (BuildContext context, _) {
              return Stack(
                children: <Widget>[
                  for (var AnimatedTile(
                        animatedX: Animation<double>(value: double animatedX),
                        animatedY: Animation<double>(value: double animatedY),
                        animatedValue: Animation<int>(value: int animatedValue),
                        scale: Animation<double>(value: double scale),
                      ) in state.renderTiles)
                    if (animatedValue != 0) //
                      Positioned(
                        left: animatedX * tileSize,
                        top: animatedY * tileSize,
                        height: tileSize,
                        width: tileSize,
                        child: Center(
                          child: ActiveTile(
                            scale: scale,
                            animatedValue: animatedValue,
                          ),
                        ),
                      ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
