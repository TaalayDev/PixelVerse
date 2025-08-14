import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildDreamscapeTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.dreamscape,
    isDark: false,
    // Primary colors - dreamy lavender
    primaryColor: const Color(0xFF9B59B6), // Rich lavender
    primaryVariant: const Color(0xFF8E44AD), // Deeper purple
    onPrimary: Colors.white,
    // Secondary colors - soft rose
    accentColor: const Color(0xFFE91E63), // Soft rose pink
    onAccent: Colors.white,
    // Background colors - cloud white with hints
    background: const Color(0xFFFAF8FF), // Very light lavender white
    surface: const Color(0xFFFFFFFF), // Pure white clouds
    surfaceVariant: const Color(0xFFF5F0FF), // Light lavender
    // Text colors - deep dream purple
    textPrimary: const Color(0xFF4A4458), // Deep dreamy purple
    textSecondary: const Color(0xFF6A5D7B), // Medium dream purple
    textDisabled: const Color(0xFFB8A9C9), // Light dreamy purple
    // UI colors
    divider: const Color(0xFFE8E0F0), // Very light purple
    toolbarColor: const Color(0xFFF5F0FF),
    error: const Color(0xFFE74C3C), // Bright red for contrast
    success: const Color(0xFF27AE60), // Fresh green
    warning: const Color(0xFFF39C12), // Warm orange
    // Grid colors
    gridLine: const Color(0xFFE8E0F0),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFF9B59B6), // Match primary
    selectionFill: const Color(0x309B59B6),
    // Icon colors
    activeIcon: const Color(0xFF9B59B6), // Dreamy purple for active
    inactiveIcon: const Color(0xFF6A5D7B), // Medium purple for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF4A4458),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF4A4458),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF4A4458),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF6A5D7B),
      ),
    ),
    primaryFontWeight: FontWeight.w400, // Light weight for dreamy feel
  );
}

class DreamscapeBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const DreamscapeBackground({
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
        controller.repeat(reverse: true);
      } else {
        controller.stop();
      }
      return null;
    }, [enableAnimation]);

    final dreamAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _DreamscapePainter(
        animation: dreamAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _DreamscapePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _DreamscapePainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(999); // Dreamy seed

    // Draw floating dream clouds
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final baseX = size.width * (0.1 + i * 0.12);
      final baseY = size.height * (0.2 + math.sin(animation * 1.5 * math.pi + i * 0.8) * 0.3);

      final cloudSize = (25 + i * 8 + math.sin(animation * 2 * math.pi + i) * 12) * intensity;
      final opacity = (0.03 + math.cos(animation * math.pi + i * 0.6) * 0.015) * intensity;

      // Create fluffy cloud shapes with multiple overlapping circles
      final cloudColor = Color.lerp(primaryColor, accentColor, i / 7.0)!;
      paint.color = cloudColor.withOpacity(opacity);

      // Main cloud body
      canvas.drawCircle(Offset(baseX, baseY), cloudSize, paint);

      // Additional puffs for cloud-like effect
      canvas.drawCircle(
        Offset(baseX - cloudSize * 0.4, baseY - cloudSize * 0.2),
        cloudSize * 0.8,
        paint,
      );
      canvas.drawCircle(
        Offset(baseX + cloudSize * 0.3, baseY - cloudSize * 0.3),
        cloudSize * 0.6,
        paint,
      );
      canvas.drawCircle(
        Offset(baseX + cloudSize * 0.1, baseY + cloudSize * 0.4),
        cloudSize * 0.7,
        paint,
      );
    }

    // Draw dreamy stars
    for (int i = 0; i < (30 * intensity).round(); i++) {
      final starX = random.nextDouble() * size.width;
      final starY = random.nextDouble() * size.height;
      final twinkle = math.sin(animation * 4 * math.pi + i * 0.3) * 0.5 + 0.5;

      if (twinkle > 0.6) {
        final starSize = (1.5 + twinkle * 3) * intensity;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.4 * twinkle),
          accentColor.withOpacity(0.5 * twinkle),
          math.sin(animation * 2 * math.pi + i) * 0.5 + 0.5,
        )!;

        // Draw cross-shaped twinkling star
        canvas.drawCircle(Offset(starX, starY), starSize, paint);

        // Add sparkle effect
        paint.strokeWidth = 1 * intensity;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(starX - starSize * 2, starY),
          Offset(starX + starSize * 2, starY),
          paint,
        );
        canvas.drawLine(
          Offset(starX, starY - starSize * 2),
          Offset(starX, starY + starSize * 2),
          paint,
        );
        paint.style = PaintingStyle.fill;
      }
    }

    // Draw floating dream bubbles
    for (int i = 0; i < (18 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion
      final floatX = baseX + math.sin(animation * 1.8 * math.pi + i * 0.4) * 18 * intensity;
      final floatY = baseY + math.cos(animation * 1.2 * math.pi + i * 0.6) * 12 * intensity;

      final bubbleSize = (4 + random.nextDouble() * 12) * intensity;
      final bubbleOpacity = (0.05 + math.sin(animation * 3 * math.pi + i * 0.7) * 0.02) * intensity;

      // Alternate between dreamy colors
      paint.color = (i % 3 == 0
              ? primaryColor
              : i % 3 == 1
                  ? accentColor
                  : Color.lerp(primaryColor, accentColor, 0.5)!)
          .withOpacity(bubbleOpacity);

      canvas.drawCircle(Offset(floatX, floatY), bubbleSize, paint);

      // Add soft glow around bubbles
      paint.color = paint.color.withOpacity(bubbleOpacity * 0.3);
      canvas.drawCircle(Offset(floatX, floatY), bubbleSize * 1.6, paint);
    }

    // Draw dream mist/ethereal wisps
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final startX = size.width * (0.1 + i * 0.2);
      final startY = size.height * (0.4 + math.sin(animation * 1.5 * math.pi + i) * 0.2);

      path.moveTo(startX, startY);

      // Create flowing, organic dream wisp paths
      for (int j = 1; j <= 6; j++) {
        final progress = j / 6.0;
        final x = startX +
            progress * 80 * intensity +
            math.sin(progress * 4 * math.pi + animation * 2 * math.pi + i) * 25 * intensity;
        final y = startY + math.cos(progress * 3 * math.pi + animation * 1.5 * math.pi + i * 0.7) * 30 * intensity;
        path.lineTo(x, y);
      }

      final wispIntensity = math.sin(animation * 2.5 * math.pi + i * 0.9) * 0.4 + 0.5;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.1 * wispIntensity * intensity),
        accentColor.withOpacity(0.08 * wispIntensity * intensity),
        i / 4.0,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw floating dream petals
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.15 + random.nextDouble() * 0.2; // Very slow falling

      final progress = (animation * speed + i * 0.08) % 1.3;
      final petalY = progress * (size.height + 40) - 20;
      final sway = math.sin(progress * 3 * math.pi + i) * 20 * intensity;
      final petalX = baseX + sway;

      if (petalY > -20 && petalY < size.height + 20) {
        final opacity = math.max(0.0, (1.3 - progress) * 0.4) * intensity;
        final rotation = progress * math.pi + i;

        paint.color = Color.lerp(
          primaryColor.withOpacity(opacity),
          accentColor.withOpacity(opacity * 0.8),
          (i % 3) / 2.0,
        )!;

        canvas.save();
        canvas.translate(petalX, petalY);
        canvas.rotate(rotation);

        // Draw petal shape (elongated oval)
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: (3 + random.nextDouble() * 2) * intensity,
            height: (6 + random.nextDouble() * 3) * intensity,
          ),
          paint,
        );

        canvas.restore();
      }
    }

    // Draw dream ribbons/streamers
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * intensity;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final ribbonStartX = size.width * (0.2 + i * 0.3);
      final ribbonStartY = size.height * 0.1;

      path.moveTo(ribbonStartX, ribbonStartY);

      // Create flowing ribbon path
      for (double t = 0; t <= 1; t += 0.05) {
        final x = ribbonStartX +
            t * size.width * 0.4 +
            math.sin(t * 6 * math.pi + animation * 3 * math.pi + i) * 40 * intensity;
        final y = ribbonStartY +
            t * size.height * 0.6 +
            math.cos(t * 4 * math.pi + animation * 2 * math.pi + i * 0.8) * 25 * intensity;
        path.lineTo(x, y);
      }

      final ribbonIntensity = math.sin(animation * 2 * math.pi + i * 1.1) * 0.3 + 0.4;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.06 * ribbonIntensity * intensity),
        accentColor.withOpacity(0.08 * ribbonIntensity * intensity),
        i / 2.0,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw dream portals/vortexes
    paint.style = PaintingStyle.stroke;
    for (int i = 0; i < 2; i++) {
      final portalX = size.width * (0.25 + i * 0.5);
      final portalY = size.height * (0.3 + i * 0.4);
      final portalSize = (20 + i * 10) * intensity;

      final portalIntensity = math.sin(animation * 4 * math.pi + i * 2) * 0.5 + 0.5;

      // Draw concentric circles for portal effect
      for (int j = 0; j < 4; j++) {
        final radius = portalSize * (0.3 + j * 0.25) * portalIntensity;
        paint.strokeWidth = (1 + j * 0.5) * intensity;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.1 * portalIntensity * intensity),
          accentColor.withOpacity(0.08 * portalIntensity * intensity),
          j / 3.0,
        )!;

        canvas.drawCircle(Offset(portalX, portalY), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
