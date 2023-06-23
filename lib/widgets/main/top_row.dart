import "dart:math";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/active_tile.dart";
import "package:twenty_fourty_eight/widgets/board/tile/game_tile.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/buttons/scoreboard_button.dart";
import "package:twenty_fourty_eight/widgets/scoreboard/scoreboard.dart";

class TopRow extends StatelessWidget {
  const TopRow({super.key});

  static const Widget _pad = SizedBox(height: 4.0, width: 4.0);

  @override
  Widget build(BuildContext context) {
    int gridX = max(3, context.select((GameState state) => state.gridX));

    double width = Sizes.tileSize * (gridX + GameTile.tileMarginRatio);

    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const ActiveTile.dummy(animatedValue: 2048),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(4.0),
              child: Column(
                children: <Widget>[
                  const Row(
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      Scoreboard(),
                    ],
                  ),
                  _pad,
                  Row(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      ScoreboardButton(
                        icon: Icons.menu,
                        onPressed: () => context.read<GameState>().openMenu(),
                      ),
                      _pad,
                      ScoreboardButton(
                        icon: Icons.undo_rounded,
                        onPressed: context.select((GameState state) => state.canBacktrack())
                            ? () => context.read<GameState>().backtrack() //
                            : null,
                      ),
                      _pad,
                      ScoreboardButton(
                        icon: Icons.refresh_rounded,
                        onPressed: () => context.read<GameState>().reset(),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
