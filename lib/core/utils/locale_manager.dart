import 'dart:ui';

import '../../data.dart';
import '../../l10n/strings.dart';

final class LocaleManager {
  static const supportedLocales = Strings.supportedLocales;

  late Locale _locale;
  Locale get locale => _locale;
  set locale(Locale newLocale) {
    if (newLocale.languageCode == _locale.languageCode) return;
    _locale = newLocale;

    LocalStorage().locale = newLocale;
  }

  void initLocale() {
    if (LocalStorage().locale case var locale?) {
      _locale = locale;
      return;
    }

    final systemLocale = PlatformDispatcher.instance.locale;
    _locale = supportedLocales.contains(systemLocale)
        ? systemLocale
        : supportedLocales.first;
    LocalStorage().locale = _locale;
  }

  bool get isLocaleSet => LocalStorage().locale != null;
}
