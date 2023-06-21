enum Direction {
  up,
  down,
  left,
  right;

  Direction get opposite => switch (this) {
        up => down,
        down => up,
        left => right,
        right => left,
      };
}
