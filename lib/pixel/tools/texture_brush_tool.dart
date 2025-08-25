import 'dart:convert';
import 'dart:ui';
import 'dart:math';
import 'dart:collection';

import 'package:flutter/services.dart';

import '../pixel_point.dart';
import '../tools.dart';

/// Mode for texture brush operation
enum TextureBrushMode {
  brush, // Paint with texture stamps
  fill, // Fill areas with texture pattern
}

class TextureBrushTool extends Tool {
  final TexturePattern _texturePattern;
  final BlendMode _blendMode;

  final TextureBrushMode _mode;
  final TextureFillMode _fillMode;

  List<PixelPoint<int>> _currentPixels = [];
  PixelPoint<int>? _lastPosition;

  // Track the last texture stamp position to maintain proper spacing
  PixelPoint<int>? _lastTextureStamp;

  // Distance threshold based on texture size for stamp placement
  late final double _stampDistance;

  late final TextureFillTool _fillTool;

  TexturePattern get texturePattern => _texturePattern;
  BlendMode get blendMode => _blendMode;
  TextureBrushMode get mode => _mode;
  TextureFillMode get fillMode => _fillMode;
  double get stampDistance => _stampDistance;

  TextureBrushTool(
    this._texturePattern,
    this._blendMode, {
    TextureBrushMode mode = TextureBrushMode.brush,
    TextureFillMode fillMode = TextureFillMode.tile,
    double spacingMultiplier = 1.0,
  })  : _mode = mode,
        _fillMode = fillMode,
        super(PixelTool.textureBrush) {
    _stampDistance = (min(_texturePattern.width, _texturePattern.height) * spacingMultiplier);
    _fillTool = TextureFillTool(_texturePattern, _blendMode, fillMode: _fillMode);
  }

  @override
  void onStart(PixelDrawDetails details) {
    if (_mode == TextureBrushMode.fill) {
      _fillTool.onStart(details);
      return;
    }

    _currentPixels.clear();
    _lastPosition = details.pixelPosition;
    _lastTextureStamp = details.pixelPosition;
    _applyTexture(details);
  }

  @override
  void onMove(PixelDrawDetails details) {
    if (_mode == TextureBrushMode.fill) {
      _fillTool.onMove(details);
      return;
    }

    final currentPos = details.pixelPosition;

    // Only apply texture stamps when we've moved far enough
    if (_lastTextureStamp != null) {
      final distance = _getDistance(_lastTextureStamp!, currentPos);

      if (distance >= _stampDistance) {
        // Calculate positions along the path where textures should be stamped
        final stampPositions = _getTextureStampPositions(_lastTextureStamp!, currentPos);

        for (final stampPos in stampPositions) {
          final texturePixels = _getTexturePixels(stampPos, details.color);
          _currentPixels.addAll(texturePixels);
        }

        // Update last stamp position to the last calculated position
        if (stampPositions.isNotEmpty) {
          _lastTextureStamp = stampPositions.last;
        }
      }
    } else {
      _applyTexture(details);
      _lastTextureStamp = currentPos;
    }

    _lastPosition = currentPos;
    details.onPixelsUpdated(_currentPixels);
  }

  @override
  void onEnd(PixelDrawDetails details) {
    if (_mode == TextureBrushMode.fill) {
      _fillTool.onEnd(details);
      return;
    }

    if (_currentPixels.isNotEmpty) {
      details.onPixelsUpdated(_currentPixels);
    }
    _currentPixels.clear();
    _lastPosition = null;
    _lastTextureStamp = null;
  }

  void _applyTexture(PixelDrawDetails details) {
    final texturePixels = _getTexturePixels(details.pixelPosition, details.color);
    _currentPixels.addAll(texturePixels);
    details.onPixelsUpdated(_currentPixels);
  }

  /// Calculate distance between two pixel points
  double _getDistance(PixelPoint<int> point1, PixelPoint<int> point2) {
    final dx = point2.x - point1.x;
    final dy = point2.y - point1.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Get positions along the path where texture stamps should be placed
  List<PixelPoint<int>> _getTextureStampPositions(PixelPoint<int> start, PixelPoint<int> end) {
    final positions = <PixelPoint<int>>[];

    final totalDistance = _getDistance(start, end);
    if (totalDistance < _stampDistance) {
      return positions; // Not far enough to place a new stamp
    }

    final dx = end.x - start.x;
    final dy = end.y - start.y;

    // Calculate how many stamps we can fit along this path
    final numberOfStamps = (totalDistance / _stampDistance).floor();

    for (int i = 1; i <= numberOfStamps; i++) {
      final t = (i * _stampDistance) / totalDistance;
      final x = start.x + (dx * t).round();
      final y = start.y + (dy * t).round();

      positions.add(PixelPoint(x, y));
    }

    return positions;
  }

  List<PixelPoint<int>> _getTexturePixels(PixelPoint<int> center, Color baseColor) {
    final pixels = <PixelPoint<int>>[];
    final pattern = _texturePattern;

    // Calculate the starting position to center the texture
    final startX = center.x - pattern.width ~/ 2;
    final startY = center.y - pattern.height ~/ 2;

    for (int py = 0; py < pattern.height; py++) {
      for (int px = 0; px < pattern.width; px++) {
        final patternValue = pattern.getPixel(px, py);

        // Extract alpha from pattern value
        final patternAlpha = (patternValue >> 24) & 0xFF;
        final intensity = patternAlpha / 255.0;

        if (intensity > 0) {
          // Blend the base color with the pattern intensity
          final blendedColor = Color.fromARGB(
            (baseColor.alpha * intensity).round().clamp(0, 255),
            baseColor.red,
            baseColor.green,
            baseColor.blue,
          );

          final pixelX = startX + px;
          final pixelY = startY + py;

          // Only add pixel if it's within bounds
          if (pixelX >= 0 && pixelY >= 0) {
            pixels.add(PixelPoint(
              pixelX,
              pixelY,
              color: blendedColor.value,
            ));
          }
        }
      }
    }

    return pixels;
  }
}

/// Represents a texture pattern for the texture brush
class TexturePattern {
  final int id;
  final String name;
  final int width;
  final int height;
  final List<int> data;

  const TexturePattern({
    required this.id,
    required this.name,
    required this.width,
    required this.height,
    required this.data,
  });

  /// Get pixel value at the given coordinates
  int getPixel(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return 0;
    }

    final index = y * width + x;
    if (index >= 0 && index < data.length) {
      return data[index];
    }

    return 0;
  }

  factory TexturePattern.fromJson(Map<String, dynamic> json) {
    return TexturePattern(
      id: json['id'] as int,
      name: json['name'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
      data: List<int>.from(json['data'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'width': width,
      'height': height,
      'data': data,
    };
  }
}

/// Service for managing texture patterns used by the texture brush tool
class TextureManager {
  static final TextureManager _instance = TextureManager._internal();
  factory TextureManager() => _instance;
  TextureManager._internal();

  List<TexturePattern>? _textures;
  bool _isLoaded = false;

  /// Get all available texture patterns
  Future<List<TexturePattern>> getTextures() async {
    if (!_isLoaded) {
      await _loadTextures();
    }
    return _textures ?? [];
  }

  /// Get a specific texture pattern by ID
  Future<TexturePattern?> getTextureById(int id) async {
    final textures = await getTextures();
    try {
      return textures.firstWhere((texture) => texture.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get a specific texture pattern by name
  Future<TexturePattern?> getTextureByName(String name) async {
    final textures = await getTextures();
    try {
      return textures.firstWhere((texture) => texture.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Create a texture brush tool with the specified texture
  Future<TextureBrushTool?> createTextureBrush({
    int? textureId,
    String? textureName,
    BlendMode blendMode = BlendMode.srcOver,
    TextureBrushMode mode = TextureBrushMode.brush,
    TextureFillMode fillMode = TextureFillMode.tile,
    double spacingMultiplier = 1.0,
  }) async {
    TexturePattern? pattern;

    if (textureId != null) {
      pattern = await getTextureById(textureId);
    } else if (textureName != null) {
      pattern = await getTextureByName(textureName);
    }

    if (pattern == null) {
      return null;
    }

    return TextureBrushTool(pattern, blendMode, mode: mode, fillMode: fillMode, spacingMultiplier: spacingMultiplier);
  }

  /// Load textures from assets
  Future<void> _loadTextures() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/textures.json');
      final List<dynamic> jsonData = json.decode(jsonString);

      _textures = jsonData.map((json) => TexturePattern.fromJson(json as Map<String, dynamic>)).toList();

      _isLoaded = true;
    } catch (e) {
      print('Error loading textures: $e');
      _textures = [];
      _isLoaded = true;
    }
  }

  /// Reload textures from assets (useful for hot reload during development)
  Future<void> reloadTextures() async {
    _isLoaded = false;
    _textures = null;
    await _loadTextures();
  }

  /// Get default textures (fallback if loading fails)
  List<TexturePattern> getDefaultTextures() {
    return [
      // Simple dot pattern
      const TexturePattern(
        id: 1,
        name: 'Dots',
        width: 4,
        height: 4,
        data: [
          0xFF000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
        ],
      ),

      // Cross pattern
      const TexturePattern(
        id: 2,
        name: 'Cross',
        width: 5,
        height: 5,
        data: [
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0xFF000000,
          0xFF000000,
          0xFF000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
        ],
      ),

      // Diagonal lines
      const TexturePattern(
        id: 3,
        name: 'Diagonal',
        width: 4,
        height: 4,
        data: [
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0xFF000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0x00000000,
          0xFF000000,
        ],
      ),
    ];
  }
}

/// Texture fill tool that fills areas with repeating texture patterns
class TextureFillTool extends Tool {
  final TexturePattern _texturePattern;
  final BlendMode _blendMode;
  final TextureFillMode _fillMode;

  TextureFillTool(
    this._texturePattern,
    this._blendMode, {
    TextureFillMode fillMode = TextureFillMode.tile,
  })  : _fillMode = fillMode,
        super(PixelTool.textureBrush);

  @override
  void onStart(PixelDrawDetails details) {
    _performTextureFill(details);
  }

  @override
  void onMove(PixelDrawDetails details) {
    // Texture fill is a single-click operation, no dragging
  }

  @override
  void onEnd(PixelDrawDetails details) {
    // Fill operation completed in onStart
  }

  void _performTextureFill(PixelDrawDetails details) {
    final startPosition = details.pixelPosition;
    final targetColor = _getPixelColor(
      details.currentLayer.pixels,
      startPosition.x,
      startPosition.y,
      details.width,
      details.height,
    );

    // Don't fill if clicking on the same pattern
    if (_isAlreadyTexturePattern(targetColor)) {
      return;
    }

    final filledPixels = _floodFillWithTexture(
      details.currentLayer.pixels,
      startPosition.x,
      startPosition.y,
      details.width,
      details.height,
      targetColor,
      details.color,
    );

    if (filledPixels.isNotEmpty) {
      details.onPixelsUpdated(filledPixels);
    }
  }

  List<PixelPoint<int>> _floodFillWithTexture(
    List<int> pixels,
    int startX,
    int startY,
    int width,
    int height,
    int targetColor,
    Color fillColor,
  ) {
    final filledPixels = <PixelPoint<int>>[];
    final visited = <int>{};
    final queue = Queue<Point<int>>();

    // Check if the starting point is the correct color before starting
    if (_getPixelColor(pixels, startX, startY, width, height) != targetColor) {
      return [];
    }

    queue.add(Point(startX, startY));

    while (queue.isNotEmpty) {
      final point = queue.removeFirst();
      final x = point.x;
      final y = point.y;

      // Check bounds
      if (x < 0 || x >= width || y < 0 || y >= height) continue;

      final index = y * width + x;

      // Skip if already visited
      if (visited.contains(index)) continue;

      // Check if this pixel matches the target color
      final currentColor = _getPixelColor(pixels, x, y, width, height);
      if (currentColor != targetColor) continue;

      // CRITICAL FIX: Mark as visited only AFTER all checks have passed.
      visited.add(index);

      // Apply texture pattern at this position
      final texturePixel = _getTexturePixelAt(x, y, fillColor);
      if (texturePixel != null) {
        filledPixels.add(PixelPoint(x, y, color: texturePixel));
      }

      // Add neighboring pixels to queue
      queue.add(Point(x + 1, y));
      queue.add(Point(x - 1, y));
      queue.add(Point(x, y + 1));
      queue.add(Point(x, y - 1));
    }

    return filledPixels;
  }

  int? _getTexturePixelAt(int x, int y, Color baseColor) {
    switch (_fillMode) {
      case TextureFillMode.tile:
        return _getTiledTexturePixel(x, y, baseColor);
      case TextureFillMode.stretch:
        return _getStretchedTexturePixel(x, y, baseColor);
      case TextureFillMode.center:
        return _getCenteredTexturePixel(x, y, baseColor);
    }
  }

  int? _getTiledTexturePixel(int x, int y, Color baseColor) {
    // Tile the texture pattern across the fill area
    final patternX = x % _texturePattern.width;
    final patternY = y % _texturePattern.height;

    final patternValue = _texturePattern.getPixel(patternX, patternY);

    // Extract alpha from pattern value
    final patternAlpha = (patternValue >> 24) & 0xFF;
    final intensity = patternAlpha / 255.0;

    if (intensity > 0) {
      final blendedColor = Color.fromARGB(
        (baseColor.alpha * intensity).round().clamp(0, 255),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );

      return blendedColor.value;
    }
    return null;
  }

  int? _getStretchedTexturePixel(int x, int y, Color baseColor) {
    // For stretched mode, we'd need the fill area bounds
    // This is more complex and would require additional parameters
    // For now, fall back to tiled mode
    return _getTiledTexturePixel(x, y, baseColor);
  }

  int? _getCenteredTexturePixel(int x, int y, Color baseColor) {
    // For centered mode, we'd need the fill area center point
    // This is more complex and would require additional parameters
    // For now, fall back to tiled mode
    return _getTiledTexturePixel(x, y, baseColor);
  }

  int _getPixelColor(List<int> pixels, int x, int y, int width, int height) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return 0; // Transparent
    }

    final index = y * width + x;
    if (index >= 0 && index < pixels.length) {
      return pixels[index];
    }

    return 0; // Transparent
  }

  bool _isAlreadyTexturePattern(int pixelColor) {
    // Simple check - in a real implementation, you might want to
    // check if the pixel matches any part of the current texture pattern
    return false;
  }
}

/// Different modes for texture filling
enum TextureFillMode {
  /// Tile the texture pattern across the fill area
  tile,

  /// Stretch the texture to fit the fill area
  stretch,

  /// Center the texture in the fill area
  center,
}

/// Enhanced texture fill tool with multiple fill modes
class TextureFillToolAdvanced extends TextureFillTool {
  final int _fillAreaStartX;
  final int _fillAreaStartY;
  final int _fillAreaWidth;
  final int _fillAreaHeight;

  TextureFillToolAdvanced(
    super.texturePattern,
    super.blendMode, {
    super.fillMode,
    required int fillAreaStartX,
    required int fillAreaStartY,
    required int fillAreaWidth,
    required int fillAreaHeight,
  })  : _fillAreaStartX = fillAreaStartX,
        _fillAreaStartY = fillAreaStartY,
        _fillAreaWidth = fillAreaWidth,
        _fillAreaHeight = fillAreaHeight;

  @override
  int? _getStretchedTexturePixel(int x, int y, Color baseColor) {
    // Calculate relative position within the fill area
    final relativeX = x - _fillAreaStartX;
    final relativeY = y - _fillAreaStartY;

    if (relativeX < 0 || relativeX >= _fillAreaWidth || relativeY < 0 || relativeY >= _fillAreaHeight) {
      return null;
    }

    // Map fill area coordinates to texture coordinates
    final textureX = ((relativeX / _fillAreaWidth) * _texturePattern.width).floor();
    final textureY = ((relativeY / _fillAreaHeight) * _texturePattern.height).floor();

    final patternValue = _texturePattern.getPixel(
      textureX.clamp(0, _texturePattern.width - 1),
      textureY.clamp(0, _texturePattern.height - 1),
    );

    // Extract alpha from pattern value
    final patternAlpha = (patternValue >> 24) & 0xFF;
    final intensity = patternAlpha / 255.0;

    if (intensity > 0) {
      final blendedColor = Color.fromARGB(
        (baseColor.alpha * intensity).round().clamp(0, 255),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );

      return blendedColor.value;
    }
    return null;
  }

  @override
  int? _getCenteredTexturePixel(int x, int y, Color baseColor) {
    // Calculate center position of fill area
    final centerX = _fillAreaStartX + (_fillAreaWidth / 2).floor();
    final centerY = _fillAreaStartY + (_fillAreaHeight / 2).floor();

    // Calculate texture center
    final textureCenterX = _texturePattern.width ~/ 2;
    final textureCenterY = _texturePattern.height ~/ 2;

    // Calculate texture coordinates relative to center
    final textureX = x - centerX + textureCenterX;
    final textureY = y - centerY + textureCenterY;

    // Check if within texture bounds
    if (textureX < 0 || textureX >= _texturePattern.width || textureY < 0 || textureY >= _texturePattern.height) {
      return null;
    }

    final patternValue = _texturePattern.getPixel(textureX, textureY);

    // Extract alpha from pattern value
    final patternAlpha = (patternValue >> 24) & 0xFF;
    final intensity = patternAlpha / 255.0;

    if (intensity > 0) {
      final blendedColor = Color.fromARGB(
        (baseColor.alpha * intensity).round().clamp(0, 255),
        baseColor.red,
        baseColor.green,
        baseColor.blue,
      );

      return blendedColor.value;
    }
    return null;
  }
}

/// Factory class to create appropriate texture fill tools
class TextureFillFactory {
  static TextureFillTool createSimpleFill(
    TexturePattern pattern,
    BlendMode blendMode,
    TextureFillMode fillMode,
  ) {
    return TextureFillTool(pattern, blendMode, fillMode: fillMode);
  }

  static TextureFillToolAdvanced createAdvancedFill(
    TexturePattern pattern,
    BlendMode blendMode,
    TextureFillMode fillMode,
    int fillAreaStartX,
    int fillAreaStartY,
    int fillAreaWidth,
    int fillAreaHeight,
  ) {
    return TextureFillToolAdvanced(
      pattern,
      blendMode,
      fillMode: fillMode,
      fillAreaStartX: fillAreaStartX,
      fillAreaStartY: fillAreaStartY,
      fillAreaWidth: fillAreaWidth,
      fillAreaHeight: fillAreaHeight,
    );
  }
}
