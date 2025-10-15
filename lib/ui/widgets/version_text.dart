import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionTextBuilder extends StatefulWidget {
  const VersionTextBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, String version, bool isLoading) builder;

  @override
  State<VersionTextBuilder> createState() => _VersionTextState();
}

class _VersionTextState extends State<VersionTextBuilder> {
  String _version = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _version, _isLoading);
  }
}
