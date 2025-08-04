import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildMidnightTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.midnight,
    isDark: true,
    primaryColor: const Color(0xFF6A3DE8),
    primaryVariant: const Color(0xFF8056EA),
    onPrimary: Colors.white,
    accentColor: const Color(0xFF03DAC6),
    onAccent: Colors.black,
    background: const Color(0xFF0A1021),
    surface: const Color(0xFF162041),
    surfaceVariant: const Color(0xFF1D2A59),
    textPrimary: Colors.white,
    textSecondary: const Color(0xFFB8C7E0),
    textDisabled: const Color(0xFF6987B7),
    divider: const Color(0xFF2B3966),
    toolbarColor: const Color(0xFF162041),
    error: const Color(0xFFF45E89),
    success: const Color(0xFF4ADE80),
    warning: const Color(0xFFF9AE59),
    gridLine: const Color(0xFF2B3966),
    gridBackground: const Color(0xFF1D2A59),
    canvasBackground: const Color(0xFF0A1021),
    selectionOutline: const Color(0xFF03DAC6),
    selectionFill: const Color(0x3003DAC6),
    activeIcon: const Color(0xFF6A3DE8),
    inactiveIcon: const Color(0xFFB8C7E0),
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: Colors.white,
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFB8C7E0),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Midnight theme background with aurora-like effects
class MidnightBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const MidnightBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final waveAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _MidnightPainter(
        animation: waveAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _MidnightPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _MidnightPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * intensity;

    // Draw aurora-like waves
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final waveHeight = 20 * intensity;
      final waveLength = size.width / 3;
      final phase = animation * 2 * math.pi + i * math.pi / 3;

      path.moveTo(0, size.height * 0.2 + i * 30);

      for (double x = 0; x <= size.width; x += 5) {
        final y = size.height * 0.2 + i * 30 + math.sin(x / waveLength * 2 * math.pi + phase) * waveHeight;
        path.lineTo(x, y);
      }

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.1),
        accentColor.withOpacity(0.15),
        (i / 4.0),
      )!;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
