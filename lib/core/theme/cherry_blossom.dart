import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildCherryBlossomTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.cherryBlossom,
    isDark: false,
    // Primary colors - soft sakura pink
    primaryColor: const Color(0xFFFFB7C5), // Soft sakura pink
    primaryVariant: const Color(0xFFFF91A4), // Slightly deeper pink
    onPrimary: const Color(0xFF5D2C2F), // Dark rose for contrast
    // Secondary colors - fresh spring green
    accentColor: const Color(0xFF98D8C8), // Soft mint green
    onAccent: const Color(0xFF2D5016), // Dark green for contrast
    // Background colors - very light and airy
    background: const Color(0xFFFDF8F9), // Very light pink-white
    surface: const Color(0xFFFFFFFF), // Pure white
    surfaceVariant: const Color(0xFFF7F0F2), // Light pink-gray
    // Text colors - soft but readable
    textPrimary: const Color(0xFF3E2723), // Dark brown with warmth
    textSecondary: const Color(0xFF795548), // Medium brown
    textDisabled: const Color(0xFFBCAAA4), // Light brown-pink
    // UI colors
    divider: const Color(0xFFE8DDDF), // Very light pink-gray
    toolbarColor: const Color(0xFFF7F0F2),
    error: const Color(0xFFD32F2F), // Traditional red
    success: const Color(0xFF4CAF50), // Fresh green
    warning: const Color(0xFFFF9800), // Warm orange
    // Grid colors
    gridLine: const Color(0xFFE8DDDF),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFFFFB7C5), // Match primary
    selectionFill: const Color(0x30FFB7C5),
    // Icon colors
    activeIcon: const Color(0xFFFFB7C5), // Sakura pink for active
    inactiveIcon: const Color(0xFF795548), // Brown for inactive
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
        color: const Color(0xFF795548),
      ),
    ),
    primaryFontWeight: FontWeight.w400, // Light weight for elegant feel
  );
}

// Cherry Blossom theme background with falling sakura petals
class CherryBlossomBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const CherryBlossomBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final petalAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _CherryBlossomPainter(
        animation: petalAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _CherryBlossomPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _CherryBlossomPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(555); // Fixed seed for consistent petals

    // Draw falling sakura petals
    final petalCount = (20 * intensity).round();
    for (int i = 0; i < petalCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.2 + random.nextDouble() * 0.3; // Slow falling

      // Calculate petal position with gentle swaying
      final progress = (animation * speed + i * 0.05) % 1.2;
      final y = progress * (size.height + 50) - 25;
      final sway = math.sin(progress * 4 * math.pi + i) * 15 * intensity;
      final x = baseX + sway;

      // Only draw if visible
      if (y > -25 && y < size.height + 25) {
        final opacity = math.max(0.0, (1.2 - progress) * 0.6) * intensity;
        final rotation = progress * 2 * math.pi + i;

        // Alternate between pink shades
        final petalColor = i % 3 == 0
            ? primaryColor.withOpacity(opacity)
            : Color.lerp(primaryColor, Colors.white, 0.3)!.withOpacity(opacity);

        paint.color = petalColor;

        // Draw petal shape (simple oval rotated)
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: (4 + random.nextDouble() * 3) * intensity,
            height: (6 + random.nextDouble() * 4) * intensity,
          ),
          paint,
        );

        canvas.restore();
      }
    }

    // Draw gentle floating blossom clusters
    for (int i = 0; i < (6 * intensity).round(); i++) {
      final clusterX = size.width * (0.1 + i * 0.15);
      final clusterY = size.height * (0.1 + math.sin(animation * math.pi + i * 0.8) * 0.2);
      final clusterSize = (15 + i * 3 + math.sin(animation * 2 * math.pi + i) * 5) * intensity;

      final opacity = (0.04 + math.cos(animation * 1.5 * math.pi + i * 0.6) * 0.02) * intensity;

      // Create soft blossom cluster
      paint.color = Color.lerp(
        primaryColor.withOpacity(opacity),
        accentColor.withOpacity(opacity * 0.7),
        math.sin(animation * math.pi + i) * 0.5 + 0.5,
      )!;

      // Main cluster
      canvas.drawCircle(Offset(clusterX, clusterY), clusterSize, paint);

      // Additional blossoms in cluster
      canvas.drawCircle(
        Offset(clusterX - clusterSize * 0.4, clusterY + clusterSize * 0.3),
        clusterSize * 0.6,
        paint,
      );
      canvas.drawCircle(
        Offset(clusterX + clusterSize * 0.3, clusterY - clusterSize * 0.2),
        clusterSize * 0.7,
        paint,
      );
    }

    // Draw soft pollen particles
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final pollenX = random.nextDouble() * size.width;
      final pollenY = random.nextDouble() * size.height;
      final drift = math.sin(animation * 1.5 * math.pi + i * 0.4) * 8 * intensity;

      final x = pollenX + drift;
      final y = pollenY + math.cos(animation * math.pi + i * 0.3) * 5 * intensity;

      final pollenIntensity = math.sin(animation * 3 * math.pi + i * 0.5) * 0.5 + 0.5;

      if (pollenIntensity > 0.6) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.2),
          accentColor.withOpacity(0.25),
          pollenIntensity,
        )!;

        canvas.drawCircle(Offset(x, y), 1 * intensity * pollenIntensity, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
