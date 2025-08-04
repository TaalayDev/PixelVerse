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

// Pastel theme background with soft floating elements
class PastelBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const PastelBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final floatAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _PastelPainter(
        animation: floatAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _PastelPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _PastelPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(789); // Fixed seed for consistent elements

    // Draw soft floating bubbles
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion
      final floatOffset = math.sin(animation * 2 * math.pi + i * 0.3) * 15 * intensity;
      final x = baseX + math.cos(animation * math.pi + i * 0.5) * 10 * intensity;
      final y = baseY + floatOffset;

      final radius = (8 + random.nextDouble() * 20) * intensity;
      final opacity = (0.02 + math.sin(animation * 2 * math.pi + i * 0.7) * 0.01) * intensity;

      // Alternate between primary and accent colors
      paint.color = (i % 2 == 0 ? primaryColor : accentColor).withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw soft gradient clouds
    for (int i = 0; i < 4; i++) {
      final centerX = size.width * (0.2 + i * 0.25);
      final centerY = size.height * (0.2 + math.sin(animation * math.pi + i) * 0.15);

      final cloudSize = (40 + i * 10 + math.sin(animation * 2 * math.pi + i) * 8) * intensity;
      final opacity = (0.01 + math.cos(animation * math.pi + i * 0.8) * 0.005) * intensity;

      // Create soft cloud-like shapes with multiple overlapping circles
      final cloudColor = Color.lerp(primaryColor, accentColor, i / 3.0)!;
      paint.color = cloudColor.withOpacity(opacity);

      // Main cloud circle
      canvas.drawCircle(Offset(centerX, centerY), cloudSize, paint);

      // Additional circles for cloud-like effect
      canvas.drawCircle(
        Offset(centerX - cloudSize * 0.3, centerY - cloudSize * 0.2),
        cloudSize * 0.7,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + cloudSize * 0.2, centerY - cloudSize * 0.3),
        cloudSize * 0.6,
        paint,
      );
    }

    // Draw gentle sparkles
    for (int i = 0; i < (20 * intensity).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparkleIntensity = math.sin(animation * 4 * math.pi + i * 0.2) * 0.5 + 0.5;

      if (sparkleIntensity > 0.7) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.3),
          accentColor.withOpacity(0.4),
          sparkleIntensity,
        )!;

        canvas.drawCircle(Offset(x, y), 1.5 * intensity * sparkleIntensity, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
