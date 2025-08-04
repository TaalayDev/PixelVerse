import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildForestTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.forest,
    isDark: false,
    primaryColor: const Color(0xFF2E7D32),
    primaryVariant: const Color(0xFF388E3C),
    onPrimary: Colors.white,
    accentColor: const Color(0xFFD3B047),
    onAccent: Colors.black,
    background: const Color(0xFFEFF4ED),
    surface: Colors.white,
    surfaceVariant: const Color(0xFFE1ECD8),
    textPrimary: const Color(0xFF1E3725),
    textSecondary: const Color(0xFF5C745F),
    textDisabled: const Color(0xFFA5B8A7),
    divider: const Color(0xFFD4E2CD),
    toolbarColor: const Color(0xFFE1ECD8),
    error: const Color(0xFFB71C1C),
    success: const Color(0xFF2E7D32),
    warning: const Color(0xFFF9A825),
    gridLine: const Color(0xFFD4E2CD),
    gridBackground: Colors.white,
    canvasBackground: Colors.white,
    selectionOutline: const Color(0xFF2E7D32),
    selectionFill: const Color(0x302E7D32),
    activeIcon: const Color(0xFF2E7D32),
    inactiveIcon: const Color(0xFF5C745F),
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF1E3725),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF1E3725),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF1E3725),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF5C745F),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Forest theme background with organic shapes
class ForestBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const ForestBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final breathingAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _ForestPainter(
        animation: breathingAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _ForestPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _ForestPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    // Draw organic, leaf-like shapes
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final centerX = random.nextDouble() * size.width;
      final centerY = random.nextDouble() * size.height;
      final radius = (20 + random.nextDouble() * 40) * intensity;
      final scale = 0.8 + animation * 0.4;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.02),
        accentColor.withOpacity(0.03),
        math.sin(animation * 2 * math.pi + i) * 0.5 + 0.5,
      )!;

      final path = Path();
      for (int j = 0; j < 8; j++) {
        final angle = j * math.pi / 4;
        final distance = radius * scale * (0.7 + 0.3 * math.sin(angle * 3));
        final x = centerX + math.cos(angle) * distance;
        final y = centerY + math.sin(angle) * distance;

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
