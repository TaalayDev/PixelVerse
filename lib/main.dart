import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/firebase_options.dart';
import 'package:window_manager/window_manager.dart';

import 'app/app.dart';
import 'core.dart';
import 'data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initWindowManager();

  await LocalStorage.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setupLogger();

  runApp(const ProviderScope(
    child: PixelVerseApp(),
  ));
}

Future<void> initWindowManager() async {
  if (kIsWeb || (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS)) {
    return;
  }

  const size = Size(1280, 720);
  await windowManager.ensureInitialized();
  const windowOptions = WindowOptions(
    size: size,
    center: true,
    backgroundColor: Color.fromARGB(255, 255, 255, 255),
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'Pixel Verse',
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
