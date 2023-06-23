import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";

class ScoreboardButton extends StatelessWidget {
  const ScoreboardButton({
    required this.text,
    required this.onPressed,
    super.key,
  });

  final String text;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) => MaterialButton(
        disabledColor: CustomColors.grayText,
        disabledTextColor: CustomColors.lightBrown,
        color: CustomColors.tile16,
        textColor: onPressed == null ? CustomColors.lightBrown : CustomColors.whiteText,
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}
