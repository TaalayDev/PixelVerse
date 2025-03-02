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
  neon;

  bool get isDark => [
        ThemeType.darkMode,
        ThemeType.midnight,
        ThemeType.monochrome,
        ThemeType.neon,
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
    }
  }
}

class AppTheme {
  static const defaultType = ThemeType.forest;
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
    }
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
      cardTheme: CardTheme(
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
