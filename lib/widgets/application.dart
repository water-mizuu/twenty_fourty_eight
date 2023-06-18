import "package:flutter/material.dart";
import "package:twenty_fourty_eight/widgets/game.dart";

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "2048",
      theme: ThemeData(useMaterial3: true),
      home: const Game(),
    );
  }
}
