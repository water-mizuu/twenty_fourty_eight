import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/board_dimensions.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_display.dart";
import "package:twenty_fourty_eight/widgets/main/top_row.dart";

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    var GameState(
      :void Function(DragEndDetails) verticalDragListener,
      :void Function(DragEndDetails) horizontalDragListener,
    ) = context.watch<GameState>();
    var BoardDimensions(
      :double tileSize,
      :double gridInnerWidth,
      :double gridHeight,
      :double gridWidth,
    ) = context.watch<BoardDimensions>();

    return GestureDetector(
      onVerticalDragEnd: verticalDragListener,
      onHorizontalDragEnd: horizontalDragListener,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: tileSize,
              width: gridInnerWidth,
              child: const TopRow(),
            ),
            SizedBox(
              height: gridHeight,
              width: gridWidth,
              child: const BoardDisplay(),
            ),
          ],
        ),
      ),
    );
  }
}
