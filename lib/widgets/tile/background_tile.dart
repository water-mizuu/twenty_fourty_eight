import "package:flutter/widgets.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";

class BackgroundTile extends StatelessWidget {
  const BackgroundTile({
    required this.y,
    required this.x,
    required this.tileSize,
    super.key,
  });

  final int y;
  final int x;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: y * tileSize,
      left: x * tileSize,
      width: tileSize,
      height: tileSize,
      child: Center(
        child: Container(
          margin: EdgeInsets.all(tileSize * 2.5.percent),
          height: tileSize,
          width: tileSize,
          decoration: roundRadius.copyWith(color: lightBrown),
        ),
      ),
    );
  }
}
