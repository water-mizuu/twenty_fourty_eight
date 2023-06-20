import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/added_score_popup.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/displays/current_score.dart";

class Scoreboard extends StatelessWidget {
  static const double aspectRatioWidthToHeight = 2 / 1;

  const Scoreboard({required this.width, super.key});

  final double width;

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
            color: Colors.blue,
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
