import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class ResetButton extends StatelessWidget {
  const ResetButton({
    required this.buttonOpacity,
    super.key,
  });

  final double buttonOpacity;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: buttonOpacity,
        child: MaterialButton(
          color: const Color.fromARGB(255, 60, 58, 51),
          onPressed: () => context.read<GameState>().reset(),
          child: const Text(
            "Try Again",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
}
