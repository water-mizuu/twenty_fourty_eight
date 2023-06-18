import "package:flutter/widgets.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class AddedScorePopup extends StatefulWidget {
  const AddedScorePopup({super.key});

  @override
  State<AddedScorePopup> createState() => _AddedScorePopupState();
}

class _AddedScorePopupState extends State<AddedScorePopup> with SingleTickerProviderStateMixin {
  late Animation<double> translateFactorY;
  late Animation<double> opacity;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: 500.milliseconds);

    resetAnimations();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: context.select((GameState state) => state.addedScoreStream),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.data) {
          case int value:
            resetAnimations();
            startAnimation();

            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                var Size(:double width, :double height) = constraints.constrain(Size.infinite);
                double translateX = (random.nextDouble() - 0.5) * 0.25 * width;

                return Container(
                  width: width,
                  margin: const EdgeInsets.all(4.0),
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
                          color: grayText,
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          case null:
            return const SizedBox();
        }
      },
    );
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
