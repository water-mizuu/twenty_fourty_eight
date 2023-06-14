import "package:flutter/widgets.dart";
import "package:twenty_fourty_eight/shared/constants.dart";

class BackgroundTile extends StatelessWidget {
  const BackgroundTile({
    required this.y,
    required this.x,
    required this.tileSize,
    super.key,
  });

  final int x;
  final double tileSize;
  final int y;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x * tileSize,
      top: y * tileSize,
      width: tileSize,
      height: tileSize,
      child: Center(
        child: Container(
          width: tileSize * 0.95,
          height: tileSize * 0.95,
          decoration: roundRadius.copyWith(color: lightBrown),
        ),
      ),
    );
  }
}
