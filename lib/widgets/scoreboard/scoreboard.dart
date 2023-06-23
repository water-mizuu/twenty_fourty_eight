import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/current_score.dart";

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  static const double width = Sizes.tileSize;
  static const double height = Sizes.tileSize;

  @override
  Widget build(BuildContext context) => const SizedBox(
        width: width,
        child: Stack(
          children: <Widget>[
            CurrentScore(),
            AddedScorePopup(),
          ],
        ),
      );
}
