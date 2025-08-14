import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildIceCrystalTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.iceCrystal,
    isDark: false,
    // Primary colors - icy blue
    primaryColor: const Color(0xFF4FC3F7), // Light blue/ice blue
    primaryVariant: const Color(0xFF29B6F6), // Slightly deeper blue
    onPrimary: Colors.white,
    // Secondary colors - crystal cyan
    accentColor: const Color(0xFF80DEEA), // Light cyan
    onAccent: const Color(0xFF004D5A), // Dark teal for contrast
    // Background colors - very light ice-like
    background: const Color(0xFFF8FCFF), // Very light blue-white
    surface: const Color(0xFFFFFFFF), // Pure white like fresh snow
    surfaceVariant: const Color(0xFFF0F8FF), // Alice blue
    // Text colors - dark for contrast on light ice
    textPrimary: const Color(0xFF0D47A1), // Dark blue
    textSecondary: const Color(0xFF1976D2), // Medium blue
    textDisabled: const Color(0xFF90CAF9), // Light blue
    // UI colors
    divider: const Color(0xFFE3F2FD), // Very light blue
    toolbarColor: const Color(0xFFF0F8FF),
    error: const Color(0xFFD32F2F), // Red for visibility
    success: const Color(0xFF388E3C), // Green for visibility
    warning: const Color(0xFFF57C00), // Orange for visibility
    // Grid colors
    gridLine: const Color(0xFFE3F2FD),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFF4FC3F7), // Match primary
    selectionFill: const Color(0x304FC3F7),
    // Icon colors
    activeIcon: const Color(0xFF4FC3F7), // Ice blue for active
    inactiveIcon: const Color(0xFF1976D2), // Darker blue for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF0D47A1),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF0D47A1),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF0D47A1),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF1976D2),
      ),
    ),
    primaryFontWeight: FontWeight.w500, // Clean, crisp weight
  );
}

// Ice Crystal theme background with crystalline formations
class IceCrystalBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const IceCrystalBackground({
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

    final crystalAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _IceCrystalPainter(
        animation: crystalAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _IceCrystalPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _IceCrystalPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final random = math.Random(123); // Fixed seed for consistent crystals

    // Draw ice crystal formations
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final centerX = random.nextDouble() * size.width;
      final centerY = random.nextDouble() * size.height;
      final crystalSize = (20 + random.nextDouble() * 40) * intensity;
      final growth = 0.7 + math.sin(animation * 2 * math.pi + i * 0.5) * 0.3;
      final currentSize = crystalSize * growth;

      final opacity = (0.15 + math.cos(animation * 1.5 * math.pi + i * 0.3) * 0.05) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(opacity),
        accentColor.withOpacity(opacity * 0.8),
        i % 2 == 0 ? 0.3 : 0.7,
      )!;
      paint.strokeWidth = (1.5 + random.nextDouble() * 1) * intensity;

      // Draw hexagonal crystal structure
      final path = Path();
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final x = centerX + math.cos(angle) * currentSize;
        final y = centerY + math.sin(angle) * currentSize;

        if (j == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);

      // Draw inner crystal lines
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final innerX = centerX + math.cos(angle) * currentSize * 0.6;
        final innerY = centerY + math.sin(angle) * currentSize * 0.6;
        canvas.drawLine(Offset(centerX, centerY), Offset(innerX, innerY), paint);
      }
    }

    // Draw floating ice particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion
      final floatX = baseX + math.sin(animation * 1.5 * math.pi + i * 0.4) * 8 * intensity;
      final floatY = baseY + math.cos(animation * math.pi + i * 0.6) * 12 * intensity;

      final particleSize = (1.5 + random.nextDouble() * 3) * intensity;
      final sparkleIntensity = math.sin(animation * 3 * math.pi + i * 0.8) * 0.5 + 0.5;

      if (sparkleIntensity > 0.4) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.6 * sparkleIntensity),
          accentColor.withOpacity(0.4 * sparkleIntensity),
          math.sin(animation * 2 * math.pi + i) * 0.5 + 0.5,
        )!;

        canvas.drawCircle(Offset(floatX, floatY), particleSize * sparkleIntensity, paint);
      }
    }

    // Draw frost spreading patterns
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * intensity;

    for (int i = 0; i < 4; i++) {
      final startX = size.width * (0.1 + i * 0.25);
      final startY = size.height * (0.2 + math.sin(animation * math.pi + i) * 0.3);
      final spreadProgress = (animation + i * 0.25) % 1.0;

      final opacity = (0.08 + math.cos(animation * 2 * math.pi + i * 0.7) * 0.03) * intensity;
      paint.color = primaryColor.withOpacity(opacity);

      // Draw branching frost patterns
      _drawFrostBranch(canvas, paint, Offset(startX, startY), 0, 30 * intensity * spreadProgress, 4, spreadProgress);
    }

    // Draw snowflake-like patterns
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5 * intensity;

    for (int i = 0; i < (6 * intensity).round(); i++) {
      final snowflakeX = random.nextDouble() * size.width;
      final snowflakeY = random.nextDouble() * size.height;
      final snowflakeSize = (8 + random.nextDouble() * 12) * intensity;
      final rotation = animation * 2 * math.pi * (i % 2 == 0 ? 1 : -1) + i;

      final opacity = (0.12 + math.sin(animation * 2.5 * math.pi + i * 0.9) * 0.04) * intensity;
      paint.color = accentColor.withOpacity(opacity);

      canvas.save();
      canvas.translate(snowflakeX, snowflakeY);
      canvas.rotate(rotation);

      // Draw 6-pointed snowflake
      for (int j = 0; j < 6; j++) {
        final angle = j * math.pi / 3;
        final endX = math.cos(angle) * snowflakeSize;
        final endY = math.sin(angle) * snowflakeSize;

        canvas.drawLine(Offset.zero, Offset(endX, endY), paint);

        // Draw small branches
        final branchSize = snowflakeSize * 0.3;
        final branchX1 = math.cos(angle + math.pi / 6) * branchSize + endX * 0.6;
        final branchY1 = math.sin(angle + math.pi / 6) * branchSize + endY * 0.6;
        final branchX2 = math.cos(angle - math.pi / 6) * branchSize + endX * 0.6;
        final branchY2 = math.sin(angle - math.pi / 6) * branchSize + endY * 0.6;

        canvas.drawLine(Offset(endX * 0.6, endY * 0.6), Offset(branchX1, branchY1), paint);
        canvas.drawLine(Offset(endX * 0.6, endY * 0.6), Offset(branchX2, branchY2), paint);
      }

      canvas.restore();
    }

    // Draw icicle formations
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (5 * intensity).round(); i++) {
      final icicleX = (i / 5) * size.width + size.width * 0.1;
      final icicleLength = (30 + math.sin(animation * 1.5 * math.pi + i) * 15) * intensity;
      final icicleWidth = (6 + i * 2) * intensity;

      final opacity = (0.06 + math.cos(animation * math.pi + i * 0.8) * 0.02) * intensity;
      paint.color = Color.lerp(
        primaryColor.withOpacity(opacity),
        accentColor.withOpacity(opacity * 0.7),
        i / 4.0,
      )!;

      // Draw icicle shape
      final path = Path();
      path.moveTo(icicleX - icicleWidth / 2, 0);
      path.lineTo(icicleX + icicleWidth / 2, 0);
      path.lineTo(icicleX, icicleLength);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  void _drawFrostBranch(
      Canvas canvas, Paint paint, Offset start, double angle, double length, int depth, double progress) {
    if (depth <= 0 || length < 5) return;

    final endX = start.dx + math.cos(angle) * length * progress;
    final endY = start.dy + math.sin(angle) * length * progress;
    final end = Offset(endX, endY);

    canvas.drawLine(start, end, paint);

    if (progress > 0.3) {
      // Draw sub-branches
      _drawFrostBranch(canvas, paint, end, angle + math.pi / 4, length * 0.6, depth - 1, math.max(0, progress - 0.3));
      _drawFrostBranch(canvas, paint, end, angle - math.pi / 4, length * 0.6, depth - 1, math.max(0, progress - 0.3));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
