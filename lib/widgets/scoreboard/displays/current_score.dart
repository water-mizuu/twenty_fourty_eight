import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class CurrentScore extends StatelessWidget {
  const CurrentScore({super.key});

  static const double aspectRatioWidthToHeight = 2 / 1;
  static const TextStyle displayTextStyle = TextStyle.new(fontSize: 32.0, fontWeight: FontWeight.w700);

  @override
  Widget build(BuildContext context) => AspectRatio(
        aspectRatio: aspectRatioWidthToHeight,
        child: ColoredBox(
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
                  context.select((GameState state) => state.score).toString(),
                  style: displayTextStyle.copyWith(color: CustomColors.whiteText),
                ),
              ],
            ),
          ),
        ),
      );
}
