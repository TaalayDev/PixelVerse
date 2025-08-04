import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildGoldenHourTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.goldenHour,
    isDark: false,
    // Primary colors - warm golden amber
    primaryColor: const Color(0xFFD4A574), // Warm golden amber
    primaryVariant: const Color(0xFFB8956A), // Deeper golden
    onPrimary: const Color(0xFF3D2914), // Dark brown for contrast
    // Secondary colors - coral orange
    accentColor: const Color(0xFFED8A63), // Warm coral
    onAccent: Colors.white,
    // Background colors - warm cream tones
    background: const Color(0xFFFDF6E3), // Warm cream
    surface: const Color(0xFFFEFCF6), // Warmer white
    surfaceVariant: const Color(0xFFF4EDD8), // Light golden beige
    // Text colors - warm browns
    textPrimary: const Color(0xFF3D2914), // Dark warm brown
    textSecondary: const Color(0xFF6B4E37), // Medium brown
    textDisabled: const Color(0xFFA08B7A), // Light brown
    // UI colors
    divider: const Color(0xFFE6D3B7), // Light golden
    toolbarColor: const Color(0xFFF4EDD8),
    error: const Color(0xFFD2691E), // Chocolate orange
    success: const Color(0xFF8FBC8F), // Dark sea green
    warning: const Color(0xFFDDAA00), // Dark golden rod
    // Grid colors
    gridLine: const Color(0xFFE6D3B7),
    gridBackground: const Color(0xFFFEFCF6),
    // Canvas colors
    canvasBackground: const Color(0xFFFEFCF6),
    selectionOutline: const Color(0xFFD4A574), // Match primary
    selectionFill: const Color(0x30D4A574),
    // Icon colors
    activeIcon: const Color(0xFFD4A574), // Golden for active
    inactiveIcon: const Color(0xFF6B4E37), // Brown for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF3D2914),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF3D2914),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF3D2914),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF6B4E37),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Golden Hour theme background with warm sunlight effects
class GoldenHourBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const GoldenHourBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final sunAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _GoldenHourPainter(
        animation: sunAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _GoldenHourPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _GoldenHourPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(333); // Fixed seed for consistent effects

    // Draw sun rays emanating from top-right corner
    final sunPosition = Offset(size.width * 0.85, size.height * 0.15);
    final rayCount = (24 * intensity).round();

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * math.pi + math.pi * 0.5; // Only bottom half rays
      final rayLength = (size.width * 0.7 + math.sin(animation * 2 * math.pi + i * 0.3) * 50) * intensity;
      final rayWidth = (3 + math.sin(animation * 3 * math.pi + i * 0.5) * 2) * intensity;

      final endX = sunPosition.dx + math.cos(angle) * rayLength;
      final endY = sunPosition.dy + math.sin(angle) * rayLength;

      // Create gradient ray
      paint.shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.8,
        colors: [
          primaryColor.withOpacity(0.08 * intensity),
          primaryColor.withOpacity(0.02 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sunPosition.dx - 50, sunPosition.dy - 50, 100, 100));

      paint.strokeWidth = rayWidth;
      paint.style = PaintingStyle.stroke;

      canvas.drawLine(sunPosition, Offset(endX, endY), paint);
    }

    // Draw floating dust particles/light motes
    paint.shader = null;
    paint.style = PaintingStyle.fill;

    for (int i = 0; i < (25 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion
      final floatX = baseX + math.sin(animation * 2 * math.pi + i * 0.4) * 20 * intensity;
      final floatY = baseY + math.cos(animation * 1.5 * math.pi + i * 0.6) * 15 * intensity;

      final particleSize = (1.5 + random.nextDouble() * 3) * intensity;
      final opacity = (0.1 + math.sin(animation * 4 * math.pi + i * 0.8) * 0.05) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(opacity),
        accentColor.withOpacity(opacity * 0.8),
        math.sin(animation * math.pi + i) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(Offset(floatX, floatY), particleSize, paint);
    }

    // Draw warm glow clouds
    for (int i = 0; i < 6; i++) {
      final cloudX = size.width * (0.1 + i * 0.15);
      final cloudY = size.height * (0.3 + math.sin(animation * math.pi + i * 0.7) * 0.2);
      final cloudSize = (35 + i * 8 + math.sin(animation * 2 * math.pi + i) * 12) * intensity;

      final glowIntensity = 0.02 + math.cos(animation * 1.5 * math.pi + i * 0.5) * 0.01;

      // Multiple overlapping circles for cloud effect
      paint.color = primaryColor.withOpacity(glowIntensity * intensity);
      canvas.drawCircle(Offset(cloudX, cloudY), cloudSize, paint);

      paint.color = accentColor.withOpacity(glowIntensity * 0.6 * intensity);
      canvas.drawCircle(Offset(cloudX - cloudSize * 0.3, cloudY + cloudSize * 0.2), cloudSize * 0.8, paint);
      canvas.drawCircle(Offset(cloudX + cloudSize * 0.4, cloudY - cloudSize * 0.1), cloudSize * 0.6, paint);
    }

    // Draw warm atmospheric haze
    final hazeCount = (8 * intensity).round();
    for (int i = 0; i < hazeCount; i++) {
      final hazeX = size.width * (i / (hazeCount - 1));
      final hazeY = size.height * (0.7 + math.sin(animation * 1.5 * math.pi + i) * 0.1);
      final hazeWidth = (60 + i * 10) * intensity;
      final hazeHeight = (20 + math.sin(animation * 2 * math.pi + i * 0.3) * 8) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.015),
        accentColor.withOpacity(0.01),
        i / (hazeCount - 1),
      )!;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(hazeX, hazeY),
          width: hazeWidth,
          height: hazeHeight,
        ),
        paint,
      );
    }

    // Draw golden sparkles
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final sparkleX = random.nextDouble() * size.width;
      final sparkleY = random.nextDouble() * size.height;
      final sparkleIntensity = math.sin(animation * 6 * math.pi + i * 0.4) * 0.5 + 0.5;

      if (sparkleIntensity > 0.8) {
        final sparkleSize = (4 + sparkleIntensity * 3) * intensity;
        paint.color = Colors.amber.withOpacity(0.2 * sparkleIntensity * intensity);

        // Draw cross-shaped sparkle
        canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleSize, paint);

        paint.strokeWidth = 1 * intensity;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(sparkleX - sparkleSize * 2, sparkleY),
          Offset(sparkleX + sparkleSize * 2, sparkleY),
          paint,
        );
        canvas.drawLine(
          Offset(sparkleX, sparkleY - sparkleSize * 2),
          Offset(sparkleX, sparkleY + sparkleSize * 2),
          paint,
        );

        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
