import "package:flutter/material.dart";

typedef Tile = ({int y, int x, int value});
typedef MergeAction = ({Tile target, Tile? merge, Tile destination});
// typedef MergeAction = ({(Tile, Tile?) from, Tile to});

@immutable
class MoveAction {
  const MoveAction({
    required this.actions,
    required this.added,
    required this.scoreDelta,
  });
  factory MoveAction.fromString(String data) {
    var [
      String encodedMerges,
      String encodedAdds,
      String encodedScoreDelta,
    ] = data.split(":");

    List<MergeAction> actions = <MergeAction>[
      for (String encodedMerge in encodedMerges.split("^"))
        if (encodedMerge.split(";").map(_parseTile).toList() case [Tile target, Tile? merge, Tile destination])
          (target: target, merge: merge, destination: destination),
    ];

    Set<Tile> added = <Tile>{
      for (String encodedAdd in encodedAdds.split(";")) //
        _parseTile(encodedAdd)!,
    };

    int scoreDelta = int.parse(encodedScoreDelta);

    return MoveAction(
      actions: actions,
      added: added,
      scoreDelta: scoreDelta,
    );
  }

  /// The merges that occurred in the move.
  final List<MergeAction> actions;

  /// The tiles that were added in the move.
  final Set<Tile> added;

  /// The score delta of the merge.
  final int scoreDelta;

  static String encode(MoveAction action) => <String>[
        <String>[
          for (MergeAction action in action.actions)
            switch (action) {
              (
                target: (y: int ty, x: int tx, value: int tv),
                merge: (y: int my, x: int mx, value: int mv),
                destination: (y: int dy, x: int dx, value: int dv),
              ) =>
                "$ty,$tx,$tv;$my,$mx,$mv;$dy,$dx,$dv",
              (
                target: (y: int ty, x: int tx, value: int tv),
                merge: null,
                destination: (y: int dy, x: int dx, value: int dv),
              ) =>
                "$ty,$tx,$tv;n;$dy,$dx,$dv",
            },
        ].join("^"),
        action.added.map((Tile tile) => "${tile.y},${tile.x},${tile.value}").join(";"),
        action.scoreDelta.toString(),
      ].join(":");

  static Tile? _parseTile(String input) {
    if (input.split(",") case [String y, String x, String value]) {
      return (y: int.parse(y), x: int.parse(x), value: int.parse(value));
    } else if (input case "n") {
      return null;
    }
    throw Error();
  }

  @override
  String toString() => "MoveAction(${<String>[
        "merges: [${<String>[
          for (MergeAction action in actions)
            switch (action) {
              (
                target: (y: int ty, x: int tx, value: int tv),
                merge: (y: int my, x: int mx, value: int mv),
                destination: (y: int dy, x: int dx, value: int dv),
              ) =>
                "Merge(target: (y: $ty, x: $tx, value: $tv), merge: (y: $my, x: $mx, value: $mv), destination: (y: $dy, x: $dx, value: $dv))",
              (
                target: (y: int ty, x: int tx, value: int tv),
                merge: null,
                destination: (y: int dy, x: int dx, value: int dv),
              ) =>
                "Merge(target: (y: $ty, x: $tx, value: $tv), merge: null, destination: (y: $dy, x: $dx, value: $dv))",
            },
        ].join(", ")}]",
        "added: {${<String>[
          for (var Tile(:int y, :int x, :int value) in added) "($y, $x, $value)",
        ].join(", ")}}",
        "scoreDelta: $scoreDelta",
      ].join(", ")})";
}
