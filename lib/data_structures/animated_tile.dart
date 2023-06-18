import "package:flutter/animation.dart";

class AnimatedTile {
  static const Curve animationCurve = Curves.ease;
  static const double split = 4 / 9;

  final int x;
  final int y;
  int value;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<int> animatedValue;
  late Animation<double> scale;

  AnimatedTile(({int y, int x}) index, this.value)
      : y = index.y,
        x = index.x {
    resetAnimations();
  }

  void resetAnimations() {
    animatedX = AlwaysStoppedAnimation<double>(x.toDouble());
    animatedY = AlwaysStoppedAnimation<double>(y.toDouble());
    animatedValue = AlwaysStoppedAnimation<int>(value);
    scale = const AlwaysStoppedAnimation<double>(1);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animatedX = CurvedAnimation(parent: parent, curve: const Interval(0, split, curve: animationCurve))
        .drive(Tween<double>(begin: this.x.toDouble(), end: x.toDouble()));

    animatedY = CurvedAnimation(parent: parent, curve: const Interval(0, split, curve: animationCurve))
        .drive(Tween<double>(begin: this.y.toDouble(), end: y.toDouble()));
  }

  void bounce(Animation<double> parent) {
    scale = CurvedAnimation(parent: parent, curve: const Interval(split, 1, curve: animationCurve)).drive(
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1, end: 1.2), weight: 0.5),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2, end: 1), weight: 0.5),
      ]),
    );
  }

  void appear(Animation<double> parent) {
    scale = CurvedAnimation(parent: parent, curve: const Interval(split, 1, curve: animationCurve))
        .drive(Tween<double>(begin: 0.0, end: 1.0));
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animatedValue = CurvedAnimation(parent: parent, curve: const Interval(split, 1, curve: animationCurve)).drive(
      TweenSequence<int>(<TweenSequenceItem<int>>[
        TweenSequenceItem<int>(tween: ConstantTween<int>(value), weight: 0.01),
        TweenSequenceItem<int>(tween: ConstantTween<int>(newValue), weight: 0.99),
      ]),
    );
  }
}
