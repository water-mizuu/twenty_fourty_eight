import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/state/game_state.dart";
import "package:twenty_fourty_eight/state/menu_state.dart";

class MenuOptions extends StatelessWidget {
  const MenuOptions({super.key});

  TableRow _option({
    required String text,
    required void Function(double) onChanged,
    required double value,
    double min = 0.0,
    double max = 1.0,
  }) =>
      TableRow(
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  color: CustomColors.grayText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).floor(),
            activeColor: CustomColors.grayText,
            label: value.floor().toString(),
            onChanged: onChanged,
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    const double boxWidth = Sizes.tileSize * 5;
    const double horizontalMargin = boxWidth * 0.035;

    MenuState state = context.read<MenuState>();
    double xSlider = context.select((MenuState state) => state.xSlider);
    double ySlider = context.select((MenuState state) => state.ySlider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: horizontalMargin),
      child: Table(
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(flex: 2.0),
          1: IntrinsicColumnWidth(flex: 3.0),
        },
        children: <TableRow>[
          _option(
            text: "Horizontal Tile Count",
            value: xSlider,
            max: GameState.maxGridX.toDouble(),
            onChanged: (double value) {
              if (value case >= GameState.minGridX && <= GameState.maxGridX) {
                state.xSlider = value;
              }
            },
          ),
          _option(
            text: "Vertical Tile Count",
            value: ySlider,
            max: GameState.maxGridY.toDouble(),
            onChanged: (double value) {
              if (value case >= GameState.minGridY && <= GameState.maxGridY) {
                state.ySlider = value;
              }
            },
          ),
        ],
      ),
    );
  }
}
