import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/data_structures/board_dimensions.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/active_tile.dart";

class BoardGame extends StatefulWidget {
  const BoardGame({super.key});

  @override
  State<BoardGame> createState() => _BoardGameState();
}

class _BoardGameState extends State<BoardGame> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    context.read<GameState>().registerAnimationController(this);
  }

  @override
  Widget build(BuildContext context) {
    GameState state = context.read<GameState>();
    var BoardDimensions(:double tileSize) = context.watch<BoardDimensions>();

    return StreamBuilder<void>(
      stream: state.updateStream,
      builder: (BuildContext context, _) {
        return AnimatedBuilder(
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
        );
      },
    );
  }
}
