import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/current_score.dart";

class Scoreboard extends StatelessWidget {
  static const double aspectRatioWidthToHeight = 2 / 1;
  static const double width = Sizes.tileSize;

  const Scoreboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
          MaterialButton(
            minWidth: width,
            color: CustomColors.tile16,
            onPressed: () {
              context.read<GameState>().openMenu();
            },
            child: const Text(
              "MENU",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        ],
      ),
    );
  }
}
