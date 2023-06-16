import "dart:ui";

import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over_screen.dart";

class GameOver extends StatefulWidget {
  const GameOver({super.key});

  @override
  State<GameOver> createState() => _GameOverState();
}

class _GameOverState extends State<GameOver> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  late Animation<double> backgroundOpacity;

  late Animation<double> textMoveDown;
  late Animation<int> textOpacity;

  late Animation<double> buttonOpacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: 1000.milliseconds);
    if (const Interval(0.00, 0.50, curve: Curves.ease) case Curve curve) {
      backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
    }

    if (const Interval(0.50, 0.75, curve: Curves.ease) case Curve curve) {
      textMoveDown = Tween<double>(begin: 0.95, end: 1.00) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
      textOpacity = IntTween(begin: 0, end: 255) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
    }

    if (const Interval(0.75, 1.00, curve: Curves.ease) case Curve curve) {
      buttonOpacity = Tween<double>(begin: 0.0, end: 1.0) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
    }

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        var Animation<double>(value: double backgroundOpacity) = this.backgroundOpacity;
        var Animation<double>(value: double textMoveDown) = this.textMoveDown;
        var Animation<int>(value: int textOpacity) = this.textOpacity;
        var Animation<double>(value: double buttonOpacity) = this.buttonOpacity;

        return Opacity(
          opacity: backgroundOpacity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: DecoratedBox(
              decoration: roundRadius.copyWith(color: const Color.fromARGB(128, 192, 192, 192)),
              child: GameOverScreen(
                textMoveDown: textMoveDown,
                textOpacity: textOpacity,
                buttonOpacity: buttonOpacity,
              ),
            ),
          ),
        );
      },
    );
  }
}
