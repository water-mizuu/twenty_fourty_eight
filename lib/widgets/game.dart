import "dart:math" as math;

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";
import "package:twenty_fourty_eight/widgets/tile/active_tile.dart";

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  static const double boardPadding = 2;

  late final GameState state;

  @override
  void initState() {
    super.initState();

    state = GameState(this)..reset();
  }

  @override
  void dispose() {
    state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      var Size(:double width, :double height) = constraints.constrain(Size.infinite);

      int determinant = math.max(gridY, gridX);

      // Yes, i used the value of [tileSize].
      // x                         = min width, height - (x / determinant - boardPadding * 0.5)
      // x                         = height - x / determinant + boardPadding * 0.5
      // x + x / determinant       = height + boardPadding * 0.5
      // (1 + 1 / determinant) * x = height + boardPadding * 0.5
      // x                         = (height + boardPadding * 0.5) / (1 + 1 / determinant)
      double constraint = math.min(width, (height + boardPadding * 0.5) / (1 + 1 / determinant) * 0.98325);

      double divisionSize = constraint / determinant;
      double gridSizeY = divisionSize * gridY;
      double gridSizeX = divisionSize * gridX;

      double tileSize = divisionSize - boardPadding * 0.5;

      return Provider<GameState>.value(
        value: state,
        child: Scaffold(
          backgroundColor: tan,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: gridSizeX,
                  height: tileSize,
                  margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: tileSize,
                        width: tileSize,
                        child: ActiveTile(
                          tileSize: tileSize,
                          scale: 1.0,
                          animatedValue: 2048,
                        ),
                      ),
                      Expanded(
                        child: Scoreboard(width: tileSize),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: gridSizeY + 2.0 * boardPadding,
                  width: gridSizeX + 2.0 * boardPadding,
                  child: StreamBuilder<void>(
                    stream: state.updateStream,
                    builder: (BuildContext context, _) {
                      return Stack(
                        children: <Widget>[
                          Board(
                            boardPadding: boardPadding,
                            divisionSize: divisionSize,
                            tileSize: tileSize,
                          ),
                          if (!state.canSwipeAnywhere()) const GameOver(),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
