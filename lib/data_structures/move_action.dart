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
  factory MoveAction.fromString(String data) {
    var [
      String encodedMerges,
      String encodedAdds,
      String encodedScoreDelta,
    ] = data.split(":");

    List<Merge> merges = <Merge>[
      for (String encodedMerge in encodedMerges.split("^"))
        if (encodedMerge.split(";") case [String target, String merge, String destination])
          (target: _parseTile(target)!, merge: _parseTile(merge), destination: _parseTile(destination)!)
    ];

    Set<Tile> added = <Tile>{
      for (String encodedAdd in encodedAdds.split(";")) //
        _parseTile(encodedAdd)!
    };

    int scoreDelta = int.parse(encodedScoreDelta);

    return MoveAction(
      merges: merges,
      added: added,
      scoreDelta: scoreDelta,
    );
  }

  /// The merges that occurred in the move.
  final List<Merge> merges;

  /// The tile/s added after the merge.
  final Set<Tile> added;

  /// The score delta of the merge.
  final int scoreDelta;

  static String encode(MoveAction action) => <String>[
        <String>[
          for (Merge merge in action.merges)
            switch (merge) {
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
        <String>[
          for (var Tile(:int y, :int x, :int value) in action.added) "$y,$x,$value",
        ].join(";"),
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
          for (Merge merge in merges)
            switch (merge) {
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
