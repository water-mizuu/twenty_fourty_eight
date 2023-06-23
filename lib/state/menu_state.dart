import "package:flutter/material.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class MenuState with ChangeNotifier {
  MenuState(TickerProvider provider, GameState gameState)
      : controller = new AnimationController(vsync: provider, duration: animationDuration),
        _xSlider = gameState.gridX.toDouble(),
        _ySlider = gameState.gridY.toDouble() {
    controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed) {
        gameState
          ..changeDimensions(_ySlider.floor(), _xSlider.floor())
          ..closeMenu();
      }
    });
  }

  static const Duration animationDuration = Duration(milliseconds: 150);

  final AnimationController controller;

  double _xSlider;
  double _ySlider;

  void animationForward() => controller.forward(from: 0.0);

  void animationReverse() => controller.reverse(from: 1.0);

  double get xSlider => _xSlider;

  void set xSlider(double value) => this
    .._xSlider = value
    ..notifyListeners();

  double get ySlider => _ySlider;

  void set ySlider(double value) => this
    .._ySlider = value
    ..notifyListeners();
}
