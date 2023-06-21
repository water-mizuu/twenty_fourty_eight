import "package:twenty_fourty_eight/shared/typedef.dart";

extension List2Extension<E> on List2<E> {
  Iterable<List<E>> get columns sync* {
    for (int x = 0; x < this[0].length; ++x) {
      yield <E>[for (int y = 0; y < this.length; ++y) this[y][x]];
    }
  }
}

extension IterableListExtension<E> on Iterable<List<E>> {
  Iterable<List<E>> get reversedRows sync* {
    for (final List<E> row in this) {
      yield row.reversed.toList();
    }
  }
}
