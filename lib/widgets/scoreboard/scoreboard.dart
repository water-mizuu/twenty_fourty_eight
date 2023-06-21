import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/scoreboard_button.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/current_score.dart";

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  static const double width = Sizes.tileSize;
  static const double height = Sizes.tileSize;

  @override
  Widget build(final BuildContext context) {
    final GameState state = context.read<GameState>();

    return Container(
      width: width,
      margin: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Stack(
            children: <Widget>[
              CurrentScore(),
              AddedScorePopup(),
            ],
          ),
          const SizedBox(height: height * 0.025),
          ScoreboardButton(text: "MENU", onPressed: () => state.openMenu()),
          const SizedBox(height: height * 0.025),
          ScoreboardButton(text: "BACKTRACK", onPressed: () => state.backtrack())
        ],
      ),
    );
  }
}
