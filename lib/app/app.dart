import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../core/theme/theme.dart';
import '../core/utils/locale_manager.dart';
import '../l10n/strings.dart';
import '../ui/screens.dart';
import '../ui/widgets/theme_selector.dart';

class PixelVerseApp extends ConsumerWidget {
  const PixelVerseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeManager = ref.watch(themeProvider);
    final appTheme = themeManager.theme;

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: MaterialApp(
        theme: appTheme.themeData,
        darkTheme: appTheme.themeData,
        themeMode: appTheme.isDark ? ThemeMode.dark : ThemeMode.light,
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => Strings.of(context).appName,
        supportedLocales: Strings.supportedLocales,
        localizationsDelegates: Strings.localizationsDelegates,
        locale: _getLocale(ref),
        home: const SplashScreen(),
      ),
    );
  }

  Locale _getLocale(WidgetRef ref) {
    final localeManager = LocaleManager();
    if (localeManager.isLocaleSet) {
      localeManager.initLocale();
      return localeManager.locale;
    }
    return Strings.supportedLocales.first;
  }
}
