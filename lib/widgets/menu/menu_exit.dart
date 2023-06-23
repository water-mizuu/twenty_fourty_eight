import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/menu_state.dart";

class MenuExit extends StatelessWidget {
  const MenuExit({super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: MaterialButton(
          hoverColor: const Color.fromARGB(0, 0, 0, 0),
          onPressed: () {
            context.read<MenuState>().animationReverse();
          },
          child: const Text(
            "Save Changes",
            style: TextStyle(
              fontSize: 28,
              color: CustomColors.brownText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}
