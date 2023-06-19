import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/board_dimensions.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/board_display.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/main/top_row.dart";

class Game extends StatelessWidget {
  const Game({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var Size(:double width, :double height) = constraints.constrain(Size.infinite);
        var GameState(
          :int gridY,
          :int gridX,
          :void Function(KeyEvent) keyEventListener,
          :void Function(DragEndDetails) verticalDragListener,
          :void Function(DragEndDetails) horizontalDragListener,
        ) = context.watch<GameState>();

        /// ts = min (w - ts * tmr) / gx
        ///          ,[h - ts * (tmr - 1)] / gy
        ///
        /// ts = (w -  ts * tmr) / gx
        /// ts = w / gx - ts * tmr / gx
        /// ts + ts * tmr / gx = w / gx
        /// ts * (1 + tmr / gx) = w / gx
        /// ts = (w / gx) / (1 + tmr / gx)
        /// ts = (w / gx) / [(gx + tmr) / gx]
        /// ts = w / (gx + tmr)
        ///
        /// ts = [h - ts * (tmr - 1)] / gy
        /// ts = h / gy - ts * (tmr - 1) / gy
        /// ts + ts * (tmr - 1) / gy = h / gy
        /// ts (1 + (tmr - 1) / gy) = h / gy
        /// ts = (h / gy) / (1 + (tmr - 1) / gy)
        /// ts = (h / gy) / ((gy + tmr - 1) / gy)
        /// ts = h / (gy + tmr - 1)

        double tileSize = min(
          width / (gridX + GameTile.tileMarginRatio),
          height / (gridY + GameTile.tileMarginRatio + 1),
        );
        double gridInnerHeight = tileSize * gridY;
        double gridInnerWidth = tileSize * gridX;
        double gridHeight = gridInnerHeight + (GameTile.tileMarginRatio * tileSize);
        double gridWidth = gridInnerWidth + (GameTile.tileMarginRatio * tileSize);

        return KeyboardListener(
          focusNode: FocusNode(),
          autofocus: true,
          onKeyEvent: keyEventListener,
          child: GestureDetector(
              onVerticalDragEnd: verticalDragListener,
              onHorizontalDragEnd: horizontalDragListener,
              child: Provider<BoardDimensions>.value(
                value: BoardDimensions(
                  tileSize: tileSize,
                  gridInnerHeight: gridInnerHeight,
                  gridInnerWidth: gridInnerWidth,
                  gridHeight: gridHeight,
                  gridWidth: gridWidth,
                ),
                child: Scaffold(
                  backgroundColor: tan,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: tileSize,
                          width: gridInnerWidth,
                          child: const TopRow(),
                        ),
                        SizedBox(
                          height: gridHeight,
                          width: gridWidth,
                          child: const BoardDisplay(),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        );
      },
    );
  }
}
