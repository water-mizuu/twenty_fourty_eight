import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/current_score.dart";

class Scoreboard extends StatefulWidget {
  static const double aspectRatio = 1 / 2;

  const Scoreboard({required this.width, super.key});

  final double width;

  @override
  State<Scoreboard> createState() => _ScoreboardState();
}

class _ScoreboardState extends State<Scoreboard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: context.watch<GameState>().scoreStream,
      initialData: 0,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const Expanded(child: SizedBox()),
            CurrentScore(width: widget.width, aspectRatio: Scoreboard.aspectRatio),
          ],
        );
      },
    );
  }
}
