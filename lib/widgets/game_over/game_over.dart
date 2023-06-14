import "dart:ui";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over_screen.dart";

class GameOver extends StatefulWidget {
  final double gridSizeY;
  final double gridSizeX;
  final void Function() reset;

  const GameOver(this.gridSizeY, this.gridSizeX, this.reset, {super.key});

  @override
  State<GameOver> createState() => _GameOverState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty("gridSizeX", gridSizeX));
    properties.add(DoubleProperty("gridSizeY", gridSizeY));
    properties.add(ObjectFlagProperty<void Function()>.has("reset", reset));
  }
}

class _GameOverState extends State<GameOver> with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  late Animation<double> backgroundOpacity;

  late Animation<double> textMoveDown;
  late Animation<int> textOpacity;

  late Animation<double> buttonOpacity;

  late bool hasRendered = false;

  @override
  void initState() {
    super.initState();

    controller = new AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() => hasRendered = true);
        }
      });
    resetAnimations();

    controller.forward();
  }

  void resetAnimations() {
    if (const Interval(0.00, 0.50, curve: Curves.ease) case Curve curve) {
      backgroundOpacity = Tween<double>(begin: 0.0, end: 1.0) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
    }

    if (const Interval(0.50, 0.75, curve: Curves.ease) case Curve curve) {
      textMoveDown = Tween<double>(begin: 0.30, end: 0.35) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
      textOpacity = IntTween(begin: 0, end: 255) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
    }

    if (const Interval(0.75, 1.00, curve: Curves.ease) case Curve curve) {
      buttonOpacity = Tween<double>(begin: 0.0, end: 1.0) //
          .animate(CurvedAnimation(parent: controller, curve: curve));
    }
  }

  @override
  Widget build(BuildContext context) {
    var GameOver(:double gridSizeY, :double gridSizeX) = widget;

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
            child: Container(
              height: gridSizeY,
              width: gridSizeX,
              decoration: const BoxDecoration(color: Color.fromARGB(128, 192, 192, 192)),
              child: GameOverScreen(
                textMoveDown: gridSizeY * textMoveDown,
                textOpacity: textOpacity,
                widget: widget,
                buttonOpacity: buttonOpacity,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AnimationController>("controller", controller));
    properties.add(DiagnosticsProperty<Animation<double>>("backgroundOpacity", backgroundOpacity));
    properties.add(DiagnosticsProperty<Animation<double>>("textMoveDown", textMoveDown));
    properties.add(DiagnosticsProperty<Animation<int>>("textOpacity", textOpacity));
    properties.add(DiagnosticsProperty<Animation<double>>("buttonOpacity", buttonOpacity));
    properties.add(DiagnosticsProperty<bool>("hasRendered", hasRendered));
  }
}
