import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/menu_button.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/reset_button.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/undo_button.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";
import "package:twenty_fourty_eight/widgets/top_tile/top_tile_display.dart";

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  static const Widget _pad = SizedBox(height: 4.0, width: 4.0);

  @override
  Widget build(BuildContext context) {
    int gridX = max(3, context.select((GameState state) => state.gridX));

    return SizedBox(
      width: Sizes.tileSize * (gridX + GameTile.tileMarginRatio),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(0.0, 4.0, 4.0, 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TopTileDisplay(),
            Expanded(
              child: Column(
                children: <Widget>[
                  Row(
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      Scoreboard(),
                    ],
                  ),
                  _pad,
                  Row(
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      MenuButton(),
                      _pad,
                      UndoButton(),
                      _pad,
                      ResetButton(),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
