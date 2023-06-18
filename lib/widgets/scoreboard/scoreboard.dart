import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/current_score.dart";

class Scoreboard extends StatelessWidget {
  static const double aspectRatio = 1 / 2;

  const Scoreboard({required this.width, super.key});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        SizedBox(
          width: width,
          child: CurrentScore(width: width, aspectRatio: aspectRatio),
        ),
        SizedBox(
          width: width,
          height: width * aspectRatio,
          child: const AddedScorePopup(),
        )
      ],
    );
  }
}
