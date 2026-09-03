import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:picell/providers/subscription_provider.dart';

import 'ad_banner.dart';

class AdWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AdWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<AdWrapper> createState() => _AdWrapperState();
}

class _AdWrapperState extends ConsumerState<AdWrapper> {
  bool _isAdLoaded = false;

  bool get isDesktopOrWeb =>
      kIsWeb ||
      !(Theme.of(context).platform == TargetPlatform.android || Theme.of(context).platform == TargetPlatform.iOS);

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionStateProvider);
    if (isDesktopOrWeb || subscription.isPro) {
      return widget.child;
    }

    return SafeArea(
      top: false,
      bottom: _isAdLoaded,
      child: Column(
        children: [
          Expanded(child: widget.child),
          AdBanner(
            height: 50,
            onAdLoaded: () {
              setState(() {
                _isAdLoaded = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
