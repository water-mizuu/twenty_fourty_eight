import "package:flutter/material.dart";

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    required this.textMoveDown,
    required this.textOpacity,
    required this.buttonOpacity,
    super.key,
  });

  final double textMoveDown;
  final int textOpacity;
  final double buttonOpacity;

  @override
  Widget build(BuildContext context) => Align(
        alignment: AlignmentGeometry.lerp(Alignment.topCenter, Alignment.center, textMoveDown)!,
        child: Text(
          "Game Over!",
          style: TextStyle(
            color: Color.fromARGB(textOpacity, 119, 110, 101),
            fontSize: 36,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
}
