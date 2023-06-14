import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

class ResetButton extends StatelessWidget {
  const ResetButton({
    required this.buttonOpacity,
    required this.widget,
    super.key,
  });

  final double buttonOpacity;
  final GameOver widget;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: buttonOpacity,
      child: MaterialButton(
        color: const Color.fromARGB(255, 60, 58, 51),
        onPressed: () => widget.reset(),
        child: const Text(
          "Try Again",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty("buttonOpacity", buttonOpacity));
  }
}
