import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";

class ScoreboardButton extends StatelessWidget {
  const ScoreboardButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final void Function() onPressed;

  @override
  Widget build(final BuildContext context) => MaterialButton(
        color: CustomColors.tile16,
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
