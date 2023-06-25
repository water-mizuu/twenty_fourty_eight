import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/scoreboard_button.dart";

class ResetButton extends StatefulWidget {
  const ResetButton({super.key});

  @override
  State<ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<ResetButton> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          controller.repeat(reverse: true);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    bool isResetHighlighted = context.select((GameState state) => state.isResetHighlighted);

    if (isResetHighlighted) {
      controller.forward(from: 0.0);
    } else {
      controller.stop();
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) => ScoreboardButton(
        icon: Icons.refresh_rounded,
        color: isResetHighlighted
            ? Color.lerp(CustomColors.tileSuper, CustomColors.tile2048, controller.value)!
            : CustomColors.tile32,
        onPressed: () async => context.read<GameState>().resetGame(),
      ),
    );
  }
}
