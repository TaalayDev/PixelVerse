import 'package:flutter/material.dart';

import 'ad_banner.dart';

class AdWrapper extends StatefulWidget {
  final Widget child;

  const AdWrapper({
    super.key,
    required this.child,
  });

  @override
  State<AdWrapper> createState() => _AdWrapperState();
}

class _AdWrapperState extends State<AdWrapper> {
  bool _isAdLoaded = false;

  @override
  Widget build(BuildContext context) {
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
