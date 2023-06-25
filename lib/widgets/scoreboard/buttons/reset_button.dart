import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/scoreboard_button.dart";

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) => ScoreboardButton(
        icon: Icons.refresh_rounded,
        onPressed: () async => context.read<GameState>().resetGame(),
      );
}
