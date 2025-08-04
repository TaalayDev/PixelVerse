import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildVolcanicTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.volcanic,
    isDark: true,
    // Primary colors - molten lava orange
    primaryColor: const Color(0xFFFF4500), // Orange red (lava)
    primaryVariant: const Color(0xFFDC143C), // Crimson
    onPrimary: Colors.white,
    // Secondary colors - bright molten yellow
    accentColor: const Color(0xFFFFD700), // Gold/molten metal
    onAccent: Colors.black,
    // Background colors - dark volcanic rock
    background: const Color(0xFF1A1A1A), // Very dark gray
    surface: const Color(0xFF2C2C2C), // Dark gray (volcanic rock)
    surfaceVariant: const Color(0xFF3D3D3D), // Lighter gray
    // Text colors - light for contrast
    textPrimary: const Color(0xFFFFF8DC), // Cornsilk (warm white)
    textSecondary: const Color(0xFFFFDAB9), // Peach puff
    textDisabled: const Color(0xFF8B7D6B), // Dark khaki
    // UI colors
    divider: const Color(0xFF4A4A4A),
    toolbarColor: const Color(0xFF2C2C2C),
    error: const Color(0xFFFF6B6B), // Light red
    success: const Color(0xFF51CF66), // Light green
    warning: const Color(0xFFFFD43B), // Bright yellow
    // Grid colors
    gridLine: const Color(0xFF4A4A4A),
    gridBackground: const Color(0xFF2C2C2C),
    // Canvas colors
    canvasBackground: const Color(0xFF1A1A1A),
    selectionOutline: const Color(0xFFFF4500), // Match primary (lava)
    selectionFill: const Color(0x30FF4500),
    // Icon colors
    activeIcon: const Color(0xFFFF4500), // Lava orange for active
    inactiveIcon: const Color(0xFFFFDAB9), // Peach for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFFFF8DC),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFFFF8DC),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFFFF8DC),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFFFDAB9),
      ),
    ),
    primaryFontWeight: FontWeight.w500, // Medium weight for strength
  );
}

// Volcanic theme background with lava flows and ember effects
class VolcanicBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const VolcanicBackground({
    super.key,
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final lavaAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _VolcanicPainter(
        animation: lavaAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _VolcanicPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _VolcanicPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(666); // Fixed seed for consistent volcanic patterns

    // Draw flowing lava streams
    for (int i = 0; i < (5 * intensity).round(); i++) {
      final streamStartX = random.nextDouble() * size.width;
      final streamFlow = animation + i * 0.2;

      final path = Path();
      path.moveTo(streamStartX, 0);

      // Create winding lava stream
      for (double y = 0; y <= size.height; y += 20) {
        final waveOffset = math.sin((y / 50) + streamFlow * 2 * math.pi) * 30 * intensity;
        final x = streamStartX + waveOffset + (y / size.height) * (random.nextDouble() - 0.5) * 40;
        path.lineTo(x, y);
      }

      // Create lava stream width variation
      final streamWidth = (8 + math.sin(streamFlow * 3 * math.pi + i) * 4) * intensity;
      paint.strokeWidth = streamWidth;
      paint.style = PaintingStyle.stroke;
      paint.strokeCap = StrokeCap.round;

      final lavaIntensity = 0.6 + math.sin(streamFlow * 4 * math.pi + i * 0.7) * 0.4;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.4 * lavaIntensity * intensity),
        accentColor.withOpacity(0.6 * lavaIntensity * intensity),
        math.sin(streamFlow * 2 * math.pi + i) * 0.5 + 0.5,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw floating ember particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (25 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Embers rise and drift
      final emberProgress = (animation * 0.5 + i * 0.04) % 1.0;
      final x = baseX + math.sin(animation * 2 * math.pi + i * 0.3) * 15 * intensity;
      final y = baseY - emberProgress * size.height * 0.3;

      final emberSize = (2 + random.nextDouble() * 4) * intensity;
      final emberIntensity =
          math.max(0.0, (1.0 - emberProgress) * (math.sin(animation * 6 * math.pi + i * 0.5) * 0.3 + 0.7));

      if (emberIntensity > 0.2) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(emberIntensity * intensity),
          accentColor.withOpacity(emberIntensity * 0.8 * intensity),
          math.sin(animation * 3 * math.pi + i) * 0.5 + 0.5,
        )!;

        canvas.drawCircle(Offset(x, y), emberSize * emberIntensity, paint);

        // Add glow effect
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.3);
        canvas.drawCircle(Offset(x, y), emberSize * emberIntensity * 2, paint);
      }
    }

    // Draw volcanic glow patches
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final glowX = random.nextDouble() * size.width;
      final glowY = size.height * (0.7 + random.nextDouble() * 0.3); // Bottom area
      final glowSize = (20 + random.nextDouble() * 40) * intensity;

      final pulseIntensity = math.sin(animation * 3 * math.pi + i * 0.8) * 0.5 + 0.5;
      final currentGlowSize = glowSize * (0.7 + pulseIntensity * 0.3);

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.1 * pulseIntensity * intensity),
        accentColor.withOpacity(0.08 * pulseIntensity * intensity),
        i / 7.0,
      )!;

      canvas.drawCircle(Offset(glowX, glowY), currentGlowSize, paint);
    }

    // Draw lava bubbles/eruptions
    for (int i = 0; i < (6 * intensity).round(); i++) {
      final bubbleX = random.nextDouble() * size.width;
      final bubbleY = size.height * (0.8 + random.nextDouble() * 0.2);

      final eruptionProgress = (animation * 2 + i * 0.3) % 1.0;

      if (eruptionProgress < 0.3) {
        final bubbleSize = (5 + eruptionProgress * 20) * intensity;
        final bubbleIntensity = math.sin(eruptionProgress * math.pi) * intensity;

        paint.color = Color.lerp(
          primaryColor.withOpacity(0.8 * bubbleIntensity),
          accentColor.withOpacity(0.9 * bubbleIntensity),
          eruptionProgress / 0.3,
        )!;

        canvas.drawCircle(Offset(bubbleX, bubbleY), bubbleSize, paint);

        // Draw eruption sparks
        if (eruptionProgress > 0.1) {
          for (int j = 0; j < 5; j++) {
            final sparkAngle = j * 2 * math.pi / 5 + animation * math.pi;
            final sparkDistance = (eruptionProgress - 0.1) * 30 * intensity;
            final sparkX = bubbleX + math.cos(sparkAngle) * sparkDistance;
            final sparkY = bubbleY + math.sin(sparkAngle) * sparkDistance;

            paint.color = accentColor.withOpacity(0.6 * bubbleIntensity);
            canvas.drawCircle(Offset(sparkX, sparkY), 1.5 * intensity, paint);
          }
        }
      }
    }

    // Draw volcanic fissures (cracks with glow)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < 3; i++) {
      final fissureStartX = size.width * (0.2 + i * 0.3);
      final fissureStartY = size.height * (0.4 + random.nextDouble() * 0.4);

      final path = Path();
      path.moveTo(fissureStartX, fissureStartY);

      // Create jagged fissure
      for (int j = 1; j <= 5; j++) {
        final segmentProgress = j / 5.0;
        final x = fissureStartX + (random.nextDouble() - 0.5) * 60 * intensity;
        final y = fissureStartY + segmentProgress * 80 * intensity;
        path.lineTo(x, y);
      }

      final fissureGlow = math.sin(animation * 4 * math.pi + i * 0.9) * 0.5 + 0.5;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.4 * fissureGlow * intensity),
        accentColor.withOpacity(0.5 * fissureGlow * intensity),
        fissureGlow,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw heat shimmer effect (wavy lines)
    paint.strokeWidth = 1 * intensity;
    for (int i = 0; i < (4 * intensity).round(); i++) {
      final shimmerY = size.height * (0.3 + i * 0.15);
      final path = Path();

      path.moveTo(0, shimmerY);
      for (double x = 0; x <= size.width; x += 10) {
        final waveOffset = math.sin((x / 30) + animation * 4 * math.pi + i) * 3 * intensity;
        path.lineTo(x, shimmerY + waveOffset);
      }

      final shimmerIntensity = math.sin(animation * 5 * math.pi + i * 1.2) * 0.3 + 0.4;
      paint.color = primaryColor.withOpacity(0.1 * shimmerIntensity * intensity);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
