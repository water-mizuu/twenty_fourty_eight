import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/twenty_fourty_eight_game.dart";

class TwentyFourtyEightApp extends StatelessWidget {
  const TwentyFourtyEightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "2048",
      home: TwentyFourtyEightGame(),
    );
  }
}
