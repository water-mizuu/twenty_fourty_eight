import "dart:collection";

import "package:flutter/animation.dart";
import "package:twenty_fourty_eight/data_structures/animated_tile.dart";
import "package:twenty_fourty_eight/shared.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/game.dart";

class GameState {
  static const Duration animationDuration = Duration(milliseconds: 250);

  bool actionIsUnlocked;
  int score;

  final List2<AnimatedTile> grid;
  final Queue<AnimatedTile> toAdd;
  final GamerState parent;

  late final AnimationController controller;

  GameState(this.parent)
      : actionIsUnlocked = true,
        score = 0,
        grid = <List<AnimatedTile>>[
          for (int y = 0; y < gridY; ++y)
            <AnimatedTile>[
              for (int x = 0; x < gridX; ++x) AnimatedTile(x, y, 0),
            ]
        ],
        toAdd = Queue<AnimatedTile>() {
    controller = AnimationController(vsync: parent, duration: animationDuration) //
      ..addStatusListener((AnimationStatus status) {
        if (status case AnimationStatus.completed) {
          while (toAdd.isNotEmpty) {
            var AnimatedTile(:int y, :int x, :int value) = toAdd.removeFirst();

            grid[y][x].value = value;
          }
          for (AnimatedTile tile in flattenedGrid) {
            tile.resetAnimations();
          }

          controller.reset();
          actionIsUnlocked = true;
        }
      });
  }

  Iterable<AnimatedTile> get flattenedGrid => grid.expand((List<AnimatedTile> r) => r);
  Iterable<AnimatedTile> get renderTiles => flattenedGrid.followedBy(toAdd);

  void dispose() {
    controller.dispose();
    grid.clear();
    toAdd.clear();
  }

  static int randomTileNumber() {
    return switch (random.nextDouble()) {
      <= 0.25 => 4,
      _ => 2,
    };
  }

  void reset() {
    for (var AnimatedTile(:int y, :int x) in flattenedGrid) {
      grid[y][x].value = 0;
    }

    startGame();
    parent.reset();
  }

  void startGame() {
    score = 0;

    List<(int, int)> shuffledIndices = grid.indices.toList()..shuffle();
    for (var (int y, int x) in shuffledIndices.take(2)) {
      grid[y][x].value = randomTileNumber();
    }

    for (AnimatedTile tile in flattenedGrid) {
      tile.resetAnimations();
    }
  }

  void addNewTile() {
    List<AnimatedTile> empty = flattenedGrid //
        .where((AnimatedTile tile) => tile.value == 0)
        .toList()
      ..shuffle();

    if (empty.isEmpty) {
      return;
    }

    var AnimatedTile(:int y, :int x) = empty.first;
    int chosen = randomTileNumber();
    grid[y][x].value = chosen;

    toAdd.add(AnimatedTile(x, y, chosen)..appear(controller));
  }

  void swipe(void Function() action) {
    /// If the swipe actions are locked, then we ignore it.
    if (!actionIsUnlocked) {
      return;
    }

    action();
    addNewTile();
    actionIsUnlocked = false;
    controller.forward(from: 0);

    parent.reset();
  }

  bool canSwipeAnywhere() => canSwipeUp() || canSwipeDown() || canSwipeLeft() || canSwipeRight();

  bool canSwipeLeft() => grid.any(canSwipe);
  bool canSwipeRight() => grid.reversedRows.any(canSwipe);
  bool canSwipeUp() => grid.columns.any(canSwipe);
  bool canSwipeDown() => grid.columns.reversedRows.any(canSwipe);

  /// Returns a [bool] indicating whether [tiles] can be swiped to left
  ///   from the following conditions:
  /// ```txt
  /// 1. the row has trailing zeros, i.e [0, 2, *, *]
  /// 2. the row has a merge, i.e [2, 2, *, *]
  /// ```
  bool canSwipe(List<AnimatedTile> tiles) {
    for (int i = 0; i < tiles.length; ++i) {
      AnimatedTile? query = tiles.skip(i + 1).skipWhile((AnimatedTile t) => t.value == 0).firstOrNull;

      if (query != null && (tiles[i].value == 0 || query.value == tiles[i].value)) {
        return true;
      }
    }

    return false;
  }

  void swipeUp() => swipe(() => grid.columns.forEach(mergeTiles));
  void swipeDown() => swipe(() => grid.columns.reversedRows.forEach(mergeTiles));
  void swipeLeft() => swipe(() => grid.forEach(mergeTiles));
  void swipeRight() => swipe(() => grid.reversedRows.forEach(mergeTiles));

  /// Merges [tiles] towards the left.
  /// i.e: [2, 0, 0, 8] -> [2, 8, 0, 0]
  void mergeTiles(List<AnimatedTile> tiles) {
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
