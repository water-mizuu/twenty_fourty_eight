import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class CurrentScore extends StatelessWidget {
  const CurrentScore({super.key});
  static const TextStyle displayTextStyle = TextStyle.new(fontSize: 32.0, fontWeight: FontWeight.w700);

  @override
  Widget build(final BuildContext context) => Container(
        margin: const EdgeInsets.all(4.0),
        color: CustomColors.darkBrown,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: <Widget>[
              Text(
                "SCORE",
                style: displayTextStyle.copyWith(color: CustomColors.displayText),
              ),
              Text(
                context.select((final GameState state) => state.score).toString(),
                style: displayTextStyle.copyWith(color: CustomColors.whiteText),
              ),
            ],
          ),
        ),
      );
}
