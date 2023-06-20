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

  static const Color transparent = Color.fromARGB(0, 0, 0, 0);

  static const Color tile2 = Color.fromARGB(255, 238, 228, 220);
  static const Color tile4 = Color.fromARGB(255, 238, 225, 201);
  static const Color tile8 = Color.fromARGB(255, 243, 178, 122);
  static const Color tile16 = Color.fromARGB(255, 246, 150, 100);
  static const Color tile32 = Color.fromARGB(255, 247, 124, 95);
  static const Color tile64 = Color.fromARGB(255, 247, 95, 59);
  static const Color tile128 = Color.fromARGB(255, 237, 208, 115);
  static const Color tile256 = Color.fromARGB(255, 237, 204, 98);
  static const Color tile512 = Color.fromARGB(255, 237, 201, 80);
  static const Color tile1024 = Color.fromARGB(255, 237, 197, 63);
  static const Color tile2048 = Color.fromARGB(255, 237, 194, 46);
  static const Color tileSuper = Color.fromARGB(255, 60, 58, 51);
}

abstract final class Sizes {
  static const double tileSize = 128.0;
}

const BoxDecoration roundRadius = BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0)));
final math.Random random = math.Random();

/// NOTE: Do not touch the code.
bool isDebug = false;
