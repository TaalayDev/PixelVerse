import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core.dart';
import 'theme_selector.dart';

class AnimatedBackground extends HookConsumerWidget {
  final Widget child;
  final double intensity;
  final bool enableAnimation;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.intensity = 1.0,
    this.enableAnimation = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final animationController = useAnimationController(
      duration: _getAnimationDuration(theme.type),
    );

    useEffect(() {
      if (enableAnimation) {
        animationController.repeat();
      } else {
        animationController.stop();
      }
      return null;
    }, [enableAnimation]);

    return Stack(
      children: [
        // Base background
        Container(
          decoration: BoxDecoration(
            gradient: _getBaseGradient(theme),
          ),
        ),

        // Animated layer
        if (enableAnimation) _buildAnimatedLayer(theme, animationController),

        // Child content
        child,
      ],
    );
  }

  Duration _getAnimationDuration(ThemeType type) {
    switch (type) {
      case ThemeType.cosmic:
      case ThemeType.neon:
        return const Duration(seconds: 8);
      case ThemeType.midnight:
        return const Duration(seconds: 12);
      case ThemeType.ocean:
        return const Duration(seconds: 10);
      case ThemeType.forest:
        return const Duration(seconds: 15);
      case ThemeType.sunset:
        return const Duration(seconds: 6);
      case ThemeType.pastel:
        return const Duration(seconds: 20); // Slow, gentle animation
      case ThemeType.purpleRain:
        return const Duration(seconds: 4); // Fast rain animation
      case ThemeType.goldenHour:
        return const Duration(seconds: 14); // Slow, warm animation
      case ThemeType.cyberpunk:
        return const Duration(seconds: 15); // Much slower for less distraction
      case ThemeType.cherryBlossom:
        return const Duration(seconds: 25); // Very slow, peaceful falling petals
      case ThemeType.retroWave:
        return const Duration(seconds: 8); // Energetic 80s beat
      case ThemeType.iceCrystal:
        return const Duration(seconds: 18); // Slow, elegant crystalline movement
      case ThemeType.volcanic:
        return const Duration(seconds: 10); // Medium speed for flowing lava
      default:
        return const Duration(seconds: 10);
    }
  }

  Gradient _getBaseGradient(AppTheme theme) {
    switch (theme.type) {
      case ThemeType.volcanic:
        return LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.15)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.08)!,
            theme.background,
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        );

      case ThemeType.iceCrystal:
        return RadialGradient(
          center: Alignment.topLeft,
          radius: 1.2,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.04)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.02)!,
            theme.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      case ThemeType.retroWave:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.background,
            Color.lerp(theme.background, theme.primaryColor, 0.12)!,
            Color.lerp(theme.background, theme.accentColor, 0.08)!,
            theme.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      case ThemeType.cherryBlossom:
        return RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.03)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.02)!,
            theme.background,
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        );

      case ThemeType.cyberpunk:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.15)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.08)!,
            theme.background,
            Color.lerp(theme.background, theme.primaryColor, 0.05)!,
          ],
          stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
        );

      case ThemeType.goldenHour:
        return RadialGradient(
          center: Alignment.topRight,
          radius: 1.8,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.06)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.03)!,
            theme.background,
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        );

      case ThemeType.purpleRain:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.08)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.05)!,
            theme.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      case ThemeType.pastel:
        return RadialGradient(
          center: Alignment.topLeft,
          radius: 2.0,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.02)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.01)!,
            theme.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      case ThemeType.cosmic:
        return RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            theme.background,
            Color.lerp(theme.background, theme.primaryColor, 0.1)!,
            theme.background,
          ],
          stops: const [0.0, 0.4, 1.0],
        );

      case ThemeType.midnight:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.background,
            Color.lerp(theme.background, theme.primaryColor, 0.05)!,
            theme.background,
          ],
        );

      case ThemeType.ocean:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.02)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.03)!,
          ],
        );

      case ThemeType.forest:
        return RadialGradient(
          center: Alignment.bottomLeft,
          radius: 1.2,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.03)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.02)!,
          ],
        );

      case ThemeType.sunset:
        return LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.02)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.01)!,
          ],
        );

      case ThemeType.neon:
        return RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            theme.background,
            Color.lerp(theme.background, theme.primaryColor, 0.08)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.05)!,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.background,
            Color.lerp(theme.background, theme.primaryColor, 0.01)!,
          ],
        );
    }
  }

  Widget _buildAnimatedLayer(AppTheme theme, AnimationController controller) {
    switch (theme.type) {
      case ThemeType.volcanic:
        return _VolcanicBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.iceCrystal:
        return _IceCrystalBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.retroWave:
        return _RetroWaveBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.cherryBlossom:
        return _CherryBlossomBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.cyberpunk:
        return _CyberpunkBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.goldenHour:
        return _GoldenHourBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.purpleRain:
        return _PurpleRainBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.pastel:
        return _PastelBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.cosmic:
        return _CosmicBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.midnight:
        return _MidnightBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.ocean:
        return _OceanBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.forest:
        return _ForestBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.sunset:
        return _SunsetBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.neon:
        return _NeonBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.monochrome:
        return _MonochromeBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      default:
        return _DefaultBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );
    }
  }
}

// Volcanic theme background with lava flows and ember effects
class _VolcanicBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _VolcanicBackground({
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

// Ice Crystal theme background with crystalline formations
class _IceCrystalBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _IceCrystalBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
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

// Retro Wave theme background with 80s synthwave effects
class _RetroWaveBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _RetroWaveBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final synthAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _RetroWavePainter(
        animation: synthAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _RetroWavePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _RetroWavePainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw 80s perspective grid
    final gridSpacing = 40.0 * intensity;
    final horizonY = size.height * 0.6;
    final vanishingPointX = size.width * 0.5;

    // Horizontal grid lines (perspective)
    paint.strokeWidth = 1 * intensity;
    for (int i = 0; i < 8; i++) {
      final progress = i / 7.0;
      final y = horizonY + (size.height - horizonY) * progress * progress; // Perspective curve
      final pulseIntensity = (math.sin(animation * 4 * math.pi + i * 0.5) * 0.3 + 0.7) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.2 * pulseIntensity),
        accentColor.withOpacity(0.15 * pulseIntensity),
        math.sin(animation * 2 * math.pi + i * 0.3) * 0.5 + 0.5,
      )!;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical grid lines (perspective)
    for (int i = -10; i <= 10; i++) {
      if (i == 0) continue; // Skip center line

      final baseX = vanishingPointX + i * gridSpacing;
      final pulseOffset = math.sin(animation * 3 * math.pi + i * 0.2) * 5 * intensity;
      final x = baseX + pulseOffset;

      final pulseIntensity = (math.cos(animation * 4 * math.pi + i * 0.4) * 0.2 + 0.8) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.15 * pulseIntensity),
        accentColor.withOpacity(0.1 * pulseIntensity),
        i.abs() / 10.0,
      )!;

      canvas.drawLine(Offset(x, horizonY), Offset(x, size.height), paint);
    }

    // Draw neon scan lines
    paint.strokeWidth = 2 * intensity;
    final scanLine1Y = (animation * size.height) % size.height;
    final scanLine2Y = ((animation * 0.7 + 0.3) * size.height) % size.height;

    paint.color = primaryColor.withOpacity(0.6 * intensity);
    canvas.drawLine(Offset(0, scanLine1Y), Offset(size.width, scanLine1Y), paint);

    paint.color = accentColor.withOpacity(0.4 * intensity);
    canvas.drawLine(Offset(0, scanLine2Y), Offset(size.width, scanLine2Y), paint);

    // Draw pulsing geometric shapes
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3 * intensity;

    for (int i = 0; i < 3; i++) {
      final shapeX = size.width * (0.2 + i * 0.3);
      final shapeY = size.height * (0.2 + math.sin(animation * 2 * math.pi + i) * 0.1);
      final shapeSize = (30 + i * 15 + math.sin(animation * 3 * math.pi + i * 0.8) * 10) * intensity;

      final pulseIntensity = math.sin(animation * 4 * math.pi + i * 0.6) * 0.5 + 0.5;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.8 * pulseIntensity * intensity),
        accentColor.withOpacity(0.6 * pulseIntensity * intensity),
        i / 2.0,
      )!;

      // Draw different geometric shapes
      switch (i % 3) {
        case 0: // Triangle
          final path = Path();
          path.moveTo(shapeX, shapeY - shapeSize);
          path.lineTo(shapeX - shapeSize, shapeY + shapeSize);
          path.lineTo(shapeX + shapeSize, shapeY + shapeSize);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case 1: // Diamond
          final path = Path();
          path.moveTo(shapeX, shapeY - shapeSize);
          path.lineTo(shapeX + shapeSize, shapeY);
          path.lineTo(shapeX, shapeY + shapeSize);
          path.lineTo(shapeX - shapeSize, shapeY);
          path.close();
          canvas.drawPath(path, paint);
          break;
        case 2: // Circle
          canvas.drawCircle(Offset(shapeX, shapeY), shapeSize, paint);
          break;
      }
    }

    // Draw neon glow particles
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final particleX = (i / 12) * size.width + math.sin(animation * 3 * math.pi + i * 0.5) * 30 * intensity;
      final particleY = size.height * (0.3 + math.cos(animation * 2 * math.pi + i * 0.4) * 0.2);

      final glowIntensity = math.sin(animation * 6 * math.pi + i * 0.7) * 0.5 + 0.5;

      if (glowIntensity > 0.3) {
        final particleSize = (2 + glowIntensity * 4) * intensity;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.8 * glowIntensity),
          accentColor.withOpacity(0.6 * glowIntensity),
          math.sin(animation * math.pi + i) * 0.5 + 0.5,
        )!;

        canvas.drawCircle(Offset(particleX, particleY), particleSize, paint);

        // Add glow effect
        paint.color = paint.color.withOpacity(paint.color.opacity * 0.3);
        canvas.drawCircle(Offset(particleX, particleY), particleSize * 2, paint);
      }
    }

    // Draw digital sun/moon
    final sunCenter = Offset(size.width * 0.5, size.height * 0.25);
    final sunRadius = (40 + math.sin(animation * 2 * math.pi) * 8) * intensity;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 4 * intensity;
    paint.color = primaryColor.withOpacity(0.7 * intensity);

    // Draw sun outline
    canvas.drawCircle(sunCenter, sunRadius, paint);

    // Draw sun rays
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + animation * math.pi;
      final rayStart = Offset(
        sunCenter.dx + math.cos(angle) * sunRadius * 1.2,
        sunCenter.dy + math.sin(angle) * sunRadius * 1.2,
      );
      final rayEnd = Offset(
        sunCenter.dx + math.cos(angle) * sunRadius * 1.6,
        sunCenter.dy + math.sin(angle) * sunRadius * 1.6,
      );

      paint.strokeWidth = 2 * intensity;
      canvas.drawLine(rayStart, rayEnd, paint);
    }

    // Draw horizontal lines through sun for retro effect
    paint.strokeWidth = 2 * intensity;
    for (int i = -2; i <= 2; i++) {
      final lineY = sunCenter.dy + i * 8 * intensity;
      canvas.drawLine(
        Offset(sunCenter.dx - sunRadius, lineY),
        Offset(sunCenter.dx + sunRadius, lineY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cherry Blossom theme background with falling sakura petals
class _CherryBlossomBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _CherryBlossomBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final petalAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _CherryBlossomPainter(
        animation: petalAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _CherryBlossomPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _CherryBlossomPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(555); // Fixed seed for consistent petals

    // Draw falling sakura petals
    final petalCount = (20 * intensity).round();
    for (int i = 0; i < petalCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.2 + random.nextDouble() * 0.3; // Slow falling

      // Calculate petal position with gentle swaying
      final progress = (animation * speed + i * 0.05) % 1.2;
      final y = progress * (size.height + 50) - 25;
      final sway = math.sin(progress * 4 * math.pi + i) * 15 * intensity;
      final x = baseX + sway;

      // Only draw if visible
      if (y > -25 && y < size.height + 25) {
        final opacity = math.max(0.0, (1.2 - progress) * 0.6) * intensity;
        final rotation = progress * 2 * math.pi + i;

        // Alternate between pink shades
        final petalColor = i % 3 == 0
            ? primaryColor.withOpacity(opacity)
            : Color.lerp(primaryColor, Colors.white, 0.3)!.withOpacity(opacity);

        paint.color = petalColor;

        // Draw petal shape (simple oval rotated)
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: (4 + random.nextDouble() * 3) * intensity,
            height: (6 + random.nextDouble() * 4) * intensity,
          ),
          paint,
        );

        canvas.restore();
      }
    }

    // Draw gentle floating blossom clusters
    for (int i = 0; i < (6 * intensity).round(); i++) {
      final clusterX = size.width * (0.1 + i * 0.15);
      final clusterY = size.height * (0.1 + math.sin(animation * math.pi + i * 0.8) * 0.2);
      final clusterSize = (15 + i * 3 + math.sin(animation * 2 * math.pi + i) * 5) * intensity;

      final opacity = (0.04 + math.cos(animation * 1.5 * math.pi + i * 0.6) * 0.02) * intensity;

      // Create soft blossom cluster
      paint.color = Color.lerp(
        primaryColor.withOpacity(opacity),
        accentColor.withOpacity(opacity * 0.7),
        math.sin(animation * math.pi + i) * 0.5 + 0.5,
      )!;

      // Main cluster
      canvas.drawCircle(Offset(clusterX, clusterY), clusterSize, paint);

      // Additional blossoms in cluster
      canvas.drawCircle(
        Offset(clusterX - clusterSize * 0.4, clusterY + clusterSize * 0.3),
        clusterSize * 0.6,
        paint,
      );
      canvas.drawCircle(
        Offset(clusterX + clusterSize * 0.3, clusterY - clusterSize * 0.2),
        clusterSize * 0.7,
        paint,
      );
    }

    // Draw soft pollen particles
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final pollenX = random.nextDouble() * size.width;
      final pollenY = random.nextDouble() * size.height;
      final drift = math.sin(animation * 1.5 * math.pi + i * 0.4) * 8 * intensity;

      final x = pollenX + drift;
      final y = pollenY + math.cos(animation * math.pi + i * 0.3) * 5 * intensity;

      final pollenIntensity = math.sin(animation * 3 * math.pi + i * 0.5) * 0.5 + 0.5;

      if (pollenIntensity > 0.6) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.2),
          accentColor.withOpacity(0.25),
          pollenIntensity,
        )!;

        canvas.drawCircle(Offset(x, y), 1 * intensity * pollenIntensity, paint);
      }
    }

    // Draw cherry blossom branches (subtle)
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2 * intensity;
    paint.color = Color.lerp(primaryColor, Colors.brown, 0.7)!.withOpacity(0.1 * intensity);

    for (int i = 0; i < 2; i++) {
      final branchStartX = size.width * (0.1 + i * 0.8);
      final branchStartY = size.height * (0.1 + i * 0.2);
      final branchEndX = branchStartX + (100 + i * 50) * intensity;
      final branchEndY = branchStartY + (30 + math.sin(animation * math.pi + i) * 20) * intensity;

      canvas.drawLine(
        Offset(branchStartX, branchStartY),
        Offset(branchEndX, branchEndY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cyberpunk theme background with digital matrix effects
class _CyberpunkBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _CyberpunkBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final matrixAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _CyberpunkPainter(
        animation: matrixAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _CyberpunkPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _CyberpunkPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Simplified: Just a few subtle matrix streams
    final streamCount = math.max(1, (3 * intensity).round());
    for (int i = 0; i < streamCount; i++) {
      final streamX = (i / streamCount) * size.width;
      final charProgress = (animation * 0.2 + i * 0.3) % 1.2;
      final charY = charProgress * (size.height + 50) - 25;

      if (charY > -10 && charY < size.height + 10) {
        final opacity = math.max(0.0, (1.0 - charProgress) * 0.08) * intensity;
        paint.color = primaryColor.withOpacity(opacity);

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(streamX, charY),
            width: 2 * intensity,
            height: 8 * intensity,
          ),
          paint,
        );
      }
    }

    // Simple scanning line
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1 * intensity;
    final scanY = (animation * size.height * 0.3) % size.height;
    paint.color = primaryColor.withOpacity(0.05 * intensity);
    canvas.drawLine(Offset(0, scanY), Offset(size.width, scanY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Golden Hour theme background with warm sunlight effects
class _GoldenHourBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _GoldenHourBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final sunAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _GoldenHourPainter(
        animation: sunAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _GoldenHourPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _GoldenHourPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(333); // Fixed seed for consistent effects

    // Draw sun rays emanating from top-right corner
    final sunPosition = Offset(size.width * 0.85, size.height * 0.15);
    final rayCount = (24 * intensity).round();

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * math.pi + math.pi * 0.5; // Only bottom half rays
      final rayLength = (size.width * 0.7 + math.sin(animation * 2 * math.pi + i * 0.3) * 50) * intensity;
      final rayWidth = (3 + math.sin(animation * 3 * math.pi + i * 0.5) * 2) * intensity;

      final endX = sunPosition.dx + math.cos(angle) * rayLength;
      final endY = sunPosition.dy + math.sin(angle) * rayLength;

      // Create gradient ray
      paint.shader = RadialGradient(
        center: Alignment.topRight,
        radius: 0.8,
        colors: [
          primaryColor.withOpacity(0.08 * intensity),
          primaryColor.withOpacity(0.02 * intensity),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(sunPosition.dx - 50, sunPosition.dy - 50, 100, 100));

      paint.strokeWidth = rayWidth;
      paint.style = PaintingStyle.stroke;

      canvas.drawLine(sunPosition, Offset(endX, endY), paint);
    }

    // Draw floating dust particles/light motes
    paint.shader = null;
    paint.style = PaintingStyle.fill;

    for (int i = 0; i < (25 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion
      final floatX = baseX + math.sin(animation * 2 * math.pi + i * 0.4) * 20 * intensity;
      final floatY = baseY + math.cos(animation * 1.5 * math.pi + i * 0.6) * 15 * intensity;

      final particleSize = (1.5 + random.nextDouble() * 3) * intensity;
      final opacity = (0.1 + math.sin(animation * 4 * math.pi + i * 0.8) * 0.05) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(opacity),
        accentColor.withOpacity(opacity * 0.8),
        math.sin(animation * math.pi + i) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(Offset(floatX, floatY), particleSize, paint);
    }

    // Draw warm glow clouds
    for (int i = 0; i < 6; i++) {
      final cloudX = size.width * (0.1 + i * 0.15);
      final cloudY = size.height * (0.3 + math.sin(animation * math.pi + i * 0.7) * 0.2);
      final cloudSize = (35 + i * 8 + math.sin(animation * 2 * math.pi + i) * 12) * intensity;

      final glowIntensity = 0.02 + math.cos(animation * 1.5 * math.pi + i * 0.5) * 0.01;

      // Multiple overlapping circles for cloud effect
      paint.color = primaryColor.withOpacity(glowIntensity * intensity);
      canvas.drawCircle(Offset(cloudX, cloudY), cloudSize, paint);

      paint.color = accentColor.withOpacity(glowIntensity * 0.6 * intensity);
      canvas.drawCircle(Offset(cloudX - cloudSize * 0.3, cloudY + cloudSize * 0.2), cloudSize * 0.8, paint);
      canvas.drawCircle(Offset(cloudX + cloudSize * 0.4, cloudY - cloudSize * 0.1), cloudSize * 0.6, paint);
    }

    // Draw warm atmospheric haze
    final hazeCount = (8 * intensity).round();
    for (int i = 0; i < hazeCount; i++) {
      final hazeX = size.width * (i / (hazeCount - 1));
      final hazeY = size.height * (0.7 + math.sin(animation * 1.5 * math.pi + i) * 0.1);
      final hazeWidth = (60 + i * 10) * intensity;
      final hazeHeight = (20 + math.sin(animation * 2 * math.pi + i * 0.3) * 8) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.015),
        accentColor.withOpacity(0.01),
        i / (hazeCount - 1),
      )!;

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(hazeX, hazeY),
          width: hazeWidth,
          height: hazeHeight,
        ),
        paint,
      );
    }

    // Draw golden sparkles
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final sparkleX = random.nextDouble() * size.width;
      final sparkleY = random.nextDouble() * size.height;
      final sparkleIntensity = math.sin(animation * 6 * math.pi + i * 0.4) * 0.5 + 0.5;

      if (sparkleIntensity > 0.8) {
        final sparkleSize = (2 + sparkleIntensity * 3) * intensity;
        paint.color = primaryColor.withOpacity(0.4 * sparkleIntensity * intensity);

        // Draw cross-shaped sparkle
        canvas.drawCircle(Offset(sparkleX, sparkleY), sparkleSize, paint);

        paint.strokeWidth = 1 * intensity;
        paint.style = PaintingStyle.stroke;
        canvas.drawLine(
          Offset(sparkleX - sparkleSize * 2, sparkleY),
          Offset(sparkleX + sparkleSize * 2, sparkleY),
          paint,
        );
        canvas.drawLine(
          Offset(sparkleX, sparkleY - sparkleSize * 2),
          Offset(sparkleX, sparkleY + sparkleSize * 2),
          paint,
        );

        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Purple Rain theme background with rain effects
class _PurpleRainBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _PurpleRainBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final rainAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _PurpleRainPainter(
        animation: rainAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _PurpleRainPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _PurpleRainPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;
    final random = math.Random(999); // Fixed seed for consistent rain

    // Draw rain drops
    final rainDropCount = (60 * intensity).round();
    for (int i = 0; i < rainDropCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 0.5 + random.nextDouble() * 0.8; // Varying speeds
      final length = (15 + random.nextDouble() * 25) * intensity;

      // Calculate rain drop position with wrapping
      final progress = (animation * speed + i * 0.1) % 1.0;
      final y = progress * (size.height + length * 2) - length;
      final x = baseX + math.sin(progress * 2 * math.pi) * 10 * intensity; // Slight sway

      // Only draw if visible
      if (y > -length && y < size.height + length) {
        final opacity = (0.15 + math.sin(animation * 4 * math.pi + i * 0.3) * 0.05) * intensity;

        paint.color = Color.lerp(
          primaryColor.withOpacity(opacity),
          accentColor.withOpacity(opacity * 0.8),
          (i % 3) / 2.0,
        )!;

        paint.strokeWidth = (1.5 + random.nextDouble() * 1) * intensity;

        canvas.drawLine(
          Offset(x, y),
          Offset(x + 2 * intensity, y + length),
          paint,
        );
      }
    }

    // Draw lightning flashes (rare)
    if (math.sin(animation * 8 * math.pi) > 0.95) {
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3 * intensity;
      paint.color = accentColor.withOpacity(0.4 * intensity);

      final lightningX = size.width * (0.2 + random.nextDouble() * 0.6);
      final segments = 5;

      for (int i = 0; i < segments; i++) {
        final startY = i * (size.height / segments);
        final endY = (i + 1) * (size.height / segments);
        final offset = (random.nextDouble() - 0.5) * 40 * intensity;

        canvas.drawLine(
          Offset(lightningX + (i > 0 ? offset * 0.5 : 0), startY),
          Offset(lightningX + offset, endY),
          paint,
        );
      }
    }

    // Draw atmospheric mist
    paint.style = PaintingStyle.fill;
    for (int i = 0; i < 8; i++) {
      final mistX = size.width * (i / 7.0);
      final mistY = size.height * (0.6 + math.sin(animation * 2 * math.pi + i * 0.5) * 0.2);
      final mistSize = (25 + i * 5 + math.cos(animation * 3 * math.pi + i) * 8) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.02),
        accentColor.withOpacity(0.015),
        math.sin(animation * math.pi + i) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(Offset(mistX, mistY), mistSize, paint);
    }

    // Draw purple glow effects
    final glowCount = (6 * intensity).round();
    for (int i = 0; i < glowCount; i++) {
      final glowX = random.nextDouble() * size.width;
      final glowY = random.nextDouble() * size.height;
      final glowIntensity = math.sin(animation * 3 * math.pi + i * 0.8) * 0.5 + 0.5;

      if (glowIntensity > 0.6) {
        final glowRadius = (15 + glowIntensity * 20) * intensity;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.08),
          accentColor.withOpacity(0.06),
          glowIntensity,
        )!;

        canvas.drawCircle(Offset(glowX, glowY), glowRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Pastel theme background with soft floating elements
class _PastelBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _PastelBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final floatAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      ),
    );

    return CustomPaint(
      painter: _PastelPainter(
        animation: floatAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _PastelPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _PastelPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(789); // Fixed seed for consistent elements

    // Draw soft floating bubbles
    for (int i = 0; i < (12 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Gentle floating motion
      final floatOffset = math.sin(animation * 2 * math.pi + i * 0.3) * 15 * intensity;
      final x = baseX + math.cos(animation * math.pi + i * 0.5) * 10 * intensity;
      final y = baseY + floatOffset;

      final radius = (8 + random.nextDouble() * 20) * intensity;
      final opacity = (0.02 + math.sin(animation * 2 * math.pi + i * 0.7) * 0.01) * intensity;

      // Alternate between primary and accent colors
      paint.color = (i % 2 == 0 ? primaryColor : accentColor).withOpacity(opacity);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw soft gradient clouds
    for (int i = 0; i < 4; i++) {
      final centerX = size.width * (0.2 + i * 0.25);
      final centerY = size.height * (0.2 + math.sin(animation * math.pi + i) * 0.15);

      final cloudSize = (40 + i * 10 + math.sin(animation * 2 * math.pi + i) * 8) * intensity;
      final opacity = (0.01 + math.cos(animation * math.pi + i * 0.8) * 0.005) * intensity;

      // Create soft cloud-like shapes with multiple overlapping circles
      final cloudColor = Color.lerp(primaryColor, accentColor, i / 3.0)!;
      paint.color = cloudColor.withOpacity(opacity);

      // Main cloud circle
      canvas.drawCircle(Offset(centerX, centerY), cloudSize, paint);

      // Additional circles for cloud-like effect
      canvas.drawCircle(
        Offset(centerX - cloudSize * 0.3, centerY - cloudSize * 0.2),
        cloudSize * 0.7,
        paint,
      );
      canvas.drawCircle(
        Offset(centerX + cloudSize * 0.2, centerY - cloudSize * 0.3),
        cloudSize * 0.6,
        paint,
      );
    }

    // Draw gentle sparkles
    for (int i = 0; i < (20 * intensity).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final sparkleIntensity = math.sin(animation * 4 * math.pi + i * 0.2) * 0.5 + 0.5;

      if (sparkleIntensity > 0.7) {
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.3),
          accentColor.withOpacity(0.4),
          sparkleIntensity,
        )!;

        canvas.drawCircle(Offset(x, y), 1.5 * intensity * sparkleIntensity, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Cosmic theme background with stars and nebula effects
class _CosmicBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _CosmicBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final rotationAnimation = useAnimation(
      Tween<double>(begin: 0, end: 2 * math.pi).animate(controller),
    );

    return CustomPaint(
      painter: _CosmicPainter(
        animation: rotationAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _CosmicPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _CosmicPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent stars

    // Draw stars
    for (int i = 0; i < (50 * intensity).round(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = (random.nextDouble() * 2 + 0.5) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.3),
        accentColor.withOpacity(0.5),
        math.sin(animation + i * 0.1) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Draw floating nebula-like shapes
    for (int i = 0; i < 3; i++) {
      final centerX = size.width * (0.2 + i * 0.3);
      final centerY = size.height * (0.3 + math.sin(animation + i) * 0.2);

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.05),
        accentColor.withOpacity(0.03),
        math.cos(animation + i * 0.5) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(
        Offset(centerX, centerY),
        (30 + math.sin(animation + i) * 10) * intensity,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Midnight theme background with aurora-like effects
class _MidnightBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _MidnightBackground({
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

// Ocean theme background with wave effects
class _OceanBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _OceanBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final waveAnimation = useAnimation(
      Tween<double>(begin: 0, end: 2 * math.pi).animate(controller),
    );

    return CustomPaint(
      painter: _OceanPainter(
        animation: waveAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _OceanPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _OceanPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw wave layers
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final waveHeight = (15 + i * 5) * intensity;
      final baseY = size.height - (50 + i * 20) * intensity;
      final phase = animation + i * math.pi / 4;

      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 10) {
        final y = baseY + math.sin(x / 100 + phase) * waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.03 + i * 0.01),
        accentColor.withOpacity(0.02 + i * 0.01),
        math.sin(phase) * 0.5 + 0.5,
      )!;

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Forest theme background with organic shapes
class _ForestBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _ForestBackground({
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

// Sunset theme background with warm gradient shifts
class _SunsetBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _SunsetBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final sunAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _SunsetPainter(
        animation: sunAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _SunsetPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _SunsetPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw sun rays
    final sunCenter = Offset(size.width * 0.8, size.height * 0.3);
    final rayCount = (12 * intensity).round();

    for (int i = 0; i < rayCount; i++) {
      final angle = (i / rayCount) * 2 * math.pi + animation * math.pi / 4;
      final length = (50 + math.sin(animation * 2 * math.pi + i) * 20) * intensity;

      final startOffset = Offset(
        sunCenter.dx + math.cos(angle) * 20,
        sunCenter.dy + math.sin(angle) * 20,
      );
      final endOffset = Offset(
        sunCenter.dx + math.cos(angle) * length,
        sunCenter.dy + math.sin(angle) * length,
      );

      paint.color = primaryColor.withOpacity(0.05 * intensity);
      paint.strokeWidth = 2 * intensity;
      paint.style = PaintingStyle.stroke;

      canvas.drawLine(startOffset, endOffset, paint);
    }

    // Draw warm glow circles
    for (int i = 0; i < 3; i++) {
      final radius = (30 + i * 20 + math.sin(animation * 2 * math.pi) * 10) * intensity;
      paint.style = PaintingStyle.fill;
      paint.color = Color.lerp(
        primaryColor.withOpacity(0.02),
        accentColor.withOpacity(0.01),
        i / 2.0,
      )!;

      canvas.drawCircle(sunCenter, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Neon theme background with electric effects
class _NeonBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _NeonBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final pulseAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _NeonPainter(
        animation: pulseAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _NeonPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _NeonPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke;

    // Draw electric grid lines
    final gridSpacing = 100.0 * intensity;
    final pulseIntensity = (math.sin(animation * 2 * math.pi) * 0.5 + 0.5) * intensity;

    paint.strokeWidth = 1;
    paint.color = primaryColor.withOpacity(0.1 * pulseIntensity);

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw pulsing nodes at intersections
    paint.style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += gridSpacing) {
      for (double y = 0; y < size.height; y += gridSpacing) {
        final nodeIntensity = math.sin(animation * 4 * math.pi + x * 0.01 + y * 0.01) * 0.5 + 0.5;
        paint.color = Color.lerp(
          primaryColor.withOpacity(0.05),
          accentColor.withOpacity(0.1),
          nodeIntensity,
        )!;

        canvas.drawCircle(
          Offset(x, y),
          3 * intensity * nodeIntensity,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Monochrome theme background with minimal geometric patterns
class _MonochromeBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _MonochromeBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final rotationAnimation = useAnimation(
      Tween<double>(begin: 0, end: 2 * math.pi).animate(controller),
    );

    return CustomPaint(
      painter: _MonochromePainter(
        animation: rotationAnimation,
        primaryColor: theme.primaryColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _MonochromePainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final double intensity;

  _MonochromePainter({
    required this.animation,
    required this.primaryColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1 * intensity;

    // Draw rotating geometric shapes
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.3;

    for (int i = 0; i < 3; i++) {
      final shapeRadius = radius * (0.3 + i * 0.2);
      final sides = 3 + i * 2;
      final rotation = animation * (i.isEven ? 1 : -1) + i * math.pi / 6;

      paint.color = primaryColor.withOpacity(0.05 * intensity * (1 - i * 0.2));

      final path = Path();
      for (int j = 0; j < sides; j++) {
        final angle = (j / sides) * 2 * math.pi + rotation;
        final x = center.dx + math.cos(angle) * shapeRadius;
        final y = center.dy + math.sin(angle) * shapeRadius;

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

// Default background for other themes
class _DefaultBackground extends HookWidget {
  final AnimationController controller;
  final AppTheme theme;
  final double intensity;

  const _DefaultBackground({
    required this.controller,
    required this.theme,
    required this.intensity,
  });

  @override
  Widget build(BuildContext context) {
    final floatAnimation = useAnimation(
      Tween<double>(begin: 0, end: 1).animate(controller),
    );

    return CustomPaint(
      painter: _DefaultPainter(
        animation: floatAnimation,
        primaryColor: theme.primaryColor,
        accentColor: theme.accentColor,
        intensity: intensity,
      ),
      size: Size.infinite,
    );
  }
}

class _DefaultPainter extends CustomPainter {
  final double animation;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _DefaultPainter({
    required this.animation,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(456);

    // Draw floating bubbles
    for (int i = 0; i < (15 * intensity).round(); i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final offset = math.sin(animation * 2 * math.pi + i * 0.5) * 20 * intensity;

      final x = baseX;
      final y = baseY + offset;
      final radius = (5 + random.nextDouble() * 15) * intensity;

      paint.color = Color.lerp(
        primaryColor.withOpacity(0.03),
        accentColor.withOpacity(0.05),
        math.sin(animation * 2 * math.pi + i) * 0.5 + 0.5,
      )!;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Convenience extension for easy usage
extension AnimatedBackgroundExtension on Widget {
  Widget withAnimatedBackground({
    required AppTheme theme,
    double intensity = 1.0,
    bool enableAnimation = true,
  }) {
    return AnimatedBackground(
      intensity: intensity,
      enableAnimation: enableAnimation,
      child: this,
    );
  }
}
