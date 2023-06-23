import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class ResetButton extends StatelessWidget {
  const ResetButton({super.key});

  @override
  Widget build(BuildContext context) => MaterialButton(
        color: CustomColors.tileSuper,
        onPressed: () => context.read<GameState>().reset(),
        textColor: CustomColors.whiteText,
        child: const Text("RESET"),
      );
}
