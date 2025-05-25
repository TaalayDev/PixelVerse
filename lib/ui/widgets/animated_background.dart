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
      default:
        return const Duration(seconds: 10);
    }
  }

  Gradient _getBaseGradient(AppTheme theme) {
    switch (theme.type) {
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
