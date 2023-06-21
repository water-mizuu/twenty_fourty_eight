import "package:flutter/material.dart";

class GameOverMessage extends StatelessWidget {
  const GameOverMessage({
    required this.textOpacity,
    super.key,
  });

  final int textOpacity;

  @override
  Widget build(final BuildContext context) => Center(
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
