import "dart:ui";

import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late double _xSliderValue;
  late double _ySliderValue;

  @override
  void initState() {
    super.initState();

    _xSliderValue = context.read<GameState>().gridX.toDouble();
    _ySliderValue = context.read<GameState>().gridY.toDouble();
  }

  Widget option({
    required String label,
    required void Function(double) callback,
    required double value,
    required double max,
    required double gridWidth,
    required double height,
    double min = 0.0,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(
            fontSize: height * 0.05,
            color: CustomColors.brownText,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).floor(),
          activeColor: CustomColors.brownText,
          label: value.floor().toString(),
          onChanged: callback,
        ),
      ],
    );
  }

  void _save() {
    GameState state = context.read<GameState>();

    if (_ySliderValue.floor() != state.gridY || _xSliderValue.floor() != state.gridX) {
      state.changeDimensions(_ySliderValue.floor(), _xSliderValue.floor());
    }
    state.closeMenu();
  }

  @override
  Widget build(BuildContext context) {
    double boxWidth = Sizes.tileSize * 5;
    double horizontalMargin = boxWidth * 0.035;

    return ColoredBox(
      color: const Color.fromARGB(128, 175, 175, 175),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: boxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Center(
                    child: Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: 64,
                        color: Color.fromARGB(255, 119, 110, 101),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
                    child: Row(
                      children: <Widget>[
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Horizontal Tile Count",
                              style: TextStyle(
                                fontSize: 28,
                                color: CustomColors.brownText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 32),
                            Text(
                              "Vertical Tile Count",
                              style: TextStyle(
                                fontSize: 28,
                                color: CustomColors.brownText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: horizontalMargin),
                        Expanded(
                          child: SliderTheme(
                            data: SliderThemeData(trackShape: CustomTrackShape()),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Slider(
                                  value: _xSliderValue,
                                  max: 8.0,
                                  divisions: 8.0.floor(),
                                  activeColor: CustomColors.brownText,
                                  label: _xSliderValue.floor().toString(),
                                  onChanged: (double value) {
                                    if (value case >= 2.0 && <= 8.0) {
                                      setState(() {
                                        _xSliderValue = value;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 32),
                                Slider(
                                  value: _ySliderValue,
                                  max: 8.0,
                                  divisions: 8.0.floor(),
                                  activeColor: CustomColors.brownText,
                                  label: _ySliderValue.floor().toString(),
                                  onChanged: (double value) {
                                    if (value case >= 2.0 && <= 8.0) {
                                      setState(() {
                                        _ySliderValue = value;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: MaterialButton(
                      hoverColor: const Color.fromARGB(0, 0, 0, 0),
                      onPressed: () {
                        _save();
                      },
                      child: const Text(
                        "Save Changes",
                        style: TextStyle(
                          fontSize: 28,
                          color: CustomColors.brownText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    double? trackHeight = sliderTheme.trackHeight;
    double trackLeft = offset.dx;
    double trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
