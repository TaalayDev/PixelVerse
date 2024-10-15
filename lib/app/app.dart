import 'package:flutter/material.dart';

import '../core/theme/theme.dart';
import '../core/utils/locale_manager.dart';
import '../l10n/strings.dart';
import '../ui/screens.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
  static _AppState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppState>()!;
  static AppTheme appTheme(BuildContext context) => of(context)._appTheme;
}

class _AppState extends State<App> {
  AppTheme _appTheme = AppTheme.defaultTheme;

  final localeManager = LocaleManager();

  void toggleTheme() {
    final newType = _appTheme.type == ThemeType.lightDarkBlue
        ? ThemeType.darkDarkBlue
        : ThemeType.lightDarkBlue;

    _appTheme = AppTheme.fromType(newType);
  }

  bool get isLocaleSet => localeManager.isLocaleSet;
  Locale get locale => localeManager.locale;
  void setLocale(Locale newLocale) async {
    localeManager.locale = newLocale;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    localeManager.initLocale();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        theme: _appTheme.themeData,
        themeMode: _appTheme.isDark ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => Strings.of(context).appName,
        supportedLocales: Strings.supportedLocales,
        localizationsDelegates: Strings.localizationsDelegates,
        locale: localeManager.locale,
        home: const SplashScreen(),
      ),
    );
  }
}
