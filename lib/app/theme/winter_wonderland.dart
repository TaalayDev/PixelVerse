import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildWinterWonderlandTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.winterWonderland,
    isDark: false,
    // Primary colors - soft winter blue
    primaryColor: const Color(0xFF7FB8E5), // Soft winter sky blue
    primaryVariant: const Color(0xFF5A9BD4), // Deeper winter blue
    onPrimary: Colors.white,
    // Secondary colors - warm winter accent
    accentColor: const Color(0xFF8EC5E8), // Light blue accent
    onAccent: const Color(0xFF2C3E50), // Dark blue-gray for contrast
    // Background colors - gentle winter whites
    background: const Color(0xFFFAFCFF), // Very soft blue-white
    surface: const Color(0xFFFFFFFF), // Pure white like fresh snow
    surfaceVariant: const Color(0xFFF0F6FC), // Light blue-gray
    // Text colors - warm and readable against snow
    textPrimary: const Color(0xFF2C3E50), // Dark blue-gray
    textSecondary: const Color(0xFF546E7A), // Medium blue-gray
    textDisabled: const Color(0xFF90A4AE), // Light blue-gray
    // UI colors
    divider: const Color(0xFFE1EAF0), // Very light blue-gray
    toolbarColor: const Color(0xFFF0F6FC),
    error: const Color(0xFFE74C3C), // Warm red for contrast
    success: const Color(0xFF27AE60), // Fresh green
    warning: const Color(0xFFF39C12), // Warm orange
    // Grid colors
    gridLine: const Color(0xFFE1EAF0),
    gridBackground: const Color(0xFFFFFFFF),
    // Canvas colors
    canvasBackground: const Color(0xFFFFFFFF),
    selectionOutline: const Color(0xFF7FB8E5), // Match primary
    selectionFill: const Color(0x307FB8E5),
    // Icon colors
    activeIcon: const Color(0xFF7FB8E5), // Winter blue for active
    inactiveIcon: const Color(0xFF546E7A), // Medium gray for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF2C3E50),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF2C3E50),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF2C3E50),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF546E7A),
      ),
    ),
    primaryFontWeight: FontWeight.w500, // Clean, readable weight
  );
}

// Winter Wonderland theme background with falling snow and cozy winter atmosphere
class WinterWonderlandBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const WinterWonderlandBackground({
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
        controller.value = 0.0;
      }
      return null;
    }, [enableAnimation]);

    final t = useAnimation(Tween<double>(begin: 0, end: 1).animate(controller));

    return RepaintBoundary(
      child: CustomPaint(
        painter: _WinterSnowPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 1.8),
        ),
        size: Size.infinite,
        isComplex: true,
        willChange: enableAnimation,
      ),
    );
  }
}

class _WinterSnowPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _WinterSnowPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Winter color palette
  late final Color _snowWhite = const Color(0xFFFFFFFD);
  late final Color _iceBlue = const Color(0xFFE6F3FF);
  late final Color _winterGray = const Color(0xFFECF0F3);
  late final Color _frostBlue = const Color(0xFFD4E5F7);
  late final Color _softBlue = const Color(0xFFB8D4EA);

  // Element counts based on intensity
  int get _snowflakeCount => (60 * intensity).round().clamp(30, 90);
  int get _treeCount => (5 * intensity).round().clamp(3, 8);
  int get _sparkleCount => (25 * intensity).round().clamp(12, 40);

  @override
  void paint(Canvas canvas, Size size) {
    _paintWinterSky(canvas, size);
    _paintDistantMountains(canvas, size);
    _paintWinterTrees(canvas, size);
    _paintFallingSnow(canvas, size);
    _paintSnowCrystals(canvas, size);
    _paintFrostEffects(canvas, size);
    _paintWinterMist(canvas, size);
  }

  void _paintWinterSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Gentle winter sky gradient
    final skyGradient = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        [
          _iceBlue.withOpacity(0.3), // Light sky
          _frostBlue.withOpacity(0.2), // Mid sky
          _snowWhite.withOpacity(0.1), // Lower atmosphere
          Colors.transparent, // Ground level
        ],
        [0.0, 0.4, 0.8, 1.0],
      );

    canvas.drawRect(rect, skyGradient);

    // Soft cloud wisps
    for (int i = 0; i < 3; i++) {
      final cloudX = size.width * (0.2 + i * 0.3) + _wave(0.02, i.toDouble()) * 20 * intensity;
      final cloudY = size.height * (0.1 + i * 0.05) + _wave(0.03, i * 0.7) * 8 * intensity;

      final cloudPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cloudX, cloudY),
          size.width * 0.25,
          [
            _winterGray.withOpacity(0.08 * intensity),
            Colors.transparent,
          ],
          [0.0, 1.0],
        );

      canvas.drawRect(rect, cloudPaint);
    }
  }

  void _paintDistantMountains(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create layered mountain silhouettes
    for (int layer = 0; layer < 3; layer++) {
      final path = Path();
      final mountainHeight = size.height * (0.15 + layer * 0.08);
      final baseY = size.height - mountainHeight;

      path.moveTo(0, size.height);
      path.lineTo(0, baseY);

      // Create mountain peaks
      for (int i = 0; i <= 6; i++) {
        final x = (i / 6) * size.width;
        final peakVariation = _wave(0.05, i * 1.2 + layer) * 25 * intensity;
        final y = baseY + peakVariation;

        if (i == 0) {
          path.lineTo(x, y);
        } else {
          // Create smooth mountain outline
          final prevX = ((i - 1) / 6) * size.width;
          final midX = (prevX + x) / 2;
          final midY = y + (math.sin(i * 1.5 + layer) * 8 * intensity);

          path.quadraticBezierTo(midX, midY, x, y);
        }
      }

      path.lineTo(size.width, size.height);
      path.close();

      // Mountain color gets lighter for distant layers
      final mountainOpacity = (0.12 - layer * 0.03) * intensity;
      paint.color = Color.lerp(
        _softBlue,
        _frostBlue,
        layer / 2.0,
      )!
          .withOpacity(mountainOpacity);

      canvas.drawPath(path, paint);
    }
  }

  void _paintWinterTrees(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _treeCount; i++) {
      final treeX = size.width * (0.05 + i * 0.18) + _wave(0.01, i.toDouble()) * 8 * intensity;
      // Much larger trees - scale with screen height
      final baseTreeHeight = size.height * 0.25; // 25% of screen height
      final treeHeight = (baseTreeHeight + i * 20 + _wave(0.02, i * 0.8) * 15) * intensity;
      final treeWidth = treeHeight * 0.8;

      final baseY = size.height - 15 * intensity;

      // Tree silhouette with darker color for better visibility
      final treeColor = _softBlue.withOpacity(0.25 * intensity);
      paint.color = treeColor;

      // Draw evergreen tree shape with more layers
      final treePath = Path();

      // Tree layers (evergreen style) - more layers for larger trees
      for (int layer = 0; layer < 6; layer++) {
        final layerY = baseY - (layer * treeHeight * 0.18);
        final layerWidth = treeWidth * (1.2 - layer * 0.15);
        final layerHeight = treeHeight * 0.15;

        // Create triangular sections for each layer
        final layerPath = Path();
        layerPath.moveTo(treeX, layerY - layerHeight);
        layerPath.lineTo(treeX - layerWidth * 0.5, layerY);
        layerPath.lineTo(treeX + layerWidth * 0.5, layerY);
        layerPath.close();

        canvas.drawPath(layerPath, paint);
      }

      // Tree trunk - larger and more visible
      paint.color = _winterGray.withOpacity(0.2 * intensity);
      final trunkWidth = treeWidth * 0.12;
      final trunkHeight = treeHeight * 0.25;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(treeX, baseY),
          width: trunkWidth,
          height: trunkHeight,
        ),
        paint,
      );

      // Snow on tree - more prominent snow coverage
      paint.color = _snowWhite.withOpacity(0.9 * intensity);
      for (int layer = 0; layer < 5; layer++) {
        final snowY = baseY - (layer * treeHeight * 0.18);
        final snowWidth = treeWidth * (1.1 - layer * 0.12);
        final snowHeight = 8 * intensity;

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(treeX, snowY),
            width: snowWidth * 0.85,
            height: snowHeight,
          ),
          paint,
        );
      }

      // Add some snow clumps for realism
      paint.color = _snowWhite.withOpacity(0.7 * intensity);
      for (int clump = 0; clump < 3; clump++) {
        final clumpX = treeX + (clump - 1) * treeWidth * 0.2;
        final clumpY = baseY - (clump + 1) * treeHeight * 0.2;
        final clumpSize = (4 + clump * 2) * intensity;

        canvas.drawCircle(Offset(clumpX, clumpY), clumpSize, paint);
      }
    }
  }

  void _paintFallingSnow(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(42); // Fixed seed for consistent snow

    for (int i = 0; i < _snowflakeCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Snowflake falling motion with gentle wind
      final fallSpeed = 0.8 + (i % 3) * 0.3;
      final progress = (t * fallSpeed + i * 0.01) % 1.2;
      final snowY = progress * (size.height + 40) - 20;

      if (snowY < -10 || snowY > size.height + 10) continue;

      // Gentle swaying motion
      final windSway = _wave(0.3, i * 0.1) * 15 * intensity;
      final microSway = _wave(1.2, i * 0.05) * 3 * intensity;
      final snowX = baseX + windSway + microSway;

      // Snowflake size and opacity
      final snowflakeSize = (1.5 + random.nextDouble() * 4) * intensity;
      final fadeIn = math.min(1.0, (snowY + 20) / 40);
      final fadeOut = math.min(1.0, (size.height + 20 - snowY) / 40);
      final opacity = (fadeIn * fadeOut * 0.8) * intensity;

      if (opacity <= 0.01) continue;

      // Different snowflake types
      final snowflakeType = i % 4;
      paint.color = _snowWhite.withOpacity(opacity);

      switch (snowflakeType) {
        case 0: // Simple dot
          canvas.drawCircle(Offset(snowX, snowY), snowflakeSize, paint);
          break;
        case 1: // Slightly larger soft flake
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
          canvas.drawCircle(Offset(snowX, snowY), snowflakeSize * 1.3, paint);
          paint.maskFilter = null;
          break;
        case 2: // Star-shaped snowflake
          _drawSnowflakeStar(canvas, paint, Offset(snowX, snowY), snowflakeSize);
          break;
        case 3: // Clustered snowflake
          canvas.drawCircle(Offset(snowX, snowY), snowflakeSize * 0.8, paint);
          canvas.drawCircle(Offset(snowX - 1, snowY - 1), snowflakeSize * 0.4, paint);
          canvas.drawCircle(Offset(snowX + 1, snowY + 1), snowflakeSize * 0.4, paint);
          break;
      }
    }
  }

  void _drawSnowflakeStar(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final x = center.dx + math.cos(angle) * size;
      final y = center.dy + math.sin(angle) * size;

      if (i == 0) {
        path.moveTo(center.dx, center.dy);
        path.lineTo(x, y);
      } else {
        path.moveTo(center.dx, center.dy);
        path.lineTo(x, y);
      }
    }

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 0.8;
    canvas.drawPath(path, paint);
    paint.style = PaintingStyle.fill;
  }

  void _paintSnowCrystals(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    for (int i = 0; i < _sparkleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Twinkling ice crystals
      final twinklePhase = _norm(0.4, i * 0.15);
      final twinkleThreshold = 0.7;

      if (twinklePhase > twinkleThreshold) {
        final sparkleIntensity = (twinklePhase - twinkleThreshold) / (1.0 - twinkleThreshold);
        final crystalSize = (1 + sparkleIntensity * 2.5) * intensity;

        // Ice crystal colors
        final crystalColors = [_snowWhite, _iceBlue, primaryColor.withOpacity(0.3)];
        final crystalColor = crystalColors[i % crystalColors.length];

        paint.color = crystalColor.withOpacity(0.6 * sparkleIntensity * intensity);
        canvas.drawCircle(Offset(x, y), crystalSize, paint);

        // Sparkle cross effect
        if (sparkleIntensity > 0.8) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 0.8 * intensity;
          paint.color = _snowWhite.withOpacity(0.9 * sparkleIntensity * intensity);

          final crossSize = crystalSize * 1.8;
          canvas.drawLine(
            Offset(x - crossSize, y),
            Offset(x + crossSize, y),
            paint,
          );
          canvas.drawLine(
            Offset(x, y - crossSize),
            Offset(x, y + crossSize),
            paint,
          );

          paint.style = PaintingStyle.fill;
        }
      }
    }
  }

  void _paintFrostEffects(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Frost patterns on edges
    for (int i = 0; i < 4; i++) {
      final startX = (i % 2 == 0) ? 0.0 : size.width;
      final startY = size.height * (0.2 + i * 0.2);

      final frostIntensity = _norm(0.15, i * 0.8);
      if (frostIntensity < 0.3) continue;

      paint
        ..strokeWidth = (1 + i * 0.3) * intensity
        ..color = _frostBlue.withOpacity(0.12 * frostIntensity * intensity);

      // Create delicate frost branches
      final path = Path();
      path.moveTo(startX, startY);

      final direction = (i % 2 == 0) ? 1.0 : -1.0;
      for (int j = 1; j <= 4; j++) {
        final progress = j / 4.0;
        final x = startX + direction * progress * 30 * intensity;
        final y = startY + _wave(0.2, progress * 3 + i) * 8 * intensity;
        path.lineTo(x, y);

        // Small frost branches
        if (j % 2 == 0) {
          final branchX = x + direction * 8 * intensity;
          final branchY = y + 4 * intensity;
          canvas.drawLine(Offset(x, y), Offset(branchX, branchY), paint);
        }
      }

      canvas.drawPath(path, paint);
    }
  }

  void _paintWinterMist(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Gentle mist layers
    for (int i = 0; i < 4; i++) {
      final mistY = size.height * (0.7 + i * 0.08) + _wave(0.02, i.toDouble()) * 8 * intensity;
      final mistWidth = size.width * (0.6 + i * 0.1);
      final mistHeight = (15 + i * 5 + _wave(0.04, i * 0.5) * 5) * intensity;

      final mistIntensity = _norm(0.06, i * 0.7);
      paint.color = _winterGray.withOpacity(0.06 * mistIntensity * intensity);

      // Create soft, organic mist shapes
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, mistY),
          width: mistWidth,
          height: mistHeight,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WinterSnowPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
