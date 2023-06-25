import "dart:collection";
import "dart:math";

import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/data_structures/move_action.dart";
import "package:twenty_fourty_eight/shared/typedef.dart";

class SpecificGridData {
  SpecificGridData(
    this.score,
    this.topScore,
    this.topTile,
    this.backtrackCount,
    this.grid,
    this.actionHistory,
  );

  SpecificGridData.create(int gridY, int gridX)
      : score = 0,
        topScore = 0,
        topTile = 2,
        backtrackCount = 0,
        grid = <List<AnimatedTile>>[
          for (int y = 0; y < gridY; ++y)
            <AnimatedTile>[
              for (int x = 0; x < gridX; ++x) AnimatedTile((y: y, x: x), 0),
            ]
        ],
        actionHistory = Queue<MoveAction>();

  SpecificGridData.empty()
      : score = 0,
        topScore = 0,
        topTile = 0,
        backtrackCount = 0,
        grid = List2<AnimatedTile>.empty(),
        actionHistory = Queue<MoveAction>();

  factory SpecificGridData.fromString(String encoded) {
    var [
      String encodedString,
      String encodedTopScore,
      String encodedTopTile,
      String encodedBacktrackCount,
      String encodedGrid,
      String encodedActionHistory,
    ] = encoded.split(topLevelSeparator);

    return SpecificGridData(
      int.parse(encodedString),
      int.parse(encodedTopScore),
      int.parse(encodedTopTile),
      int.parse(encodedBacktrackCount),
      _decodeRunLengthEncoding(encodedGrid),
      Queue<MoveAction>.from(encodedActionHistory.split(moveActionHistorySeparator).map(MoveAction.fromString)),
    );
  }

  static const int backtrackingLimit = 4;
  static const String moveActionHistorySeparator = "#";
  static const String topLevelSeparator = "@";

  final Queue<MoveAction> actionHistory;
  int backtrackCount;
  final List2<AnimatedTile> grid;
  int score;
  int topScore;
  int topTile;

  String encode() {
    List<String> buffer = <String>[
      score.toString(),
      topScore.toString(),
      topTile.toString(),
      backtrackCount.toString(),
      _encodeRunLengthEncoding(grid),
      actionHistory
          .take(min(backtrackingLimit, actionHistory.length))
          .map(MoveAction.encode)
          .join(moveActionHistorySeparator),
    ];

    return buffer.join(topLevelSeparator);
  }

  static String _encodeRunLengthEncoding(List2<AnimatedTile> tiles) {
    StringBuffer buffer = StringBuffer("${tiles[0].length}::");

    List<AnimatedTile> flattenedTiles = tiles.expand((List<AnimatedTile> v) => v).toList();
    for (int i = 0; i < flattenedTiles.length; ++i) {
      int count = 1;
      while (i + 1 < flattenedTiles.length && flattenedTiles[i].value == flattenedTiles[i + 1].value) {
        ++count;
        ++i;
      }
      buffer.write("${flattenedTiles[i].value}:$count");
      if (i < flattenedTiles.length - 1) {
        buffer.write(";");
      }
    }

    return buffer.toString();
  }

  static List2<AnimatedTile> _decodeRunLengthEncoding(String encoding) {
    var [String dimensionEncoding, String bodyEncoding] = encoding.split("::");
    int gridX = int.parse(dimensionEncoding);

    List2<AnimatedTile> grid = <List<AnimatedTile>>[];
    List<String> splitEncoding = bodyEncoding.split(";");

    int i = 0;

    List<AnimatedTile> buffer = <AnimatedTile>[];
    for (var [int value, int count] in splitEncoding.map((String v) => v.split(":").map(int.parse).toList())) {
      for (int j = 0; j < count; ++j, ++i) {
        var (int y, int x) = (i ~/ gridX, i % gridX);

        buffer.add(AnimatedTile((y: y, x: x), value));
        if (x == gridX - 1) {
          grid.add(buffer);
          buffer = <AnimatedTile>[];
        }
      }
    }

    return grid;
  }
}
