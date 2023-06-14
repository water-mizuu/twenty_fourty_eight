import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

class GameOverMessage extends StatelessWidget {
  const GameOverMessage({
    required this.textOpacity,
    super.key,
  });

  final int textOpacity;

  @override
  Widget build(BuildContext context) {
    return Center(
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

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty("textOpacity", textOpacity));
  }
}
