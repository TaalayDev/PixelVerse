import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildRetroWaveTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.retroWave,
    isDark: true,
    // Primary colors - hot pink/magenta
    primaryColor: const Color(0xFFFF0080), // Hot pink/magenta
    primaryVariant: const Color(0xFFE91E63), // Deep pink
    onPrimary: Colors.white,
    // Secondary colors - electric cyan/blue
    accentColor: const Color(0xFF00FFFF), // Electric cyan
    onAccent: Colors.black,
    // Background colors - dark with purple gradients
    background: const Color(0xFF0A0A1A), // Very dark blue-purple
    surface: const Color(0xFF1A1A2E), // Dark purple-blue
    surfaceVariant: const Color(0xFF16213E), // Darker blue
    // Text colors - bright neon
    textPrimary: const Color(0xFF00FFFF), // Bright cyan text
    textSecondary: const Color(0xFFFF0080), // Hot pink secondary text
    textDisabled: const Color(0xFF666B85), // Muted blue-gray
    // UI colors
    divider: const Color(0xFF2A2D47),
    toolbarColor: const Color(0xFF1A1A2E),
    error: const Color(0xFFFF073A), // Bright neon red
    success: const Color(0xFF39FF14), // Electric lime
    warning: const Color(0xFFFFFF00), // Electric yellow
    // Grid colors
    gridLine: const Color(0xFF2A2D47),
    gridBackground: const Color(0xFF1A1A2E),
    // Canvas colors
    canvasBackground: const Color(0xFF0A0A1A),
    selectionOutline: const Color(0xFFFF0080), // Hot pink selection
    selectionFill: const Color(0x30FF0080),
    // Icon colors
    activeIcon: const Color(0xFFFF0080), // Hot pink for active
    inactiveIcon: const Color(0xFF00FFFF), // Cyan for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF00FFFF),
        fontWeight: FontWeight.w700, // Bold for retro feel
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF00FFFF),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF00FFFF),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFFF0080),
      ),
    ),
    primaryFontWeight: FontWeight.w600, // Bold for 80s aesthetic
  );
}

// Retro Wave theme background with 80s synthwave effects
class RetroWaveBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const RetroWaveBackground({
    super.key,
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final synthAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _RetroWavePainter(
        animation: synthAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _RetroWavePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _RetroWavePainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw 80s perspective grid
    final gridSpacing = 40.0 * intensity;
    final horizonY = size.height * 0.6;
    final vanishingPointX = size.width * 0.5;

    // Horizontal grid lines (perspective)
    paint.strokeWidth = 1 * intensity;
    for (int i = 0; i < 8; i++) {
      final progress = i / 7.0;
      final y = horizonY + (size.height - horizonY) * progress * progress; // Perspective curve
      final pulseIntensity = (math.sin(animation * 4 * math.pi + i * 0.5) * 0.3 + 0.7) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.2 * pulseIntensity),
        accentColor.withOpacity(0.15 * pulseIntensity),
        math.sin(animation * 2 * math.pi + i * 0.3) * 0.5 + 0.5,
      )!;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical grid lines (perspective)
    for (int i = -10; i <= 10; i++) {
      if (i == 0) continue; // Skip center line

      final baseX = vanishingPointX + i * gridSpacing;
      final pulseOffset = math.sin(animation * 3 * math.pi + i * 0.2) * 5 * intensity;
      final x = baseX + pulseOffset;

      final pulseIntensity = (math.cos(animation * 4 * math.pi + i * 0.4) * 0.2 + 0.8) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.15 * pulseIntensity),
        accentColor.withOpacity(0.1 * pulseIntensity),
        i.abs() / 10.0,
      )!;

      canvas.drawLine(Offset(x, horizonY), Offset(x, size.height), paint);
    }

    // Draw neon scan lines
    paint.strokeWidth = 2 * intensity;
    final scanLine1Y = (animation * size.height) % size.height;
    final scanLine2Y = ((animation * 0.7 + 0.3) * size.height) % size.height;

    paint.color = primaryColor.withOpacity(0.6 * intensity);
    canvas.drawLine(Offset(0, scanLine1Y), Offset(size.width, scanLine1Y), paint);

    paint.color = accentColor.withOpacity(0.4 * intensity);
    canvas.drawLine(Offset(0, scanLine2Y), Offset(size.width, scanLine2Y), paint);

    // Draw pulsing geometric shapes
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * intensity;

    for (int i = 0; i < 3; i++) {
      final shapeX = size.width * (0.2 + i * 0.3);
      final shapeY = size.height * (0.2 + math.sin(animation * 2 * math.pi + i) * 0.1);
      final shapeSize = (30 + i * 15 + math.sin(animation * 3 * math.pi + i * 0.8) * 10) * intensity;

      final pulseIntensity = math.sin(animation * 4 * math.pi + i * 0.6) * 0.5 + 0.5;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.8 * pulseIntensity * intensity),
        accentColor.withOpacity(0.6 * pulseIntensity * intensity),
        i / 2.0,
      )!;

      // Draw different geometric shapes
      switch (i % 3) {
        case 0: // Triangle
          final path = Path();
          path.moveTo(shapeX, shapeY - shapeSize);
          path.lineTo(shapeX - shapeSize, shapeY + shapeSize);
          path.lineTo(shapeX + shapeSize, shapeY + shapeSize);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case 1: // Diamond
          final path = Path();
          path.moveTo(shapeX, shapeY - shapeSize);
          path.lineTo(shapeX + shapeSize, shapeY);
          path.lineTo(shapeX, shapeY + shapeSize);
          path.lineTo(shapeX - shapeSize, shapeY);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case 2: // Circle
          canvas.drawCircle(Offset(shapeX, shapeY), shapeSize, paint);
          break;
      }
    }

    // Draw neon glow particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final particleX = (i / 12) * size.width + math.sin(animation * 3 * math.pi + i * 0.5) * 30 * intensity;
      final particleY = size.height * (0.3 + math.cos(animation * 2 * math.pi + i * 0.4) * 0.2);

      final glowIntensity = math.sin(animation * 6 * math.pi + i * 0.7) * 0.5 + 0.5;

      if (glowIntensity > 0.3) {
        final particleSize = (2 + glowIntensity * 4) * intensity;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.8 * glowIntensity),
          accentColor.withOpacity(0.6 * glowIntensity),
          math.sin(animation * math.pi + i) * 0.5 + 0.5,
        )!;

        canvas.drawCircle(Offset(particleX, particleY), particleSize, paint);

        // Add glow effect
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.3);
        canvas.drawCircle(Offset(particleX, particleY), particleSize * 2, paint);
      }
    }

    // Draw digital sun/moon
    final sunCenter = Offset(size.width * 0.5, size.height * 0.25);
    final sunRadius = (40 + math.sin(animation * 2 * math.pi) * 8) * intensity;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4 * intensity;
    paint.color = primaryColor.withOpacity(0.7 * intensity);

    // Draw sun outline
    canvas.drawCircle(sunCenter, sunRadius, paint);

    // Draw sun rays
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + animation * math.pi;
      final rayStart = Offset(
        sunCenter.dx + math.cos(angle) * sunRadius * 1.2,
        sunCenter.dy + math.sin(angle) * sunRadius * 1.2,
      );
      final rayEnd = Offset(
        sunCenter.dx + math.cos(angle) * sunRadius * 1.6,
        sunCenter.dy + math.sin(angle) * sunRadius * 1.6,
      );

      paint.strokeWidth = 2 * intensity;
      canvas.drawLine(rayStart, rayEnd, paint);
    }

    // Draw horizontal lines through sun for retro effect
    paint.strokeWidth = 2 * intensity;
    for (int i = -2; i <= 2; i++) {
      final lineY = sunCenter.dy + i * 8 * intensity;
      canvas.drawLine(
        Offset(sunCenter.dx - sunRadius, lineY),
        Offset(sunCenter.dx + sunRadius, lineY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
