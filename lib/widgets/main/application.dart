import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/board_dimensions.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/main/game.dart";
import "package:twenty_fourty_eight/widgets/menu/menu.dart";

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> {
  late final GameState state;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    state = GameState()..reset();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "2048",
      theme: ThemeData(useMaterial3: true),
      home: KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: state.keyEventListener,
        child: Provider<GameState>.value(
          updateShouldNotify: (_, __) => false,
          value: state,
          child: StreamBuilder<void>(
            stream: state.gridDimensionStream,
            builder: (BuildContext context, _) {
              return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                var Size(:double width, :double height) = constraints.constrain(Size.infinite);
                var GameState(:int gridX, :int gridY) = state;
                double tileSize = min(
                  width / (gridX + GameTile.tileMarginRatio),
                  height / (gridY + GameTile.tileMarginRatio + 1),
                );
                double gridInnerHeight = tileSize * gridY;
                double gridInnerWidth = tileSize * gridX;
                double gridHeight = gridInnerHeight + (GameTile.tileMarginRatio * tileSize);
                double gridWidth = gridInnerWidth + (GameTile.tileMarginRatio * tileSize);

                return Provider<BoardDimensions>.value(
                  value: BoardDimensions(
                    tileSize: tileSize,
                    gridInnerHeight: gridInnerHeight,
                    gridInnerWidth: gridInnerWidth,
                    gridHeight: gridHeight,
                    gridWidth: gridWidth,
                    width: width,
                    height: height,
                  ),
                  child: StreamBuilder<MenuState>(
                    stream: state.menuStateStream,
                    initialData: MenuState.closeMenu,
                    builder: (BuildContext context, AsyncSnapshot<MenuState> snapshot) {
                      return Scaffold(
                        backgroundColor: CustomColors.tan,
                        body: Stack(
                          children: <Widget>[
                            const Game(),
                            if (snapshot.data case MenuState.openMenu) const Menu(),
                          ],
                        ),
                      );
                    },
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
