import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over_message.dart";
import "package:twenty_fourty_eight/widgets/game_over/reset_button.dart";

class GameOverScreen extends StatelessWidget {
  const GameOverScreen({
    required this.textMoveDown,
    required this.textOpacity,
    required this.widget,
    required this.buttonOpacity,
    super.key,
  });

  final double textMoveDown;
  final int textOpacity;
  final GameOver widget;
  final double buttonOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        Positioned(
          top: textMoveDown,
          child: GameOverMessage(textOpacity: textOpacity),
        ),
        Positioned(
          top: widget.gridSizeY / 2,
          child: ResetButton(buttonOpacity: buttonOpacity),
        ),
      ],
    );
  }
}
