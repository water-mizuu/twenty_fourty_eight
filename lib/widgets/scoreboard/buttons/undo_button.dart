import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/scoreboard_button.dart";

class UndoButton extends StatelessWidget {
  const UndoButton({super.key});

  @override
  Widget build(BuildContext context) => ScoreboardButton(
        icon: Icons.undo_rounded,
        onPressed: context.select((GameState state) => state.canBacktrack())
            ? () => context.read<GameState>().backtrack() //
            : null,
      );
}
