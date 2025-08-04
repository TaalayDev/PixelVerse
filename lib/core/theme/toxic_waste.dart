import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildToxicWasteTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.toxicWaste,
    isDark: true,
    // Primary colors - radioactive green
    primaryColor: const Color(0xFF39FF14), // Electric lime/radioactive green
    primaryVariant: const Color(0xFF32CD32), // Lime green
    onPrimary: Colors.black,
    // Secondary colors - toxic yellow
    accentColor: const Color(0xFFCCFF00), // Bright toxic yellow
    onAccent: Colors.black,
    // Background colors - dark industrial/chemical
    background: const Color(0xFF0F1419), // Very dark green-gray
    surface: const Color(0xFF1A2520), // Dark toxic green
    surfaceVariant: const Color(0xFF263529), // Slightly lighter toxic
    // Text colors - bright for contrast
    textPrimary: const Color(0xFFE8FFE8), // Very light green
    textSecondary: const Color(0xFFB8FFB8), // Light toxic green
    textDisabled: const Color(0xFF6B8E6B), // Muted green
    // UI colors
    divider: const Color(0xFF3A4F3A),
    toolbarColor: const Color(0xFF1A2520),
    error: const Color(0xFFFF4757), // Bright red warning
    success: const Color(0xFF39FF14), // Match primary for success
    warning: const Color(0xFFFFD700), // Bright gold warning
    // Grid colors
    gridLine: const Color(0xFF3A4F3A),
    gridBackground: const Color(0xFF1A2520),
    // Canvas colors
    canvasBackground: const Color(0xFF0F1419),
    selectionOutline: const Color(0xFF39FF14), // Radioactive green
    selectionFill: const Color(0x3039FF14),
    // Icon colors
    activeIcon: const Color(0xFF39FF14), // Radioactive green for active
    inactiveIcon: const Color(0xFFB8FFB8), // Light green for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFE8FFE8),
        fontWeight: FontWeight.w700, // Bold for industrial feel
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFE8FFE8),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFE8FFE8),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFB8FFB8),
      ),
    ),
    primaryFontWeight: FontWeight.w600, // Bold for toxic aesthetic
  );
}

class ToxicWasteBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const ToxicWasteBackground({
    super.key,
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _ToxicWastePainter(
        animation: bubbleAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _ToxicWastePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _ToxicWastePainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(666); // Evil seed for toxic theme

    // Draw toxic bubbling liquid at bottom
    final liquidLevel = size.height * 0.75;
    final path = Path();
    path.moveTo(0, liquidLevel);

    for (double x = 0; x <= size.width; x += 5) {
      final bubbleWave = math.sin(x / 30 + animation * 4 * math.pi) * 8 * intensity;
      final liquidWave = math.sin(x / 80 + animation * 2 * math.pi) * 4 * intensity;
      path.lineTo(x, liquidLevel + bubbleWave + liquidWave);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    paint.color = primaryColor.withOpacity(0.1 * intensity);
    canvas.drawPath(path, paint);

    for (int i = 0; i < (15 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final floatX = baseX + math.sin(animation * 1.5 * math.pi + i * 0.4) * 12 * intensity;
      final floatY = baseY + math.cos(animation * math.pi + i * 0.6) * 8 * intensity;

      final crystalSize = (2 + random.nextDouble() * 4) * intensity;
      final sparkleIntensity = math.sin(animation * 5 * math.pi + i * 0.9) * 0.5 + 0.5;

      if (sparkleIntensity > 0.6) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.4 * sparkleIntensity),
          accentColor.withOpacity(0.5 * sparkleIntensity),
          sparkleIntensity,
        )!;

        canvas.drawCircle(Offset(floatX, floatY), crystalSize * sparkleIntensity, paint);

        paint.color = paint.color.withOpacity(paint.color.opacity * 0.3);
        canvas.drawCircle(Offset(floatX, floatY), crystalSize * 1.8, paint);
      }
    }

    // Draw toxic steam/vapor
    for (int i = 0; i < (10 * intensity).round(); i++) {
      final steamX = (i / 10) * size.width + math.sin(animation * 2 * math.pi + i * 0.7) * 25 * intensity;
      final steamY = liquidLevel - (20 + i * 15) * intensity;
      final steamSize = (15 + i * 5 + math.cos(animation * 3 * math.pi + i) * 8) * intensity;

      final vaporIntensity = math.sin(animation * 4 * math.pi + i * 0.6) * 0.4 + 0.6;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.04 * vaporIntensity * intensity),
        accentColor.withOpacity(0.06 * vaporIntensity * intensity),
        i / 9.0,
      )!;

      canvas.drawCircle(Offset(steamX, steamY), steamSize * vaporIntensity, paint);
    }

    // Draw radioactive particles
    for (int i = 0; i < (20 * intensity).round(); i++) {
      final particleX = random.nextDouble() * size.width;
      final particleY = random.nextDouble() * size.height;
      final drift = math.sin(animation * 3 * math.pi + i * 0.4) * 5 * intensity;

      final x = particleX + drift;
      final y = particleY + math.cos(animation * 2 * math.pi + i * 0.3) * 3 * intensity;

      final glowIntensity = math.sin(animation * 6 * math.pi + i * 0.8) * 0.5 + 0.5;

      if (glowIntensity > 0.7) {
        paint.color = primaryColor.withOpacity(0.8 * glowIntensity * intensity);
        canvas.drawCircle(Offset(x, y), 1.5 * intensity * glowIntensity, paint);

        // Add radioactive glow
        paint.color = primaryColor.withOpacity(0.2 * glowIntensity * intensity);
        canvas.drawCircle(Offset(x, y), 4 * intensity * glowIntensity, paint);
      }
    }

    // Draw toxic drips from top
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < (6 * intensity).round(); i++) {
      final dripX = (i / 6) * size.width + size.width * 0.1;
      final dripProgress = (animation * 0.8 + i * 0.3) % 1.0;
      final dripLength = dripProgress * size.height * 0.3;

      if (dripProgress > 0.1) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.5 * intensity),
          accentColor.withOpacity(0.6 * intensity),
          i / 5.0,
        )!;

        canvas.drawLine(
          Offset(dripX, 0),
          Offset(dripX, dripLength),
          paint,
        );

        // Draw drip bulb at end
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(dripX, dripLength),
          3 * intensity,
          paint,
        );
        paint.style = PaintingStyle.stroke;
      }
    }

    // Draw warning symbols (hazard indicators)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < 3; i++) {
      final symbolX = size.width * (0.2 + i * 0.3);
      final symbolY = size.height * (0.1 + math.sin(animation * math.pi + i) * 0.05);
      final symbolSize = (12 + i * 2) * intensity;
      final symbolIntensity = math.sin(animation * 5 * math.pi + i * 1.2) * 0.3 + 0.4;

      paint.color = accentColor.withOpacity(0.15 * symbolIntensity * intensity);

      // Draw triangle warning symbol
      final path = Path();
      path.moveTo(symbolX, symbolY - symbolSize);
      path.lineTo(symbolX - symbolSize, symbolY + symbolSize);
      path.lineTo(symbolX + symbolSize, symbolY + symbolSize);
      path.close();

      canvas.drawPath(path, paint);

      // Draw exclamation mark inside
      paint.style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(symbolX, symbolY - symbolSize * 0.2),
          width: 2 * intensity,
          height: symbolSize * 0.6,
        ),
        paint,
      );
      canvas.drawCircle(
        Offset(symbolX, symbolY + symbolSize * 0.3),
        1.5 * intensity,
        paint,
      );
      paint.style = PaintingStyle.stroke;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
