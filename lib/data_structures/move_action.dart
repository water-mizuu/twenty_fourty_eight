import "package:flutter/material.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/enum/direction.dart";

@immutable
class MoveAction {
  const MoveAction({
    required this.direction,
    required this.merges,
    required this.added,
  });

  final Direction direction;
  final Set<((AnimatedTile, AnimatedTile), AnimatedTile)> merges;
  final Set<AnimatedTile> added;
}
