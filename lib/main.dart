import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/main/application.dart";
import "package:window_manager/window_manager.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await windowManager.ensureInitialized();

    await WindowManager.instance.setMinimumSize(const Size(400, 500));
    // await WindowManager.instance.setSize(const Size(400, 650));
  }

  sharedPreferences = await SharedPreferences.getInstance();

  assert(
    () {
      isDebug = true;

      return true;
    }(),
    "Should never fail",
  );
  runApp(const Application());
}
