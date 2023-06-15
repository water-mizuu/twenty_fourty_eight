import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";

abstract mixin class GameTile {
  double get tileSize;

  EdgeInsets get margin => EdgeInsets.all(tileSize * 3.33.percent);
}
