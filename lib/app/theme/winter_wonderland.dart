import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildWinterWonderlandTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.winterWonderland,
    isDark: false,
    // Primary colors - soft winter blue
    primaryColor: const Color(0xFF7FB8E5), // Soft winter sky blue
    primaryVariant: const Color(0xFF5A9BD4), // Deeper winter blue
    onPrimary: Colors.white,
    // Secondary colors - warm winter accent
    accentColor: const Color(0xFF8EC5E8), // Light blue accent
    onAccent: const Color(0xFF2C3E50), // Dark blue-gray for contrast
    // Background colors - gentle winter whites
    background: const Color(0xFFFAFCFF), // Very soft blue-white
    surface: const Color(0xFFFFFFFF), // Pure white like fresh snow
    surfaceVariant: const Color(0xFFF0F6FC), // Light blue-gray
    // Text colors - warm and readable against snow
    textPrimary: const Color(0xFF2C3E50), // Dark blue-gray
    textSecondary: const Color(0xFF546E7A), // Medium blue-gray
    textDisabled: const Color(0xFF90A4AE), // Light blue-gray
    // UI colors
    divider: const Color(0xFFE1EAF0), // Very light blue-gray
    toolbarColor: const Color(0xFFF0F6FC),
    error: const Color(0xFFE74C3C), // Warm red for contrast
    success: const Color(0xFF27AE60), // Fresh green
    warning: const Color(0xFFF39C12), // Warm orange
    // Grid colors
    gridLine: const Color(0xFFE1EAF0),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFF7FB8E5), // Match primary
    selectionFill: const Color(0x307FB8E5),
    // Icon colors
    activeIcon: const Color(0xFF7FB8E5), // Winter blue for active
    inactiveIcon: const Color(0xFF546E7A), // Medium gray for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF2C3E50),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF2C3E50),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF2C3E50),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF546E7A),
      ),
    ),
    primaryFontWeight: FontWeight.w500, // Clean, readable weight
  );
}

// Winter Wonderland theme background with falling snow and cozy winter atmosphere
class WinterWonderlandBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const WinterWonderlandBackground({
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

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/winter_background.webp',
            fit: BoxFit.cover,
            colorBlendMode: BlendMode.darken,
          ),
        ),
        RepaintBoundary(
          child: CustomPaint(
            painter: _WinterSnowPainter(
              t: t,
              primaryColor: theme.primaryColor,
              accentColor: theme.accentColor,
              intensity: intensity.clamp(0.3, 1.8),
            ),
            size: Size.infinite,
            isComplex: true,
            willChange: enableAnimation,
          ),
        ),
      ],
    );
  }
}

class _WinterSnowPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _WinterSnowPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);

  // Winter color palette
  late final Color _snowWhite = const Color(0xFFFFFFFD);

  // Element counts based on intensity
  int get _snowflakeCount => (60 * intensity).round().clamp(30, 90);

  @override
  void paint(Canvas canvas, Size size) {
    _paintFallingSnow(canvas, size);
  }

  void _paintFallingSnow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent snow

    for (int i = 0; i < _snowflakeCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Snowflake falling motion with gentle wind
      final fallSpeed = 0.8 + (i % 3) * 0.3;
      final progress = (t * fallSpeed + i * 0.01) % 1.2;
      final snowY = progress * (size.height + 40) - 20;

      if (snowY < -10 || snowY > size.height + 10) continue;

      // Gentle swaying motion
      final windSway = _wave(0.3, i * 0.1) * 15 * intensity;
      final microSway = _wave(1.2, i * 0.05) * 3 * intensity;
      final snowX = baseX + windSway + microSway;

      // Snowflake size and opacity
      final snowflakeSize = (1.5 + random.nextDouble() * 4) * intensity;
      final fadeIn = math.min(1.0, (snowY + 20) / 40);
      final fadeOut = math.min(1.0, (size.height + 20 - snowY) / 40);
      final opacity = (fadeIn * fadeOut * 0.8) * intensity;

      if (opacity <= 0.01) continue;

      // Different snowflake types
      final snowflakeType = i % 4;
      paint.color = _snowWhite.withOpacity(opacity);

      switch (snowflakeType) {
        case 0: // Simple dot
          canvas.drawCircle(Offset(snowX, snowY), snowflakeSize, paint);
          break;
        case 1: // Slightly larger soft flake
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
          canvas.drawCircle(Offset(snowX, snowY), snowflakeSize * 1.3, paint);
          paint.maskFilter = null;
          break;
        case 2: // Star-shaped snowflake
          _drawSnowflakeStar(canvas, paint, Offset(snowX, snowY), snowflakeSize);
          break;
        case 3: // Clustered snowflake
          canvas.drawCircle(Offset(snowX, snowY), snowflakeSize * 0.8, paint);
          canvas.drawCircle(Offset(snowX - 1, snowY - 1), snowflakeSize * 0.4, paint);
          canvas.drawCircle(Offset(snowX + 1, snowY + 1), snowflakeSize * 0.4, paint);
          break;
      }
    }
  }

  void _drawSnowflakeStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;

      if (i == 0) {
        path.moveTo(center.dx, center.dy);
        path.lineTo(x, y);
      } else {
        path.moveTo(center.dx, center.dy);
        path.lineTo(x, y);
      }
    }

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }

  @override
  bool shouldRepaint(covariant _WinterSnowPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
