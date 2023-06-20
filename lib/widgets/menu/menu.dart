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

  void save() {
    GameState state = context.read<GameState>();

    if (_ySliderValue.floor() != state.gridY || _xSliderValue.floor() != state.gridX) {
      state.changeDimensions(_ySliderValue.floor(), _xSliderValue.floor());
    }
    state.closeMenu();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      var Size(:double height) = constraints.constrain(Size.infinite);
      int gridX = context.select((GameState state) => state.gridX);

      return ColoredBox(
        color: const Color.fromARGB(128, 175, 175, 175),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Center(
            child: SizedBox(
              width: Sizes.tileSize * gridX,
              height: height,
              child: FittedBox(
                alignment: Alignment.topCenter,
                fit: BoxFit.scaleDown,
                child: Column(
                  children: <Widget>[
                    Text("$gridX", style: const TextStyle(fontSize: 100)),
                    Text(
                      "Menu",
                      style: TextStyle(
                        fontSize: height * 0.085,
                        color: const Color.fromARGB(255, 119, 110, 101),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: height * 0.045),
                    Row(
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "Horizontal",
                              style: TextStyle(
                                fontSize: height * 0.05,
                                color: CustomColors.brownText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: height * 0.045),
                            Text(
                              "Vertical",
                              style: TextStyle(
                                fontSize: height * 0.05,
                                color: CustomColors.brownText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Column(
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
                            SizedBox(height: height * 0.045),
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
                      ],
                    ),
                    SizedBox(height: height * 0.045),
                    MaterialButton(
                      child: const Text("Save Changes"),
                      onPressed: () {
                        save();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
