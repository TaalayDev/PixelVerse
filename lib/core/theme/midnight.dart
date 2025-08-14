import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildMidnightTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.midnight,
    isDark: true,
    primaryColor: const Color(0xFF6A3DE8),
    primaryVariant: const Color(0xFF8056EA),
    onPrimary: Colors.white,
    accentColor: const Color(0xFF03DAC6),
    onAccent: Colors.black,
    background: const Color(0xFF0A1021),
    surface: const Color(0xFF162041),
    surfaceVariant: const Color(0xFF1D2A59),
    textPrimary: Colors.white,
    textSecondary: const Color(0xFFB8C7E0),
    textDisabled: const Color(0xFF6987B7),
    divider: const Color(0xFF2B3966),
    toolbarColor: const Color(0xFF162041),
    error: const Color(0xFFF45E89),
    success: const Color(0xFF4ADE80),
    warning: const Color(0xFFF9AE59),
    gridLine: const Color(0xFF2B3966),
    gridBackground: const Color(0xFF1D2A59),
    canvasBackground: const Color(0xFF0A1021),
    selectionOutline: const Color(0xFF03DAC6),
    selectionFill: const Color(0x3003DAC6),
    activeIcon: const Color(0xFF6A3DE8),
    inactiveIcon: const Color(0xFFB8C7E0),
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: Colors.white,
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFB8C7E0),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Enhanced Midnight theme background with aurora, stars, and atmospheric effects
class MidnightBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const MidnightBackground({
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
        painter: _EnhancedMidnightPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 1.8),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class _EnhancedMidnightPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _EnhancedMidnightPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Midnight color palette
  late final Color _deepPurple = const Color(0xFF4A148C);
  late final Color _mysticalBlue = const Color(0xFF1A237E);
  late final Color _starWhite = const Color(0xFFF8F8FF);
  late final Color _moonSilver = const Color(0xFFE8E8E8);
  late final Color _auroraGreen = const Color(0xFF00E676);
  late final Color _auroraViolet = const Color(0xFF7C4DFF);

  // Element counts based on intensity
  int get _starCount => (80 * intensity).round().clamp(40, 120);
  int get _auroraLayers => (6 * intensity).round().clamp(3, 9);

  @override
  void paint(Canvas canvas, Size size) {
    _paintNightSky(canvas, size);
    _paintDistantMountains(canvas, size);
    _paintStarField(canvas, size);
    _paintMoon(canvas, size);
  }

  void _paintNightSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Create deep night sky gradient
    final skyGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF0A0A1A), // Deep space black
          const Color(0xFF1A1A2E), // Dark midnight blue
          _mysticalBlue.withOpacity(0.8),
          _deepPurple.withOpacity(0.4),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, skyGradient);

    // Add subtle stellar nebula effect
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topRight,
        radius: 1.5,
        colors: [
          primaryColor.withOpacity(0.05 * intensity),
          Colors.transparent,
          accentColor.withOpacity(0.03 * intensity),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, nebulaPaint);
  }

  void _paintDistantMountains(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create layered mountain silhouettes
    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final mountainHeight = size.height * (0.2 + layer * 0.05);
      final baseY = size.height - mountainHeight;

      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      // Create mountain peaks
      for (int i = 0; i <= 8; i++) {
        final x = (i / 8) * size.width;
        final peakVariation = _wave(0.1, i * 0.8 + layer) * 30 * intensity;
        final y = baseY + peakVariation;

        if (i == 0) {
          path.lineTo(x, y);
        } else {
          // Create jagged mountain outline
          final prevX = ((i - 1) / 8) * size.width;
          final midX = (prevX + x) / 2;
          final midY = y + (math.sin(i * 2 + layer) * 15 * intensity);

          path.quadraticBezierTo(midX, midY, x, y);
        }
      }

      path.lineTo(size.width, size.height);
      path.close();

      // Mountain color gets lighter for distant layers
      final mountainOpacity = (0.6 - layer * 0.15) * intensity;
      paint.color = Color.lerp(
        const Color(0xFF0D1B2A),
        _mysticalBlue,
        layer / 2.0,
      )!
          .withOpacity(mountainOpacity);

      canvas.drawPath(path, paint);
    }
  }

  void _paintStarField(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent star positions

    for (int i = 0; i < _starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.7; // Keep stars in upper area

      // Star twinkling with different phases
      final twinklePhase = _norm(0.5, 0.12);
      final twinkleThreshold = 0.1;

      if (twinklePhase > twinkleThreshold) {
        final starIntensity = (twinklePhase - twinkleThreshold) / (1.0 - twinkleThreshold);
        final starSize = (0.5 + starIntensity * 2.5) * intensity;

        // Different star colors and brightness
        Color starColor;
        final starType = random.nextDouble();
        if (starType < 0.7) {
          starColor = _starWhite; // Most stars are white
        } else if (starType < 0.85) {
          starColor = Color.lerp(_starWhite, primaryColor, 0.3)!; // Slightly purple
        } else {
          starColor = Color.lerp(_starWhite, accentColor, 0.2)!; // Slightly cyan
        }

        paint.color = starColor.withOpacity(0.8 * starIntensity * intensity);
        canvas.drawCircle(Offset(x, y), starSize, paint);

        // Bright stars get a cross-shaped twinkle
        if (starIntensity > 0.8 && starSize > 1.5) {
          paint.strokeWidth = 0.5 * intensity;
          paint.style = PaintingStyle.stroke;

          final crossSize = starSize * 2;
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
  }

  void _paintMoon(Canvas canvas, Size size) {
    final moonCenter = Offset(size.width * 0.85, size.height * 0.2);
    final moonRadius = 25 * intensity;
    final moonPhase = _norm(0.05); // Very slow moon phase cycle

    final moonPaint = Paint()..style = PaintingStyle.fill;

    // Moon glow
    moonPaint
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..color = _moonSilver.withOpacity(0.3 * intensity);
    canvas.drawCircle(moonCenter, moonRadius * 2, moonPaint);

    // Moon body
    moonPaint
      ..maskFilter = null
      ..color = _moonSilver.withOpacity(0.9 * intensity);
    canvas.drawCircle(moonCenter, moonRadius, moonPaint);

    // Moon craters (subtle dark spots)
    moonPaint.color = const Color(0xFF888888).withOpacity(0.3 * intensity);
    canvas.drawCircle(
      moonCenter + Offset(-moonRadius * 0.3, moonRadius * 0.2),
      moonRadius * 0.15,
      moonPaint,
    );
    canvas.drawCircle(
      moonCenter + Offset(moonRadius * 0.2, -moonRadius * 0.4),
      moonRadius * 0.1,
      moonPaint,
    );

    // Moon phase shadow
    if (moonPhase < 0.8) {
      final shadowPath = Path();
      final shadowOffset = (moonPhase - 0.5) * moonRadius * 2;

      shadowPath.addOval(Rect.fromCircle(
        center: moonCenter + Offset(shadowOffset, 0),
        radius: moonRadius,
      ));

      moonPaint.color = const Color(0xFF000000).withOpacity(0.6 * intensity);
      canvas.drawPath(shadowPath, moonPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EnhancedMidnightPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
