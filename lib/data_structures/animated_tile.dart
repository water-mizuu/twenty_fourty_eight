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

  AnimatedTile(this.x, this.y, this.value) {
    resetAnimations();
  }

  void resetAnimations() {
    animatedX = AlwaysStoppedAnimation<double>(x.toDouble());
    animatedY = AlwaysStoppedAnimation<double>(y.toDouble());
    animatedValue = AlwaysStoppedAnimation<int>(value);
    scale = const AlwaysStoppedAnimation<double>(1);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    Animatable<double> animatableX = Tween<double>(begin: this.x.toDouble(), end: x.toDouble());
    Animation<double> animationX = CurvedAnimation(
      parent: parent,
      curve: const Interval(0, split, curve: animationCurve),
    );
    animatedX = animatableX.animate(animationX);

    Animatable<double> animatableY = Tween<double>(begin: this.y.toDouble(), end: y.toDouble());
    Animation<double> animationY = CurvedAnimation(
      parent: parent,
      curve: const Interval(0, split, curve: animationCurve),
    );
    animatedY = animatableY.animate(animationY);
  }

  void bounce(Animation<double> parent) {
    Animatable<double> animatable = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1, end: 1.5), weight: 0.5),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 1.5, end: 1), weight: 0.5),
    ]);
    Animation<double> animation = CurvedAnimation(
      parent: parent,
      curve: const Interval(split, 1, curve: animationCurve),
    );
    scale = animatable.animate(animation);
  }

  void appear(Animation<double> parent) {
    Animatable<double> animatable = Tween<double>(begin: 0, end: 1);
    Animation<double> animation = CurvedAnimation(
      parent: parent,
      curve: const Interval(split, 1, curve: animationCurve),
    );
    scale = animatable.animate(animation);
  }

  void changeNumber(Animation<double> parent, int newValue) {
    Animatable<int> animatable = TweenSequence<int>(<TweenSequenceItem<int>>[
      TweenSequenceItem<int>(tween: ConstantTween<int>(value), weight: 0.01),
      TweenSequenceItem<int>(tween: ConstantTween<int>(newValue), weight: 0.99),
    ]);
    Animation<double> animation =
        CurvedAnimation(parent: parent, curve: const Interval(split, 1, curve: animationCurve));
    animatedValue = animatable.animate(animation);
  }
}
