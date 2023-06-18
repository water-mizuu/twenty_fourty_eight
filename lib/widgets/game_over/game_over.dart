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

  late Animation<double> blurRadius;

  late Animation<double> backgroundOpacity;

  late Animation<double> textMoveDown;
  late Animation<int> textOpacity;

  late Animation<double> buttonOpacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: 1000.milliseconds);

    if (const Interval(0.00, 1.00, curve: Curves.ease) case Curve curve) {
      blurRadius = CurvedAnimation(parent: controller, curve: curve) //
          .drive(Tween<double>(begin: 0.0, end: 4.0));
    }

    if (const Interval(0.00, 0.50, curve: Curves.ease) case Curve curve) {
      backgroundOpacity = CurvedAnimation(parent: controller, curve: curve) //
          .drive(Tween<double>(begin: 0.0, end: 1.0));
    }

    if (const Interval(0.50, 0.75, curve: Curves.ease) case Curve curve) {
      textMoveDown = CurvedAnimation(parent: controller, curve: curve) //
          .drive(Tween<double>(begin: 0.95, end: 1.00));
      textOpacity = CurvedAnimation(parent: controller, curve: curve) //
          .drive(IntTween(begin: 0, end: 255));
    }

    if (const Interval(0.75, 1.00, curve: Curves.ease) case Curve curve) {
      buttonOpacity = CurvedAnimation(parent: controller, curve: curve) //
          .drive(Tween<double>(begin: 0.0, end: 1.0));
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
        var Animation<double>(value: double blurRadius) = this.blurRadius;
        var Animation<double>(value: double textMoveDown) = this.textMoveDown;
        var Animation<int>(value: int textOpacity) = this.textOpacity;
        var Animation<double>(value: double buttonOpacity) = this.buttonOpacity;

        return Opacity(
          opacity: backgroundOpacity,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
            child: DecoratedBox(
              decoration: roundRadius.copyWith(color: const Color.fromARGB(155, 225, 225, 225)),
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
