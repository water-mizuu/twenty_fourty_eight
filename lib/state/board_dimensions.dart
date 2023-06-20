import "package:flutter/material.dart";

@immutable
class BoardDimensions {
  final double tileSize;
  final double gridHeight;
  final double gridWidth;
  final double gridInnerHeight;
  final double gridInnerWidth;
  final double width;
  final double height;

  const BoardDimensions({
    required this.tileSize,
    required this.gridHeight,
    required this.gridWidth,
    required this.gridInnerHeight,
    required this.gridInnerWidth,
    required this.width,
    required this.height,
  });

  ({
    double tileSize,
    double gridHeight,
    double gridWidth,
    double gridInnerHeight,
    double gridInnerWidth,
    double width,
    double height,
  }) get _record => (
        tileSize: tileSize,
        gridHeight: gridHeight,
        gridWidth: gridWidth,
        gridInnerHeight: gridInnerHeight,
        gridInnerWidth: gridInnerWidth,
        width: width,
        height: height,
      );

  @override
  bool operator ==(Object other) => other is BoardDimensions && _record == other._record;

  @override
  int get hashCode => _record.hashCode;
}
