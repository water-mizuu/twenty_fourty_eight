import "package:flutter/widgets.dart";

class MenuTitle extends StatelessWidget {
  const MenuTitle({
    super.key,
  });

  @override
  Widget build(BuildContext context) => const Center(
        child: Text(
          "Menu",
          style: TextStyle(
            fontSize: 64,
            color: Color.fromARGB(255, 119, 110, 101),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
