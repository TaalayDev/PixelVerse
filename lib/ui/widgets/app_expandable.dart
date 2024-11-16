import 'package:flutter/material.dart';

class AppExpandable extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final bool expand;
  final double? maxHeight;

  const AppExpandable({
    super.key,
    required this.child,
    this.expand = false,
    this.maxHeight,
    this.duration,
  });

  @override
  _AppExpandableState createState() => _AppExpandableState();
}

class _AppExpandableState extends State<AppExpandable>
    with SingleTickerProviderStateMixin {
  late AnimationController expandController;
  late Animation<double> animation;

  bool _showWidget = false;

  @override
  void initState() {
    super.initState();
    prepareAnimations();
    _runExpandCheck();
  }

  @override
  void didUpdateWidget(covariant AppExpandable oldWidget) {
    super.didUpdateWidget(oldWidget);
    _runExpandCheck();
  }

  ///Setting up the animation
  void prepareAnimations() {
    expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = CurvedAnimation(
      parent: expandController,
      curve: Curves.fastOutSlowIn,
    );
  }

  void _runExpandCheck() {
    if (widget.expand) {
      setState(() {
        _showWidget = true;
      });

      expandController.forward();
    } else {
      expandController.reverse().then((value) {
        setState(() {
          _showWidget = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body = SizeTransition(
      axisAlignment: 1.0,
      sizeFactor: animation,
      child: _showWidget ? widget.child : null,
    );
    if (widget.maxHeight != null) {
      body = Container(
        constraints: BoxConstraints(
          maxHeight: widget.maxHeight!,
        ),
        child: SingleChildScrollView(
          child: body,
        ),
      );
    }

    return body;
  }

  @override
  void dispose() {
    expandController.dispose();
    super.dispose();
  }
}
