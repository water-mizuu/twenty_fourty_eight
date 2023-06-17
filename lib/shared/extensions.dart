import "package:twenty_fourty_eight/shared/typedef.dart";

extension NumberExtension<E extends num> on E {
  double get percent => this / 100;
}

extension IntegerDurationExtension on int {
  Duration get microseconds => Duration(microseconds: this);
  Duration get milliseconds => Duration(milliseconds: this);
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
  Duration get hours => Duration(hours: this);
  Duration get days => Duration(days: this);
}

extension List2Extension<E> on List2<E> {
  Iterable<List<E>> get columns sync* {
    for (int x = 0; x < this[0].length; ++x) {
      yield <E>[for (int y = 0; y < this.length; ++y) this[y][x]];
    }
  }
}

extension IterableListExtension<E> on Iterable<List<E>> {
  Iterable<List<E>> get reversedRows sync* {
    for (List<E> row in this) {
      yield row.reversed.toList();
    }
  }
}
