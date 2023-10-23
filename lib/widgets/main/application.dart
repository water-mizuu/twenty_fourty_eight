import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/widgets/main/game.dart";
import "package:twenty_fourty_eight/widgets/menu/menu.dart";

class Application extends StatefulWidget {
  const Application({super.key});

  @override
  State<Application> createState() => _ApplicationState();
}

class _ApplicationState extends State<Application> with SingleTickerProviderStateMixin {
  late final GameState state;
  late final FocusNode focusNode;

  @override
  void initState() {
    super.initState();

    state = GameState(vsync: this);
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    focusNode.dispose();
    state.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: "2048",
        theme: ThemeData(useMaterial3: true),
        home: KeyboardListener(
          focusNode: focusNode,
          autofocus: true,
          onKeyEvent: state.keyListener,
          child: ChangeNotifierProvider<GameState>.value(
            value: state,
            builder: (BuildContext context, _) => Scaffold(
              backgroundColor: CustomColors.tan,
              body: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  const Game(),
                  if (context.select((GameState state) => state.isMenuDisplayed)) const Menu(),
                ],
              ),
            ),
          ),
        ),
      );
}
