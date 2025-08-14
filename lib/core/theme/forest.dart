import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildForestTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.forest,
    isDark: false,
    primaryColor: const Color(0xFF2E7D32),
    primaryVariant: const Color(0xFF388E3C),
    onPrimary: Colors.white,
    accentColor: const Color(0xFFD3B047),
    onAccent: Colors.black,
    background: const Color(0xFFEFF4ED),
    surface: Colors.white,
    surfaceVariant: const Color(0xFFE1ECD8),
    textPrimary: const Color(0xFF1E3725),
    textSecondary: const Color(0xFF5C745F),
    textDisabled: const Color(0xFFA5B8A7),
    divider: const Color(0xFFD4E2CD),
    toolbarColor: const Color(0xFFE1ECD8),
    error: const Color(0xFFB71C1C),
    success: const Color(0xFF2E7D32),
    warning: const Color(0xFFF9A825),
    gridLine: const Color(0xFFD4E2CD),
    gridBackground: Colors.white,
    canvasBackground: Colors.white,
    selectionOutline: const Color(0xFF2E7D32),
    selectionFill: const Color(0x302E7D32),
    activeIcon: const Color(0xFF2E7D32),
    inactiveIcon: const Color(0xFF5C745F),
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF1E3725),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF1E3725),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF1E3725),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF5C745F),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Enhanced Forest theme background with layered depth and natural elements
class ForestBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const ForestBackground({
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
        painter: _EnhancedForestPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 1.8),
        ),
        size: Size.infinite,
        isComplex: true,
        willChange: enableAnimation,
      ),
    );
  }
}

class _EnhancedForestPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _EnhancedForestPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Forest color palette
  late final Color _deepForest = const Color(0xFF1B5E20);
  late final Color _midForest = const Color(0xFF2E7D32);
  late final Color _lightForest = const Color(0xFF4CAF50);
  late final Color _sunlight = const Color(0xFFFFF8E1);
  late final Color _warmBrown = const Color(0xFF5D4037);
  late final Color _richBrown = const Color(0xFF3E2723);
  late final Color _leafGreen = const Color(0xFF8BC34A);
  late final Color _mossGreen = const Color(0xFF689F38);
  late final Color _dappleLight = const Color(0xFFFFE082);

  // Element counts based on intensity
  int get _treeCount => (8 * intensity).round().clamp(4, 12);
  int get _leafCount => (40 * intensity).round().clamp(20, 60);
  int get _lightRayCount => (6 * intensity).round().clamp(3, 9);
  int get _undergrowthCount => (12 * intensity).round().clamp(6, 18);

  @override
  void paint(Canvas canvas, Size size) {
    _paintForestSky(canvas, size);
    _paintSunlightRays(canvas, size);
    // _paintDistantTrees(canvas, size);
    _paintMidgroundTrees(canvas, size);
    _paintForegroundTrees(canvas, size);
    _paintUndergrowth(canvas, size);
    _paintFallingLeaves(canvas, size);
    _paintLightDapples(canvas, size);
    _paintMist(canvas, size);
  }

  void _paintForestSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Forest canopy gradient - from bright sky to filtered green light
    final skyGradient = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        [
          _sunlight.withOpacity(0.9), // Bright sky above canopy
          Color.lerp(_sunlight, _leafGreen, 0.3)!, // Filtered light
          Color.lerp(_leafGreen, _midForest, 0.2)!, // Deep forest filtering
          Color.lerp(_midForest, _deepForest, 0.1)!, // Forest floor
        ],
        [0.0, 0.25, 0.7, 1.0],
      );

    canvas.drawRect(rect, skyGradient);

    // Add subtle cloud shadows moving across canopy
    for (int i = 0; i < 3; i++) {
      final cloudProgress = (t * 0.1 + i * 0.33) % 1.0;
      final cloudX = cloudProgress * size.width * 1.2 - size.width * 0.1;
      final cloudY = size.height * (0.1 + i * 0.05);

      final shadowPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cloudX, cloudY),
          size.width * 0.3,
          [
            Colors.black.withOpacity(0.05 * intensity),
            Colors.transparent,
          ],
          [0.0, 1.0],
        );

      canvas.drawRect(rect, shadowPaint);
    }
  }

  void _paintSunlightRays(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _lightRayCount; i++) {
      final rayStartX = size.width * (0.2 + i * 0.12);
      final rayStartY = size.height * 0.05;
      final rayAngle = (15 + i * 8 + _wave(0.05, i.toDouble()) * 5) * math.pi / 180;
      final rayLength = size.height * (0.6 + _wave(0.08, i * 0.7) * 0.2);

      // Create sunbeam path
      final path = Path();
      final rayWidth = (20 + i * 5) * intensity;

      final endX = rayStartX + math.sin(rayAngle) * rayLength;
      final endY = rayStartY + math.cos(rayAngle) * rayLength;

      // Sunbeam widening as it descends
      final startWidth = rayWidth * 0.3;
      final endWidth = rayWidth;

      path.moveTo(rayStartX - startWidth / 2, rayStartY);
      path.lineTo(rayStartX + startWidth / 2, rayStartY);
      path.lineTo(endX + endWidth / 2, endY);
      path.lineTo(endX - endWidth / 2, endY);
      path.close();

      // Sunbeam intensity varies
      final beamIntensity = 0.4 + 0.3 * _norm(0.1, i * 0.6);

      paint.shader = ui.Gradient.linear(
        Offset(rayStartX, rayStartY),
        Offset(endX, endY),
        [
          _sunlight.withOpacity(0.6 * beamIntensity * intensity),
          _dappleLight.withOpacity(0.4 * beamIntensity * intensity),
          _sunlight.withOpacity(0.2 * beamIntensity * intensity),
          Colors.transparent,
        ],
        [0.0, 0.3, 0.7, 1.0],
      );

      canvas.drawPath(path, paint);
    }
  }

  void _paintDistantTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Background tree silhouettes
    for (int i = 0; i < _treeCount + 2; i++) {
      final treeX = (i / (_treeCount + 1)) * size.width;
      final treeHeight = size.height * (0.4 + _wave(0.03, i.toDouble()) * 0.1);
      final treeWidth = (30 + i * 8) * intensity;

      // Tree trunk
      paint.color = _deepForest.withOpacity(0.3 * intensity);
      final trunkRect = Rect.fromLTWH(
        treeX - treeWidth * 0.1,
        size.height - treeHeight,
        treeWidth * 0.2,
        treeHeight * 0.4,
      );
      canvas.drawRect(trunkRect, paint);

      // Tree canopy (simplified for distance)
      paint.color = Color.lerp(_deepForest, _midForest, 0.3)!.withOpacity(0.4 * intensity);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(treeX, size.height - treeHeight * 0.8),
          width: treeWidth,
          height: treeHeight * 0.6,
        ),
        paint,
      );
    }
  }

  void _paintMidgroundTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _treeCount; i++) {
      final treeX = size.width * (0.1 + i * 0.12) + _wave(0.02, i.toDouble()) * 10 * intensity;
      final treeHeight = size.height * (0.6 + _wave(0.04, i * 0.8) * 0.15);
      final treeWidth = (40 + i * 10) * intensity;

      // Tree trunk with texture
      _drawTreeTrunk(canvas, paint, Offset(treeX, size.height), treeWidth * 0.25, treeHeight * 0.5);

      // Layered canopy for depth
      for (int layer = 0; layer < 3; layer++) {
        final canopyY = size.height - treeHeight * (0.6 + layer * 0.15);
        final canopySize = treeWidth * (1.2 - layer * 0.2);
        final canopyHeight = treeHeight * (0.4 + layer * 0.1);

        final canopyColor = [_midForest, _lightForest, _leafGreen][layer];
        paint.color = canopyColor.withOpacity((0.7 - layer * 0.15) * intensity);

        _drawTreeCanopy(canvas, paint, Offset(treeX, canopyY), canopySize, canopyHeight, i + layer);
      }
    }
  }

  void _paintForegroundTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Large foreground trees (partial, suggesting they extend beyond screen)
    for (int i = 0; i < 3; i++) {
      final treeX = size.width * (0.1 + i * 0.4) + _wave(0.015, i.toDouble()) * 15 * intensity;
      final treeHeight = size.height * 1.2; // Extends beyond screen
      final treeWidth = (60 + i * 20) * intensity;

      // Massive trunk
      _drawTreeTrunk(canvas, paint, Offset(treeX, size.height), treeWidth * 0.3, treeHeight * 0.6);

      // Large canopy sections
      for (int section = 0; section < 4; section++) {
        final sectionY = size.height - treeHeight * (0.3 + section * 0.2);
        final sectionSize = treeWidth * (1.5 - section * 0.1);

        if (sectionY < size.height) {
          // Only draw visible sections
          final sectionColor = Color.lerp(_deepForest, _lightForest, section / 3.0)!;
          paint.color = sectionColor.withOpacity(0.8 * intensity);

          _drawTreeCanopy(canvas, paint, Offset(treeX, sectionY), sectionSize, treeHeight * 0.3, i * 4 + section);
        }
      }
    }
  }

  void _drawTreeTrunk(Canvas canvas, Paint paint, Offset base, double width, double height) {
    // Main trunk
    paint.color = _richBrown.withOpacity(0.9 * intensity);
    final trunkRect = Rect.fromLTWH(
      base.dx - width / 2,
      base.dy - height,
      width,
      height,
    );
    canvas.drawRect(trunkRect, paint);

    // Bark texture lines
    paint.color = _warmBrown.withOpacity(0.6 * intensity);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * intensity;

    for (int i = 0; i < (height / 15).round(); i++) {
      final lineY = base.dy - i * 15;
      canvas.drawLine(
        Offset(base.dx - width * 0.4, lineY),
        Offset(base.dx + width * 0.4, lineY),
        paint,
      );
    }

    paint.style = PaintingStyle.fill;
  }

  void _drawTreeCanopy(Canvas canvas, Paint paint, Offset center, double width, double height, int seed) {
    // Create organic canopy shape with multiple overlapping circles
    final random = math.Random(seed);
    final circleCount = 5 + (width / 20).round();

    for (int i = 0; i < circleCount; i++) {
      final offsetX = (random.nextDouble() - 0.5) * width * 0.8;
      final offsetY = (random.nextDouble() - 0.5) * height * 0.6;
      final circleSize = width * (0.3 + random.nextDouble() * 0.4);

      canvas.drawCircle(
        center + Offset(offsetX, offsetY),
        circleSize,
        paint,
      );
    }
  }

  void _drawBranches(Canvas canvas, Paint paint, Offset trunk, double treeWidth, int seed) {
    paint.color = _warmBrown.withOpacity(0.7 * intensity);
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    final random = math.Random(seed);
    final branchCount = 3 + (treeWidth / 30).round();

    for (int i = 0; i < branchCount; i++) {
      final angle = (random.nextDouble() - 0.5) * math.pi * 0.6;
      final length = treeWidth * (0.4 + random.nextDouble() * 0.4);
      paint.strokeWidth = (2 + treeWidth / 30) * intensity;

      final endX = trunk.dx + math.cos(angle) * length;
      final endY = trunk.dy - math.sin(angle).abs() * length;

      canvas.drawLine(trunk, Offset(endX, endY), paint);

      // Small sub-branches
      if (random.nextDouble() > 0.5) {
        final subAngle = angle + (random.nextDouble() - 0.5) * 0.5;
        final subLength = length * 0.5;
        final subEndX = endX + math.cos(subAngle) * subLength;
        final subEndY = endY - math.sin(subAngle).abs() * subLength;

        paint.strokeWidth = (1 + treeWidth / 60) * intensity;
        canvas.drawLine(Offset(endX, endY), Offset(subEndX, subEndY), paint);
      }
    }

    paint.style = PaintingStyle.fill;
  }

  void _paintUndergrowth(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _undergrowthCount; i++) {
      final plantX = (i / _undergrowthCount) * size.width;
      final plantHeight = (15 + i * 3) * intensity;
      final sway = _wave(0.15, i * 0.3) * 5 * intensity;

      // Ferns and bushes
      final plantType = i % 3;
      switch (plantType) {
        case 0: // Fern
          _drawFern(canvas, paint, Offset(plantX + sway, size.height), plantHeight);
          break;
        case 1: // Bush
          _drawBush(canvas, paint, Offset(plantX + sway, size.height), plantHeight);
          break;
        case 2: // Grass clump
          _drawGrassClump(canvas, paint, Offset(plantX + sway, size.height), plantHeight);
          break;
      }
    }
  }

  void _drawFern(Canvas canvas, Paint paint, Offset base, double height) {
    paint.color = _mossGreen.withOpacity(0.6 * intensity);

    // Fern fronds
    for (int frond = 0; frond < 5; frond++) {
      final angle = (frond - 2) * 0.3;
      final frondLength = height * (0.8 + frond * 0.1);

      final path = Path();
      path.moveTo(base.dx, base.dy);

      for (int segment = 0; segment < 6; segment++) {
        final segmentRatio = segment / 5.0;
        final x = base.dx + math.sin(angle) * frondLength * segmentRatio;
        final y = base.dy - math.cos(angle) * frondLength * segmentRatio;
        path.lineTo(x, y);

        // Small leaflets
        if (segment > 0) {
          final leafletSize = height * 0.1 * (1 - segmentRatio);
          paint.style = PaintingStyle.fill;
          canvas.drawOval(
            Rect.fromCenter(center: Offset(x, y), width: leafletSize * 2, height: leafletSize),
            paint,
          );
        }
      }

      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1 * intensity;
      canvas.drawPath(path, paint);
    }

    paint.style = PaintingStyle.fill;
  }

  void _drawBush(Canvas canvas, Paint paint, Offset base, double height) {
    paint.color = _leafGreen.withOpacity(0.5 * intensity);

    // Multiple overlapping circles for bush shape
    for (int i = 0; i < 4; i++) {
      final circleX = base.dx + (i - 1.5) * height * 0.2;
      final circleY = base.dy - height * (0.3 + i * 0.1);
      final circleSize = height * (0.4 + i * 0.1);

      canvas.drawCircle(Offset(circleX, circleY), circleSize, paint);
    }
  }

  void _drawGrassClump(Canvas canvas, Paint paint, Offset base, double height) {
    paint.color = _leafGreen.withOpacity(0.4 * intensity);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5 * intensity;
    paint.strokeCap = StrokeCap.round;

    // Individual grass blades
    for (int blade = 0; blade < 8; blade++) {
      final angle = (blade - 4) * 0.2 + _wave(0.2, blade.toDouble()) * 0.3;
      final bladeHeight = height * (0.8 + blade * 0.05);

      final endX = base.dx + math.sin(angle) * bladeHeight * 0.3;
      final endY = base.dy - bladeHeight;

      canvas.drawLine(base, Offset(endX, endY), paint);
    }

    paint.style = PaintingStyle.fill;
  }

  void _paintFallingLeaves(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    for (int i = 0; i < _leafCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final leafSpeed = 0.1 + random.nextDouble() * 0.15;

      // Continuous falling motion
      final progress = (t * leafSpeed + i * 0.025) % 1.2;
      final leafY = progress * (size.height + 40) - 20;

      if (leafY > -20 && leafY < size.height + 20) {
        // Leaf swaying motion
        final swayAmount = 20 + random.nextDouble() * 30;
        final swaySpeed = 0.8 + random.nextDouble() * 0.4;
        final sway = math.sin(progress * swaySpeed * 2 * math.pi + i) * swayAmount * intensity;
        final leafX = baseX + sway;

        // Leaf rotation
        final rotation = progress * 4 * math.pi + i;

        // Leaf size and opacity
        final leafSize = (3 + random.nextDouble() * 5) * intensity;
        final leafOpacity = math.max(0.0, (1.2 - progress) * 0.8) * intensity;

        // Leaf colors
        final leafColors = [_leafGreen, accentColor, _warmBrown, Color.lerp(_leafGreen, _warmBrown, 0.5)!];
        final leafColor = leafColors[i % leafColors.length];

        paint.color = leafColor.withOpacity(leafOpacity);

        canvas.save();
        canvas.translate(leafX, leafY);
        canvas.rotate(rotation);

        // Draw leaf shape
        _drawLeafShape(canvas, paint, leafSize);

        canvas.restore();
      }
    }
  }

  void _drawLeafShape(Canvas canvas, Paint paint, double size) {
    final path = Path();

    // Simple leaf shape
    path.moveTo(0, size);
    path.quadraticBezierTo(-size * 0.5, size * 0.3, 0, -size);
    path.quadraticBezierTo(size * 0.5, size * 0.3, 0, size);
    path.close();

    canvas.drawPath(path, paint);

    // Leaf vein
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    paint.color = paint.color.withOpacity(paint.color.opacity * 0.5);
    canvas.drawLine(Offset(0, -size), Offset(0, size), paint);
    paint.style = PaintingStyle.fill;
  }

  void _paintLightDapples(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(456);

    // Dappled sunlight on forest floor
    for (int i = 0; i < 15; i++) {
      final dappleX = random.nextDouble() * size.width;
      final dappleY = size.height * (0.6 + random.nextDouble() * 0.4);

      final dappleSize = (8 + random.nextDouble() * 20) * intensity;
      final shimmer = _norm(0.12, i * 0.4);
      final dappleIntensity = 0.3 + shimmer * 0.4;

      paint.color = _dappleLight.withOpacity(0.3 * dappleIntensity * intensity);

      // Organic dapple shape
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(dappleX, dappleY),
          width: dappleSize * (1 + shimmer * 0.2),
          height: dappleSize * 0.7,
        ),
        paint,
      );
    }
  }

  void _paintMist(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Gentle forest mist
    for (int i = 0; i < 4; i++) {
      final mistX = size.width * (0.1 + i * 0.25) + _wave(0.02, i.toDouble()) * 50 * intensity;
      final mistY = size.height * (0.7 + _wave(0.03, i * 0.8) * 0.15);
      final mistSize = (40 + i * 15) * intensity;

      final mistIntensity = _norm(0.08, i * 0.6);

      paint.color = _sunlight.withOpacity(0.1 * mistIntensity * intensity);

      // Soft, organic mist shape
      for (int j = 0; j < 3; j++) {
        final offsetX = (j - 1) * mistSize * 0.3;
        final offsetY = j * mistSize * 0.1;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(mistX + offsetX, mistY + offsetY),
            width: mistSize * (0.8 + j * 0.2),
            height: mistSize * 0.4,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _EnhancedForestPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
