import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildDeepSeaTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.deepSea,
    isDark: true,
    // Primary colors - bioluminescent teal
    primaryColor: const Color(0xFF00FFCC), // Bright bioluminescent teal
    primaryVariant: const Color(0xFF00D4AA), // Deeper teal
    onPrimary: Colors.black,
    // Secondary colors - electric blue
    accentColor: const Color(0xFF00AAFF), // Electric deep blue
    onAccent: Colors.white,
    // Background colors - deep ocean depths
    background: const Color(0xFF0A0F1C), // Very dark navy (deep ocean)
    surface: const Color(0xFF0F1A2A), // Dark blue-black (ocean depths)
    surfaceVariant: const Color(0xFF1A2635), // Slightly lighter depths
    // Text colors - light for deep water contrast
    textPrimary: const Color(0xFFE0F4F7), // Light cyan-white
    textSecondary: const Color(0xFFB3D9E0), // Medium cyan
    textDisabled: const Color(0xFF6B8E9B), // Muted blue-gray
    // UI colors
    divider: const Color(0xFF2A3A4A),
    toolbarColor: const Color(0xFF0F1A2A),
    error: const Color(0xFFFF4757), // Bright red for visibility
    success: const Color(0xFF00FFCC), // Match primary bioluminescent
    warning: const Color(0xFFFFD700), // Bright gold warning
    // Grid colors
    gridLine: const Color(0xFF2A3A4A),
    gridBackground: const Color(0xFF0F1A2A),
    // Canvas colors
    canvasBackground: const Color(0xFF0A0F1C),
    selectionOutline: const Color(0xFF00FFCC), // Bioluminescent selection
    selectionFill: const Color(0x3000FFCC),
    // Icon colors
    activeIcon: const Color(0xFF00FFCC), // Bioluminescent teal for active
    inactiveIcon: const Color(0xFFB3D9E0), // Light blue for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFE0F4F7),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFE0F4F7),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFE0F4F7),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFB3D9E0),
      ),
    ),
    primaryFontWeight: FontWeight.w400, // Light weight for fluid feel
  );
}

class DeepSeaBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const DeepSeaBackground({
    super.key,
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final currentAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _DeepSeaPainter(
        animation: currentAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _DeepSeaPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _DeepSeaPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(777); // Deep sea seed

    // Draw gentle current waves (depth layers)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final waveHeight = (8 + i * 3) * intensity;
      final baseY = size.height * (0.15 + i * 0.12);
      final phase = animation * 1.5 * math.pi + i * math.pi / 3;

      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 12) {
        final primaryWave = math.sin(x / 150 + phase) * waveHeight;
        final secondaryWave = math.sin(x / 90 + phase * 1.2) * waveHeight * 0.4;
        final y = baseY + primaryWave + secondaryWave;
        path.lineTo(x, y);
      }

      final currentIntensity = math.sin(animation * 2 * math.pi + i * 0.5) * 0.3 + 0.4;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.04 * currentIntensity * intensity),
        accentColor.withOpacity(0.03 * currentIntensity * intensity),
        i / 5.0,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw bioluminescent plankton particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (35 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion affected by currents
      final currentDrift = math.sin(animation * 1.2 * math.pi + i * 0.3) * 15 * intensity;
      final verticalFloat = math.cos(animation * 0.8 * math.pi + i * 0.5) * 8 * intensity;

      final x = baseX + currentDrift;
      final y = baseY + verticalFloat;

      final planktonSize = (1 + random.nextDouble() * 3) * intensity;
      final glowCycle = math.sin(animation * 4 * math.pi + i * 0.7) * 0.5 + 0.5;

      if (glowCycle > 0.3) {
        // Main plankton particle
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.8 * glowCycle * intensity),
          accentColor.withOpacity(0.6 * glowCycle * intensity),
          math.sin(animation * 2 * math.pi + i) * 0.5 + 0.5,
        )!;

        canvas.drawCircle(Offset(x, y), planktonSize * glowCycle, paint);

        // Bioluminescent glow halo
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.2);
        canvas.drawCircle(Offset(x, y), planktonSize * glowCycle * 2.5, paint);
      }
    }

    // Draw jellyfish-like floating organisms
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final jellyfishX = size.width * (0.1 + i * 0.12) + math.sin(animation * 1.5 * math.pi + i * 0.8) * 40 * intensity;
      final jellyfishY = size.height * (0.2 + i * 0.08) + math.cos(animation * math.pi + i * 0.6) * 25 * intensity;

      final jellyfishSize = (12 + i * 4) * intensity;
      final pulseIntensity = math.sin(animation * 3 * math.pi + i * 0.9) * 0.4 + 0.6;

      // Jellyfish bell/dome
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.06 * pulseIntensity * intensity),
        accentColor.withOpacity(0.04 * pulseIntensity * intensity),
        i / 7.0,
      )!;

      canvas.drawCircle(Offset(jellyfishX, jellyfishY), jellyfishSize * pulseIntensity, paint);

      // Jellyfish tentacles (simple trailing lines)
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 1 * intensity;
      paint.color = paint.color.withOpacity(paint.color.opacity * 0.7);

      for (int j = 0; j < 4; j++) {
        final tentacleAngle = (j / 4.0) * math.pi + animation * 0.5;
        final tentacleLength = jellyfishSize * (1.5 + math.sin(animation * 2 * math.pi + j) * 0.5);

        final tentacleEndX = jellyfishX + math.cos(tentacleAngle) * 3;
        final tentacleEndY = jellyfishY + tentacleLength;

        canvas.drawLine(
          Offset(jellyfishX, jellyfishY + jellyfishSize * 0.5),
          Offset(tentacleEndX, tentacleEndY),
          paint,
        );
      }

      paint.style = PaintingStyle.fill;
    }

    // Draw bioluminescent light trails
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5 * intensity;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final trailStartX = size.width * (0.15 + i * 0.25);
      final trailStartY = size.height * (0.1 + i * 0.2);

      path.moveTo(trailStartX, trailStartY);

      // Create organic, flowing bioluminescent trails
      for (int j = 1; j <= 8; j++) {
        final progress = j / 8.0;
        final trailFlow = animation * 2 * math.pi + i * math.pi / 2;

        final x =
            trailStartX + progress * 100 * intensity + math.sin(progress * 3 * math.pi + trailFlow) * 20 * intensity;
        final y = trailStartY +
            progress * 60 * intensity +
            math.cos(progress * 2 * math.pi + trailFlow * 0.8) * 15 * intensity;

        path.lineTo(x, y);
      }

      final trailIntensity = math.sin(animation * 2.5 * math.pi + i * 1.1) * 0.5 + 0.5;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.1 * trailIntensity * intensity),
        accentColor.withOpacity(0.08 * trailIntensity * intensity),
        i / 3.0,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw deep water pressure distortions
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final distortionX = size.width * (0.2 + i * 0.2);
      final distortionY = size.height * (0.4 + math.sin(animation * 1.8 * math.pi + i) * 0.3);

      final distortionSize = (25 + i * 10 + math.cos(animation * 2.2 * math.pi + i) * 8) * intensity;
      final pressureIntensity = math.sin(animation * 1.5 * math.pi + i * 0.7) * 0.2 + 0.3;

      // Create subtle pressure wave distortions
      paint.color = primaryColor.withOpacity(0.02 * pressureIntensity * intensity);
      canvas.drawCircle(Offset(distortionX, distortionY), distortionSize, paint);

      paint.color = accentColor.withOpacity(0.015 * pressureIntensity * intensity);
      canvas.drawCircle(Offset(distortionX, distortionY), distortionSize * 1.4, paint);
    }

    // Draw bioluminescent light orbs (larger creatures)
    for (int i = 0; i < (6 * intensity).round(); i++) {
      final orbX = size.width * (0.1 + i * 0.15) + math.sin(animation * 1.3 * math.pi + i * 0.9) * 30 * intensity;
      final orbY = size.height * (0.3 + i * 0.1) + math.cos(animation * 0.9 * math.pi + i * 0.7) * 20 * intensity;

      final orbSize = (8 + i * 3) * intensity;
      final orbPulse = math.sin(animation * 5 * math.pi + i * 1.3) * 0.5 + 0.5;

      if (orbPulse > 0.4) {
        // Core light
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.9 * orbPulse * intensity),
          accentColor.withOpacity(0.7 * orbPulse * intensity),
          orbPulse,
        )!;

        canvas.drawCircle(Offset(orbX, orbY), orbSize * orbPulse * 0.7, paint);

        // Outer glow
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.15);
        canvas.drawCircle(Offset(orbX, orbY), orbSize * orbPulse * 2, paint);

        // Extended glow field
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.3);
        canvas.drawCircle(Offset(orbX, orbY), orbSize * orbPulse * 3.5, paint);
      }
    }

    // Draw subtle seafloor glow (bottom illumination)
    final seafloorY = size.height * 0.85;
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final glowX = (i / 8) * size.width;
      final glowSize = (15 + math.sin(animation * 2 * math.pi + i * 0.6) * 8) * intensity;
      final seafloorGlow = math.cos(animation * 1.8 * math.pi + i * 0.4) * 0.2 + 0.3;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.03 * seafloorGlow * intensity),
        accentColor.withOpacity(0.02 * seafloorGlow * intensity),
        i / 7.0,
      )!;

      canvas.drawCircle(Offset(glowX, seafloorY + glowSize * 0.5), glowSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
