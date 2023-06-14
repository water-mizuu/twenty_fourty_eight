import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/tile/active_tile.dart";
import "package:twenty_fourty_eight/widgets/tile/background_tile.dart";

class Board extends StatelessWidget {
  const Board({
    required this.divisionSize,
    required this.boardPadding,
    super.key,
  });

  final double divisionSize;
  final double boardPadding;

  @override
  Widget build(BuildContext context) {
    GameState state = context.read<GameState>();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (KeyEvent event) => keyEventListener(state, event),
      child: GestureDetector(
        onVerticalDragEnd: (DragEndDetails details) => verticalDragListener(state, details),
        onHorizontalDragEnd: (DragEndDetails details) => horizontalDragListener(state, details),
        child: AnimatedBuilder(
          animation: state.controller,
          builder: (BuildContext context, _) {
            double tileSize = divisionSize - boardPadding * 0.5;

            return Stack(
              children: <Widget>[
                for (var (int y, int x) in state.grid.indices) //
                  BackgroundTile(x: x, tileSize: tileSize, y: y),
                for (AnimatedTile tile in state.renderTiles)
                  if (tile.animatedValue.value != 0) //
                    ActiveTile(tile: tile, tileSize: tileSize),
              ],
            );
          },
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
