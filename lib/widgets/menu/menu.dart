import "dart:ui";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/state/menu_state.dart";
import "package:twenty_fourty_eight/widgets/menu/menu_exit.dart";
import "package:twenty_fourty_eight/widgets/menu/menu_options.dart";
import "package:twenty_fourty_eight/widgets/menu/menu_title.dart";

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  static const double boxWidth = Sizes.tileSize * 5;
  static const Widget _pad = SizedBox(height: 32);

  late final MenuState state;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    state = MenuState(this, context.read<GameState>());
    _opacity = state.controller.drive(Tween<double>(begin: 0.0, end: 1.0));
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<MenuState>.value(
        value: state..animationForward(),
        child: AnimatedBuilder(
          animation: state.controller,
          builder: (BuildContext context, Widget? child) => Opacity(
            opacity: _opacity.value,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: const ColoredBox(
                color: Color.fromARGB(64, 255, 255, 255),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: boxWidth,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        MenuTitle(),
                        _pad,
                        MenuOptions(),
                        _pad,
                        MenuExit(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
