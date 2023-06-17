import "package:twenty_fourty_eight/shared/extensions.dart";

abstract mixin class GameTile {
  /// Each side has 5.0% margin
  double get tileMarginRatio => 5.0.percent;

  /// Each text has 3.5% margin
  double get textMarginRatio => 3.5.percent;
}
