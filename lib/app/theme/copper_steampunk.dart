import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildCopperSteampunkTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.copperSteampunk,
    isDark: true,
    // Primary colors - copper and bronze
    primaryColor: const Color(0xFFB87333), // Copper
    primaryVariant: const Color(0xFFA0522D), // Dark copper
    onPrimary: Colors.white,
    // Secondary colors - brass
    accentColor: const Color(0xFFCD7F32), // Brass/Bronze
    onAccent: Colors.black,
    // Background colors - dark industrial iron
    background: const Color(0xFF1C1C1C), // Dark charcoal iron
    surface: const Color(0xFF2A2A2A), // Dark iron surface
    surfaceVariant: const Color(0xFF353535), // Lighter iron variant
    // Text colors - light brass for contrast
    textPrimary: const Color(0xFFF4E4BC), // Light brass/cream
    textSecondary: const Color(0xFFDEB887), // Burlywood (warm brass)
    textDisabled: const Color(0xFF8B7355), // Dark khaki
    // UI colors
    divider: const Color(0xFF404040),
    toolbarColor: const Color(0xFF2A2A2A),
    error: const Color(0xFFCD5C5C), // Indian red
    success: const Color(0xFF9ACD32), // Yellow green
    warning: const Color(0xFFDAA520), // Goldenrod
    // Grid colors
    gridLine: const Color(0xFF404040),
    gridBackground: const Color(0xFF2A2A2A),
    // Canvas colors
    canvasBackground: const Color(0xFF1C1C1C),
    selectionOutline: const Color(0xFFB87333), // Copper selection
    selectionFill: const Color(0x30B87333),
    // Icon colors
    activeIcon: const Color(0xFFB87333), // Copper for active
    inactiveIcon: const Color(0xFFDEB887), // Brass for inactive
    // Typography - using a more industrial/mechanical feel
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFF4E4BC),
        fontWeight: FontWeight.w700, // Bold for industrial feel
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFF4E4BC),
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFF4E4BC),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFDEB887),
      ),
    ),
    primaryFontWeight: FontWeight.w600, // Bold for mechanical aesthetic
  );
}

class CopperSteampunkBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const CopperSteampunkBackground({
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
      }
      return null;
    }, [enableAnimation]);

    final mechanicalAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _CopperSteampunkPainter(
        animation: mechanicalAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _CopperSteampunkPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _CopperSteampunkPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final random = math.Random(1337); // Industrial seed

    // Draw rotating gears
    final gearCount = (8 * intensity).round();
    for (int i = 0; i < gearCount; i++) {
      final gearX = random.nextDouble() * size.width;
      final gearY = random.nextDouble() * size.height;
      final gearRadius = (15 + random.nextDouble() * 25) * intensity;
      final rotation = animation * 2 * math.pi * (i % 2 == 0 ? 1 : -1) + i;

      final gearOpacity = (0.08 + math.sin(animation * 3 * math.pi + i * 0.7) * 0.03) * intensity;
      paint.color = Color.lerp(
        primaryColor.withOpacity(gearOpacity),
        accentColor.withOpacity(gearOpacity * 0.8),
        i / (gearCount - 1),
      )!;
      paint.strokeWidth = 2 * intensity;

      _drawGear(canvas, paint, Offset(gearX, gearY), gearRadius, rotation, 8);
    }

    // // Draw steam puffs
    // paint.style = PaintingStyle.fill;
    // final steamCount = (12 * intensity).round();
    // for (int i = 0; i < steamCount; i++) {
    //   final baseX = random.nextDouble() * size.width;
    //   final baseY = size.height * (0.7 + random.nextDouble() * 0.3); // Bottom area for steam sources

    //   // Steam rises and expands
    //   final steamProgress = (animation * 0.3 + i * 0.08) % 1.0;
    //   final steamX = baseX + math.sin(animation * 2 * math.pi + i * 0.4) * 20 * intensity;
    //   final steamY = baseY - steamProgress * size.height * 0.5;
    //   final steamSize = (8 + steamProgress * 20) * intensity;

    //   final steamOpacity = math.max(0.0, (1.0 - steamProgress) * 0.15 * intensity);

    //   if (steamOpacity > 0.01) {
    //     // Create multiple overlapping circles for cloud effect
    //     paint.color = Colors.white.withOpacity(steamOpacity);
    //     canvas.drawCircle(Offset(steamX, steamY), steamSize, paint);

    //     paint.color = Colors.white.withOpacity(steamOpacity * 0.6);
    //     canvas.drawCircle(Offset(steamX - steamSize * 0.3, steamY + steamSize * 0.2), steamSize * 0.8, paint);
    //     canvas.drawCircle(Offset(steamX + steamSize * 0.4, steamY - steamSize * 0.1), steamSize * 0.6, paint);
    //   }
    // }

    // Draw floating mechanical particles (screws, bolts, etc.)
    paint.style = PaintingStyle.fill;
    final particleCount = (20 * intensity).round();
    for (int i = 0; i < particleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final floatX = baseX + math.sin(animation * 1.5 * math.pi + i * 0.3) * 8 * intensity;
      final floatY = baseY + math.cos(animation * math.pi + i * 0.5) * 6 * intensity;

      final particleIntensity = math.sin(animation * 4 * math.pi + i * 0.6) * 0.5 + 0.5;

      if (particleIntensity > 0.4) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.4 * particleIntensity * intensity),
          accentColor.withOpacity(0.3 * particleIntensity * intensity),
          math.sin(animation * 2 * math.pi + i) * 0.5 + 0.5,
        )!;

        // Draw different mechanical shapes
        switch (i % 4) {
          case 0: // Screw head
            canvas.drawCircle(Offset(floatX, floatY), 2 * intensity * particleIntensity, paint);
            paint.style = PaintingStyle.stroke;
            paint.strokeWidth = 0.5 * intensity;
            canvas.drawLine(
              Offset(floatX - 1.5 * intensity, floatY),
              Offset(floatX + 1.5 * intensity, floatY),
              paint,
            );
            paint.style = PaintingStyle.fill;
            break;
          case 1: // Bolt/nut (hexagon)
            _drawHexagon(canvas, paint, Offset(floatX, floatY), 2 * intensity * particleIntensity);
            break;
          case 2: // Gear tooth
            final toothPath = Path();
            toothPath.moveTo(floatX - 2 * intensity, floatY - 1 * intensity);
            toothPath.lineTo(floatX + 2 * intensity, floatY - 1 * intensity);
            toothPath.lineTo(floatX + 1 * intensity, floatY + 2 * intensity);
            toothPath.lineTo(floatX - 1 * intensity, floatY + 2 * intensity);
            toothPath.close();
            canvas.drawPath(toothPath, paint);
            break;
          case 3: // Rivet
            canvas.drawCircle(Offset(floatX, floatY), 1.5 * intensity * particleIntensity, paint);
            paint.color = paint.color.withOpacity(paint.color.opacity * 0.6);
            canvas.drawCircle(Offset(floatX, floatY), 0.8 * intensity * particleIntensity, paint);
            break;
        }
      }
    }

    // Draw industrial smokestacks with steam
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 6 * intensity;

    for (int i = 0; i < 3; i++) {
      final stackX = size.width * (0.15 + i * 0.35);
      final stackHeight = (40 + i * 10) * intensity;

      paint.color = primaryColor.withOpacity(0.15 * intensity);
      canvas.drawLine(
        Offset(stackX, size.height),
        Offset(stackX, size.height - stackHeight),
        paint,
      );

      // Draw steam coming out of stacks
      paint.style = PaintingStyle.fill;
      for (int j = 0; j < 3; j++) {
        final steamOffset = (animation * 0.8 + j * 0.3) % 1.0;
        final steamY = size.height - stackHeight - steamOffset * 30 * intensity;
        final steamSize = (6 + steamOffset * 8) * intensity;
        final steamOpacity = (1.0 - steamOffset) * 0.2 * intensity;

        paint.color = Colors.white.withOpacity(steamOpacity);
        canvas.drawCircle(
          Offset(stackX + math.sin(steamOffset * 2 * math.pi) * 8 * intensity, steamY),
          steamSize,
          paint,
        );
      }
      paint.style = PaintingStyle.stroke;
    }

    // Draw clockwork mechanisms (rotating mechanical patterns)
    paint.strokeWidth = 1.5 * intensity;

    for (int i = 0; i < 3; i++) {
      final clockX = size.width * (0.2 + i * 0.3);
      final clockY = size.height * (0.3 + math.sin(animation * 1.5 * math.pi + i) * 0.1);
      final clockRadius = (25 + i * 5) * intensity;
      final clockRotation = animation * 2 * math.pi * (i % 2 == 0 ? 1 : -0.5);

      final clockOpacity = (0.06 + math.cos(animation * 2 * math.pi + i * 0.9) * 0.02) * intensity;
      paint.color = accentColor.withOpacity(clockOpacity);

      canvas.save();
      canvas.translate(clockX, clockY);
      canvas.rotate(clockRotation);

      // Draw clockwork spokes
      for (int j = 0; j < 8; j++) {
        final spokeAngle = j * math.pi / 4;
        canvas.drawLine(
          Offset(math.cos(spokeAngle) * clockRadius * 0.3, math.sin(spokeAngle) * clockRadius * 0.3),
          Offset(math.cos(spokeAngle) * clockRadius, math.sin(spokeAngle) * clockRadius),
          paint,
        );
      }

      // Draw outer ring
      paint.style = PaintingStyle.stroke;
      canvas.drawCircle(Offset.zero, clockRadius, paint);
      canvas.drawCircle(Offset.zero, clockRadius * 0.7, paint);

      canvas.restore();
      paint.style = PaintingStyle.stroke;
    }

    // Draw pressure gauges (circular dials)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < 4; i++) {
      final gaugeX = size.width * (0.1 + i * 0.25) + math.sin(animation * math.pi + i) * 10 * intensity;
      final gaugeY = size.height * (0.1 + i * 0.05);
      final gaugeRadius = (12 + i * 2) * intensity;

      final gaugeIntensity = math.sin(animation * 3 * math.pi + i * 1.1) * 0.4 + 0.6;
      paint.color = primaryColor.withOpacity(0.1 * gaugeIntensity * intensity);

      // Draw gauge circle
      canvas.drawCircle(Offset(gaugeX, gaugeY), gaugeRadius, paint);

      // Draw gauge needle
      final needleAngle = animation * 4 * math.pi + i * math.pi / 2;
      paint.strokeWidth = 1 * intensity;
      canvas.drawLine(
        Offset(gaugeX, gaugeY),
        Offset(
          gaugeX + math.cos(needleAngle) * gaugeRadius * 0.8,
          gaugeY + math.sin(needleAngle) * gaugeRadius * 0.8,
        ),
        paint,
      );

      // Draw gauge marks
      for (int j = 0; j < 8; j++) {
        final markAngle = j * math.pi / 4;
        final markStart = Offset(
          gaugeX + math.cos(markAngle) * gaugeRadius * 0.85,
          gaugeY + math.sin(markAngle) * gaugeRadius * 0.85,
        );
        final markEnd = Offset(
          gaugeX + math.cos(markAngle) * gaugeRadius * 0.95,
          gaugeY + math.sin(markAngle) * gaugeRadius * 0.95,
        );
        canvas.drawLine(markStart, markEnd, paint);
      }
    }

    // Draw copper patina effects (subtle color variations)
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (6 * intensity).round(); i++) {
      final patinaX = random.nextDouble() * size.width;
      final patinaY = random.nextDouble() * size.height;
      final patinaSize = (20 + random.nextDouble() * 30) * intensity;

      final patinaIntensity = math.sin(animation * 1.5 * math.pi + i * 0.6) * 0.2 + 0.3;

      // Create verdigris (green patina) effect
      paint.color = const Color(0xFF40826D).withOpacity(0.03 * patinaIntensity * intensity);
      canvas.drawCircle(Offset(patinaX, patinaY), patinaSize, paint);
    }
  }

  void _drawGear(Canvas canvas, Paint paint, Offset center, double radius, double rotation, int teeth) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final path = Path();
    final toothHeight = radius * 0.2;
    final innerRadius = radius * 0.7;

    for (int i = 0; i < teeth; i++) {
      final angle = i * 2 * math.pi / teeth;
      final nextAngle = (i + 1) * 2 * math.pi / teeth;

      // Outer tooth
      final toothStart = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final toothPeak = Offset(math.cos(angle + math.pi / teeth / 2) * (radius + toothHeight),
          math.sin(angle + math.pi / teeth / 2) * (radius + toothHeight));
      final toothEnd = Offset(math.cos(nextAngle) * radius, math.sin(nextAngle) * radius);

      if (i == 0) path.moveTo(toothStart.dx, toothStart.dy);
      path.lineTo(toothPeak.dx, toothPeak.dy);
      path.lineTo(toothEnd.dx, toothEnd.dy);
    }
    path.close();

    canvas.drawPath(path, paint);

    // Draw inner circle
    canvas.drawCircle(Offset.zero, innerRadius, paint);

    // Draw spokes
    for (int i = 0; i < 4; i++) {
      final spokeAngle = i * math.pi / 2;
      canvas.drawLine(
        Offset(math.cos(spokeAngle) * innerRadius * 0.3, math.sin(spokeAngle) * innerRadius * 0.3),
        Offset(math.cos(spokeAngle) * innerRadius, math.sin(spokeAngle) * innerRadius),
        paint,
      );
    }

    canvas.restore();
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + math.cos(angle) * radius;
      final y = center.dy + math.sin(angle) * radius;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
