import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/tile/active_tile.dart";
import "package:twenty_fourty_eight/widgets/tile/background_tile.dart";

class Board extends StatelessWidget {
  const Board({required this.tileSize, super.key});

  final double tileSize;

  @override
  Widget build(BuildContext context) {
    GameState state = context.read<GameState>();

    return DecoratedBox(
      decoration: roundRadius.copyWith(color: darkBrown),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (KeyEvent event) => keyEventListener(state, event),
        child: GestureDetector(
          onVerticalDragEnd: (DragEndDetails details) => verticalDragListener(state, details),
          onHorizontalDragEnd: (DragEndDetails details) => horizontalDragListener(state, details),
          child: Stack(
            children: <Widget>[
              for (var AnimatedTile(:int y, :int x) in state.renderTiles) //
                Positioned(
                  top: y * tileSize,
                  left: x * tileSize,
                  width: tileSize,
                  height: tileSize,
                  child: Center(
                    child: BackgroundTile(
                      y: y,
                      x: x,
                    ),
                  ),
                ),
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
        ),
      ),
    );
  }

  void keyEventListener(GameState state, KeyEvent event) {
    /// 4294968068 -> UP
    /// 4294968065 -> DOWN
    /// 4294968066 -> LEFT
    /// 4294968067 -> RIGHT

    switch (event.logicalKey.keyId % 100) {
      /// UP
      case 68 when state.canSwipeUp():
        state.swipeUp();

      /// DOWN
      case 65 when state.canSwipeDown():
        state.swipeDown();

      /// LEFT
      case 66 when state.canSwipeLeft():
        state.swipeLeft();

      /// RIGHT
      case 67 when state.canSwipeRight():
        state.swipeRight();
    }
  }

  void verticalDragListener(GameState state, DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dy) {
      /// Swipe Up
      case < -200 when state.canSwipeUp():
        state.swipeUp();

      /// Swipe Down
      case > 200 when state.canSwipeDown():
        state.swipeDown();
    }
  }

  void horizontalDragListener(GameState state, DragEndDetails details) {
    switch (details.velocity.pixelsPerSecond.dx) {
      /// Swipe Left
      case < -200 when state.canSwipeLeft():
        state.swipeLeft();

      /// Swipe Right
      case > 200 when state.canSwipeRight():
        state.swipeRight();
    }
  }
}
