import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:twenty_fourty_eight/shared/constants.dart";
import "package:twenty_fourty_eight/widgets/main/application.dart";
import "package:window_manager/window_manager.dart";

void main() async {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    await windowManager.ensureInitialized();

    await WindowManager.instance.setMinimumSize(const Size(400, 500));
    // await WindowManager.instance.setSize(const Size(400, 650));
  }
  assert(() {
    isDebug = true;

    return true;
  }(), "Should never fail");
  runApp(const Application());
}
