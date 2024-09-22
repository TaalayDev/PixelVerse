import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

void setupLogger() {
  Logger.root.onRecord.listen((record) {
    if (kReleaseMode) return;
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      print('${record.stackTrace}');
    }
  });
}
