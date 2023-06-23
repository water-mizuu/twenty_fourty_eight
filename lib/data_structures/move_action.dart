import "package:flutter/material.dart";

typedef Tile = ({int y, int x, int value});
typedef Merge = ({Tile target, Tile? merge, Tile destination});
// typedef Merge = ({(Tile, Tile?) from, Tile to});

@immutable
class MoveAction {
  const MoveAction({
    required this.merges,
    required this.added,
    required this.scoreDelta,
  });

  /// The merges that occurred in the move.
  final List<Merge> merges;

  /// The tile/s added after the merge.
  final Set<Tile> added;

  /// The score delta of the merge.
  final int scoreDelta;
}
