typedef List2<E> = List<List<E>>;

extension List2Extension<E> on List2<E> {
  Iterable<List<E>> get columns sync* {
    for (int x = 0; x < this[0].length; ++x) {
      yield <E>[for (int y = 0; y < this.length; ++y) this[y][x]];
    }
  }

  Iterable<(int, int)> get indices sync* {
    for (int y = 0; y < this.length; ++y) {
      for (int x = 0; x < this[y].length; ++x) {
        yield (y, x);
      }
    }
  }
}

extension IterableListExtension<E> on Iterable<List<E>> {
  Iterable<List<E>> get reversedRows => this.map((List<E> row) => row.reversed.toList());
}
