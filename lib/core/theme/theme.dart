import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType {
  darkMode,
  lightMode,
  midnight,
  forest,
  sunset,
  ocean,
  monochrome,
  neon,
  cosmic,
  pastel,
  purpleRain,
  goldenHour,
  cyberpunk,
  cherryBlossom,
  retroWave,
  iceCrystal,
  volcanic; // Added Volcanic theme

  bool get isDark => [
        ThemeType.darkMode,
        ThemeType.midnight,
        ThemeType.monochrome,
        ThemeType.neon,
        ThemeType.cosmic,
        ThemeType.purpleRain,
        ThemeType.cyberpunk,
        ThemeType.retroWave,
        ThemeType.volcanic,
      ].contains(this);

  bool get isLight => !isDark;

  String get displayName {
    switch (this) {
      case ThemeType.darkMode:
        return 'Dark Mode';
      case ThemeType.lightMode:
        return 'Light Mode';
      case ThemeType.midnight:
        return 'Midnight';
      case ThemeType.forest:
        return 'Forest';
      case ThemeType.sunset:
        return 'Sunset';
      case ThemeType.ocean:
        return 'Ocean';
      case ThemeType.monochrome:
        return 'Monochrome';
      case ThemeType.neon:
        return 'Neon';
      case ThemeType.cosmic:
        return 'Cosmic';
      case ThemeType.pastel:
        return 'Pastel';
      case ThemeType.purpleRain:
        return 'Purple Rain';
      case ThemeType.goldenHour:
        return 'Golden Hour';
      case ThemeType.cyberpunk:
        return 'Cyberpunk';
      case ThemeType.cherryBlossom:
        return 'Cherry Blossom';
      case ThemeType.retroWave:
        return 'Retro Wave';
      case ThemeType.iceCrystal:
        return 'Ice Crystal';
      case ThemeType.volcanic:
        return 'Volcanic';
    }
  }
}

class AppTheme {
  static const defaultType = ThemeType.lightMode;
  static final defaultTheme = AppTheme.fromType(defaultType);

  final ThemeType type;
  final bool isDark;

  // Primary colors
  final Color primaryColor;
  final Color primaryVariant;
  final Color onPrimary;

  // Secondary colors
  final Color accentColor;
  final Color onAccent;

  // Background colors
  final Color background;
  final Color surface;
  final Color surfaceVariant;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  // UI element colors
  final Color divider;
  final Color toolbarColor;
  final Color error;
  final Color success;
  final Color warning;

  // Grid colors
  final Color gridLine;
  final Color gridBackground;

  // Canvas-related colors
  final Color canvasBackground;
  final Color selectionOutline;
  final Color selectionFill;

  // Icon colors
  final Color activeIcon;
  final Color inactiveIcon;

  // Font settings
  final TextTheme textTheme;
  final FontWeight primaryFontWeight;

  AppTheme({
    required this.type,
    required this.isDark,
    required this.primaryColor,
    required this.primaryVariant,
    required this.onPrimary,
    required this.accentColor,
    required this.onAccent,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.divider,
    required this.toolbarColor,
    required this.error,
    required this.success,
    required this.warning,
    required this.gridLine,
    required this.gridBackground,
    required this.canvasBackground,
    required this.selectionOutline,
    required this.selectionFill,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.textTheme,
    required this.primaryFontWeight,
  });

  factory AppTheme.fromType(ThemeType type) {
    switch (type) {
      case ThemeType.lightMode:
        return _buildLightTheme();
      case ThemeType.darkMode:
        return _buildDarkTheme();
      case ThemeType.midnight:
        return _buildMidnightTheme();
      case ThemeType.forest:
        return _buildForestTheme();
      case ThemeType.sunset:
        return _buildSunsetTheme();
      case ThemeType.ocean:
        return _buildOceanTheme();
      case ThemeType.monochrome:
        return _buildMonochromeTheme();
      case ThemeType.neon:
        return _buildNeonTheme();
      case ThemeType.cosmic:
        return _buildCosmicTheme();
      case ThemeType.pastel:
        return _buildPastelTheme();
      case ThemeType.purpleRain:
        return _buildPurpleRainTheme();
      case ThemeType.goldenHour:
        return _buildGoldenHourTheme();
      case ThemeType.cyberpunk:
        return _buildCyberpunkTheme();
      case ThemeType.cherryBlossom:
        return _buildCherryBlossomTheme();
      case ThemeType.retroWave:
        return _buildRetroWaveTheme();
      case ThemeType.iceCrystal:
        return _buildIceCrystalTheme();
      case ThemeType.volcanic:
        return _buildVolcanicTheme();
    }
  }

  static AppTheme _buildPastelTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.pastel,
      isDark: false,
      // Primary colors - soft lavender
      primaryColor: const Color(0xFFB4A7D6), // Soft lavender
      primaryVariant: const Color(0xFF9C8DC1), // Slightly deeper lavender
      onPrimary: Colors.white,
      // Secondary colors - soft pink
      accentColor: const Color(0xFFEBB2B8), // Soft pink
      onAccent: const Color(0xFF5D4037), // Warm brown for contrast
      // Background colors - very light and soft
      background: const Color(0xFFFBF9F7), // Warm off-white
      surface: const Color(0xFFFFFFFF), // Pure white
      surfaceVariant: const Color(0xFFF5F2F0), // Very light beige
      // Text colors - soft but readable
      textPrimary: const Color(0xFF4A4458), // Soft dark purple-gray
      textSecondary: const Color(0xFF857A8C), // Muted purple-gray
      textDisabled: const Color(0xFFC4BDC9), // Light purple-gray
      // UI colors
      divider: const Color(0xFFE8E2E6), // Very light purple-gray
      toolbarColor: const Color(0xFFF5F2F0),
      error: const Color(0xFFE8A2A2), // Soft coral
      success: const Color(0xFFA8D5BA), // Soft mint green
      warning: const Color(0xFFFDD4A3), // Soft peach
      // Grid colors
      gridLine: const Color(0xFFE8E2E6),
      gridBackground: const Color(0xFFFFFFFF),
      // Canvas colors
      canvasBackground: const Color(0xFFFFFFFF),
      selectionOutline: const Color(0xFFB4A7D6), // Match primary
      selectionFill: const Color(0x30B4A7D6),
      // Icon colors
      activeIcon: const Color(0xFFB4A7D6), // Soft lavender for active
      inactiveIcon: const Color(0xFF857A8C), // Muted for inactive
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
          color: const Color(0xFF857A8C),
        ),
      ),
      primaryFontWeight: FontWeight.w400, // Lighter weight for softer feel
    );
  }

  static AppTheme _buildVolcanicTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.volcanic,
      isDark: true,
      // Primary colors - molten lava orange
      primaryColor: const Color(0xFFFF4500), // Orange red (lava)
      primaryVariant: const Color(0xFFDC143C), // Crimson
      onPrimary: Colors.white,
      // Secondary colors - bright molten yellow
      accentColor: const Color(0xFFFFD700), // Gold/molten metal
      onAccent: Colors.black,
      // Background colors - dark volcanic rock
      background: const Color(0xFF1A1A1A), // Very dark gray
      surface: const Color(0xFF2C2C2C), // Dark gray (volcanic rock)
      surfaceVariant: const Color(0xFF3D3D3D), // Lighter gray
      // Text colors - light for contrast
      textPrimary: const Color(0xFFFFF8DC), // Cornsilk (warm white)
      textSecondary: const Color(0xFFFFDAB9), // Peach puff
      textDisabled: const Color(0xFF8B7D6B), // Dark khaki
      // UI colors
      divider: const Color(0xFF4A4A4A),
      toolbarColor: const Color(0xFF2C2C2C),
      error: const Color(0xFFFF6B6B), // Light red
      success: const Color(0xFF51CF66), // Light green
      warning: const Color(0xFFFFD43B), // Bright yellow
      // Grid colors
      gridLine: const Color(0xFF4A4A4A),
      gridBackground: const Color(0xFF2C2C2C),
      // Canvas colors
      canvasBackground: const Color(0xFF1A1A1A),
      selectionOutline: const Color(0xFFFF4500), // Match primary (lava)
      selectionFill: const Color(0x30FF4500),
      // Icon colors
      activeIcon: const Color(0xFFFF4500), // Lava orange for active
      inactiveIcon: const Color(0xFFFFDAB9), // Peach for inactive
      // Typography
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFFFFF8DC),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFFFFF8DC),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFFFFF8DC),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFFFFDAB9),
        ),
      ),
      primaryFontWeight: FontWeight.w500, // Medium weight for strength
    );
  }

  static AppTheme _buildIceCrystalTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.iceCrystal,
      isDark: false,
      // Primary colors - icy blue
      primaryColor: const Color(0xFF4FC3F7), // Light blue/ice blue
      primaryVariant: const Color(0xFF29B6F6), // Slightly deeper blue
      onPrimary: Colors.white,
      // Secondary colors - crystal cyan
      accentColor: const Color(0xFF80DEEA), // Light cyan
      onAccent: const Color(0xFF004D5A), // Dark teal for contrast
      // Background colors - very light ice-like
      background: const Color(0xFFF8FCFF), // Very light blue-white
      surface: const Color(0xFFFFFFFF), // Pure white like fresh snow
      surfaceVariant: const Color(0xFFF0F8FF), // Alice blue
      // Text colors - dark for contrast on light ice
      textPrimary: const Color(0xFF0D47A1), // Dark blue
      textSecondary: const Color(0xFF1976D2), // Medium blue
      textDisabled: const Color(0xFF90CAF9), // Light blue
      // UI colors
      divider: const Color(0xFFE3F2FD), // Very light blue
      toolbarColor: const Color(0xFFF0F8FF),
      error: const Color(0xFFD32F2F), // Red for visibility
      success: const Color(0xFF388E3C), // Green for visibility
      warning: const Color(0xFFF57C00), // Orange for visibility
      // Grid colors
      gridLine: const Color(0xFFE3F2FD),
      gridBackground: const Color(0xFFFFFFFF),
      // Canvas colors
      canvasBackground: const Color(0xFFFFFFFF),
      selectionOutline: const Color(0xFF4FC3F7), // Match primary
      selectionFill: const Color(0x304FC3F7),
      // Icon colors
      activeIcon: const Color(0xFF4FC3F7), // Ice blue for active
      inactiveIcon: const Color(0xFF1976D2), // Darker blue for inactive
      // Typography
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF0D47A1),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF0D47A1),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF0D47A1),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF1976D2),
        ),
      ),
      primaryFontWeight: FontWeight.w500, // Clean, crisp weight
    );
  }

  static AppTheme _buildRetroWaveTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.retroWave,
      isDark: true,
      // Primary colors - hot pink/magenta
      primaryColor: const Color(0xFFFF0080), // Hot pink/magenta
      primaryVariant: const Color(0xFFE91E63), // Deep pink
      onPrimary: Colors.white,
      // Secondary colors - electric cyan/blue
      accentColor: const Color(0xFF00FFFF), // Electric cyan
      onAccent: Colors.black,
      // Background colors - dark with purple gradients
      background: const Color(0xFF0A0A1A), // Very dark blue-purple
      surface: const Color(0xFF1A1A2E), // Dark purple-blue
      surfaceVariant: const Color(0xFF16213E), // Darker blue
      // Text colors - bright neon
      textPrimary: const Color(0xFF00FFFF), // Bright cyan text
      textSecondary: const Color(0xFFFF0080), // Hot pink secondary text
      textDisabled: const Color(0xFF666B85), // Muted blue-gray
      // UI colors
      divider: const Color(0xFF2A2D47),
      toolbarColor: const Color(0xFF1A1A2E),
      error: const Color(0xFFFF073A), // Bright neon red
      success: const Color(0xFF39FF14), // Electric lime
      warning: const Color(0xFFFFFF00), // Electric yellow
      // Grid colors
      gridLine: const Color(0xFF2A2D47),
      gridBackground: const Color(0xFF1A1A2E),
      // Canvas colors
      canvasBackground: const Color(0xFF0A0A1A),
      selectionOutline: const Color(0xFFFF0080), // Hot pink selection
      selectionFill: const Color(0x30FF0080),
      // Icon colors
      activeIcon: const Color(0xFFFF0080), // Hot pink for active
      inactiveIcon: const Color(0xFF00FFFF), // Cyan for inactive
      // Typography
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF00FFFF),
          fontWeight: FontWeight.w700, // Bold for retro feel
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF00FFFF),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF00FFFF),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFFFF0080),
        ),
      ),
      primaryFontWeight: FontWeight.w600, // Bold for 80s aesthetic
    );
  }

  static AppTheme _buildCherryBlossomTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.cherryBlossom,
      isDark: false,
      // Primary colors - soft sakura pink
      primaryColor: const Color(0xFFFFB7C5), // Soft sakura pink
      primaryVariant: const Color(0xFFFF91A4), // Slightly deeper pink
      onPrimary: const Color(0xFF5D2C2F), // Dark rose for contrast
      // Secondary colors - fresh spring green
      accentColor: const Color(0xFF98D8C8), // Soft mint green
      onAccent: const Color(0xFF2D5016), // Dark green for contrast
      // Background colors - very light and airy
      background: const Color(0xFFFDF8F9), // Very light pink-white
      surface: const Color(0xFFFFFFFF), // Pure white
      surfaceVariant: const Color(0xFFF7F0F2), // Light pink-gray
      // Text colors - soft but readable
      textPrimary: const Color(0xFF3E2723), // Dark brown with warmth
      textSecondary: const Color(0xFF795548), // Medium brown
      textDisabled: const Color(0xFFBCAAA4), // Light brown-pink
      // UI colors
      divider: const Color(0xFFE8DDDF), // Very light pink-gray
      toolbarColor: const Color(0xFFF7F0F2),
      error: const Color(0xFFD32F2F), // Traditional red
      success: const Color(0xFF4CAF50), // Fresh green
      warning: const Color(0xFFFF9800), // Warm orange
      // Grid colors
      gridLine: const Color(0xFFE8DDDF),
      gridBackground: const Color(0xFFFFFFFF),
      // Canvas colors
      canvasBackground: const Color(0xFFFFFFFF),
      selectionOutline: const Color(0xFFFFB7C5), // Match primary
      selectionFill: const Color(0x30FFB7C5),
      // Icon colors
      activeIcon: const Color(0xFFFFB7C5), // Sakura pink for active
      inactiveIcon: const Color(0xFF795548), // Brown for inactive
      // Typography
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF3E2723),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF3E2723),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF3E2723),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF795548),
        ),
      ),
      primaryFontWeight: FontWeight.w400, // Light weight for elegant feel
    );
  }

  static AppTheme _buildCyberpunkTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.cyberpunk,
      isDark: true,
      // Primary colors - electric cyan
      primaryColor: const Color(0xFF00F5FF), // Electric cyan
      primaryVariant: const Color(0xFF00BFFF), // Deep sky blue
      onPrimary: Colors.black,
      // Secondary colors - neon magenta
      accentColor: const Color(0xFFFF073A), // Neon red/magenta
      onAccent: Colors.white,
      // Background colors - deep dark with tech undertones
      background: const Color(0xFF0A0A0A), // Almost black
      surface: const Color(0xFF1A1A1A), // Dark gray
      surfaceVariant: const Color(0xFF2A2A2A), // Lighter dark gray
      // Text colors - bright neon
      textPrimary: const Color(0xFF00F5FF), // Bright cyan text
      textSecondary: const Color(0xFF8BB8FF), // Light blue
      textDisabled: const Color(0xFF4A5568), // Dark gray
      // UI colors
      divider: const Color(0xFF2D3748),
      toolbarColor: const Color(0xFF1A1A1A),
      error: const Color(0xFFFF073A), // Bright red error
      success: const Color(0xFF39FF14), // Electric lime success
      warning: const Color(0xFFFFFF00), // Electric yellow warning
      // Grid colors
      gridLine: const Color(0xFF2D3748),
      gridBackground: const Color(0xFF1A1A1A),
      // Canvas colors
      canvasBackground: const Color(0xFF0A0A0A),
      selectionOutline: const Color(0xFF00F5FF), // Cyan selection
      selectionFill: const Color(0x3000F5FF),
      // Icon colors
      activeIcon: const Color(0xFF00F5FF), // Electric cyan for active
      inactiveIcon: const Color(0xFF8BB8FF), // Light blue for inactive
      // Typography
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF00F5FF),
          fontWeight: FontWeight.w700, // Extra bold for cyberpunk feel
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF00F5FF),
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF00F5FF),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF8BB8FF),
        ),
      ),
      primaryFontWeight: FontWeight.w600, // Bold for tech aesthetic
    );
  }

  static AppTheme _buildGoldenHourTheme() {
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

  static AppTheme _buildPurpleRainTheme() {
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

  static AppTheme _buildCosmicTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.cosmic,
      isDark: true,
      // Primary colors - vibrant orange like in the image
      primaryColor: const Color(0xFFFF6B35), // Bright orange from the UI
      primaryVariant: const Color(0xFFE55A2B),
      onPrimary: Colors.white,
      // Secondary colors - cyan accent
      accentColor: const Color(0xFF00D9FF), // Bright cyan
      onAccent: Colors.black,
      // Background colors - deep space purple/blue gradient feel
      background: const Color(0xFF1A1B3A), // Deep cosmic purple
      surface: const Color(0xFF252653), // Lighter cosmic purple for surfaces
      surfaceVariant: const Color(0xFF2D2E5F), // Even lighter for variants
      // Text colors - bright and cosmic
      textPrimary: const Color(0xFFE8E9FF), // Almost white with purple tint
      textSecondary: const Color(0xFFB8BADF), // Muted purple-white
      textDisabled: const Color(0xFF7A7BA0), // Darker purple-gray
      // UI colors
      divider: const Color(0xFF3A3C6B),
      toolbarColor: const Color(0xFF252653),
      error: const Color(0xFFFF4757), // Bright red
      success: const Color(0xFF5CE65C), // Bright green
      warning: const Color(0xFFFFA726), // Bright amber
      // Grid colors
      gridLine: const Color(0xFF3A3C6B),
      gridBackground: const Color(0xFF252653),
      // Canvas colors
      canvasBackground: const Color(0xFF1A1B3A),
      selectionOutline: const Color(0xFF00D9FF), // Cyan selection
      selectionFill: const Color(0x3000D9FF),
      // Icon colors
      activeIcon: const Color(0xFFFF6B35), // Orange for active
      inactiveIcon: const Color(0xFFB8BADF), // Muted for inactive
      // Typography
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFFE8E9FF),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFFE8E9FF),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFFE8E9FF),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFFB8BADF),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildLightTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.lightMode,
      isDark: false,
      primaryColor: const Color(0xFF1A863A),
      primaryVariant: const Color(0xFF006428),
      onPrimary: Colors.white,
      accentColor: const Color(0xFF3F51B5),
      onAccent: Colors.white,
      background: const Color(0xFFF5F5F5),
      surface: Colors.white,
      surfaceVariant: const Color(0xFFE0E0E0),
      textPrimary: const Color(0xFF212121),
      textSecondary: const Color(0xFF757575),
      textDisabled: const Color(0xFFBDBDBD),
      divider: const Color(0xFFDDDDDD),
      toolbarColor: const Color(0xFFEEEEEE),
      error: const Color(0xFFB00020),
      success: const Color(0xFF388E3C),
      warning: const Color(0xFFFFA000),
      gridLine: const Color(0xFFDDDDDD),
      gridBackground: Colors.white,
      canvasBackground: Colors.white,
      selectionOutline: const Color(0xFF2196F3),
      selectionFill: const Color(0x302196F3),
      activeIcon: const Color(0xFF1A863A),
      inactiveIcon: const Color(0xFF757575),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF212121),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF212121),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF212121),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF757575),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildDarkTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.darkMode,
      isDark: true,
      primaryColor: const Color(0xFF00C853),
      primaryVariant: const Color(0xFF4CAF50),
      onPrimary: Colors.black,
      accentColor: const Color(0xFF536DFE),
      onAccent: Colors.white,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      surfaceVariant: const Color(0xFF2D2D2D),
      textPrimary: Colors.white,
      textSecondary: const Color(0xFFB0B0B0),
      textDisabled: const Color(0xFF6E6E6E),
      divider: const Color(0xFF3D3D3D),
      toolbarColor: const Color(0xFF252525),
      error: const Color(0xFFCF6679),
      success: const Color(0xFF4CAF50),
      warning: const Color(0xFFFFB74D),
      gridLine: const Color(0xFF3D3D3D),
      gridBackground: const Color(0xFF2D2D2D),
      canvasBackground: const Color(0xFF121212),
      selectionOutline: const Color(0xFF2196F3),
      selectionFill: const Color(0x502196F3),
      activeIcon: const Color(0xFF00C853),
      inactiveIcon: const Color(0xFFB0B0B0),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFFB0B0B0),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildMidnightTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.midnight,
      isDark: true,
      primaryColor: const Color(0xFF6A3DE8),
      primaryVariant: const Color(0xFF8056EA),
      onPrimary: Colors.white,
      accentColor: const Color(0xFF03DAC6),
      onAccent: Colors.black,
      background: const Color(0xFF0A1021),
      surface: const Color(0xFF162041),
      surfaceVariant: const Color(0xFF1D2A59),
      textPrimary: Colors.white,
      textSecondary: const Color(0xFFB8C7E0),
      textDisabled: const Color(0xFF6987B7),
      divider: const Color(0xFF2B3966),
      toolbarColor: const Color(0xFF162041),
      error: const Color(0xFFF45E89),
      success: const Color(0xFF4ADE80),
      warning: const Color(0xFFF9AE59),
      gridLine: const Color(0xFF2B3966),
      gridBackground: const Color(0xFF1D2A59),
      canvasBackground: const Color(0xFF0A1021),
      selectionOutline: const Color(0xFF03DAC6),
      selectionFill: const Color(0x3003DAC6),
      activeIcon: const Color(0xFF6A3DE8),
      inactiveIcon: const Color(0xFFB8C7E0),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFFB8C7E0),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildForestTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.forest,
      isDark: false,
      primaryColor: const Color(0xFF2E7D32),
      primaryVariant: const Color(0xFF388E3C),
      onPrimary: Colors.white,
      accentColor: const Color(0xFFD3B047),
      onAccent: Colors.black,
      background: const Color(0xFFEFF4ED),
      surface: Colors.white,
      surfaceVariant: const Color(0xFFE1ECD8),
      textPrimary: const Color(0xFF1E3725),
      textSecondary: const Color(0xFF5C745F),
      textDisabled: const Color(0xFFA5B8A7),
      divider: const Color(0xFFD4E2CD),
      toolbarColor: const Color(0xFFE1ECD8),
      error: const Color(0xFFB71C1C),
      success: const Color(0xFF2E7D32),
      warning: const Color(0xFFF9A825),
      gridLine: const Color(0xFFD4E2CD),
      gridBackground: Colors.white,
      canvasBackground: Colors.white,
      selectionOutline: const Color(0xFF2E7D32),
      selectionFill: const Color(0x302E7D32),
      activeIcon: const Color(0xFF2E7D32),
      inactiveIcon: const Color(0xFF5C745F),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF1E3725),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF1E3725),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF1E3725),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF5C745F),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildSunsetTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.sunset,
      isDark: false,
      primaryColor: const Color(0xFFFF6F00),
      primaryVariant: const Color(0xFFE65100),
      onPrimary: Colors.white,
      accentColor: const Color(0xFF304FFE),
      onAccent: Colors.white,
      background: const Color(0xFFFFF9F0),
      surface: Colors.white,
      surfaceVariant: const Color(0xFFFFEED3),
      textPrimary: const Color(0xFF33261D),
      textSecondary: const Color(0xFF7A6058),
      textDisabled: const Color(0xFFBBA79E),
      divider: const Color(0xFFFFD8B0),
      toolbarColor: const Color(0xFFFFEED3),
      error: const Color(0xFFB71C1C),
      success: const Color(0xFF388E3C),
      warning: const Color(0xFFFFB300),
      gridLine: const Color(0xFFFFD8B0),
      gridBackground: Colors.white,
      canvasBackground: Colors.white,
      selectionOutline: const Color(0xFFFF6F00),
      selectionFill: const Color(0x30FF6F00),
      activeIcon: const Color(0xFFFF6F00),
      inactiveIcon: const Color(0xFF7A6058),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF33261D),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF33261D),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF33261D),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF7A6058),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildOceanTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.ocean,
      isDark: false,
      primaryColor: const Color(0xFF0288D1),
      primaryVariant: const Color(0xFF006DB3),
      onPrimary: Colors.white,
      accentColor: const Color(0xFFFF6D00),
      onAccent: Colors.white,
      background: const Color(0xFFECF8FD),
      surface: Colors.white,
      surfaceVariant: const Color(0xFFD4F0FB),
      textPrimary: const Color(0xFF004466),
      textSecondary: const Color(0xFF4D748A),
      textDisabled: const Color(0xFF9EBFD1),
      divider: const Color(0xFFB3E3F5),
      toolbarColor: const Color(0xFFD4F0FB),
      error: const Color(0xFFB71C1C),
      success: const Color(0xFF2E7D32),
      warning: const Color(0xFFF9A825),
      gridLine: const Color(0xFFB3E3F5),
      gridBackground: Colors.white,
      canvasBackground: Colors.white,
      selectionOutline: const Color(0xFF0288D1),
      selectionFill: const Color(0x300288D1),
      activeIcon: const Color(0xFF0288D1),
      inactiveIcon: const Color(0xFF4D748A),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFF004466),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFF004466),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFF004466),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF4D748A),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildMonochromeTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.monochrome,
      isDark: true,
      primaryColor: const Color(0xFFBBBBBB),
      primaryVariant: const Color(0xFF999999),
      onPrimary: Colors.black,
      accentColor: Colors.white,
      onAccent: Colors.black,
      background: const Color(0xFF121212),
      surface: const Color(0xFF212121),
      surfaceVariant: const Color(0xFF292929),
      textPrimary: Colors.white,
      textSecondary: const Color(0xFFBBBBBB),
      textDisabled: const Color(0xFF777777),
      divider: const Color(0xFF3D3D3D),
      toolbarColor: const Color(0xFF292929),
      error: const Color(0xFFE0E0E0),
      success: const Color(0xFFBBBBBB),
      warning: const Color(0xFF999999),
      gridLine: const Color(0xFF3D3D3D),
      gridBackground: const Color(0xFF212121),
      canvasBackground: const Color(0xFF121212),
      selectionOutline: Colors.white,
      selectionFill: const Color(0x50FFFFFF),
      activeIcon: Colors.white,
      inactiveIcon: const Color(0xFFBBBBBB),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: Colors.white,
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFFBBBBBB),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  static AppTheme _buildNeonTheme() {
    final baseTextTheme = GoogleFonts.sourceCodeProTextTheme();

    return AppTheme(
      type: ThemeType.neon,
      isDark: true,
      primaryColor: const Color(0xFF00FF9C),
      primaryVariant: const Color(0xFF00CC7D),
      onPrimary: Colors.black,
      accentColor: const Color(0xFFFF00FF),
      onAccent: Colors.white,
      background: const Color(0xFF0F1020),
      surface: const Color(0xFF191B36),
      surfaceVariant: const Color(0xFF242757),
      textPrimary: const Color(0xFFCDFFF9),
      textSecondary: const Color(0xFF9BBDB7),
      textDisabled: const Color(0xFF5C7D78),
      divider: const Color(0xFF242757),
      toolbarColor: const Color(0xFF191B36),
      error: const Color(0xFFFF004C),
      success: const Color(0xFF00FF9C),
      warning: const Color(0xFFFFDF00),
      gridLine: const Color(0xFF242757),
      gridBackground: const Color(0xFF191B36),
      canvasBackground: const Color(0xFF0F1020),
      selectionOutline: const Color(0xFF00FF9C),
      selectionFill: const Color(0x3000FF9C),
      activeIcon: const Color(0xFF00FF9C),
      inactiveIcon: const Color(0xFF9BBDB7),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge!.copyWith(
          color: const Color(0xFFCDFFF9),
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTextTheme.titleMedium!.copyWith(
          color: const Color(0xFFCDFFF9),
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: baseTextTheme.bodyLarge!.copyWith(
          color: const Color(0xFFCDFFF9),
        ),
        bodyMedium: baseTextTheme.bodyMedium!.copyWith(
          color: const Color(0xFF9BBDB7),
        ),
      ),
      primaryFontWeight: FontWeight.w500,
    );
  }

  ThemeData get themeData {
    var t = ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimary,
        secondary: accentColor,
        onSecondary: onAccent,
        error: error,
        onError: isDark ? Colors.black : Colors.white,
        background: background,
        onBackground: textPrimary,
        surface: surface,
        onSurface: textPrimary,
      ),
      primaryColor: primaryColor,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      dividerColor: divider,
      textTheme: textTheme,
      iconTheme: IconThemeData(
        color: activeIcon,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: toolbarColor,
        foregroundColor: textPrimary,
        centerTitle: true,
      ),
      dialogBackgroundColor: surface,
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        textStyle: TextStyle(color: textPrimary),
      ),
      bottomAppBarTheme: BottomAppBarTheme(
        color: toolbarColor,
      ),
      cardTheme: CardThemeData(
        color: surface,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: surfaceVariant,
        filled: true,
        labelStyle: TextStyle(color: textSecondary),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: divider),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: error, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: onPrimary,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: onPrimary,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: primaryColor.withOpacity(0.3),
        thumbColor: primaryColor,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        }),
        checkColor: MaterialStateProperty.all(onPrimary),
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade200;
        }),
      ),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade800 : Colors.grey.shade300;
        }),
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return isDark ? Colors.grey.shade200 : Colors.white;
        }),
      ),
    );

    return t;
  }

  Color shift(Color c, double amount) {
    amount *= (isDark ? -1 : 1);

    /// Convert to HSL
    var hslc = HSLColor.fromColor(c);

    /// Add/Remove lightness
    double lightness = (hslc.lightness + amount).clamp(0, 1.0).toDouble();

    /// Convert back to Color
    return hslc.withLightness(lightness).toColor();
  }
}

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'app_theme';
  AppTheme _currentTheme = AppTheme.defaultTheme;

  AppTheme get theme => _currentTheme;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey);

    if (themeString != null) {
      try {
        final themeType = ThemeType.values.firstWhere(
          (t) => t.toString() == themeString,
          orElse: () => ThemeType.darkMode,
        );
        _currentTheme = AppTheme.fromType(themeType);
        notifyListeners();
      } catch (e) {
        // If theme loading fails, use default
        _currentTheme = AppTheme.defaultTheme;
      }
    }
  }

  Future<void> setTheme(ThemeType themeType) async {
    _currentTheme = AppTheme.fromType(themeType);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeType.toString());

    notifyListeners();
  }
}
