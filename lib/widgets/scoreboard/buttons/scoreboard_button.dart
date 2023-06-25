import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";

class ScoreboardButton extends StatelessWidget {
  const ScoreboardButton({
    required this.icon,
    required this.onPressed,
    this.color = CustomColors.tile32,
    super.key,
  });

  final Color color;
  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) => MaterialButton(
        minWidth: 0.0,
        disabledColor: CustomColors.grayText,
        disabledTextColor: CustomColors.lightBrown,
        color: color,
        textColor: onPressed == null ? CustomColors.lightBrown : CustomColors.whiteText,
        onPressed: onPressed,
        child: Icon(icon),
      );
}
