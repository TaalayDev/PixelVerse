import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pixelverse/l10n/strings.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../config/assets.dart';
import '../../config/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          Strings.of(context).aboutTitle,
        ),
        foregroundColor: const Color.fromARGB(255, 222, 222, 224),
        backgroundColor: const Color(0xFF2e2131), //Theme.of(context).colorScheme.primary,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            _buildInfoSection(context),
            _buildFeaturesList(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    const headerColor = Color(0xFF2e2131);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            headerColor,
            headerColor.withOpacity(0.99),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const PixelArtLogo(),
            const SizedBox(height: 16),
            Text(
              Strings.of(context).appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black.withOpacity(0.5),
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
            Text(
              Strings.of(context).version('1.1.0'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.of(context).welcome,
            style: Theme.of(context).textTheme.headlineSmall,
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 8),
          Text(
            Strings.of(context).aboutAppDescription,
            style: Theme.of(context).textTheme.bodyLarge,
          ).animate().fadeIn(delay: 300.ms, duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features =
        Strings.of(context).features.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Strings.of(context).featuresTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(height: 8),
          ...features.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  const Icon(Icons.check, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(entry.value)),
                ],
              ).animate().fadeIn(delay: (300 + entry.key * 100).ms, duration: 600.ms),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            Strings.of(context).visitWebsite,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              launchUrlString('https://taalaydev.github.io');
            },
            child: Text(
              'https://taalaydev.github.io',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  // Launch terms of service URL
                  launchUrlString(Constants.termsOfServiceUrl);
                },
                child: Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                ' • ',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              InkWell(
                onTap: () {
                  // Launch privacy policy URL
                  launchUrlString(Constants.privacyPolicyUrl);
                },
                child: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(delay: 1000.ms, duration: 600.ms),
    );
  }
}

class PixelArtLogo extends StatelessWidget {
  const PixelArtLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Image.asset(Assets.images.logo),
    ).animate().scale(duration: 600.ms, curve: Curves.elasticOut);
  }
}

class PixelArtLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = size.width / 20;
    final paint = Paint();

    // Define the pixel art logo
    final logo = [
      // Rows 0-6: Empty
      for (int i = 0; i < 7; i++) List.filled(20, 0),
      // Row 7
      List.filled(20, 0),
      // Row 8
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0],
      // Row 9
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 4, 3, 0, 0, 0],
      // Row 10
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 4, 3, 0, 0],
      // Row 11
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 2, 4, 3, 0],
      // Row 12
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 2, 2, 2, 4, 3],
      // Row 13
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 4],
      // Row 14
      [0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      // Row 15
      [0, 0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      // Row 16
      [0, 0, 0, 0, 0, 0, 0, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2],
      // Row 17
      [0, 0, 0, 0, 0, 0, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5],
      // Row 18
      [0, 0, 0, 0, 0, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
      // Row 19
      [0, 0, 0, 0, 3, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
    ];

    // Define a palette of colors
    final colors = {
      0: Colors.transparent, // Empty space
      1: Colors.grey[300]!, // Grid background
      2: Colors.yellow, // Pencil body
      3: Colors.brown, // Pencil tip
      4: Colors.black, // Outline
      5: Colors.red, // Eraser
    };

    // Drawing the grid background
    for (int y = 0; y < 20; y++) {
      for (int x = 0; x < 20; x++) {
        paint.color = colors[1]!;
        canvas.drawRect(
          Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
          paint,
        );
      }
    }

    // Drawing the pencil over the grid
    for (int y = 0; y < logo.length; y++) {
      for (int x = 0; x < logo[y].length; x++) {
        int colorIndex = logo[y][x];
        if (colorIndex != 0 && colorIndex != 1) {
          // Skip empty and grid background
          paint.color = colors[colorIndex]!;
          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }

    // Optionally, draw grid lines (uncomment to enable)
    /*
    paint.color = Colors.grey;
    paint.style = PaintingStyle.stroke;
    for (int y = 0; y <= 20; y++) {
      canvas.drawLine(Offset(0, y * pixelSize), Offset(size.width, y * pixelSize), paint);
    }
    for (int x = 0; x <= 20; x++) {
      canvas.drawLine(Offset(x * pixelSize, 0), Offset(x * pixelSize, size.height), paint);
    }
    */
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
