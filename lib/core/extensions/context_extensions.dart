import 'package:flutter/widgets.dart';

import '../utils/screen_size.dart';

extension ContextExtensions on BuildContext {
  NavigatorState get navigator => Navigator.of(this);

  ScreenSize get screenSize => MediaQuery.of(this).size.adaptiveValue(
        ScreenSize.md,
        {
          ScreenSize.xxs: ScreenSize.xs,
          ScreenSize.xs: ScreenSize.sm,
          ScreenSize.sm: ScreenSize.md,
          ScreenSize.md: ScreenSize.lg,
          ScreenSize.lg: ScreenSize.xl,
        },
      );

  R byScreenSize<R>(
    R Function() defValue,
    Map<ScreenSize, R Function()> values,
  ) {
    return values[screenSize]?.call() ?? defValue();
  }
}
