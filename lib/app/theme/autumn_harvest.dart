import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildAutumnHarvestTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.autumnHarvest,
    isDark: false,
    // Primary colors - warm amber/pumpkin
    primaryColor: const Color(0xFFE67E22), // Warm pumpkin orange
    primaryVariant: const Color(0xFFD35400), // Deeper burnt orange
    onPrimary: Colors.white,
    // Secondary colors - deep burgundy
    accentColor: const Color(0xFF8B4513), // Saddle brown/burgundy
    onAccent: Colors.white,
    // Background colors - warm and cozy
    background: const Color(0xFFFDF6E3), // Warm cream/seashell
    surface: const Color(0xFFFFFFFF), // Pure white
    surfaceVariant: const Color(0xFFF5E6D3), // Light peach/cream
    // Text colors - deep warm browns
    textPrimary: const Color(0xFF3E2723), // Dark brown
    textSecondary: const Color(0xFF5D4037), // Medium brown
    textDisabled: const Color(0xFFA1887F), // Light brown
    // UI colors
    divider: const Color(0xFFD7CCC8), // Light brown
    toolbarColor: const Color(0xFFF5E6D3),
    error: const Color(0xFFD32F2F), // Red for contrast
    success: const Color(0xFF388E3C), // Forest green
    warning: const Color(0xFFFF9800), // Amber orange
    // Grid colors
    gridLine: const Color(0xFFD7CCC8),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFFE67E22), // Match primary
    selectionFill: const Color(0x30E67E22),
    // Icon colors
    activeIcon: const Color(0xFFE67E22), // Warm orange for active
    inactiveIcon: const Color(0xFF5D4037), // Brown for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF3E2723),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF3E2723),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF3E2723),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF5D4037),
      ),
    ),
    primaryFontWeight: FontWeight.w500, // Comfortable reading weight
  );
}

// Autumn Harvest theme background with falling leaves and warm atmosphere
class AutumnHarvestBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const AutumnHarvestBackground({
    super.key,
    required this.theme,
    required this.intensity,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: theme.type.animationDuration);

    useEffect(() {
      if (enableAnimation) {
        controller.repeat();
      } else {
        controller.stop();
        controller.value = 0.0;
      }
      return null;
    }, [enableAnimation]);

    final t = useAnimation(Tween<double>(begin: 0, end: 1).animate(controller));

    return RepaintBoundary(
      child: CustomPaint(
        painter: _AutumnHarvestPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 2.0),
        ),
        size: Size.infinite,
        isComplex: true,
        willChange: enableAnimation,
      ),
    );
  }
}

class _AutumnHarvestPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _AutumnHarvestPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Autumn color palette
  late final Color _goldenYellow = const Color(0xFFFFD700); // Golden yellow
  late final Color _burnishedOrange = const Color(0xFFFF8C00); // Dark orange
  late final Color _crimsonRed = const Color(0xFFDC143C); // Crimson
  late final Color _rustBrown = const Color(0xFFCD853F); // Peru/rust
  late final Color _warmAmber = const Color(0xFFFFC649); // Warm amber
  late final Color _deepRed = const Color(0xFF8B0000); // Dark red
  late final Color _chestnutBrown = const Color(0xFF954535); // Chestnut

  // Element counts based on intensity
  int get _leafCount => (60 * intensity).round().clamp(30, 90);
  int get _branchCount => (8 * intensity).round().clamp(4, 12);
  int get _lightRayCount => (5 * intensity).round().clamp(3, 8);
  int get _seedCount => (25 * intensity).round().clamp(12, 40);
  int get _treeCount => (8 * intensity).round().clamp(4, 12);
  int get _undergrowthCount => (16 * intensity).round().clamp(8, 24);

  @override
  void paint(Canvas canvas, Size size) {
    _paintAutumnSky(canvas, size);
    _paintWarmSunlight(canvas, size);
    _paintDistantTrees(canvas, size);
    _paintMidgroundTrees(canvas, size);
    _paintForegroundTrees(canvas, size);
    _paintAutumnUndergrowth(canvas, size);
    _paintFallingLeaves(canvas, size);
    _paintFloatingSeeds(canvas, size);
    _paintLightDapples(canvas, size);
    _paintAutumnMist(canvas, size);
    _paintWarmVignette(canvas, size);
  }

  void _paintAutumnSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Simple warm autumn sky with solid color layers instead of gradients
    final paint = Paint()..style = PaintingStyle.fill;

    // Base sky color
    paint.color = const Color(0xFFFFF8DC).withOpacity(0.3);
    canvas.drawRect(rect, paint);

    // Gentle cloud formations with simple colors
    for (int i = 0; i < 3; i++) {
      final cloudX = size.width * (0.2 + i * 0.3) + _wave(0.02, i.toDouble()) * 20 * intensity;
      final cloudY = size.height * (0.15 + i * 0.05) + _wave(0.03, i * 0.7) * 10 * intensity;
      final cloudSize = (45 + i * 10) * intensity;

      paint.color = const Color(0xFFFFFAF0).withOpacity(0.08 * intensity);
      canvas.drawCircle(Offset(cloudX, cloudY), cloudSize, paint);
    }
  }

  void _paintWarmSunlight(Canvas canvas, Size size) {
    final sunPosition = Offset(size.width * 0.75, size.height * 0.25);
    final paint = Paint()..style = PaintingStyle.fill;

    // Warm sun glow
    for (int i = 0; i < 4; i++) {
      final glowRadius = math.max(1.0, (25 + i * 15) * intensity);
      final glowIntensity = math.max(0.0, (0.08 - i * 0.015) * intensity);

      if (glowIntensity > 0.0) {
        paint.color = _warmAmber.withOpacity(glowIntensity);
        canvas.drawCircle(sunPosition, glowRadius, paint);

        paint.color = _goldenYellow.withOpacity(glowIntensity * 0.6);
        canvas.drawCircle(sunPosition, glowRadius * 0.7, paint);
      }
    }

    // Gentle light rays
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    for (int i = 0; i < _lightRayCount; i++) {
      final rayAngle = (i / _lightRayCount) * 2 * math.pi + _phase * 0.1;
      final rayLength = math.max(10.0, (60 + _wave(0.08, i.toDouble()) * 20) * intensity);
      final rayIntensity = _norm(0.15, i * 0.3);

      if (rayIntensity > 0.4) {
        final endPoint = Offset(
          sunPosition.dx + math.cos(rayAngle) * rayLength,
          sunPosition.dy + math.sin(rayAngle) * rayLength,
        );

        // Simple color instead of gradient to avoid shader issues
        paint
          ..strokeWidth = math.max(0.5, (2 + rayIntensity * 2) * intensity)
          ..color = _warmAmber.withOpacity(0.15 * rayIntensity * intensity)
          ..shader = null;

        canvas.drawLine(sunPosition, endPoint, paint);
      }
    }
  }

  void _paintDistantTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background tree silhouettes with autumn colors
    for (int i = 0; i < (_branchCount + 2); i++) {
      final treeX = (i / (_branchCount + 1)) * size.width;
      final treeHeight = size.height * (0.35 + _wave(0.03, i.toDouble()) * 0.08);
      final treeWidth = (35 + i * 10) * intensity;

      // Tree trunk
      paint.color = _chestnutBrown.withOpacity(0.4 * intensity);
      final trunkRect = Rect.fromLTWH(
        treeX - treeWidth * 0.08,
        size.height - treeHeight,
        treeWidth * 0.16,
        treeHeight * 0.4,
      );
      canvas.drawRect(trunkRect, paint);

      // Autumn tree canopy
      final canopyColors = [_burnishedOrange, _crimsonRed, _goldenYellow, _rustBrown];
      paint.color = canopyColors[i % canopyColors.length].withOpacity(0.5 * intensity);

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(treeX, size.height - treeHeight * 0.75),
          width: treeWidth,
          height: treeHeight * 0.6,
        ),
        paint,
      );
    }
  }

  void _paintMidgroundTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _branchCount; i++) {
      final treeX = size.width * (0.1 + i * 0.12) + _wave(0.02, i.toDouble()) * 15 * intensity;
      final treeHeight = size.height * (0.55 + _wave(0.04, i * 0.8) * 0.12);
      final treeWidth = (45 + i * 12) * intensity;

      // Tree trunk with autumn bark texture
      _drawAutumnTreeTrunk(canvas, paint, Offset(treeX, size.height), treeWidth * 0.2, treeHeight * 0.5);

      // Layered autumn canopy for depth
      final canopyColors = [_goldenYellow, _burnishedOrange, _crimsonRed, _rustBrown, _warmAmber];

      for (int layer = 0; layer < 3; layer++) {
        final canopyY = size.height - treeHeight * (0.55 + layer * 0.12);
        final canopySize = treeWidth * (1.1 - layer * 0.15);
        final canopyHeight = treeHeight * (0.35 + layer * 0.08);

        paint.color = canopyColors[(i + layer) % canopyColors.length].withOpacity((0.6 - layer * 0.12) * intensity);

        _drawAutumnCanopy(canvas, paint, Offset(treeX, canopyY), canopySize, canopyHeight, i + layer);
      }
    }
  }

  void _paintForegroundTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Large foreground trees with rich autumn foliage
    for (int i = 0; i < 3; i++) {
      final treeX = size.width * (0.1 + i * 0.4) + _wave(0.015, i.toDouble()) * 20 * intensity;
      final treeHeight = size.height * 1.1; // Extends beyond screen
      final treeWidth = (70 + i * 25) * intensity;

      // Massive trunk
      _drawAutumnTreeTrunk(canvas, paint, Offset(treeX, size.height), treeWidth * 0.25, treeHeight * 0.6);

      // Large autumn canopy sections
      final canopyColors = [_crimsonRed, _goldenYellow, _burnishedOrange, _deepRed, _warmAmber];

      for (int section = 0; section < 4; section++) {
        final sectionY = size.height - treeHeight * (0.25 + section * 0.18);
        final sectionSize = treeWidth * (1.4 - section * 0.08);

        if (sectionY < size.height) {
          paint.color = canopyColors[(i * 4 + section) % canopyColors.length].withOpacity(0.7 * intensity);

          _drawAutumnCanopy(canvas, paint, Offset(treeX, sectionY), sectionSize, treeHeight * 0.25, i * 4 + section);
        }
      }
    }
  }

  void _drawAutumnTreeTrunk(Canvas canvas, Paint paint, Offset base, double width, double height) {
    // Ensure valid dimensions
    width = math.max(1.0, width);
    height = math.max(1.0, height);

    // Main trunk with autumn tree bark color
    paint.color = _chestnutBrown.withOpacity(0.8 * intensity);
    final trunkRect = Rect.fromLTWH(
      base.dx - width / 2,
      base.dy - height,
      width,
      height,
    );
    canvas.drawRect(trunkRect, paint);

    // Bark texture lines
    paint.color = _rustBrown.withOpacity(0.6 * intensity);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = math.max(0.5, 1 * intensity);

    final lineCount = math.max(1, (height / 18).round());
    for (int i = 0; i < lineCount; i++) {
      final lineY = base.dy - i * 18;
      canvas.drawLine(
        Offset(base.dx - width * 0.4, lineY),
        Offset(base.dx + width * 0.4, lineY),
        paint,
      );
    }

    // Add some vertical bark lines
    for (int i = 0; i < 3; i++) {
      final lineX = base.dx - width * 0.3 + (i * width * 0.3);
      canvas.drawLine(
        Offset(lineX, base.dy),
        Offset(lineX, base.dy - height * 0.8),
        paint,
      );
    }

    paint.style = PaintingStyle.fill;
  }

  void _drawAutumnCanopy(Canvas canvas, Paint paint, Offset center, double width, double height, int seed) {
    // Ensure valid dimensions
    width = math.max(1.0, width);
    height = math.max(1.0, height);

    // Ensure paint has no shader
    paint.shader = null;

    // Create organic autumn canopy shape with multiple overlapping circles
    final random = math.Random(seed);
    final circleCount = math.max(1, 6 + (width / 25).round());

    for (int i = 0; i < circleCount; i++) {
      final offsetX = (random.nextDouble() - 0.5) * width * 0.7;
      final offsetY = (random.nextDouble() - 0.5) * height * 0.5;
      final circleSize = math.max(1.0, width * (0.25 + random.nextDouble() * 0.35));

      canvas.drawCircle(
        center + Offset(offsetX, offsetY),
        circleSize,
        paint,
      );
    }
  }

  void _paintAutumnUndergrowth(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < (_branchCount * 2); i++) {
      final plantX = (i / (_branchCount * 2)) * size.width;
      final plantHeight = (12 + i * 2) * intensity;
      final sway = _wave(0.15, i * 0.3) * 8 * intensity;

      // Autumn undergrowth - ferns, bushes, and grasses in fall colors
      final plantType = i % 3;
      switch (plantType) {
        case 0: // Autumn fern
          _drawAutumnFern(canvas, paint, Offset(plantX + sway, size.height), plantHeight);
          break;
        case 1: // Autumn bush
          _drawAutumnBush(canvas, paint, Offset(plantX + sway, size.height), plantHeight);
          break;
        case 2: // Autumn grass clump
          _drawAutumnGrassClump(canvas, paint, Offset(plantX + sway, size.height), plantHeight);
          break;
      }
    }
  }

  void _drawAutumnFern(Canvas canvas, Paint paint, Offset base, double height) {
    // Ensure valid height
    height = math.max(1.0, height);

    // Autumn-colored fern fronds
    final fernColors = [_rustBrown, _burnishedOrange, _goldenYellow];
    final colorIndex = (base.dx.abs().toInt()) % fernColors.length;
    paint.color = fernColors[colorIndex].withOpacity(math.max(0.0, math.min(1.0, 0.5 * intensity)));
    paint.shader = null; // Ensure no shader

    // Fern fronds
    for (int frond = 0; frond < 4; frond++) {
      final angle = (frond - 1.5) * 0.4;
      final frondLength = height * (0.7 + frond * 0.08);

      final path = Path();
      path.moveTo(base.dx, base.dy);

      for (int segment = 0; segment < 5; segment++) {
        final segmentRatio = segment / 4.0;
        final x = base.dx + math.sin(angle) * frondLength * segmentRatio;
        final y = base.dy - math.cos(angle) * frondLength * segmentRatio;
        path.lineTo(x, y);

        // Small autumn leaflets
        if (segment > 0) {
          final leafletSize = math.max(0.5, height * 0.08 * (1 - segmentRatio));
          paint.style = PaintingStyle.fill;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: leafletSize * 2, height: leafletSize),
            paint,
          );
        }
      }

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = math.max(0.5, 1 * intensity);
      canvas.drawPath(path, paint);
    }

    paint.style = PaintingStyle.fill;
  }

  void _drawAutumnBush(Canvas canvas, Paint paint, Offset base, double height) {
    // Ensure valid height
    height = math.max(1.0, height);

    final bushColors = [_crimsonRed, _burnishedOrange, _goldenYellow, _rustBrown];
    final colorIndex = (base.dx.abs().toInt()) % bushColors.length;
    paint.color = bushColors[colorIndex].withOpacity(math.max(0.0, math.min(1.0, 0.4 * intensity)));
    paint.shader = null; // Ensure no shader

    // Multiple overlapping circles for autumn bush shape
    for (int i = 0; i < 4; i++) {
      final circleX = base.dx + (i - 1.5) * height * 0.15;
      final circleY = base.dy - height * (0.25 + i * 0.08);
      final circleSize = math.max(0.5, height * (0.3 + i * 0.08));

      canvas.drawCircle(Offset(circleX, circleY), circleSize, paint);
    }
  }

  void _drawAutumnGrassClump(Canvas canvas, Paint paint, Offset base, double height) {
    // Ensure valid height
    height = math.max(1.0, height);

    final grassColors = [_rustBrown, _goldenYellow, _burnishedOrange];
    final colorIndex = (base.dx.abs().toInt()) % grassColors.length;
    paint.color = grassColors[colorIndex].withOpacity(math.max(0.0, math.min(1.0, 0.3 * intensity)));
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = math.max(0.5, 1.2 * intensity);
    paint.strokeCap = StrokeCap.round;
    paint.shader = null; // Ensure no shader

    // Individual autumn grass blades
    for (int blade = 0; blade < 6; blade++) {
      final angle = (blade - 3) * 0.25 + _wave(0.2, blade.toDouble()) * 0.4;
      final bladeHeight = height * (0.7 + blade * 0.05);

      final endX = base.dx + math.sin(angle) * bladeHeight * 0.25;
      final endY = base.dy - bladeHeight;

      canvas.drawLine(base, Offset(endX, endY), paint);
    }

    paint.style = PaintingStyle.fill;
  }

  void _paintLightDapples(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = null; // Ensure no shader is set
    final random = math.Random(456);

    // Dappled autumn sunlight on forest floor
    for (int i = 0; i < 12; i++) {
      final dappleX = random.nextDouble() * size.width;
      final dappleY = size.height * (0.65 + random.nextDouble() * 0.35);

      final dappleSize = math.max(1.0, (10 + random.nextDouble() * 18) * intensity);
      final shimmer = _norm(0.12, i * 0.4);
      final dappleIntensity = 0.25 + shimmer * 0.3;

      final opacity = math.max(0.0, math.min(1.0, 0.15 * dappleIntensity * intensity));
      paint.color = _warmAmber.withOpacity(opacity);

      // Organic dapple shape
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(dappleX, dappleY),
          width: dappleSize * (1 + shimmer * 0.2),
          height: dappleSize * 0.6,
        ),
        paint,
      );
    }
  }

  void _paintFallingLeaves(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent leaves

    for (int i = 0; i < _leafCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final leafSpeed = 0.08 + random.nextDouble() * 0.12; // Gentle falling speed

      // Seamless falling motion
      final progress = (t * leafSpeed + i * 0.03) % 1.3;
      final leafY = progress * (size.height + 60) - 30;

      if (leafY > -30 && leafY < size.height + 30) {
        // Gentle swaying as leaves fall
        final swayAmount = 25 + random.nextDouble() * 20;
        final swaySpeed = 0.6 + random.nextDouble() * 0.4;
        final sway = math.sin(progress * swaySpeed * 2 * math.pi + i) * swayAmount * intensity;
        final leafX = baseX + sway;

        // Leaf rotation and flutter
        final rotation = progress * 3 * math.pi + i + _wave(0.2, i * 0.1) * 0.5;

        // Leaf size and opacity with safety checks
        final leafSize = math.max(1.0, (4 + random.nextDouble() * 8) * intensity);
        final leafOpacity = math.max(0.0, math.min(1.0, math.max(0.0, (1.3 - progress) * 0.9) * intensity));

        if (leafOpacity > 0.01) {
          // Autumn leaf colors
          final leafColors = [
            _goldenYellow,
            _burnishedOrange,
            _crimsonRed,
            _rustBrown,
            primaryColor,
            _deepRed,
            _warmAmber,
          ];
          final leafColor = leafColors[i % leafColors.length];

          paint.color = leafColor.withOpacity(leafOpacity);

          canvas.save();
          canvas.translate(leafX, leafY);
          canvas.rotate(rotation);

          // Draw autumn leaf shape
          _drawAutumnLeaf(canvas, paint, leafSize);

          canvas.restore();
        }
      }
    }
  }

  void _drawAutumnLeaf(Canvas canvas, Paint paint, double size) {
    // Ensure valid size
    size = math.max(1.0, size);

    final path = Path();

    // Create realistic autumn leaf shape (maple-like)
    path.moveTo(0, size); // Stem point

    // Left side of leaf
    path.quadraticBezierTo(-size * 0.8, size * 0.6, -size * 0.6, size * 0.2);
    path.quadraticBezierTo(-size * 0.4, -size * 0.2, -size * 0.2, -size * 0.6);
    path.quadraticBezierTo(-size * 0.1, -size * 0.8, 0, -size); // Tip

    // Right side of leaf
    path.quadraticBezierTo(size * 0.1, -size * 0.8, size * 0.2, -size * 0.6);
    path.quadraticBezierTo(size * 0.4, -size * 0.2, size * 0.6, size * 0.2);
    path.quadraticBezierTo(size * 0.8, size * 0.6, 0, size);

    path.close();

    canvas.drawPath(path, paint);

    // Add leaf vein (center line) with safety checks
    final currentColor = paint.color;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = math.max(0.2, 0.5);
    paint.color = currentColor.withOpacity(math.min(1.0, currentColor.opacity * 0.6));
    canvas.drawLine(Offset(0, -size * 0.8), Offset(0, size * 0.8), paint);
    paint.style = PaintingStyle.fill;
    paint.color = currentColor; // Restore original color
  }

  void _paintFloatingSeeds(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    for (int i = 0; i < _seedCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion like maple seeds
      final floatSpeed = 0.05 + (i % 3) * 0.02;
      final floatX = baseX + _wave(floatSpeed, i * 0.2) * 20 * intensity;
      final floatY = baseY + _wave(floatSpeed * 0.8, i * 0.4) * 12 * intensity;

      final seedSize = math.max(1.0, (2 + random.nextDouble() * 4) * intensity);
      final twirl = _phase * 2 + i * 0.1; // Spinning motion

      // Seed opacity with gentle pulsing
      final opacity = math.max(0.0, math.min(1.0, (0.04 + _norm(0.2, i * 0.3) * 0.02) * intensity));

      if (opacity > 0.01) {
        paint.color = _rustBrown.withOpacity(opacity);

        canvas.save();
        canvas.translate(floatX, floatY);
        canvas.rotate(twirl);

        // Draw helicopter seed shape (simple version)
        canvas.drawRect(
          Rect.fromLTWH(0, -seedSize * 0.5, seedSize * 3, seedSize),
          paint,
        );

        // Seed body
        canvas.drawCircle(Offset.zero, seedSize * 0.6, paint);

        canvas.restore();
      }
    }
  }

  void _paintAutumnMist(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..shader = null; // Ensure no shader

    // Gentle morning mist
    for (int i = 0; i < 4; i++) {
      final mistX = size.width * (0.15 + i * 0.2) + _wave(0.02, i.toDouble()) * 30 * intensity;
      final mistY = size.height * (0.6 + _wave(0.03, i * 0.8) * 0.1);
      final mistWidth = math.max(10.0, (80 + i * 15) * intensity);
      final mistHeight = math.max(5.0, (20 + i * 5) * intensity);

      final mistIntensity = _norm(0.06, i * 0.7);
      final opacity = math.max(0.0, math.min(1.0, 0.04 * mistIntensity * intensity));

      paint.color = const Color(0xFFFFF8DC).withOpacity(opacity);

      // Soft, horizontal mist shapes
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(mistX, mistY),
          width: mistWidth,
          height: mistHeight,
        ),
        Radius.circular(mistHeight / 2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  void _paintWarmVignette(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Simple warm overlay instead of complex gradients
    paint.color = _warmAmber.withOpacity(0.03 * intensity);
    canvas.drawRect(Offset.zero & size, paint);

    // Simple edge darkening
    paint.color = primaryColor.withOpacity(0.02 * intensity);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _AutumnHarvestPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
