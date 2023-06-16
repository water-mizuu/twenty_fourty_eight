import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/current_score.dart";

class Scoreboard extends StatelessWidget {
  const Scoreboard({required this.width, super.key});

  final double width;
  static const double aspectRatio = 1 / 2;

  @override
  Widget build(BuildContext context) => StreamBuilder<int>(
        stream: context.watch<GameState>().scoreStream,
        initialData: 0,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const Expanded(child: SizedBox()),
            Stack(
              children: <Widget>[
                CurrentScore(width: width, aspectRatio: aspectRatio),
                if (snapshot.data case int value && != 0)
                  AddedScorePopup(width: width, aspectRatio: aspectRatio, value: value)
              ],
            ),
          ],
        ),
      );
}
