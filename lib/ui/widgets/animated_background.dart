import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core.dart';
import '../../core/theme/arctic_aurora.dart';
import '../../core/theme/cherry_blossom.dart';
import '../../core/theme/copper_steampunk.dart';
import '../../core/theme/cosmic.dart';
import '../../core/theme/cyberpunk.dart';
import '../../core/theme/deep_sea.dart';
import '../../core/theme/dream_scape.dart';
import '../../core/theme/forest.dart';
import '../../core/theme/golden_hour.dart';
import '../../core/theme/ice_crystal.dart';
import '../../core/theme/midnight.dart';
import '../../core/theme/monochrome.dart';
import '../../core/theme/neon.dart';
import '../../core/theme/ocean.dart';
import '../../core/theme/pastel.dart';
import '../../core/theme/prismatic.dart';
import '../../core/theme/purple_rain.dart';
import '../../core/theme/retro_wave.dart';
import '../../core/theme/sunset.dart';
import '../../core/theme/toxic_waste.dart';
import '../../core/theme/volcanic.dart';
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
      duration: theme.type.animationDuration,
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

      case ThemeType.arcticAurora:
        return RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.05)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.03)!,
            theme.background,
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        );

      case ThemeType.toxicWaste:
        return LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.2)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.1)!,
            theme.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      case ThemeType.dreamscape:
        return RadialGradient(
          center: Alignment.center,
          radius: 2.0,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.03)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.02)!,
            theme.background,
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        );

      case ThemeType.deepSea:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.04)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.02)!,
            theme.background,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        );

      case ThemeType.copperSteampunk:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(theme.background, theme.primaryColor, 0.1)!,
            theme.background,
            Color.lerp(theme.background, theme.accentColor, 0.05)!,
            theme.background,
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
        return VolcanicBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.iceCrystal:
        return IceCrystalBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.retroWave:
        return RetroWaveBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.cherryBlossom:
        return CherryBlossomBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.cyberpunk:
        return CyberpunkBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.goldenHour:
        return GoldenHourBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.purpleRain:
        return PurpleRainBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.pastel:
        return PastelBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.cosmic:
        return CosmicBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.midnight:
        return MidnightBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.ocean:
        return OceanBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.forest:
        return ForestBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.sunset:
        return SunsetBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.neon:
        return NeonBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.monochrome:
        return MonochromeBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.arcticAurora:
        return ArcticAuroraBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.toxicWaste:
        return ToxicWasteBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.dreamscape:
        return DreamscapeBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.deepSea:
        return DeepSeaBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.copperSteampunk:
        return CopperSteampunkBackground(
          controller: controller,
          theme: theme,
          intensity: intensity,
        );

      case ThemeType.prismatic:
        return PrismaticBackground(
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
