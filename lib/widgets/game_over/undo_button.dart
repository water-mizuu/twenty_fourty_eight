import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class UndoButton extends StatelessWidget {
  const UndoButton({super.key});

  @override
  Widget build(BuildContext context) {
    bool canUndo = context.select((GameState state) => state.canBacktrack());

    return MaterialButton(
      disabledColor: CustomColors.grayText,
      disabledTextColor: CustomColors.lightBrown,
      color: CustomColors.tileSuper,
      textColor: canUndo ? CustomColors.whiteText : CustomColors.lightBrown,
      onPressed: canUndo ? () => context.read<GameState>().backtrack() : null,
      child: const Text("BACKTRACK"),
    );
  }
}
