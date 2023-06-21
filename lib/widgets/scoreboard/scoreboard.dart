import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/scoreboard_button.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/current_score.dart";

class Scoreboard extends StatelessWidget {
  const Scoreboard({super.key});

  static const double aspectRatioWidthToHeight = 2 / 1;
  static const double width = Sizes.tileSize;

  @override
  Widget build(final BuildContext context) => SizedBox(
        width: width,
        child: Column(
          children: <Widget>[
            const Stack(
              children: <Widget>[
                AspectRatio(
                  aspectRatio: aspectRatioWidthToHeight,
                  child: CurrentScore(),
                ),
                AspectRatio(
                  aspectRatio: aspectRatioWidthToHeight,
                  child: AddedScorePopup(),
                )
              ],
            ),
            ScoreboardButton(
              text: "MENU",
              onPressed: () => context.read<GameState>().openMenu(),
            ),
            const SizedBox(height: Sizes.tileSize * 0.05),
            ScoreboardButton(
              text: "BACKTRACK",
              onPressed: () => context.read<GameState>().backtrack(),
            )
          ],
        ),
      );
}
