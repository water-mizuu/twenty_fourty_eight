import "package:flutter/widgets.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:twenty_fourty_eight/shared/constants.dart";

class AddedScorePopup extends StatelessWidget {
  const AddedScorePopup({
    required this.width,
    required this.aspectRatio,
    required this.value,
    super.key,
  });

  final double width;
  final double aspectRatio;
  final int value;

  @override
  Widget build(BuildContext context) => Container(
        height: width * aspectRatio,
        width: width,
        margin: const EdgeInsets.all(4.0),
        child: Center(
          child: Text(
            value > 0 ? "+${value.abs()}" : "-${value.abs()}",
            style: const TextStyle(
              color: grayText,
              fontSize: 24.0,
              fontWeight: FontWeight.w700,
            ),
          )
              .animate(key: UniqueKey())
              .fadeIn(duration: 250.ms, curve: Curves.easeIn)
              .moveY(
                duration: 500.ms,
                begin: 0.0,
                end: -width * aspectRatio * 0.5,
                curve: Curves.easeOut,
              )
              .then()
              .fadeOut(duration: 250.ms, curve: Curves.easeOut)
              .then(),
        ),
      );
}
