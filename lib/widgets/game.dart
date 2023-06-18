import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_area.dart";
import "package:twenty_fourty_eight/widgets/main/top_row.dart";

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> with SingleTickerProviderStateMixin {
  // static const double boardPadding = 2;

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
      var GameState(:int gridY, :int gridX) = state;
      var Size(:double width, :double height) = constraints.constrain(Size.infinite);

      /// ts = min w/gx, (h - ts)/gy
      /// ts = (h - ts)/gy
      /// ts = h/gy - ts/gy
      /// ts + ts/gy = h/gy
      /// (1 + 1/gy)ts = h/gy
      /// ts = (h/gy) / (1 + 1/gy)
      double tileSize = min(width / gridX, (height / gridY) / (1 + 1 / gridY));
      double gridSizeY = tileSize * gridY;
      double gridSizeX = tileSize * gridX;

      return KeyboardListener(
        focusNode: FocusNode(),
        autofocus: true,
        onKeyEvent: state.keyEventListener,
        child: GestureDetector(
          onVerticalDragEnd: state.verticalDragListener,
          onHorizontalDragEnd: state.horizontalDragListener,
          child: Provider<GameState>.value(
            updateShouldNotify: (_, __) => false,
            value: state,
            child: Scaffold(
              backgroundColor: tan,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: tileSize,
                      width: gridSizeX,
                      child: TopRow(tileSize: tileSize),
                    ),
                    SizedBox(
                      height: gridSizeY,
                      width: gridSizeX,
                      child: BoardArea(tileSize: tileSize),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
