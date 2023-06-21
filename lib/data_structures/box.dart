import "package:flutter/foundation.dart";

@immutable
class Box<T> {
  const Box(this.value);
  final int value;

  @override
  bool operator ==(final Object other) => identical(this, other);

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;
}
