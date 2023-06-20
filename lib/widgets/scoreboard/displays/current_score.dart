import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class CurrentScore extends StatelessWidget {
  static const TextStyle displayTextStyle = TextStyle.new(fontSize: 32.0, fontWeight: FontWeight.w700);

  const CurrentScore({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      color: CustomColors.darkBrown,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: <Widget>[
            Text(
              "SCORE",
              style: displayTextStyle.copyWith(color: CustomColors.displayText),
            ),
            StreamBuilder<int>(
              stream: context.select((GameState state) => state.scoreStream),
              initialData: 0,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                return Text(
                  snapshot.data.toString(),
                  style: displayTextStyle.copyWith(color: CustomColors.whiteText),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
