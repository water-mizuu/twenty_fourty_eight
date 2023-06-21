import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";

class ScoreboardButton extends StatelessWidget {
  const ScoreboardButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final void Function() onPressed;

  @override
  Widget build(final BuildContext context) => MaterialButton(
        minWidth: Scoreboard.width,
        color: CustomColors.tile16,
        onPressed: () {
          context.read<GameState>().backtrack();
        },
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
