import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildRoseQuartzGardenTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.roseQuartzGarden,
    isDark: false,
    // Primary colors - soft rose quartz pink
    primaryColor: const Color(0xFFF7CAC9), // Soft rose quartz pink
    primaryVariant: const Color(0xFFE6B8B7), // Slightly deeper rose
    onPrimary: const Color(0xFF5D2C2F), // Dark rose for contrast
    // Secondary colors - deep rose
    accentColor: const Color(0xFFE91E63), // Deep rose accent
    onAccent: Colors.white,
    // Background colors - gentle and soft
    background: const Color(0xFFFDF8F8), // Very light pink-white
    surface: const Color(0xFFFFFFFF), // Pure white
    surfaceVariant: const Color(0xFFF5F0F5), // Gentle gray-pink
    // Text colors - warm and readable
    textPrimary: const Color(0xFF4A3B3C), // Deep warm gray
    textSecondary: const Color(0xFF7D6465), // Medium warm gray
    textDisabled: const Color(0xFFBCAAAB), // Light warm gray
    // UI colors
    divider: const Color(0xFFE8DDDE), // Very light rose-gray
    toolbarColor: const Color(0xFFF5F0F5),
    error: const Color(0xFFDC143C), // Crimson red
    success: const Color(0xFF228B22), // Forest green
    warning: const Color(0xFFFF8C00), // Dark orange
    // Grid colors
    gridLine: const Color(0xFFE8DDDE),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFFF7CAC9), // Match primary
    selectionFill: const Color(0x30F7CAC9),
    // Icon colors
    activeIcon: const Color(0xFFF7CAC9), // Rose quartz for active
    inactiveIcon: const Color(0xFF7D6465), // Warm gray for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF4A3B3C),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF4A3B3C),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF4A3B3C),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF7D6465),
      ),
    ),
    primaryFontWeight: FontWeight.w400, // Light weight for gentle feel
  );
}

// Rose Quartz Garden theme background with crystal formations and floating elements
class RoseQuartzGardenBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const RoseQuartzGardenBackground({
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
        painter: _RoseQuartzGardenPainter(
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

class _RoseQuartzGardenPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _RoseQuartzGardenPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Rose quartz color palette
  late final Color _softRose = const Color(0xFFFFC0CB); // Light pink
  late final Color _pearlWhite = const Color(0xFFF0F8FF); // Alice blue
  late final Color _blushPink = const Color(0xFFFFB6C1); // Light pink
  late final Color _dustyRose = const Color(0xFFD8BFD8); // Thistle
  late final Color _warmGray = const Color(0xFFF5F5F0); // Beige

  // Element counts based on intensity
  int get _crystalCount => (8 * intensity).round().clamp(4, 12);
  int get _petalCount => (25 * intensity).round().clamp(12, 40);
  int get _heartCount => (6 * intensity).round().clamp(3, 9);
  int get _sparkleCount => (30 * intensity).round().clamp(15, 45);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGardenMist(canvas, size);
    _paintCrystalFormations(canvas, size);
    _paintFloatingPetals(canvas, size);
    _paintRoseQuartzHearts(canvas, size);
    _paintCrystalSparkles(canvas, size);
    _paintEnergyFlows(canvas, size);
    _paintSoftGlow(canvas, size);
  }

  void _paintGardenMist(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Soft garden atmosphere
    final mistGradient = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.3, size.height * 0.4),
        size.width * 0.8,
        [
          _pearlWhite.withOpacity(0.1 * intensity),
          _softRose.withOpacity(0.06 * intensity),
          Colors.transparent,
          _blushPink.withOpacity(0.04 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.3, 0.5, 0.8, 1.0],
      );

    canvas.drawRect(rect, mistGradient);

    // Gentle morning light effect
    final lightPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height * 0.3),
        [
          _pearlWhite.withOpacity(0.08 * intensity),
          Colors.transparent,
          _softRose.withOpacity(0.05 * intensity),
        ],
        [0.0, 0.6, 1.0],
      );

    canvas.drawRect(rect, lightPaint);
  }

  void _paintCrystalFormations(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _crystalCount; i++) {
      final baseX = size.width * (0.1 + (i / _crystalCount) * 0.8);
      final baseY = size.height * (0.6 + (i % 3) * 0.15);

      // Gentle swaying motion
      final swayX = baseX + _wave(0.08, i.toDouble()) * 8 * intensity;
      final swayY = baseY + _wave(0.12, i * 0.7) * 6 * intensity;

      final crystalSize = (25 + i * 4 + _wave(0.15, i * 0.5) * 8) * intensity;
      final growth = 0.8 + 0.2 * _norm(0.2, i * 0.3);
      final currentSize = crystalSize * growth;

      // Crystal color with gentle variation
      final crystalHues = [primaryColor, _softRose, _blushPink, _dustyRose];
      final crystalColor = crystalHues[i % crystalHues.length];
      final opacity = (0.15 + _norm(0.1, i * 0.4) * 0.08) * intensity;

      paint.color = crystalColor.withOpacity(opacity);

      // Draw rose quartz crystal cluster
      _drawCrystalCluster(canvas, paint, Offset(swayX, swayY), currentSize, i);
    }
  }

  void _drawCrystalCluster(Canvas canvas, Paint paint, Offset center, double size, int seed) {
    // Main crystal formation
    final path = Path();
    final points = 6;

    for (int i = 0; i < points; i++) {
      final angle = i * 2 * math.pi / points;
      final radius = size * (0.8 + 0.2 * math.sin(angle * 3));
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);

    // Inner crystal structure
    paint.color = paint.color.withOpacity(paint.color.opacity * 0.6);
    for (int i = 0; i < points; i++) {
      final angle = i * 2 * math.pi / points;
      final innerRadius = size * 0.4;
      final innerX = center.dx + math.cos(angle) * innerRadius;
      final innerY = center.dy + math.sin(angle) * innerRadius;

      canvas.drawLine(
          center,
          Offset(innerX, innerY),
          Paint()
            ..color = paint.color
            ..strokeWidth = 1 * intensity
            ..style = PaintingStyle.stroke);
    }

    // Crystal highlights
    paint.style = PaintingStyle.fill;
    paint.color = _pearlWhite.withOpacity(0.3 * intensity);
    canvas.drawCircle(
      center + Offset(-size * 0.3, -size * 0.3),
      size * 0.15,
      paint,
    );
  }

  void _paintFloatingPetals(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(789);

    for (int i = 0; i < _petalCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion like flower petals
      final floatSpeed = 0.04 + (i % 3) * 0.02;
      final floatX = baseX + _wave(floatSpeed, i * 0.2) * 15 * intensity;
      final floatY = baseY + _wave(floatSpeed * 0.7, i * 0.4) * 10 * intensity;

      final petalSize = (4 + random.nextDouble() * 12) * intensity;
      final rotation = _phase * 0.5 + i * 0.1;

      // Color cycling through rose palette
      final colors = [primaryColor, _softRose, _blushPink, _dustyRose, _pearlWhite];
      final petalColor = colors[i % colors.length];
      final opacity = (0.08 + _norm(0.2, i * 0.3) * 0.04) * intensity;

      paint.color = petalColor.withOpacity(opacity);

      canvas.save();
      canvas.translate(floatX, floatY);
      canvas.rotate(rotation);

      // Draw crystalline petal shape
      _drawCrystallinePetal(canvas, paint, petalSize);

      canvas.restore();
    }
  }

  void _drawCrystallinePetal(Canvas canvas, Paint paint, double size) {
    final path = Path();

    // Create a geometric crystal petal
    path.moveTo(0, -size);
    path.quadraticBezierTo(size * 0.7, -size * 0.5, size * 0.5, 0);
    path.quadraticBezierTo(size * 0.3, size * 0.8, 0, size);
    path.quadraticBezierTo(-size * 0.3, size * 0.8, -size * 0.5, 0);
    path.quadraticBezierTo(-size * 0.7, -size * 0.5, 0, -size);
    path.close();

    canvas.drawPath(path, paint);

    // Add crystal facet lines
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.5;
    paint.color = paint.color.withOpacity(paint.color.opacity * 0.4);

    canvas.drawLine(Offset(0, -size), Offset(0, size), paint);
    canvas.drawLine(Offset(-size * 0.3, -size * 0.3), Offset(size * 0.3, size * 0.3), paint);

    paint.style = PaintingStyle.fill;
  }

  void _paintRoseQuartzHearts(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _heartCount; i++) {
      final heartX = size.width * (0.2 + i * 0.15);
      final heartY = size.height * (0.2 + _wave(0.06, i.toDouble()) * 0.3);

      final heartSize = (18 + i * 3) * intensity;
      final glow = 0.7 + 0.3 * _norm(0.18, i * 0.6);
      final currentSize = heartSize * glow;

      // Heart color with warm glow
      final heartOpacity = (0.12 + _norm(0.15, i * 0.5) * 0.06) * intensity;
      paint.color = Color.lerp(primaryColor, accentColor, 0.3)!.withOpacity(heartOpacity);

      // Draw rose quartz heart
      _drawCrystalHeart(canvas, paint, Offset(heartX, heartY), currentSize);

      // Inner glow
      paint.color = _pearlWhite.withOpacity(0.08 * glow * intensity);
      _drawCrystalHeart(canvas, paint, Offset(heartX, heartY), currentSize * 0.6);
    }
  }

  void _drawCrystalHeart(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();

    // Create a geometric crystal heart shape
    final halfSize = size * 0.5;

    path.moveTo(center.dx, center.dy + halfSize);
    path.cubicTo(
      center.dx - size,
      center.dy - halfSize * 0.5,
      center.dx - halfSize,
      center.dy - size,
      center.dx,
      center.dy - halfSize * 0.3,
    );
    path.cubicTo(
      center.dx + halfSize,
      center.dy - size,
      center.dx + size,
      center.dy - halfSize * 0.5,
      center.dx,
      center.dy + halfSize,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _paintCrystalSparkles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(456);

    for (int i = 0; i < _sparkleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Twinkling crystal sparkles
      final twinklePhase = _norm(0.3, i * 0.12);
      final twinkleThreshold = 0.75;

      if (twinklePhase > twinkleThreshold) {
        final sparkleIntensity = (twinklePhase - twinkleThreshold) / (1.0 - twinkleThreshold);
        final sparkleSize = (1.5 + sparkleIntensity * 3) * intensity;

        final sparkleColors = [_pearlWhite, primaryColor, _softRose, _blushPink];
        final sparkleColor = sparkleColors[i % sparkleColors.length];

        paint.color = sparkleColor.withOpacity(0.6 * sparkleIntensity * intensity);
        canvas.drawCircle(Offset(x, y), sparkleSize, paint);

        // Cross-shaped sparkle effect
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1 * intensity;
        paint.color = sparkleColor.withOpacity(0.8 * sparkleIntensity * intensity);

        final crossSize = sparkleSize * 2;
        canvas.drawLine(
          Offset(x - crossSize, y),
          Offset(x + crossSize, y),
          paint,
        );
        canvas.drawLine(
          Offset(x, y - crossSize),
          Offset(x, y + crossSize),
          paint,
        );

        paint.style = PaintingStyle.fill;
      }
    }
  }

  void _paintEnergyFlows(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Gentle energy flows connecting crystals
    for (int i = 0; i < 4; i++) {
      final startX = size.width * (0.1 + i * 0.25);
      final startY = size.height * (0.3 + _wave(0.08, i.toDouble()) * 0.2);

      final path = Path();
      path.moveTo(startX, startY);

      // Create flowing energy paths
      for (int j = 1; j <= 6; j++) {
        final progress = j / 6.0;
        final x = startX + progress * 100 * intensity + _wave(0.12, progress * 2 + i) * 25 * intensity;
        final y = startY + _wave(0.1, progress * 1.5 + i * 0.7) * 20 * intensity;

        if (j == 1) {
          path.quadraticBezierTo(startX + 15 * intensity, startY + 8 * intensity, x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final energyColors = [primaryColor, _softRose, _blushPink, _pearlWhite];
      final energyIntensity = _norm(0.2, i * 0.8);

      paint
        ..strokeWidth = (1.2 + i * 0.3) * intensity
        ..color = energyColors[i].withOpacity(0.06 * energyIntensity * intensity);

      canvas.drawPath(path, paint);
    }
  }

  void _paintSoftGlow(Canvas canvas, Size size) {
    // Final soft atmospheric glow
    final rect = Offset.zero & size;

    // Gentle rose garden ambiance
    final gardenGlow = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.6, size.height * 0.4),
        size.width * 0.7,
        [
          primaryColor.withOpacity(0.03 * intensity),
          _softRose.withOpacity(0.02 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(rect, gardenGlow);

    // Warm morning light
    final warmLight = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.8, 0),
        Offset(size.width * 0.2, size.height),
        [
          _pearlWhite.withOpacity(0.04 * intensity),
          Colors.transparent,
          _blushPink.withOpacity(0.02 * intensity),
        ],
        [0.0, 0.6, 1.0],
      );

    canvas.drawRect(rect, warmLight);
  }

  @override
  bool shouldRepaint(covariant _RoseQuartzGardenPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
