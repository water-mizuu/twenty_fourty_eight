import "dart:ui";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

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
  late Animation<double> textOpacity;

  late Animation<double> buttonOpacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

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
          .drive(Tween<double>(begin: 0.00, end: 1.00));
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
    if (context.select((GameState state) => state.canSwipeAnywhere())) {
      return const SizedBox();
    } else {
      controller
        ..reset()
        ..forward();

      return AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, _) {
          var _GameOverState(
            backgroundOpacity: Animation<double>(value: double backgroundOpacity),
            blurRadius: Animation<double>(value: double blurRadius),
            textMoveDown: Animation<double>(value: double textMoveDown),
            textOpacity: Animation<double>(value: double textOpacity),
          ) = this;

          return Opacity(
            opacity: backgroundOpacity,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
              child: DecoratedBox(
                decoration: roundRadius.copyWith(color: const Color.fromARGB(64, 192, 192, 192)),
                child: Opacity(
                  opacity: textOpacity,
                  child: Align(
                    alignment: AlignmentGeometry.lerp(Alignment.topCenter, Alignment.center, textMoveDown)!,
                    child: const Text(
                      "Game Over!",
                      style: TextStyle(
                        color: CustomColors.grayText,
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
