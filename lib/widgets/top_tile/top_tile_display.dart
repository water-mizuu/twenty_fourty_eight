import "package:flutter/widgets.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/board/tile/active_tile.dart";

class TopTileDisplay extends StatelessWidget {
  const TopTileDisplay({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: Sizes.tileSize,
        decoration: BoxDecoration(
          color: CustomColors.darkBrown,
          borderRadius: BorderRadius.circular(2.0),
        ),
        child: Column(
          children: <Widget>[
            const Center(
              child: Text(
                "TOP TILE",
                style: TextStyle.new(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w700,
                  color: CustomColors.displayText,
                ),
              ),
            ),
            SizedBox(
              height: Sizes.tileSize,
              width: Sizes.tileSize,
              child: Selector<GameState, (AnimationController, AnimatedTile)>(
                selector: (BuildContext context, GameState state) => (state.controller, state.topTile),
                builder: (BuildContext context, (AnimationController, AnimatedTile) value, Widget? child) {
                  var (AnimationController controller, AnimatedTile tile) = value;

                  return AnimatedBuilder(
                    animation: controller,
                    builder: (BuildContext context, Widget? child) => ActiveTile(
                      animatedValue: tile.animatedValue.value,
                      scale: tile.scale.value,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
}
