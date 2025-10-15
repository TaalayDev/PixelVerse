import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';

AppTheme buildPurpleRainTheme() {
  final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

  return AppTheme(
    type: ThemeType.purpleRain,
    isDark: true,
    // Primary colors - deep royal purple
    primaryColor: const Color(0xFF6A0DAD), // Deep royal purple
    primaryVariant: const Color(0xFF4B0082), // Indigo
    onPrimary: Colors.white,
    // Secondary colors - bright violet
    accentColor: const Color(0xFF9932CC), // Dark orchid
    onAccent: Colors.white,
    // Background colors - dark with purple undertones
    background: const Color(0xFF1A0B2E), // Very dark purple
    surface: const Color(0xFF2D1B4E), // Dark purple surface
    surfaceVariant: const Color(0xFF3D2B5E), // Lighter purple variant
    // Text colors - light with purple tints
    textPrimary: const Color(0xFFE6E0FF), // Light lavender
    textSecondary: const Color(0xFFB8A9DB), // Muted lavender
    textDisabled: const Color(0xFF7D6B9B), // Darker muted purple
    // UI colors
    divider: const Color(0xFF4A3B6B),
    toolbarColor: const Color(0xFF2D1B4E),
    error: const Color(0xFFFF6B9D), // Pink-purple error
    success: const Color(0xFF8A2BE2), // Blue violet success
    warning: const Color(0xFFDA70D6), // Orchid warning
    // Grid colors
    gridLine: const Color(0xFF4A3B6B),
    gridBackground: const Color(0xFF2D1B4E),
    // Canvas colors
    canvasBackground: const Color(0xFF1A0B2E),
    selectionOutline: const Color(0xFF9932CC), // Bright violet selection
    selectionFill: const Color(0x309932CC),
    // Icon colors
    activeIcon: const Color(0xFF9932CC), // Bright violet for active
    inactiveIcon: const Color(0xFFB8A9DB), // Muted for inactive
    // Typography
    textTheme: baseTextTheme.copyWith(
      titleLarge: baseTextTheme.titleLarge!.copyWith(
        color: const Color(0xFFE6E0FF),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: baseTextTheme.titleMedium!.copyWith(
        color: const Color(0xFFE6E0FF),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: baseTextTheme.bodyLarge!.copyWith(
        color: const Color(0xFFE6E0FF),
      ),
      bodyMedium: baseTextTheme.bodyMedium!.copyWith(
        color: const Color(0xFFB8A9DB),
      ),
    ),
    primaryFontWeight: FontWeight.w500,
  );
}

// ===================== CALM PURPLE RAIN =====================
class PurpleRainBackground extends HookWidget {
  final AppTheme theme;
  final double intensity; // overall look; 0.5–1.0 recommended for calm
  final bool enableAnimation;

  /// Extra controls for calmness
  final double motion; // 0..1 how much things move (default calm)
  final double density; // 0..1 how many elements are drawn (default calm)
  final bool showLightning; // off by default
  final bool showSplashes; // off by default

  const PurpleRainBackground({
    super.key,
    required this.theme,
    this.intensity = 0.9,
    this.enableAnimation = true,
    this.motion = 0.5,
    this.density = 0.6,
    this.showLightning = false,
    this.showSplashes = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: theme.type.animationDuration);

    // Respect system "reduce motion" if available
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final motionScale = (reduceMotion || !enableAnimation) ? 0.0 : motion.clamp(0.0, 1.0);
    final densityScale = density.clamp(0.2, 1.0);

    useEffect(() {
      if (motionScale > 0) {
        controller.repeat();
      } else {
        controller.stop();
        controller.value = 0.0;
      }
      return null;
    }, [motionScale]);

    final t = useAnimation(Tween<double>(begin: 0, end: 1).animate(controller));

    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        isComplex: true,
        willChange: motionScale > 0,
        painter: _CalmPurpleRainPainter(
          t: t,
          primaryColor: theme.primaryColor,
          accentColor: theme.accentColor,
          intensity: intensity.clamp(0.3, 1.2),
          motion: motionScale,
          density: densityScale,
          showLightning: showLightning,
          showSplashes: showSplashes,
        ),
      ),
    );
  }
}

class _CalmPurpleRainPainter extends CustomPainter {
  final double t; // 0..1 loop
  final Color primaryColor;
  final Color accentColor;
  final double intensity; // visual strength (colors/widths)
  final double motion; // 0..1 animation amount
  final double density; // 0..1 element counts
  final bool showLightning;
  final bool showSplashes;

  _CalmPurpleRainPainter({
    required this.t,
    required this.primaryColor,
    required this.accentColor,
    required this.intensity,
    required this.motion,
    required this.density,
    required this.showLightning,
    required this.showSplashes,
  });

  // Loop helpers
  double get _phase => 2 * math.pi * t;
  double _wave(double speed, [double off = 0]) => math.sin(_phase * speed * motion + off);
  double _norm(double speed, [double off = 0]) => 0.5 * (1 + _wave(speed, off));
  double _fract(double x) => x - x.floorToDouble();
  double _hash1(double n) => _fract(math.sin(n) * 43758.5453123);
  double _rand(int i, double salt) => _hash1(i * 12.9898 + 78.233 + salt * 43758.5453);
  double _smoothstep(double a, double b, double x) {
    final tt = ((x - a) / (b - a)).clamp(0.0, 1.0);
    return tt * tt * (3 - 2 * tt);
  }

  // Palette
  final Color _deepPurple = const Color(0xFF2D0A4B);
  final Color _royalPurple = const Color(0xFF4B0082);
  final Color _brightViolet = const Color(0xFF8A2BE2);
  final Color _electricPurple = const Color(0xFF9932CC);
  final Color _amethyst = const Color(0xFF9966CC);
  final Color _lavender = const Color(0xFFB19CD9);

  // Counts (scaled by density for calmness)
  int get _dropsBg => (60 * density * intensity).round().clamp(24, 80);
  int get _dropsMid => (90 * density * intensity).round().clamp(36, 120);
  int get _dropsFg => (50 * density * intensity).round().clamp(20, 80);
  int get _mistLayers => (4 * density).round().clamp(2, 6);

  @override
  void paint(Canvas canvas, Size size) {
    _paintSky(canvas, size);

    // Soft, steady wind; angle and speeds reduced by motion
    final gust = _wave(0.04) * 0.35 + _wave(0.013, 1.7) * 0.25;
    final wind = (10.0 + 6.0 * gust) * motion; // px lateral sway
    final angle = 0.18 + 0.03 * gust * motion; // ≈10–12°, calmer

    // Lightning: optional and very soft
    final flash = showLightning ? _pulseAt(t, center: 0.6, width: 0.07) * 0.6 : 0.0;

    _paintRain(canvas, size, wind, angle);
    if (showSplashes) _paintSplashes(canvas, size, wind, flash);
    _paintMist(canvas, size, wind);
    _paintVignette(canvas, size, flash);
  }

  // Loop-safe pulse
  double _pulseAt(double tt, {required double center, required double width}) {
    final d = (tt - center).abs();
    final delta = math.min(d, 1.0 - d);
    final x = (1.0 - (delta / width).clamp(0.0, 1.0));
    return x * x;
  }

  void _paintSky(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final g = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.5, 0),
        Offset(size.width * 0.5, size.height),
        [
          _deepPurple.withOpacity(0.95),
          _royalPurple.withOpacity(0.72),
          primaryColor.withOpacity(0.5),
          Color.lerp(_deepPurple, Colors.black, 0.35)!,
        ],
        const [0.0, 0.4, 0.75, 1.0],
      );
    canvas.drawRect(rect, g);

    // Very subtle cloud swells (barely move)
    for (int i = 0; i < 2; i++) {
      final cx = size.width * (0.3 + 0.4 * i) + 18 * _wave(0.02, i.toDouble());
      final cy = size.height * (0.14 + 0.1 * i) + 6 * _wave(0.03, i * 0.7);
      final r = size.width * (0.38 + 0.05 * i);
      final p = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          r,
          [
            _deepPurple.withOpacity(0.12),
            Colors.transparent,
          ],
          const [0.0, 1.0],
        );
      canvas.drawRect(rect, p);
    }
  }

  void _paintRain(Canvas canvas, Size size, double wind, double angle) {
    final layers = <_RainLayer>[
      _RainLayer(count: _dropsBg, speedMul: 0.60, widthMul: 0.9, opacityMul: 0.07, shade: _lavender),
      _RainLayer(count: _dropsMid, speedMul: 0.85, widthMul: 1.0, opacityMul: 0.10, shade: _amethyst),
      _RainLayer(count: _dropsFg, speedMul: 1.05, widthMul: 1.10, opacityMul: 0.12, shade: _brightViolet),
    ];

    final sinA = math.sin(angle);
    final cosA = math.cos(angle);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 50.0;

    for (int li = 0; li < layers.length; li++) {
      final L = layers[li];
      for (int i = 0; i < L.count; i++) {
        final rx = _rand(i + li * 1000, 1.0);
        final rlen = _rand(i + li * 1000, 2.0);
        final rs = _rand(i + li * 1000, 3.0);
        final ro = _rand(i + li * 1000, 4.0);

        final baseX = rx * size.width;
        final speed = ui.lerpDouble(0.5, 1.0, rs)! * L.speedMul * (0.8 + 0.2 * motion);
        final length = ui.lerpDouble(14, 28, rlen)! * intensity * (0.9 + 0.15 * li);

        final s = (t * speed + ro) % 1.0;
        final travel = size.height + 2 * margin + length;
        final y = -margin + s * travel;
        final wobble = math.sin(_phase * 0.5 + i * 0.13) * 3.0 * (0.6 + 0.4 * li) * motion;
        final x = baseX + wind * 0.35 + wobble + sinA * (s * 18 * motion);

        if (y < -length || y > size.height + length) continue;

        final fadeIn = _smoothstep(-margin, 0.0, y);
        final fadeOut = 1.0 - _smoothstep(size.height, size.height + margin, y);
        final edge = (fadeIn * fadeOut).clamp(0.0, 1.0);

        final alpha = (L.opacityMul * intensity * edge).clamp(0.0, 0.14); // soft cap
        if (alpha <= 0.01) continue;

        paint
          ..strokeWidth = (1.0 + 0.7 * li) * intensity * L.widthMul
          ..color = Color.lerp(primaryColor, L.shade, 0.6)!.withOpacity(alpha);

        final dx = sinA * length;
        final dy = cosA * length;
        canvas.drawLine(Offset(x, y), Offset(x + dx, y + dy), paint);
      }
    }
  }

  void _paintSplashes(Canvas canvas, Size size, double wind, double flash) {
    // Very subtle, and only if enabled
    final baseY = size.height * 0.9;
    final lanes = (4 * density).round().clamp(2, 6);

    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = (1.0 * intensity).clamp(0.8, 1.4)
      ..color = _lavender.withOpacity(0.10);

    for (int i = 0; i < lanes; i++) {
      final laneX = (i + 0.5) / lanes * size.width + wind * 0.08;
      final hit = (t * 0.6 + _rand(i, 7.0)) % 1.0;
      final r = hit * 18 * intensity;
      final op = (1.0 - hit).clamp(0.0, 1.0) * 0.10 * intensity;

      if (op > 0.01) {
        rim.color = _amethyst.withOpacity(op);
        canvas.drawCircle(Offset(laneX, baseY), r, rim);
      }
    }
  }

  void _paintMist(Canvas canvas, Size size, double wind) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < _mistLayers; i++) {
      final y = size.height * (0.58 + 0.06 * i) + 4 * _wave(0.03, i.toDouble());
      final x = size.width * (0.18 + 0.12 * i) + wind * 0.04 + _wave(0.02, i.toDouble()) * 8;
      final w = size.width * (0.48 + 0.08 * i);
      final h = 18.0 + 5.0 * i;
      paint.color = Color.lerp(_royalPurple, _amethyst, i / (_mistLayers))!
          .withOpacity((0.035 - 0.004 * i).clamp(0.015, 0.04) * intensity);

      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: w, height: h),
        const Radius.circular(14),
      );
      canvas.drawRRect(rrect, paint);
    }
  }

  void _paintVignette(Canvas canvas, Size size, double flash) {
    final vignette = Paint()
      ..shader = ui.Gradient.radial(
        Offset(size.width * 0.5, size.height * 0.5),
        size.longestSide * 0.78,
        [
          Colors.transparent,
          _deepPurple.withOpacity(0.10 + 0.05 * flash),
          _deepPurple.withOpacity(0.16 + 0.07 * flash),
        ],
        const [0.0, 0.82, 1.0],
      );
    canvas.drawRect(Offset.zero & size, vignette);
  }

  @override
  bool shouldRepaint(covariant _CalmPurpleRainPainter old) {
    return old.t != t ||
        old.primaryColor != primaryColor ||
        old.accentColor != accentColor ||
        old.intensity != intensity ||
        old.motion != motion ||
        old.density != density ||
        old.showLightning != showLightning ||
        old.showSplashes != showSplashes;
  }
}

class _RainLayer {
  final int count;
  final double speedMul;
  final double widthMul;
  final double opacityMul;
  final Color shade;
  _RainLayer({
    required this.count,
    required this.speedMul,
    required this.widthMul,
    required this.opacityMul,
    required this.shade,
  });
}
// =================== END CALM PURPLE RAIN ===================
