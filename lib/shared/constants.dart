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

const BoxDecoration roundRadius = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)));
final math.Random random = math.Random();

const bool isDebug = true;
