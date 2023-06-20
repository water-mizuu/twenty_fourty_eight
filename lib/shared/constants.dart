import "dart:math" as math;

import "package:flutter/widgets.dart";

abstract final class CustomColors {
  static const Color lightBrown = Color.fromARGB(255, 205, 193, 180);
  static const Color darkBrown = Color.fromARGB(255, 187, 173, 160);
  static const Color tan = Color.fromARGB(255, 238, 228, 218);
  static const Color whiteText = Color.fromARGB(255, 255, 255, 255);
  static const Color grayText = Color.fromARGB(255, 119, 110, 101);
  static const Color displayText = Color.fromARGB(255, 238, 228, 218);
  static const Color brownText = Color.fromARGB(255, 119, 110, 101);
}

abstract final class Sizes {
  static const double tileSize = 128.0;
}

const BoxDecoration roundRadius = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0)));
final math.Random random = math.Random();

/// NOTE: Do not touch the code.
bool isDebug = false;
