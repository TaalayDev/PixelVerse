import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildPurpleRainTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.purpleRain,
    isDark: true,
    // Primary colors - deep royal purple
    primaryColor: const Color(0xFF6A0DAD), // Deep royal purple
    primaryVariant: const Color(0xFF4B0082), // Indigo
    onPrimary: Colors.white,
    // Secondary colors - bright violet
    accentColor: const Color(0xFF9932CC), // Dark orchid
    onAccent: Colors.white,
    // Background colors - dark with purple undertones
    background: const Color(0xFF1A0B2E), // Very dark purple
    surface: const Color(0xFF2D1B4E), // Dark purple surface
    surfaceVariant: const Color(0xFF3D2B5E), // Lighter purple variant
    // Text colors - light with purple tints
    textPrimary: const Color(0xFFE6E0FF), // Light lavender
    textSecondary: const Color(0xFFB8A9DB), // Muted lavender
    textDisabled: const Color(0xFF7D6B9B), // Darker muted purple
    // UI colors
    divider: const Color(0xFF4A3B6B),
    toolbarColor: const Color(0xFF2D1B4E),
    error: const Color(0xFFFF6B9D), // Pink-purple error
    success: const Color(0xFF8A2BE2), // Blue violet success
    warning: const Color(0xFFDA70D6), // Orchid warning
    // Grid colors
    gridLine: const Color(0xFF4A3B6B),
    gridBackground: const Color(0xFF2D1B4E),
    // Canvas colors
    canvasBackground: const Color(0xFF1A0B2E),
    selectionOutline: const Color(0xFF9932CC), // Bright violet selection
    selectionFill: const Color(0x309932CC),
    // Icon colors
    activeIcon: const Color(0xFF9932CC), // Bright violet for active
    inactiveIcon: const Color(0xFFB8A9DB), // Muted for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFE6E0FF),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFE6E0FF),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFE6E0FF),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFB8A9DB),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Purple Rain theme background with rain effects
class PurpleRainBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const PurpleRainBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final rainAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _PurpleRainPainter(
        animation: rainAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _PurpleRainPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _PurpleRainPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final random = math.Random(999); // Fixed seed for consistent rain

    // Draw rain drops
    final rainDropCount = (60 * intensity).round();
    for (int i = 0; i < rainDropCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.5 + random.nextDouble() * 0.8; // Varying speeds
      final length = (15 + random.nextDouble() * 25) * intensity;

      // Calculate rain drop position with wrapping
      final progress = (animation * speed + i * 0.1) % 1.0;
      final y = progress * (size.height + length * 2) - length;
      final x = baseX + math.sin(progress * 2 * math.pi) * 10 * intensity; // Slight sway

      // Only draw if visible
      if (y > -length && y < size.height + length) {
        final opacity = (0.15 + math.sin(animation * 4 * math.pi + i * 0.3) * 0.05) * intensity;

        paint.color = Color.lerp(
          primaryColor.withOpacity(opacity),
          accentColor.withOpacity(opacity * 0.8),
          (i % 3) / 2.0,
        )!;

        paint.strokeWidth = (1.5 + random.nextDouble() * 1) * intensity;

        canvas.drawLine(
          Offset(x, y),
          Offset(x + 2 * intensity, y + length),
          paint,
        );
      }
    }

    // Draw atmospheric mist
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final mistX = size.width * (i / 7.0);
      final mistY = size.height * (0.6 + math.sin(animation * 2 * math.pi + i * 0.5) * 0.2);
      final mistSize = (25 + i * 5 + math.cos(animation * 3 * math.pi + i) * 8) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.02),
        accentColor.withOpacity(0.015),
        math.sin(animation * math.pi + i) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(Offset(mistX, mistY), mistSize, paint);
    }

    // Draw purple glow effects
    final glowCount = (6 * intensity).round();
    for (int i = 0; i < glowCount; i++) {
      final glowX = random.nextDouble() * size.width;
      final glowY = random.nextDouble() * size.height;
      final glowIntensity = math.sin(animation * 3 * math.pi + i * 0.8) * 0.5 + 0.5;

      if (glowIntensity > 0.6) {
        final glowRadius = (15 + glowIntensity * 20) * intensity;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.08),
          accentColor.withOpacity(0.06),
          glowIntensity,
        )!;

        canvas.drawCircle(Offset(glowX, glowY), glowRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
