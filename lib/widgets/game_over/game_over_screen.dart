import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over_message.dart";
import "package:twenty_fourty_eight/widgets/game_over/reset_button.dart";

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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double height = constraints.constrainHeight();

          return Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              Positioned(
                top: ((height - 128) / 2) * textMoveDown,
                child: GameOverMessage(textOpacity: textOpacity),
              ),
              Positioned(
                top: height / 2,
                child: ResetButton(buttonOpacity: buttonOpacity),
              ),
            ],
          );
        },
      );
}
