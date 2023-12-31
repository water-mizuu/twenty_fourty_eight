import "package:flutter/widgets.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class AddedScorePopup extends StatefulWidget {
  const AddedScorePopup({super.key});

  @override
  State<AddedScorePopup> createState() => _AddedScorePopupState();
}

class _AddedScorePopupState extends State<AddedScorePopup> with SingleTickerProviderStateMixin {
  static const double aspectRatioWidthToHeight = 2 / 1;

  late Animation<double> translateFactorY;
  late Animation<double> opacity;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    resetAnimations();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int currentScore = context.select((GameState state) => state.addedScore).value;

    switch (currentScore) {
      case int value && != 0:
        resetAnimations();
        startAnimation();

        return AspectRatio(
          aspectRatio: aspectRatioWidthToHeight,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              var Size(:double width, :double height) = constraints.constrain(Size.infinite);
              double translateX = (random.nextDouble() - 0.5) * 0.25 * width;

              return SizedBox(
                width: width,
                child: Center(
                  child: AnimatedBuilder(
                    animation: animationController,
                    builder: (BuildContext context, Widget? child) {
                      var Animation<double>(value: double opacity) = this.opacity;
                      var Animation<double>(value: double translateFactorY) = this.translateFactorY;

                      return Transform.translate(
                        offset: Offset(translateX, height * translateFactorY),
                        child: Opacity(
                          opacity: opacity,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      value > 0 ? "+${value.abs()}" : "-${value.abs()}",
                      style: const TextStyle(
                        color: CustomColors.grayText,
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      case _:
        return const SizedBox();
    }
  }

  void resetAnimations() {
    opacity = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: 1.0), weight: 0.5),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.0, end: 0.0), weight: 0.5),
      ],
    ).animate(CurvedAnimation(parent: animationController, curve: Curves.easeInOut));
    translateFactorY = Tween<double>(begin: 0.35, end: -0.50)
        .animate(CurvedAnimation(parent: animationController, curve: Curves.easeOut));
  }

  void startAnimation() {
    animationController
      ..reset()
      ..forward();
  }
}
