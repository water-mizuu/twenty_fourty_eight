class Box<T> {
  final int value;

  const Box(this.value);

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => super.hashCode;
}
