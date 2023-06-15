import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class CurrentScore extends StatelessWidget {
  const CurrentScore({
    required this.width,
    required this.aspectRatio,
    super.key,
  });

  final double width;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width * aspectRatio,
      width: width,
      margin: const EdgeInsets.all(4.0),
      decoration: const BoxDecoration(
        color: darkBrown,
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: <Widget>[
            const Text(
              "SCORE",
              style: TextStyle(
                color: displayText,
                fontSize: 32.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "${context.watch<GameState>().score}",
              style: const TextStyle(
                color: whiteText,
                fontSize: 32.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
