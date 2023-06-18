import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_game.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

class BoardArea extends StatelessWidget {
  const BoardArea({
    required this.tileSize,
    super.key,
  });

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    GameState state = context.watch<GameState>();
    double gridSizeY = tileSize * state.gridY;
    double gridSizeX = tileSize * state.gridX;

    return StreamBuilder<void>(
      stream: state.updateStream,
      builder: (BuildContext context, _) {
        return Stack(
          children: <Widget>[
            BoardGame(tileSize: tileSize),
            if (!state.canSwipeAnywhere())
              Positioned(
                height: gridSizeY + 4,
                width: gridSizeX + 4,
                child: const GameOver(),
              ),
          ],
        );
      },
    );
  }
}
