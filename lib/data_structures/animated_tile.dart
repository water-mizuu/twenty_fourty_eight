import "package:flutter/animation.dart";
import "package:twenty_fourty_eight/data_structures/move_action.dart";

class AnimatedTile {
  AnimatedTile(({int y, int x}) index, this.value)
      : y = index.y,
        x = index.x {
    resetAnimations();
  }

  AnimatedTile.from(Tile tile, [int? value])
      : x = tile.x,
        y = tile.y,
        value = value ?? tile.value {
    resetAnimations();
  }

  static const Curve animationCurve = Curves.ease;
  static const double reverseSplit = 1.0 - split;
  static const double split = 4 / 9;

  late Animation<int> animatedValue;
  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<double> opacity;
  late Animation<double> scale;
  int value;
  final int x;
  final int y;

  Tile get tile => (y: y, x: x, value: value);

  void resetAnimations() {
    animatedX = AlwaysStoppedAnimation<double>(x.toDouble());
    animatedY = AlwaysStoppedAnimation<double>(y.toDouble());
    animatedValue = AlwaysStoppedAnimation<int>(value);
    scale = const AlwaysStoppedAnimation<double>(1.0);
    opacity = const AlwaysStoppedAnimation<double>(1.0);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animatedX = CurvedAnimation(parent: parent, curve: const Interval(0.0, split, curve: animationCurve))
        .drive(Tween<double>(begin: this.x.toDouble(), end: x.toDouble()));

    animatedY = CurvedAnimation(parent: parent, curve: const Interval(0.0, split, curve: animationCurve))
        .drive(Tween<double>(begin: this.y.toDouble(), end: y.toDouble()));
  }

  void unmoveTo(Animation<double> parent, int x, int y) {
    animatedX = CurvedAnimation(parent: parent, curve: const Interval(1 - reverseSplit, 1.0, curve: animationCurve))
        .drive(Tween<double>(begin: this.x.toDouble(), end: x.toDouble()));

    animatedY = CurvedAnimation(parent: parent, curve: const Interval(1 - reverseSplit, 1.0, curve: animationCurve))
        .drive(Tween<double>(begin: this.y.toDouble(), end: y.toDouble()));
  }

  void bounce(Animation<double> parent) {
    scale = CurvedAnimation(parent: parent, curve: const Interval(split, 1.0, curve: animationCurve)).drive(
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 0.5),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 0.5),
      ]),
    );
  }

  void debounce(Animation<double> parent) {
    scale = CurvedAnimation(parent: parent, curve: const Interval(0.0, reverseSplit, curve: animationCurve)).drive(
      TweenSequence<double>(<TweenSequenceItem<double>>[
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.0, end: 1.2), weight: 0.5),
        TweenSequenceItem<double>(tween: Tween<double>(begin: 1.2, end: 1.0), weight: 0.5),
      ]),
    );
  }

  void appear(Animation<double> parent) {
    scale = CurvedAnimation(parent: parent, curve: const Interval(split, 1.0, curve: animationCurve))
        .drive(Tween<double>(begin: 0.0, end: 1.0));
  }

  void disappear(Animation<double> parent) {
    scale = CurvedAnimation(parent: parent, curve: const Interval(0.0, reverseSplit, curve: animationCurve))
        .drive(Tween<double>(begin: 1.0, end: 0.0));
  }

  void changeNumber(Animation<double> parent, int newValue) {
    animatedValue = CurvedAnimation(parent: parent, curve: const Interval(split, 1.0, curve: animationCurve)).drive(
      TweenSequence<int>(<TweenSequenceItem<int>>[
        TweenSequenceItem<int>(tween: ConstantTween<int>(this.value), weight: 0.01),
        TweenSequenceItem<int>(tween: ConstantTween<int>(newValue), weight: 0.99),
      ]),
    );
  }

  void unchangeNumber(Animation<double> parent, int newValue) {
    animatedValue =
        CurvedAnimation(parent: parent, curve: const Interval(0.0, reverseSplit, curve: animationCurve)).drive(
      TweenSequence<int>(<TweenSequenceItem<int>>[
        TweenSequenceItem<int>(tween: ConstantTween<int>(value), weight: 0.99),
        TweenSequenceItem<int>(tween: ConstantTween<int>(newValue), weight: 0.01),
      ]),
    );
  }

  void hide(Animation<double> parent) {
    opacity = parent.drive(ConstantTween<double>(0.0));
  }

  void show(Animation<double> parent) {
    opacity = parent.drive(ConstantTween<double>(1.0));
  }
}
