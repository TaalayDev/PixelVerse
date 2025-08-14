import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildEmeraldForestTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.emeraldForest,
    isDark: false,
    // Primary colors - rich emerald green
    primaryColor: const Color(0xFF50C878), // Emerald green
    primaryVariant: const Color(0xFF2E8B57), // Sea green
    onPrimary: Colors.white,
    // Secondary colors - forest gold
    accentColor: const Color(0xFFDAA520), // Goldenrod
    onAccent: Colors.black,
    // Background colors - soft natural tones
    background: const Color(0xFFF0F8F0), // Honeydew (very light green)
    surface: const Color(0xFFFFFFFF), // Pure white
    surfaceVariant: const Color(0xFFE8F5E8), // Light mint green
    // Text colors - deep forest tones
    textPrimary: const Color(0xFF1C3A1C), // Dark forest green
    textSecondary: const Color(0xFF2F5233), // Medium forest green
    textDisabled: const Color(0xFF8FBC8F), // Light sea green
    // UI colors
    divider: const Color(0xFFD4E6D4), // Very light green
    toolbarColor: const Color(0xFFE8F5E8),
    error: const Color(0xFFB22222), // Fire brick red
    success: const Color(0xFF228B22), // Forest green
    warning: const Color(0xFFFF8C00), // Dark orange
    // Grid colors
    gridLine: const Color(0xFFD4E6D4),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFF50C878), // Match primary
    selectionFill: const Color(0x3050C878),
    // Icon colors
    activeIcon: const Color(0xFF50C878), // Emerald for active
    inactiveIcon: const Color(0xFF2F5233), // Forest green for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF1C3A1C),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF1C3A1C),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF1C3A1C),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF2F5233),
      ),
    ),
    primaryFontWeight: FontWeight.w500, // Natural, readable weight
  );
}

// Emerald Forest theme background with mystical forest effects
class EmeraldForestBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const EmeraldForestBackground({
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

    final forestAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _EmeraldForestPainter(
        animation: forestAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _EmeraldForestPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _EmeraldForestPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(333); // Fixed seed for consistent forest

    // Draw forest canopy layers (depth effect)
    for (int layer = 0; layer < 4; layer++) {
      final canopyY = size.height * (0.1 + layer * 0.15);
      final layerOpacity = (0.02 + layer * 0.01) * intensity;

      final path = Path();
      path.moveTo(0, canopyY);

      // Create organic canopy shapes
      for (double x = 0; x <= size.width; x += 15) {
        final canopyWave = math.sin(x / 100 + animation * 1.5 * math.pi + layer * 0.5) * 20 * intensity;
        final leafVariation = math.sin(x / 40 + animation * 2 * math.pi + layer) * 8 * intensity;
        final y = canopyY + canopyWave + leafVariation;
        path.lineTo(x, y);
      }

      // Complete the canopy fill
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();

      paint.color = Color.lerp(
        primaryColor.withOpacity(layerOpacity),
        const Color(0xFF228B22).withOpacity(layerOpacity * 0.8), // Forest green mix
        layer / 3.0,
      )!;

      canvas.drawPath(path, paint);
    }

    // Draw mystical floating leaves
    for (int i = 0; i < (25 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Leaves drift gently in forest breeze
      final driftX = baseX + math.sin(animation * 1.2 * math.pi + i * 0.3) * 25 * intensity;
      final driftY = baseY + math.cos(animation * 0.8 * math.pi + i * 0.5) * 15 * intensity;

      final leafSize = (3 + random.nextDouble() * 6) * intensity;
      final leafRotation = animation * math.pi + i * 0.4;
      final shimmer = math.sin(animation * 4 * math.pi + i * 0.7) * 0.5 + 0.5;

      if (shimmer > 0.3) {
        canvas.save();
        canvas.translate(driftX, driftY);
        canvas.rotate(leafRotation);

        // Draw leaf shape (oval with slight curve)
        final leafPath = Path();
        leafPath.moveTo(0, -leafSize);
        leafPath.quadraticBezierTo(leafSize * 0.6, -leafSize * 0.3, leafSize * 0.8, 0);
        leafPath.quadraticBezierTo(leafSize * 0.4, leafSize * 0.8, 0, leafSize);
        leafPath.quadraticBezierTo(-leafSize * 0.4, leafSize * 0.8, -leafSize * 0.8, 0);
        leafPath.quadraticBezierTo(-leafSize * 0.6, -leafSize * 0.3, 0, -leafSize);
        leafPath.close();

        paint.color = Color.lerp(
          primaryColor.withOpacity(0.4 * shimmer),
          const Color(0xFF9ACD32).withOpacity(0.5 * shimmer), // Yellow green
          math.sin(animation * 3 * math.pi + i) * 0.5 + 0.5,
        )!;

        canvas.drawPath(leafPath, paint);

        // Add leaf vein (center line)
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 0.5 * intensity;
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.6);
        canvas.drawLine(Offset(0, -leafSize * 0.8), Offset(0, leafSize * 0.8), paint);
        paint.style = PaintingStyle.fill;

        canvas.restore();
      }
    }

    // Draw enchanted forest sprites/fireflies
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final spriteX = random.nextDouble() * size.width;
      final spriteY = random.nextDouble() * size.height;

      // Sprites move in magical patterns
      final magicX = spriteX + math.sin(animation * 2.5 * math.pi + i * 0.6) * 30 * intensity;
      final magicY = spriteY + math.cos(animation * 1.8 * math.pi + i * 0.4) * 20 * intensity;

      final spriteGlow = math.sin(animation * 6 * math.pi + i * 0.9) * 0.5 + 0.5;

      if (spriteGlow > 0.6) {
        final glowRadius = (2 + spriteGlow * 4) * intensity;

        // Core sprite light
        paint.color = accentColor.withOpacity(0.8 * spriteGlow);
        canvas.drawCircle(Offset(magicX, magicY), glowRadius * 0.6, paint);

        // Outer magical glow
        paint.color = accentColor.withOpacity(0.2 * spriteGlow);
        canvas.drawCircle(Offset(magicX, magicY), glowRadius * 1.8, paint);

        // Sparkle trails
        for (int j = 0; j < 4; j++) {
          final trailAngle = j * math.pi / 2 + animation * 3 * math.pi;
          final trailDistance = glowRadius * 2.5;
          final trailX = magicX + math.cos(trailAngle) * trailDistance;
          final trailY = magicY + math.sin(trailAngle) * trailDistance;

          paint.color = accentColor.withOpacity(0.3 * spriteGlow);
          canvas.drawCircle(Offset(trailX, trailY), glowRadius * 0.3, paint);
        }
      }
    }

    // Draw forest floor mushrooms/fungi
    for (int i = 0; i < (8 * intensity).round(); i++) {
      final mushroomX = (i / 8.0) * size.width + random.nextDouble() * 40 - 20;
      final mushroomY = size.height * (0.85 + random.nextDouble() * 0.1);
      final mushroomSize = (6 + random.nextDouble() * 8) * intensity;

      final mushroomGlow = math.sin(animation * 2 * math.pi + i * 0.8) * 0.3 + 0.4;

      // Mushroom cap (dome)
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.15 * mushroomGlow),
        const Color(0xFF8B4513).withOpacity(0.1 * mushroomGlow), // Saddle brown
        mushroomGlow,
      )!;

      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(mushroomX, mushroomY - mushroomSize * 0.3),
          width: mushroomSize * 2,
          height: mushroomSize,
        ),
        0,
        math.pi,
        true,
        paint,
      );

      // Mushroom stem
      paint.color = const Color(0xFFF5F5DC).withOpacity(0.1 * mushroomGlow); // Beige
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(mushroomX, mushroomY),
          width: mushroomSize * 0.3,
          height: mushroomSize * 0.8,
        ),
        paint,
      );
    }

    // Draw sunlight rays filtering through canopy
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;

    for (int i = 0; i < (6 * intensity).round(); i++) {
      final rayX = size.width * (0.1 + i * 0.15);
      final rayAngle = (15 + i * 5) * math.pi / 180; // Slight angles
      final rayLength = (80 + math.sin(animation * 1.5 * math.pi + i) * 20) * intensity;

      final rayEndX = rayX + math.cos(rayAngle) * rayLength;
      final rayEndY = math.sin(rayAngle) * rayLength;

      final rayIntensity = math.sin(animation * 2 * math.pi + i * 0.7) * 0.3 + 0.4;

      // Create sunbeam gradient effect
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withOpacity(0.08 * rayIntensity * intensity),
          accentColor.withOpacity(0.02 * rayIntensity * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromPoints(Offset(rayX, 0), Offset(rayEndX, rayEndY)));

      canvas.drawLine(Offset(rayX, 0), Offset(rayEndX, rayEndY), paint);
    }

    paint.shader = null;
    paint.style = PaintingStyle.fill;

    // Draw mystical forest mist
    for (int i = 0; i < 5; i++) {
      final mistX = size.width * (0.15 + i * 0.2);
      final mistY = size.height * (0.6 + math.sin(animation * math.pi + i * 0.6) * 0.15);
      final mistWidth = (60 + i * 10 + math.cos(animation * 1.5 * math.pi + i) * 15) * intensity;
      final mistHeight = (20 + math.sin(animation * 2 * math.pi + i * 0.3) * 8) * intensity;

      paint.color = primaryColor.withOpacity(0.015 * intensity);

      // Create soft, oval mist shapes
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(mistX, mistY),
          width: mistWidth,
          height: mistHeight,
        ),
        paint,
      );
    }

    // Draw forest floor flowers (small accents)
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final flowerX = random.nextDouble() * size.width;
      final flowerY = size.height * (0.8 + random.nextDouble() * 0.15);

      final bloom = math.sin(animation * 3 * math.pi + i * 0.4) * 0.5 + 0.5;

      if (bloom > 0.7) {
        final flowerSize = (2 + bloom * 3) * intensity;

        // Draw simple flower petals
        for (int petal = 0; petal < 5; petal++) {
          final petalAngle = petal * 2 * math.pi / 5;
          final petalX = flowerX + math.cos(petalAngle) * flowerSize;
          final petalY = flowerY + math.sin(petalAngle) * flowerSize;

          paint.color = Color.lerp(
            accentColor.withOpacity(0.4 * bloom),
            const Color(0xFFFFB6C1).withOpacity(0.3 * bloom), // Light pink
            bloom,
          )!;

          canvas.drawCircle(Offset(petalX, petalY), flowerSize * 0.4, paint);
        }

        // Flower center
        paint.color = accentColor.withOpacity(0.6 * bloom);
        canvas.drawCircle(Offset(flowerX, flowerY), flowerSize * 0.3, paint);
      }
    }

    // Draw ancient tree spirits (subtle energy wisps)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5 * intensity;

    for (int i = 0; i < 3; i++) {
      final spiritCenterX = size.width * (0.25 + i * 0.25);
      final spiritCenterY = size.height * (0.4 + math.cos(animation * 1.2 * math.pi + i) * 0.2);

      // Create spiral energy pattern
      final path = Path();
      final spiralRadius = 25 * intensity;
      final spiralTurns = 2.5;

      for (double t = 0; t <= 1; t += 0.02) {
        final angle = t * spiralTurns * 2 * math.pi + animation * 4 * math.pi;
        final radius = spiralRadius * (1 - t) * (0.8 + 0.2 * math.sin(animation * 3 * math.pi + i));
        final x = spiritCenterX + math.cos(angle) * radius;
        final y = spiritCenterY + math.sin(angle) * radius;

        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }

      final spiritIntensity = math.sin(animation * 2.5 * math.pi + i * 1.1) * 0.4 + 0.5;
      paint.color = primaryColor.withOpacity(0.1 * spiritIntensity * intensity);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
