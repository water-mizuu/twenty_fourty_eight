import "dart:math" as math;

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board.dart";
import "package:twenty_fourty_eight/widgets/game_over/game_over.dart";

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  static const double boardPadding = 4;

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
    var Size(:double width, :double height) = MediaQuery.of(context).size;
    int determinant = math.max(gridY, gridX);
    double constraint = math.min(width, height);

    double divisionSize = constraint / determinant;
    double gridSizeY = divisionSize * gridY;
    double gridSizeX = divisionSize * gridX;

    return Provider<GameState>.value(
      value: state,
      child: Scaffold(
        backgroundColor: tan,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: StreamBuilder<void>(
                stream: state.updateStream,
                builder: (BuildContext context, _) {
                  return Stack(
                    children: <Widget>[
                      Container(
                        height: gridSizeY,
                        width: gridSizeX,
                        padding: const EdgeInsets.all(boardPadding),
                        decoration: roundRadius.copyWith(color: darkBrown),
                        child: Board(
                          divisionSize: divisionSize,
                          boardPadding: boardPadding,
                        ),
                      ),
                      if (!state.canSwipeAnywhere())
                        SizedBox(
                          height: gridSizeY,
                          width: gridSizeX,
                          child: GameOver(gridSizeY, gridSizeX),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
