import "package:flutter/material.dart";

@immutable
class BoardDimensions {
  final double tileSize;
  final double gridHeight;
  final double gridWidth;
  final double gridInnerHeight;
  final double gridInnerWidth;

  const BoardDimensions({
    required this.tileSize,
    required this.gridHeight,
    required this.gridWidth,
    required this.gridInnerHeight,
    required this.gridInnerWidth,
  });

  ({
    double tileSize,
    double gridHeight,
    double gridWidth,
    double gridInnerHeight,
    double gridInnerWidth,
  }) get _record => (
        tileSize: tileSize,
        gridHeight: gridHeight,
        gridWidth: gridWidth,
        gridInnerHeight: gridInnerHeight,
        gridInnerWidth: gridInnerWidth,
      );

  @override
  bool operator ==(Object other) => other is BoardDimensions && _record == other._record;

  @override
  int get hashCode => _record.hashCode;
}
