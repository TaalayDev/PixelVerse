import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildPrismaticTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.prismatic,
    isDark: true,
    // Primary colors - vibrant magenta/fuchsia
    primaryColor: const Color(0xFFFF1493), // Deep pink/magenta
    primaryVariant: const Color(0xFFFF69B4), // Hot pink
    onPrimary: Colors.white,
    // Secondary colors - electric cyan
    accentColor: const Color(0xFF00FFFF), // Electric cyan
    onAccent: Colors.black,
    // Background colors - deep space for holographic contrast
    background: const Color(0xFF0A0A0F), // Very dark purple-black
    surface: const Color(0xFF1A1A2E), // Dark purple-blue
    surfaceVariant: const Color(0xFF16213E), // Darker blue-purple
    // Text colors - bright holographic
    textPrimary: const Color(0xFFFFFFFF), // Pure white for maximum contrast
    textSecondary: const Color(0xFFE0E0FF), // Light purple-white
    textDisabled: const Color(0xFF8A8AAA), // Muted purple-gray
    // UI colors
    divider: const Color(0xFF2A2D47),
    toolbarColor: const Color(0xFF1A1A2E),
    error: const Color(0xFFFF073A), // Bright neon red
    success: const Color(0xFF00FF7F), // Spring green
    warning: const Color(0xFFFFD700), // Gold
    // Grid colors
    gridLine: const Color(0xFF2A2D47),
    gridBackground: const Color(0xFF1A1A2E),
    // Canvas colors
    canvasBackground: const Color(0xFF0A0A0F),
    selectionOutline: const Color(0xFFFF1493), // Match primary
    selectionFill: const Color(0x30FF1493),
    // Icon colors
    activeIcon: const Color(0xFFFF1493), // Bright magenta for active
    inactiveIcon: const Color(0xFFE0E0FF), // Light purple for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFFFFFFF),
        fontWeight: FontWeight.w700, // Bold for futuristic feel
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFFFFFFF),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFFFFFFF),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFE0E0FF),
      ),
    ),
    primaryFontWeight: FontWeight.w600, // Bold for high-tech aesthetic
  );
}

class PrismaticBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const PrismaticBackground({
    super.key,
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final prismaticAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _PrismaticPainter(
        animation: prismaticAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _PrismaticPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _PrismaticPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Generate rainbow colors based on hue rotation
  Color _getRainbowColor(double position, double animation) {
    final hue = ((position + animation * 360) % 360);
    return HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123); // Fixed seed for consistent patterns

    // Draw spectrum waves across the screen
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * intensity;

    for (int i = 0; i < 6; i++) {
      final path = Path();
      final waveHeight = (15 + i * 8) * intensity;
      final baseY = size.height * (0.1 + i * 0.15);
      final phase = animation * 2 * math.pi + i * math.pi / 3;

      path.moveTo(0, baseY);
      for (double x = 0; x <= size.width; x += 8) {
        final primaryWave = math.sin(x / 120 + phase) * waveHeight;
        final secondaryWave = math.sin(x / 80 + phase * 1.3) * waveHeight * 0.5;
        final y = baseY + primaryWave + secondaryWave;
        path.lineTo(x, y);
      }

      // Create rainbow spectrum effect
      final spectrumPosition = (animation * 60 + i * 60) % 360;
      final waveIntensity = math.sin(animation * 3 * math.pi + i * 0.7) * 0.4 + 0.6;

      paint.color = _getRainbowColor(spectrumPosition, animation * 0.5).withOpacity(0.6 * waveIntensity * intensity);

      canvas.drawPath(path, paint);
    }

    // Draw holographic interference patterns
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final interferenceX = (i / 12) * size.width;
      final interferenceY = size.height * (0.3 + math.sin(animation * 2 * math.pi + i * 0.5) * 0.4);

      final patternSize = (20 + math.cos(animation * 3 * math.pi + i) * 8) * intensity;
      final hologramIntensity = math.sin(animation * 4 * math.pi + i * 0.8) * 0.5 + 0.5;

      if (hologramIntensity > 0.3) {
        // Create shifting rainbow interference
        final hue1 = (animation * 180 + i * 30) % 360;
        final hue2 = (animation * 200 + i * 40 + 180) % 360;

        final color1 = HSVColor.fromAHSV(1.0, hue1, 0.8, 0.9).toColor();
        final color2 = HSVColor.fromAHSV(1.0, hue2, 0.8, 0.9).toColor();

        // Draw overlapping interference circles
        paint.color = color1.withOpacity(0.15 * hologramIntensity * intensity);
        canvas.drawCircle(Offset(interferenceX, interferenceY), patternSize, paint);

        paint.color = color2.withOpacity(0.12 * hologramIntensity * intensity);
        canvas.drawCircle(Offset(interferenceX + patternSize * 0.3, interferenceY), patternSize * 0.8, paint);
      }
    }

    // Draw prismatic light beams
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4 * intensity;

    for (int i = 0; i < (8 * intensity).round(); i++) {
      final beamStartX = size.width * (0.1 + i * 0.11);
      final beamStartY = size.height * 0.05;
      final beamAngle = (i * 15 + animation * 30) * math.pi / 180;
      final beamLength = (60 + math.sin(animation * 2 * math.pi + i) * 20) * intensity;

      final beamEndX = beamStartX + math.cos(beamAngle) * beamLength;
      final beamEndY = beamStartY + math.sin(beamAngle) * beamLength;

      final beamIntensity = math.sin(animation * 5 * math.pi + i * 0.6) * 0.5 + 0.5;

      if (beamIntensity > 0.4) {
        // Create spectrum beam effect
        final beamHue = (animation * 120 + i * 45) % 360;
        paint.color = HSVColor.fromAHSV(1.0, beamHue, 1.0, 1.0).toColor().withOpacity(0.4 * beamIntensity * intensity);

        canvas.drawLine(
          Offset(beamStartX, beamStartY),
          Offset(beamEndX, beamEndY),
          paint,
        );

        // Add beam glow
        paint.strokeWidth = 8 * intensity;
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.3);
        canvas.drawLine(
          Offset(beamStartX, beamStartY),
          Offset(beamEndX, beamEndY),
          paint,
        );
        paint.strokeWidth = 4 * intensity;
      }
    }

    // Draw floating holographic particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (30 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Particles drift in holographic patterns
      final floatX = baseX + math.sin(animation * 1.5 * math.pi + i * 0.3) * 20 * intensity;
      final floatY = baseY + math.cos(animation * 1.2 * math.pi + i * 0.4) * 15 * intensity;

      final particleSize = (2 + random.nextDouble() * 4) * intensity;
      final glowCycle = math.sin(animation * 6 * math.pi + i * 0.7) * 0.5 + 0.5;

      if (glowCycle > 0.4) {
        // Particles shift through spectrum
        final particleHue = (animation * 300 + i * 12) % 360;
        paint.color = HSVColor.fromAHSV(1.0, particleHue, 0.9, 1.0).toColor().withOpacity(0.8 * glowCycle * intensity);

        canvas.drawCircle(Offset(floatX, floatY), particleSize * glowCycle, paint);

        // Add holographic shimmer
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.4);
        canvas.drawCircle(Offset(floatX, floatY), particleSize * glowCycle * 2, paint);
      }
    }

    // Draw prismatic refraction patterns
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < 4; i++) {
      final refractionCenterX = size.width * (0.2 + i * 0.2);
      final refractionCenterY = size.height * (0.4 + math.sin(animation * math.pi + i) * 0.2);

      // Create refraction fan effect
      for (int j = 0; j < 8; j++) {
        final rayAngle = (j * 45 + animation * 60 + i * 30) * math.pi / 180;
        final rayLength = (25 + j * 3) * intensity;

        final rayEndX = refractionCenterX + math.cos(rayAngle) * rayLength;
        final rayEndY = refractionCenterY + math.sin(rayAngle) * rayLength;

        final rayHue = (animation * 90 + i * 90 + j * 15) % 360;
        final rayIntensity = math.sin(animation * 4 * math.pi + i + j * 0.3) * 0.3 + 0.5;

        paint.color = HSVColor.fromAHSV(1.0, rayHue, 1.0, 1.0).toColor().withOpacity(0.3 * rayIntensity * intensity);

        canvas.drawLine(
          Offset(refractionCenterX, refractionCenterY),
          Offset(rayEndX, rayEndY),
          paint,
        );
      }
    }

    // Draw holographic grid distortions
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * intensity;

    final gridSpacing = 60.0 * intensity;
    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        final distortionX = math.sin(animation * 2 * math.pi + x * 0.01) * 8 * intensity;
        final distortionY = math.cos(animation * 2.5 * math.pi + y * 0.01) * 6 * intensity;

        final gridHue = (animation * 45 + x * 0.5 + y * 0.3) % 360;
        final gridIntensity = math.sin(animation * 3 * math.pi + x * 0.02 + y * 0.02) * 0.3 + 0.4;

        paint.color = HSVColor.fromAHSV(1.0, gridHue, 0.7, 0.8).toColor().withOpacity(0.08 * gridIntensity * intensity);

        // Draw distorted grid squares
        final rect = Rect.fromLTWH(
          x + distortionX,
          y + distortionY,
          gridSpacing * 0.8,
          gridSpacing * 0.8,
        );
        canvas.drawRect(rect, paint);
      }
    }

    // Draw spectrum auroras
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 3; i++) {
      final auroraPath = Path();
      final auroraY = size.height * (0.6 + i * 0.1);
      final phase = animation * 1.5 * math.pi + i * math.pi / 2;

      auroraPath.moveTo(0, auroraY);
      for (double x = 0; x <= size.width; x += 12) {
        final waveOffset = math.sin(x / 100 + phase) * 25 * intensity;
        auroraPath.lineTo(x, auroraY + waveOffset);
      }

      // Close the path to create filled aurora
      auroraPath.lineTo(size.width, size.height);
      auroraPath.lineTo(0, size.height);
      auroraPath.close();

      final auroraHue = (animation * 60 + i * 120) % 360;
      final auroraIntensity = math.sin(animation * 2 * math.pi + i * 0.8) * 0.3 + 0.4;

      paint.color =
          HSVColor.fromAHSV(1.0, auroraHue, 0.8, 1.0).toColor().withOpacity(0.05 * auroraIntensity * intensity);

      canvas.drawPath(auroraPath, paint);
    }

    // Draw prismatic crystal formations
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * intensity;

    for (int i = 0; i < (6 * intensity).round(); i++) {
      final crystalX = random.nextDouble() * size.width;
      final crystalY = random.nextDouble() * size.height;
      final crystalSize = (12 + random.nextDouble() * 18) * intensity;
      final rotation = animation * 2 * math.pi + i * 0.7;

      canvas.save();
      canvas.translate(crystalX, crystalY);
      canvas.rotate(rotation);

      // Draw prismatic crystal shape
      final crystalPath = Path();
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final x = math.cos(angle) * crystalSize;
        final y = math.sin(angle) * crystalSize;

        if (j == 0) {
          crystalPath.moveTo(x, y);
        } else {
          crystalPath.lineTo(x, y);
        }
      }
      crystalPath.close();

      final crystalHue = (animation * 150 + i * 60) % 360;
      final crystalIntensity = math.sin(animation * 4 * math.pi + i * 0.9) * 0.4 + 0.6;

      paint.color =
          HSVColor.fromAHSV(1.0, crystalHue, 1.0, 1.0).toColor().withOpacity(0.4 * crystalIntensity * intensity);

      canvas.drawPath(crystalPath, paint);

      // Draw inner crystal structure
      paint.strokeWidth = 1 * intensity;
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final innerX = math.cos(angle) * crystalSize * 0.6;
        final innerY = math.sin(angle) * crystalSize * 0.6;
        canvas.drawLine(Offset.zero, Offset(innerX, innerY), paint);
      }
      paint.strokeWidth = 3 * intensity;

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
