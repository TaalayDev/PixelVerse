import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildGoldenHourTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.goldenHour,
    isDark: false,
    // Primary colors - warm golden amber
    primaryColor: const Color(0xFFD4A574), // Warm golden amber
    primaryVariant: const Color(0xFFB8956A), // Deeper golden
    onPrimary: const Color(0xFF3D2914), // Dark brown for contrast
    // Secondary colors - coral orange
    accentColor: const Color(0xFFED8A63), // Warm coral
    onAccent: Colors.white,
    // Background colors - warm cream tones
    background: const Color(0xFFFDF6E3), // Warm cream
    surface: const Color(0xFFFEFCF6), // Warmer white
    surfaceVariant: const Color(0xFFF4EDD8), // Light golden beige
    // Text colors - warm browns
    textPrimary: const Color(0xFF3D2914), // Dark warm brown
    textSecondary: const Color(0xFF6B4E37), // Medium brown
    textDisabled: const Color(0xFFA08B7A), // Light brown
    // UI colors
    divider: const Color(0xFFE6D3B7), // Light golden
    toolbarColor: const Color(0xFFF4EDD8),
    error: const Color(0xFFD2691E), // Chocolate orange
    success: const Color(0xFF8FBC8F), // Dark sea green
    warning: const Color(0xFFDDAA00), // Dark golden rod
    // Grid colors
    gridLine: const Color(0xFFE6D3B7),
    gridBackground: const Color(0xFFFEFCF6),
    // Canvas colors
    canvasBackground: const Color(0xFFFEFCF6),
    selectionOutline: const Color(0xFFD4A574), // Match primary
    selectionFill: const Color(0x30D4A574),
    // Icon colors
    activeIcon: const Color(0xFFD4A574), // Golden for active
    inactiveIcon: const Color(0xFF6B4E37), // Brown for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFF3D2914),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFF3D2914),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFF3D2914),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFF6B4E37),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// Enhanced Golden Hour theme background with cinematic sunset effects
class GoldenHourBackground extends HookWidget {
  final AppTheme theme;
  final double intensity;
  final bool enableAnimation;

  const GoldenHourBackground({
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
        painter: _EnhancedGoldenHourPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 2.0),
        ),
        size: Size.infinite,
        isComplex: true,
        willChange: enableAnimation,
      ),
    );
  }
}

class _EnhancedGoldenHourPainter extends CustomPainter {
  final double t;
  final Color primaryColor;
  final Color accentColor;
  final double intensity;

  _EnhancedGoldenHourPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
  });

  // Animation helpers for smooth looping
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double offset = 0]) => math.sin(_phase * speed + offset);
  double _norm(double speed, [double offset = 0]) => 0.5 * (1 + _wave(speed, offset));

  // Golden hour color palette
  late final Color _deepGold = const Color(0xFFB8860B);
  late final Color _sunsetOrange = const Color(0xFFFF8C00);
  late final Color _warmAmber = const Color(0xFFFFBF00);
  late final Color _honeyglow = const Color(0xFFFFC649);
  late final Color _peach = const Color(0xFFFFDAB9);
  late final Color _rosyGold = const Color(0xFFEEC591);
  late final Color _burnishedGold = const Color(0xFFCD7F32);
  late final Color _creamGold = const Color(0xFFFFF8DC);

  // Element counts based on intensity
  int get _sunrayCount => (32 * intensity).round().clamp(16, 48);
  int get _cloudLayers => (5 * intensity).round().clamp(3, 8);
  int get _dustParticleCount => (60 * intensity).round().clamp(30, 90);
  int get _lensFlareCount => (8 * intensity).round().clamp(4, 12);

  @override
  void paint(Canvas canvas, Size size) {
    _paintGoldenSky(canvas, size);
    _paintSun(canvas, size);
    _paintSunRays(canvas, size);
    _paintGoldenClouds(canvas, size);
    _paintAtmosphericHaze(canvas, size);
    _paintFloatingDust(canvas, size);
    _paintLensFlares(canvas, size);
    _paintWarmGlow(canvas, size);
  }

  void _paintGoldenSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Cinematic golden hour sky gradient
    final skyGradient = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        [
          _creamGold.withOpacity(0.3), // High sky
          _peach.withOpacity(0.4), // Upper atmosphere
          _honeyglow.withOpacity(0.6), // Mid sky
          primaryColor.withOpacity(0.7), // Lower atmosphere
          accentColor.withOpacity(0.5), // Horizon area
          _burnishedGold.withOpacity(0.3), // Ground level
        ],
        [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
      );

    canvas.drawRect(rect, skyGradient);

    // Add subtle color temperature shifts
    final tempShift = _norm(0.02);
    final tempPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.75, size.height * 0.25),
        size.width * 0.8,
        [
          _warmAmber.withOpacity(0.08 * tempShift * intensity),
          Colors.transparent,
        ],
        [0.0, 1.0],
      );

    canvas.drawRect(rect, tempPaint);
  }

  void _paintSun(Canvas canvas, Size size) {
    final sunCenter = Offset(size.width * 0.82, size.height * 0.22);
    final sunRadius = 45 * intensity;
    final sunPulse = 0.95 + 0.05 * _wave(0.08);

    // Sun's corona/outer glow
    final coronaPaint = Paint()
      ..shader = ui.Gradient.radial(
        sunCenter,
        sunRadius * 3,
        [
          _warmAmber.withOpacity(0.4 * intensity),
          _honeyglow.withOpacity(0.25 * intensity),
          _sunsetOrange.withOpacity(0.1 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.3, 0.6, 1.0],
      );

    canvas.drawCircle(sunCenter, sunRadius * 3 * sunPulse, coronaPaint);

    // Sun's main glow
    final sunGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        sunCenter,
        sunRadius * 2,
        [
          Colors.white.withOpacity(0.9),
          _warmAmber.withOpacity(0.8),
          _sunsetOrange.withOpacity(0.6),
          accentColor.withOpacity(0.3),
        ],
        [0.0, 0.4, 0.7, 1.0],
      );

    canvas.drawCircle(sunCenter, sunRadius * 1.8 * sunPulse, sunGlowPaint);

    // Sun's core
    final sunCorePaint = Paint()
      ..shader = ui.Gradient.radial(
        sunCenter,
        sunRadius,
        [
          Colors.white.withOpacity(0.95),
          _warmAmber.withOpacity(0.9),
          _deepGold.withOpacity(0.7),
        ],
        [0.0, 0.6, 1.0],
      );

    canvas.drawCircle(sunCenter, sunRadius * sunPulse, sunCorePaint);

    // Sun's surface details (solar flares)
    final flarePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * intensity
      ..color = Colors.white.withOpacity(0.6);

    for (int i = 0; i < 6; i++) {
      final flareIntensity = _norm(0.12, i * 0.3);
      if (flareIntensity > 0.7) {
        final flareAngle = i * math.pi / 3 + _phase * 0.1;
        final flareLength = sunRadius * (0.3 + flareIntensity * 0.2);

        final startPoint = Offset(
          sunCenter.dx + math.cos(flareAngle) * sunRadius * 0.7,
          sunCenter.dy + math.sin(flareAngle) * sunRadius * 0.7,
        );

        final endPoint = Offset(
          sunCenter.dx + math.cos(flareAngle) * (sunRadius * 0.7 + flareLength),
          sunCenter.dy + math.sin(flareAngle) * (sunRadius * 0.7 + flareLength),
        );

        canvas.drawLine(startPoint, endPoint, flarePaint);
      }
    }
  }

  void _paintSunRays(Canvas canvas, Size size) {
    final sunPosition = Offset(size.width * 0.82, size.height * 0.22);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dynamic sun rays
    for (int i = 0; i < _sunrayCount; i++) {
      final rayAngle = (i / _sunrayCount) * 2 * math.pi + _phase * 0.02;
      final rayIntensity = _norm(0.15, i * 0.1);
      final rayLength = (120 + rayIntensity * 80 + _wave(0.05, i * 0.2) * 40) * intensity;

      // Vary ray thickness and opacity
      final rayThickness = (2 + rayIntensity * 3) * intensity;
      final rayOpacity = (0.15 + rayIntensity * 0.2) * intensity;

      if (rayOpacity > 0.1) {
        final endPoint = Offset(
          sunPosition.dx + math.cos(rayAngle) * rayLength,
          sunPosition.dy + math.sin(rayAngle) * rayLength,
        );

        // Main ray
        paint
          ..strokeWidth = rayThickness
          ..shader = ui.Gradient.linear(
            sunPosition,
            endPoint,
            [
              _warmAmber.withOpacity(rayOpacity),
              _honeyglow.withOpacity(rayOpacity * 0.6),
              Colors.transparent,
            ],
            [0.0, 0.7, 1.0],
          );

        canvas.drawLine(sunPosition, endPoint, paint);

        // Secondary ray glow
        paint
          ..strokeWidth = rayThickness * 2
          ..shader = ui.Gradient.linear(
            sunPosition,
            endPoint,
            [
              _peach.withOpacity(rayOpacity * 0.3),
              Colors.transparent,
            ],
            [0.0, 1.0],
          );

        canvas.drawLine(sunPosition, endPoint, paint);
      }
    }
  }

  void _paintGoldenClouds(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(123);

    // Layered golden clouds
    for (int layer = 0; layer < _cloudLayers; layer++) {
      final cloudY = size.height * (0.15 + layer * 0.12);
      final cloudDrift = _wave(0.01, layer.toDouble()) * 30 * intensity;

      for (int i = 0; i < 4; i++) {
        final baseX = size.width * (0.1 + i * 0.25) + cloudDrift;
        final cloudSize = (40 + layer * 8 + random.nextDouble() * 20) * intensity;
        final cloudHeight = cloudSize * (0.6 + random.nextDouble() * 0.4);

        final breathe = 0.9 + 0.1 * _norm(0.03, layer + i.toDouble());
        final currentSize = cloudSize * breathe;

        // Cloud illumination varies by position relative to sun
        final sunPosition = Offset(size.width * 0.82, size.height * 0.22);
        final cloudCenter = Offset(baseX, cloudY);
        final distanceToSun = (cloudCenter - sunPosition).distance;
        final sunInfluence = math.max(0.0, 1.0 - (distanceToSun / (size.width * 0.5)));

        // Cloud colors based on sun illumination
        final cloudColors = [
          Color.lerp(_creamGold, _warmAmber, sunInfluence * 0.7)!,
          Color.lerp(_peach, _honeyglow, sunInfluence * 0.6)!,
          Color.lerp(_rosyGold, accentColor, sunInfluence * 0.5)!,
        ];

        final cloudColor = cloudColors[layer % cloudColors.length];
        final opacity = (0.08 + sunInfluence * 0.15 + layer * 0.02) * intensity;

        paint.color = cloudColor.withOpacity(opacity);

        // Create organic cloud shape
        _drawCloudShape(canvas, paint, cloudCenter, currentSize, cloudHeight);
      }
    }
  }

  void _drawCloudShape(Canvas canvas, Paint paint, Offset center, double width, double height) {
    // Main cloud body
    canvas.drawOval(
      Rect.fromCenter(center: center, width: width, height: height),
      paint,
    );

    // Additional cloud puffs for organic shape
    final puffOffsets = [
      Offset(-width * 0.3, -height * 0.2),
      Offset(width * 0.35, -height * 0.1),
      Offset(width * 0.15, height * 0.3),
      Offset(-width * 0.25, height * 0.2),
      Offset(width * 0.45, height * 0.1),
    ];

    final puffSizes = [
      width * 0.6,
      width * 0.5,
      width * 0.4,
      width * 0.55,
      width * 0.35,
    ];

    for (int i = 0; i < puffOffsets.length; i++) {
      canvas.drawCircle(
        center + puffOffsets[i],
        puffSizes[i],
        paint,
      );
    }
  }

  void _paintAtmosphericHaze(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Layered atmospheric haze
    for (int i = 0; i < 6; i++) {
      final hazeY = size.height * (0.5 + i * 0.08) + _wave(0.02, i.toDouble()) * 15 * intensity;
      final hazeWidth = size.width * (0.8 + i * 0.1);
      final hazeHeight = (25 + i * 8 + _wave(0.04, i * 0.5) * 10) * intensity;

      final hazeIntensity = _norm(0.06, i * 0.7);
      final hazeColors = [_peach, _honeyglow, _warmAmber, _rosyGold];
      final hazeColor = hazeColors[i % hazeColors.length];

      paint.color = hazeColor.withOpacity(0.05 * hazeIntensity * intensity);

      // Create horizontal haze layers
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 0.5, hazeY),
          width: hazeWidth,
          height: hazeHeight,
        ),
        paint,
      );
    }
  }

  void _paintFloatingDust(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = math.Random(456);

    // Golden dust motes floating in sunlight
    for (int i = 0; i < _dustParticleCount; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Dust particles drift lazily
      final driftX = baseX + _wave(0.03, i * 0.1) * 20 * intensity;
      final driftY = baseY + _wave(0.025, i * 0.15) * 15 * intensity;

      final particleSize = (1 + random.nextDouble() * 3) * intensity;
      final shimmer = _norm(0.2, i * 0.05);

      // Particles catch the light at different intensities
      final catchesLight = shimmer > 0.6;

      if (catchesLight) {
        final lightIntensity = (shimmer - 0.6) / 0.4;

        // Dust particle colors
        final dustColors = [_warmAmber, _honeyglow, _creamGold, Colors.white];
        final dustColor = dustColors[i % dustColors.length];

        paint.color = dustColor.withOpacity(0.4 * lightIntensity * intensity);
        canvas.drawCircle(Offset(driftX, driftY), particleSize * lightIntensity, paint);

        // Bright particles get extra glow
        if (lightIntensity > 0.8) {
          paint.color = Colors.white.withOpacity(0.6 * lightIntensity * intensity);
          canvas.drawCircle(Offset(driftX, driftY), particleSize * 0.5, paint);
        }
      }
    }
  }

  void _paintLensFlares(Canvas canvas, Size size) {
    final sunPosition = Offset(size.width * 0.82, size.height * 0.22);
    final paint = Paint()..style = PaintingStyle.fill;

    // Lens flare effects
    for (int i = 0; i < _lensFlareCount; i++) {
      final flareProgress = i / (_lensFlareCount - 1);
      final flareIntensity = _norm(0.08, i * 0.4);

      if (flareIntensity > 0.5) {
        // Position flares along line from sun to opposite corner
        final flareX = sunPosition.dx - (sunPosition.dx * flareProgress * 1.2);
        final flareY = sunPosition.dy + ((size.height - sunPosition.dy) * flareProgress * 0.8);

        final flareSize = (8 + i * 3 + flareIntensity * 10) * intensity;
        final brightness = (flareIntensity - 0.5) / 0.5;

        // Different flare shapes and colors
        switch (i % 4) {
          case 0: // Circular flare
            paint.color = _warmAmber.withOpacity(0.3 * brightness * intensity);
            canvas.drawCircle(Offset(flareX, flareY), flareSize, paint);
            break;

          case 1: // Hexagonal flare
            paint.color = _honeyglow.withOpacity(0.25 * brightness * intensity);
            _drawHexagon(canvas, paint, Offset(flareX, flareY), flareSize);
            break;

          case 2: // Ring flare
            paint
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2 * intensity
              ..color = _peach.withOpacity(0.4 * brightness * intensity);
            canvas.drawCircle(Offset(flareX, flareY), flareSize, paint);
            paint.style = PaintingStyle.fill;
            break;

          case 3: // Star flare
            paint.color = Colors.white.withOpacity(0.5 * brightness * intensity);
            _drawStarFlare(canvas, paint, Offset(flareX, flareY), flareSize);
            break;
        }
      }
    }
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

  void _drawStarFlare(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final r = (i % 2 == 0) ? radius : radius * 0.4;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintWarmGlow(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Overall warm atmospheric glow
    final warmGlowPaint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.75, size.height * 0.3),
        size.width * 0.9,
        [
          _warmAmber.withOpacity(0.06 * intensity),
          _honeyglow.withOpacity(0.04 * intensity),
          _peach.withOpacity(0.02 * intensity),
          Colors.transparent,
        ],
        [0.0, 0.4, 0.7, 1.0],
      );

    canvas.drawRect(rect, warmGlowPaint);

    // Subtle edge warming
    final edgeWarmth = _norm(0.03);
    final edgePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, 0),
        Offset(size.width, size.height),
        [
          Colors.transparent,
          accentColor.withOpacity(0.03 * edgeWarmth * intensity),
          Colors.transparent,
        ],
        [0.0, 0.5, 1.0],
      );

    canvas.drawRect(rect, edgePaint);
  }

  @override
  bool shouldRepaint(covariant _EnhancedGoldenHourPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.intensity != intensity;
  }
}
