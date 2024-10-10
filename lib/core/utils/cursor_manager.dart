import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:custom_mouse_cursor/custom_mouse_cursor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:pixelverse/config/assets.dart';

import '../../pixel/tools.dart';

class CursorManager {
  static CursorManager? _instance;
  static CursorManager get instance {
    _instance ??= CursorManager._();
    return _instance!;
  }

  CursorManager._();

  final Map<PixelTool, MouseCursor> _cursors = {};

  Future<void> init() async {
    // Load cursors
  }

  MouseCursor? getCursor(PixelTool tool) {
    final cursor = _cursors[tool];
    return cursor;
  }

  Future<void> _loadCursorFromAsset(
    PixelTool tool,
    String asset, {
    int hotSpotX = 0,
    int hotSpotY = 0,
  }) async {
    _cursors[tool] = await CustomMouseCursor.asset(
      asset,
      hotX: hotSpotX,
      hotY: hotSpotY,
    );
  }

  Future<void> _convertIconDataToCursor(
    PixelTool tool,
    IconData icon, {
    Color color = Colors.black,
    double size = 20,
    int hotSpotX = 0,
    int hotSpotY = 0,
  }) async {
    final cursor = await CustomMouseCursor.icon(
      icon,
      color: color,
      size: size,
      hotX: hotSpotX,
      hotY: hotSpotY,
    );

    _cursors[tool] = cursor;
  }
}
