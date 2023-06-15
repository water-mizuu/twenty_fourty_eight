import "dart:async";
import "dart:collection";

import "package:flutter/animation.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/shared/extensions.dart";
import "package:twenty_fourty_eight/shared/typedef.dart";

class GameState {
  static final Duration animationDuration = 250.milliseconds;

  bool actionIsUnlocked;
  int score;

  late final AnimationController controller;

  late final List2<AnimatedTile> _grid;
  late final Queue<AnimatedTile> _toAdd;
  late final StreamController<void> _streamController;

  GameState(TickerProvider parent)
      : actionIsUnlocked = true,
        score = 0 {
    _streamController = StreamController<void>();

    _toAdd = Queue<AnimatedTile>();
    _grid = List2<AnimatedTile>.generate(
      gridY,
      (int y) => List<AnimatedTile>.generate(gridX, (int x) => AnimatedTile((y: y, x: x), 0)),
    );
    controller = AnimationController(vsync: parent, duration: animationDuration)
      ..addStatusListener((AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          while (_toAdd.isNotEmpty) {
            var AnimatedTile(:int y, :int x, :int value) = _toAdd.removeFirst();

            _grid[y][x].value = value;
          }
          for (AnimatedTile tile in flattenedGrid) {
            tile.resetAnimations();
          }

          controller.reset();
          actionIsUnlocked = true;
        }
      });
  }

  Iterable<AnimatedTile> get flattenedGrid => _grid.expand((List<AnimatedTile> r) => r);
  Iterable<AnimatedTile> get renderTiles => flattenedGrid.followedBy(_toAdd);
  Stream<void> get updateStream => _streamController.stream;

  void dispose() {
    controller.dispose();
    _grid.clear();
    _toAdd.clear();
    unawaited(_streamController.close());
  }

  void reset() {
    for (var AnimatedTile(:int y, :int x) in flattenedGrid) {
      _grid[y][x].value = 0;
    }

    _startGame();
    _alert();
  }

  bool canSwipeLeft() => _grid.any(_canSwipe);
  bool canSwipeRight() => _grid.reversedRows.any(_canSwipe);
  bool canSwipeUp() => _grid.columns.any(_canSwipe);
  bool canSwipeDown() => _grid.columns.reversedRows.any(_canSwipe);
  bool canSwipeAnywhere() => canSwipeUp() || canSwipeDown() || canSwipeLeft() || canSwipeRight();

  void swipeUp() => _swipe(() => _grid.columns.forEach(_mergeTiles));
  void swipeDown() => _swipe(() => _grid.columns.reversedRows.forEach(_mergeTiles));
  void swipeLeft() => _swipe(() => _grid.forEach(_mergeTiles));
  void swipeRight() => _swipe(() => _grid.reversedRows.forEach(_mergeTiles));

  static int _randomTileNumber() {
    return switch (random.nextDouble()) {
      <= 0.25 => 4,
      _ => 2,
    };
  }

  void _startGame() {
    score = 0;

    List<(int, int)> shuffledIndices = _grid.indices.toList()..shuffle();
    for (var (int y, int x) in shuffledIndices.take(2)) {
      _grid[y][x].value = _randomTileNumber();
    }
    // for (var (int y, int x) in shuffledIndices.skip(1)) {
    //   grid[y][x].value = pow(2, y * gridY + x + 1).floor();
    // }

    for (AnimatedTile tile in flattenedGrid) {
      tile.resetAnimations();
    }
  }

  void _addNewTile() {
    List<AnimatedTile> empty = flattenedGrid //
        .where((AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isEmpty) {
      return;
    }

    var AnimatedTile(:int y, :int x) = empty.first;
    int chosen = _randomTileNumber();
    _grid[y][x].value = chosen;

    _toAdd.add(AnimatedTile((y: y, x: x), chosen)..appear(controller));
  }

  void _swipe(void Function() action) {
    /// If the swipe actions are locked, then we ignore it.
    if (!actionIsUnlocked) {
      return;
    }

    action();
    _addNewTile();
    actionIsUnlocked = false;
    controller.forward(from: 0);

    _alert();
  }

  void _alert() {
    _streamController.add(null);
  }

  /// Returns a [bool] indicating whether [tiles] can be swiped to left
  ///   from the following conditions:
  /// ```txt
  /// 1. the row has trailing zeros, i.e [0, 2, *, *]
  /// 2. the row has a merge, i.e [2, 2, *, *]
  /// ```
  bool _canSwipe(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      AnimatedTile? query = tiles.skip(i + 1).skipWhile((AnimatedTile t) => t.value == 0).firstOrNull;

      if (query != null && (tiles[i].value == 0 || query.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  /// Merges [tiles] towards the left.
  /// i.e: [2, 0, 0, 8] -> [2, 8, 0, 0]
  void _mergeTiles(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      /// We get the sublist from [i], disregarding zeros until the first nonzero.
      List<AnimatedTile> toCheck = tiles
          .sublist(i) //
          .skipWhile((AnimatedTile tile) => tile.value == 0)
          .toList();

      /// If this happens, then the rest of the list from the right of [i]
      ///   are all zeros, so we don't have to do anything now.
      if (toCheck.isEmpty) {
        return;
      }

      AnimatedTile target = toCheck.first;

      AnimatedTile? merge = toCheck //
          .skip(1)
          .where((AnimatedTile tile) => tile.value != 0)
          .firstOrNull;

      if (merge case AnimatedTile(:int value) when value != target.value) {
        merge = null;
      }

      if (tiles[i].value == 0 || merge != null) {
        var AnimatedTile(:int x, :int y) = tiles[i];
        var AnimatedTile(:int value) = target;

        /// Animate the tile at position t.
        target.moveTo(controller, x, y);

        /// If we are *confirmed* to be merging two tiles, then:
        if (merge != null) {
          /// Increase the resulting value of the target,
          value *= 2;

          /// Do some animations.
          merge.moveTo(controller, x, y);
          merge.bounce(controller);
          merge.changeNumber(controller, value);

          /// Change the value of the merged tile,
          merge.value = 0;

          /// And the last animation
          target.changeNumber(controller, 0);
        }

        /// Update their values after the update.
        /// Sequence is important here, because there are cases when target == tiles[i].
        target.value = 0;
        tiles[i].value = value;
      }
    }
  }
}
