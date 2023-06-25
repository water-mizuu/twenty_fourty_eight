import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (kDebugMode) {
        print("Called `start` on WidgetsBinding");
      }
      context.read<GameState>().start();
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: context.select((GameState state) => state.controller),
        builder: (BuildContext context, _) => Stack(
          children: <Widget>[
            for (var AnimatedTile(
                  animatedX: Animation<double>(value: double animatedX),
                  animatedY: Animation<double>(value: double animatedY),
                  animatedValue: Animation<int>(value: int animatedValue),
                  scale: Animation<double>(value: double scale),
                  opacity: Animation<double>(value: double opacity),
                ) in context.select((GameState state) => state.renderTiles))
              if (animatedValue != 0) //
                Positioned(
                  left: animatedX * Sizes.tileSize,
                  top: animatedY * Sizes.tileSize,
                  height: Sizes.tileSize,
                  width: Sizes.tileSize,
                  child: Opacity(
                    opacity: opacity,
                    child: ActiveTile(
                      scale: scale,
                      animatedValue: animatedValue,
                    ),
                  ),
                ),
          ],
        ),
      );
}
