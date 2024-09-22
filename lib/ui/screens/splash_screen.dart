import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'projects_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Pixel> _pixels = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {});
      });

    _controller.forward();

    Future.delayed(const Duration(seconds: 4), _navigateToNextScreen);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const ProjectsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: PixelArtPainter(_pixels, _controller.value),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'PixelVerse',
              style: GoogleFonts.pixelifySans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.white.withOpacity(0.7),
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Pixel {
  final double x;
  final double y;
  final Color color;
  final double size;

  Pixel(this.x, this.y, this.color, this.size);
}

class PixelArtPainter extends CustomPainter {
  final List<Pixel> pixels;
  final double animationValue;

  PixelArtPainter(this.pixels, this.animationValue) {
    if (pixels.isEmpty) {
      _generatePixels();
    }
  }

  void _generatePixels() {
    final random = Random();
    for (int i = 0; i < 500; i++) {
      pixels.add(Pixel(
        random.nextDouble() * 200,
        random.nextDouble() * 200,
        Color.fromRGBO(
          random.nextInt(256),
          random.nextInt(256),
          random.nextInt(256),
          1,
        ),
        random.nextDouble() * 4 + 1,
      ));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var pixel in pixels) {
      final paint = Paint()..color = pixel.color.withOpacity(animationValue);
      canvas.drawRect(
        Rect.fromLTWH(pixel.x, pixel.y, pixel.size, pixel.size),
        paint,
      );
    }

    // Draw a simple pixel art logo
    _drawPixelArtLogo(canvas, size);
  }

  void _drawPixelArtLogo(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(animationValue);
    final pixelSize = 10.0;

    // Draw a simple "P" shape
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(
        Rect.fromLTWH(50, 50 + i * pixelSize, pixelSize, pixelSize),
        paint,
      );
    }
    canvas.drawRect(Rect.fromLTWH(60, 50, pixelSize, pixelSize), paint);
    canvas.drawRect(Rect.fromLTWH(70, 60, pixelSize, pixelSize), paint);
    canvas.drawRect(Rect.fromLTWH(60, 70, pixelSize, pixelSize), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
