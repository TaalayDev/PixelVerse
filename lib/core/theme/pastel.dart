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

// Enhanced Pastel theme background with layered soft elements
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
        painter: _EnhancedPastelPainter(
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

class _EnhancedPastelPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _EnhancedPastelPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Extended pastel palette
  late final Color _softMint = const Color(0xFFB8E6B8); // Soft mint green
  late final Color _softPeach = const Color(0xFFFFDAB9); // Soft peach
  late final Color _softYellow = const Color(0xFFFFF8DC); // Cream yellow
  late final Color _softBlue = const Color(0xFFE6F3FF); // Powder blue
  late final Color _softCoral = const Color(0xFFFFE4E1); // Misty rose

  // Element counts based on intensity
  int get _cloudCount => (6 * intensity).round().clamp(3, 9);
  int get _bubbleCount => (25 * intensity).round().clamp(12, 40);
  int get _particleCount => (40 * intensity).round().clamp(20, 60);
  int get _waveCount => (4 * intensity).round().clamp(2, 6);

  @override
  void paint(Canvas canvas, Size size) {
    _paintSkyGradient(canvas, size);
    _paintSoftClouds(canvas, size);
    _paintGentleWaves(canvas, size);
    _paintFloatingBubbles(canvas, size);
    _paintSparklingParticles(canvas, size);
    _paintDreamyWisps(canvas, size);
    _paintSoftVignette(canvas, size);
  }

  void _paintSkyGradient(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final skyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          _softBlue.withOpacity(0.3),
          _softYellow.withOpacity(0.2),
          _softPeach.withOpacity(0.25),
          _softMint.withOpacity(0.2),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, skyGradient);
  }

  void _paintSoftClouds(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(789);

    for (int i = 0; i < _cloudCount; i++) {
      final baseX = size.width * (0.1 + i * 0.15);
      final baseY = size.height * (0.15 + (i % 3) * 0.25);

      // Gentle drift motion
      final driftX = baseX + _wave(0.08, i.toDouble()) * 25 * intensity;
      final driftY = baseY + _wave(0.12, i * 0.7) * 15 * intensity;

      final cloudSize = (35 + i * 8 + _wave(0.15, i * 0.5) * 12) * intensity;
      final breathe = 0.85 + 0.15 * _norm(0.2, i * 0.3);
      final currentSize = cloudSize * breathe;

      // Cloud color with slight variation
      final cloudHue = [_softPeach, primaryColor, accentColor, _softMint, _softBlue][i % 5];
      final opacity = (0.03 + _norm(0.1, i * 0.4) * 0.02) * intensity;

      paint.color = cloudHue.withOpacity(opacity);

      // Main cloud body with multiple overlapping circles for organic shape
      _drawCloudShape(canvas, paint, Offset(driftX, driftY), currentSize);
    }
  }

  void _drawCloudShape(Canvas canvas, Paint paint, Offset center, double size) {
    // Main cloud circle
    canvas.drawCircle(center, size, paint);

    // Additional puffs for natural cloud shape
    final offsets = [
      Offset(-size * 0.4, -size * 0.2),
      Offset(size * 0.3, -size * 0.3),
      Offset(size * 0.1, size * 0.4),
      Offset(-size * 0.2, size * 0.3),
    ];

    final sizes = [size * 0.7, size * 0.6, size * 0.65, size * 0.5];

    for (int i = 0; i < offsets.length; i++) {
      canvas.drawCircle(center + offsets[i], sizes[i], paint);
    }
  }

  void _paintGentleWaves(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < _waveCount; i++) {
      final baseY = size.height * (0.6 + i * 0.08);
      final waveHeight = (8 + i * 3) * intensity;
      final strokeWidth = (1.5 + i * 0.5) * intensity;

      final path = Path();
      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 8) {
        final primaryWave = _wave(0.08, x * 0.01 + i * 0.3) * waveHeight;
        final secondaryWave = _wave(0.12, x * 0.015 + i * 0.5) * waveHeight * 0.5;
        final y = baseY + primaryWave + secondaryWave;
        path.lineTo(x, y);
      }

      final waveColor = [primaryColor, accentColor, _softMint, _softCoral][i % 4];
      final waveIntensity = _norm(0.25, i * 0.6);

      paint
        ..strokeWidth = strokeWidth
        ..color = waveColor.withOpacity(0.06 * waveIntensity * intensity);

      canvas.drawPath(path, paint);
    }
  }

  void _paintFloatingBubbles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(456);

    for (int i = 0; i < _bubbleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion with different speeds
      final floatSpeed = 0.05 + (i % 3) * 0.03;
      final floatX = baseX + _wave(floatSpeed, i * 0.2) * 18 * intensity;
      final floatY = baseY + _wave(floatSpeed * 0.7, i * 0.4) * 12 * intensity;

      final bubbleSize = (4 + random.nextDouble() * 16) * intensity;
      final pulseSize = bubbleSize * (0.9 + 0.1 * _norm(0.3, i * 0.1));

      // Color cycling through pastel palette
      final colors = [primaryColor, accentColor, _softMint, _softPeach, _softBlue, _softCoral];
      final bubbleColor = colors[i % colors.length];
      final opacity = (0.02 + _norm(0.2, i * 0.3) * 0.01) * intensity;

      paint.color = bubbleColor.withOpacity(opacity);
      canvas.drawCircle(Offset(floatX, floatY), pulseSize, paint);

      // Inner highlight for dimension
      if (bubbleSize > 8) {
        paint.color = Colors.white.withOpacity(opacity * 0.6);
        canvas.drawCircle(Offset(floatX - pulseSize * 0.3, floatY - pulseSize * 0.3), pulseSize * 0.2, paint);
      }
    }
  }

  void _paintSparklingParticles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    for (int i = 0; i < _particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Twinkling effect with varying phases
      final twinklePhase = _norm(0.4, i * 0.15);
      final twinkleThreshold = 0.7;

      if (twinklePhase > twinkleThreshold) {
        final sparkleIntensity = (twinklePhase - twinkleThreshold) / (1.0 - twinkleThreshold);
        final particleSize = (0.8 + sparkleIntensity * 2.5) * intensity;

        final colors = [Colors.white, primaryColor, accentColor, _softYellow];
        final sparkleColor = colors[i % colors.length];

        paint.color = sparkleColor.withOpacity(0.3 * sparkleIntensity * intensity);
        canvas.drawCircle(Offset(x, y), particleSize, paint);

        // Soft glow around sparkle
        paint.color = sparkleColor.withOpacity(0.1 * sparkleIntensity * intensity);
        canvas.drawCircle(Offset(x, y), particleSize * 2.5, paint);
      }
    }
  }

  void _paintDreamyWisps(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 4; i++) {
      final startX = size.width * (0.1 + i * 0.25);
      final startY = size.height * (0.2 + _wave(0.1, i.toDouble()) * 0.15);

      final path = Path();
      path.moveTo(startX, startY);

      // Create flowing, organic wisp paths
      for (int j = 1; j <= 8; j++) {
        final progress = j / 8.0;
        final x = startX + progress * 120 * intensity + _wave(0.15, progress * 3 + i) * 30 * intensity;
        final y = startY + _wave(0.12, progress * 2.5 + i * 0.7) * 40 * intensity;

        if (j == 1) {
          path.quadraticBezierTo(startX + 20 * intensity, startY + 10 * intensity, x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final wispColors = [primaryColor, accentColor, _softMint, _softCoral];
      final wispIntensity = _norm(0.18, i * 0.8);

      paint
        ..strokeWidth = (1.5 + i * 0.3) * intensity
        ..color = wispColors[i].withOpacity(0.04 * wispIntensity * intensity);

      canvas.drawPath(path, paint);
    }
  }

  void _paintSoftVignette(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);
    final radius = size.longestSide * 0.9;

    final vignette = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          primaryColor.withOpacity(0.02 * intensity),
          accentColor.withOpacity(0.015 * intensity),
        ],
        stops: const [0.7, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _EnhancedPastelPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
