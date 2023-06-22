import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_display.dart";
import "package:twenty_fourty_eight/widgets/main/top_row.dart";

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    var (
      GestureDragEndCallback vertical,
      GestureDragEndCallback horizontal,
    ) = context.select((GameState state) => state.dragEndListeners);

    return GestureDetector(
      onVerticalDragEnd: vertical,
      onHorizontalDragEnd: horizontal,
      child: const FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TopRow(),
            BoardDisplay(),
          ],
        ),
      ),
    );
  }
}
