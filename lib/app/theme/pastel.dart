import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildPastelTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.pastel,
    isDark: false,
    // Primary colors - soft lavender
    primaryColor: const Color(0xFFB4A7D6), // Soft lavender
    primaryVariant: const Color(0xFF9C8DC1), // Slightly deeper lavender
    onPrimary: Colors.white,
    // Secondary colors - soft pink
    accentColor: const Color(0xFFEBB2B8), // Soft pink
    onAccent: const Color(0xFF5D4037), // Warm brown for contrast
    // Background colors - very light and soft
    background: const Color(0xFFFBF9F7), // Warm off-white
    surface: const Color(0xFFFFFFFF), // Pure white
    surfaceVariant: const Color(0xFFF5F2F0), // Very light beige
    // Text colors - soft but readable
    textPrimary: const Color(0xFF4A4458), // Soft dark purple-gray
    textSecondary: const Color(0xFF857A8C), // Muted purple-gray
    textDisabled: const Color(0xFFC4BDC9), // Light purple-gray
    // UI colors
    divider: const Color(0xFFE8E2E6), // Very light purple-gray
    toolbarColor: const Color(0xFFF5F2F0),
    error: const Color(0xFFE8A2A2), // Soft coral
    success: const Color(0xFFA8D5BA), // Soft mint green
    warning: const Color(0xFFFDD4A3), // Soft peach
    // Grid colors
    gridLine: const Color(0xFFE8E2E6),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFFB4A7D6), // Match primary
    selectionFill: const Color(0x30B4A7D6),
    // Icon colors
    activeIcon: const Color(0xFFB4A7D6), // Soft lavender for active
    inactiveIcon: const Color(0xFF857A8C), // Muted for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF4A4458),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF4A4458),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF4A4458),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF857A8C),
      ),
    ),
    primaryFontWeight: FontWeight.w400, // Lighter weight for softer feel
  );
}

// Enhanced Pastel theme background with scenic landscape
class PastelBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const PastelBackground({
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
        painter: _ScenicPastelPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 1.5),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _ScenicPastelPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _ScenicPastelPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Pastel landscape palette
  late final Color _skyBlue = const Color(0xFFE6F3FF); // Very light blue
  late final Color _softMint = const Color(0xFFB8E6B8); // Soft mint green
  late final Color _softPeach = const Color(0xFFFFDAB9); // Soft peach
  late final Color _lavenderMist = const Color(0xFFE6E6FA); // Lavender
  late final Color _hillGreen = const Color(0xFFC8E6C9); // Light sage green
  late final Color _sunYellow = const Color(0xFFFFFACD); // Lemon chiffon
  late final Color _flowerPink = const Color(0xFFFFB6C1); // Light pink

  // Element counts based on intensity
  int get _hillLayers => (4 * intensity).round().clamp(2, 6);
  int get _cloudCount => (5 * intensity).round().clamp(3, 8);
  int get _treeCount => (8 * intensity).round().clamp(4, 12);
  int get _flowerCount => (20 * intensity).round().clamp(10, 30);

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);
    _paintSun(canvas, size);
    _paintClouds(canvas, size);
    _paintDistantHills(canvas, size);
    _paintTrees(canvas, size);
    _paintMeadow(canvas, size);
    _paintFlowers(canvas, size);
    _paintAtmosphere(canvas, size);
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final skyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _skyBlue.withOpacity(0.6),
          _lavenderMist.withOpacity(0.4),
          _softPeach.withOpacity(0.3),
          Colors.white.withOpacity(0.8),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, skyGradient);
  }

  void _paintSun(Canvas canvas, Size size) {
    final sunCenter = Offset(size.width * 0.75, size.height * 0.25);
    final sunRadius = 40 * intensity;
    final sunPulse = 0.95 + 0.05 * _wave(0.05);

    final paint = Paint()..style = PaintingStyle.fill;

    // Sun glow
    paint
      ..color = _sunYellow.withOpacity(0.6 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(sunCenter, sunRadius * 2.5 * sunPulse, paint);

    // Sun body
    paint
      ..color = _sunYellow.withOpacity(0.8 * intensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(sunCenter, sunRadius * sunPulse, paint);

    // Sun core
    paint
      ..color = Colors.white.withOpacity(0.9 * intensity)
      ..maskFilter = null;
    canvas.drawCircle(sunCenter, sunRadius * 0.6 * sunPulse, paint);
  }

  void _paintClouds(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _cloudCount; i++) {
      final baseX = size.width * (0.1 + i * 0.15);
      final baseY = size.height * (0.1 + (i % 3) * 0.08);

      // Gentle cloud drift
      final driftX = baseX + _wave(0.02, i.toDouble()) * 30 * intensity;
      final driftY = baseY + _wave(0.03, i * 0.7) * 8 * intensity;

      final cloudSize = (25 + i * 6 + _wave(0.04, i * 0.5) * 8) * intensity;
      final opacity = (0.4 + _norm(0.06, i * 0.4) * 0.2) * intensity;

      paint.color = Colors.white.withOpacity(opacity);

      // Draw puffy cloud shape
      _drawCloud(canvas, paint, Offset(driftX, driftY), cloudSize);
    }
  }

  void _drawCloud(Canvas canvas, Paint paint, Offset center, double size) {
    // Main cloud body with multiple overlapping circles
    canvas.drawCircle(center, size, paint);
    canvas.drawCircle(center + Offset(-size * 0.4, -size * 0.2), size * 0.8, paint);
    canvas.drawCircle(center + Offset(size * 0.3, -size * 0.1), size * 0.7, paint);
    canvas.drawCircle(center + Offset(size * 0.1, size * 0.3), size * 0.6, paint);
    canvas.drawCircle(center + Offset(-size * 0.2, size * 0.2), size * 0.5, paint);
  }

  void _paintDistantHills(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int layer = 0; layer < _hillLayers; layer++) {
      final hillHeight = size.height * (0.3 + layer * 0.1);
      final baseY = size.height - hillHeight;

      final path = Path();
      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      // Create rolling hills
      for (int i = 0; i <= 10; i++) {
        final x = (i / 10) * size.width;
        final hillVariation = _wave(0.03, i * 0.8 + layer) * 40 * intensity;
        final y = baseY + hillVariation;

        if (i == 0) {
          path.lineTo(x, y);
        } else {
          // Create smooth curves
          final prevX = ((i - 1) / 10) * size.width;
          final prevY = baseY + _wave(0.03, (i - 1) * 0.8 + layer) * 40 * intensity;
          final controlX = (prevX + x) / 2;
          final controlY = (prevY + y) / 2 - 10;
          path.quadraticBezierTo(controlX, controlY, x, y);
        }
      }

      path.lineTo(size.width, size.height);
      path.close();

      // Hill colors get lighter with distance
      final hillOpacity = (0.6 - layer * 0.1) * intensity;
      final hillColors = [_hillGreen, _softMint, primaryColor.withOpacity(0.3), _lavenderMist];
      paint.color = hillColors[layer % hillColors.length].withOpacity(hillOpacity);

      canvas.drawPath(path, paint);
    }
  }

  void _paintTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _treeCount; i++) {
      final treeX = size.width * (0.1 + i * 0.1);
      final treeY = size.height * (0.6 + (i % 3) * 0.05);

      // Gentle tree sway
      final swayX = treeX + _wave(0.08, i.toDouble()) * 3 * intensity;

      final treeSize = (12 + i * 2) * intensity;
      final treeOpacity = (0.5 + _norm(0.1, i * 0.3) * 0.2) * intensity;

      // Tree colors
      final treeColors = [_hillGreen, _softMint, primaryColor.withOpacity(0.4)];
      paint.color = treeColors[i % treeColors.length].withOpacity(treeOpacity);

      // Simple tree shape
      _drawSimpleTree(canvas, paint, Offset(swayX, treeY), treeSize);
    }
  }

  void _drawSimpleTree(Canvas canvas, Paint paint, Offset base, double size) {
    // Tree crown (circle)
    canvas.drawCircle(base + Offset(0, -size), size * 0.8, paint);

    // Tree trunk
    paint.color = const Color(0xFFD2B48C).withOpacity(0.3 * intensity); // Tan
    canvas.drawRect(
      Rect.fromCenter(
        center: base + Offset(0, -size * 0.3),
        width: size * 0.2,
        height: size * 0.6,
      ),
      paint,
    );
  }

  void _paintMeadow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Ground layer
    final meadowY = size.height * 0.75;
    final meadowRect = Rect.fromLTWH(0, meadowY, size.width, size.height - meadowY);

    paint.color = _softMint.withOpacity(0.3 * intensity);
    canvas.drawRect(meadowRect, paint);

    // Grass texture with gentle waves
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * intensity;

    for (int i = 0; i < (size.width / 8).round(); i++) {
      final x = i * 8.0;
      final grassHeight = 10 + _wave(0.1, i * 0.2) * 5 * intensity;
      final grassY = meadowY + _wave(0.05, i * 0.1) * 3 * intensity;

      paint.color = _hillGreen.withOpacity(0.4 * intensity);
      canvas.drawLine(
        Offset(x, grassY),
        Offset(x, grassY + grassHeight),
        paint,
      );
    }
  }

  void _paintFlowers(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(456);

    for (int i = 0; i < _flowerCount; i++) {
      final flowerX = random.nextDouble() * size.width;
      final flowerY = size.height * (0.75 + random.nextDouble() * 0.2);

      // Gentle flower sway
      final swayX = flowerX + _wave(0.12, i * 0.2) * 2 * intensity;

      final flowerSize = (2 + random.nextDouble() * 4) * intensity;
      final bloom = _norm(0.15, i * 0.1);

      if (bloom > 0.3) {
        final flowerColors = [_flowerPink, accentColor, primaryColor, _softPeach];
        paint.color = flowerColors[i % flowerColors.length].withOpacity(0.6 * bloom * intensity);

        // Simple flower (small circle)
        canvas.drawCircle(Offset(swayX, flowerY), flowerSize * bloom, paint);

        // Flower center
        paint.color = _sunYellow.withOpacity(0.8 * bloom * intensity);
        canvas.drawCircle(Offset(swayX, flowerY), flowerSize * 0.3 * bloom, paint);
      }
    }
  }

  void _paintAtmosphere(Canvas canvas, Size size) {
    // Soft atmospheric haze
    final rect = Offset.zero & size;

    final atmosphereGradient = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.2,
        colors: [
          Colors.white.withOpacity(0.2 * intensity),
          _lavenderMist.withOpacity(0.1 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, atmosphereGradient);

    // Gentle morning mist
    for (int i = 0; i < 3; i++) {
      final mistX = size.width * (0.2 + i * 0.3) + _wave(0.02, i.toDouble()) * 20 * intensity;
      final mistY = size.height * (0.6 + i * 0.1);
      final mistSize = (60 + i * 20) * intensity;

      final mistPaint = Paint()
        ..color = Colors.white.withOpacity(0.15 * intensity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(Offset(mistX, mistY), mistSize, mistPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ScenicPastelPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
