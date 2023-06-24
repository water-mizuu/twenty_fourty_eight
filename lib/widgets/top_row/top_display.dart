import "package:flutter/widgets.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/active_tile.dart";

class TopDisplay extends StatelessWidget {
  const TopDisplay({super.key});

  @override
  Widget build(BuildContext context) => Column(
        children: <Widget>[
          ActiveTile.dummy(animatedValue: context.select((GameState state) => state.topTileValue)),
          const Text("Top Tile"),
        ],
      );
}
