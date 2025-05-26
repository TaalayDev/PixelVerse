import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ZoomController extends ChangeNotifier {
  double _zoomLevel = 1.0;
  Offset _panOffset = Offset.zero;
  Size _canvasSize = Size.zero;

  // Zoom constraints
  static const double minZoom = 0.1;
  static const double maxZoom = 20.0;
  static const double zoomSensitivity = 0.1;

  // Animation
  AnimationController? _animationController;
  Animation<double>? _zoomAnimation;
  Animation<Offset>? _offsetAnimation;

  double get zoomLevel => _zoomLevel;
  Offset get panOffset => _panOffset;
  Size get canvasSize => _canvasSize;

  bool get canZoomIn => _zoomLevel < maxZoom;
  bool get canZoomOut => _zoomLevel > minZoom;

  void setCanvasSize(Size size) {
    _canvasSize = size;
    notifyListeners();
  }

  void setAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  /// Smooth zoom with center point
  void zoomToPoint({
    required double targetZoom,
    required Offset focalPoint,
    bool animate = true,
  }) {
    final clampedZoom = targetZoom.clamp(minZoom, maxZoom);

    if (clampedZoom == _zoomLevel) return;

    // Calculate new offset to keep focal point stationary
    final zoomFactor = clampedZoom / _zoomLevel;
    final newOffset = focalPoint - (focalPoint - _panOffset) * zoomFactor;

    if (animate && _animationController != null) {
      _animateToZoom(clampedZoom, newOffset);
    } else {
      _zoomLevel = clampedZoom;
      _panOffset = newOffset;
      notifyListeners();
    }
  }

  /// Zoom in with smooth animation
  void zoomIn({Offset? focalPoint}) {
    final center = focalPoint ?? _getCanvasCenter();
    final newZoom = _calculateSmartZoomLevel(_zoomLevel, true);
    zoomToPoint(targetZoom: newZoom, focalPoint: center);
  }

  /// Zoom out with smooth animation
  void zoomOut({Offset? focalPoint}) {
    final center = focalPoint ?? _getCanvasCenter();
    final newZoom = _calculateSmartZoomLevel(_zoomLevel, false);
    zoomToPoint(targetZoom: newZoom, focalPoint: center);
  }

  /// Mouse wheel zoom
  void handleWheelZoom(PointerScrollEvent event, Offset localPosition) {
    if (event.scrollDelta.dy == 0) return;

    final zoomDelta = -event.scrollDelta.dy * zoomSensitivity * 0.01;
    final newZoom = (_zoomLevel * (1 + zoomDelta)).clamp(minZoom, maxZoom);

    zoomToPoint(
      targetZoom: newZoom,
      focalPoint: localPosition,
      animate: false, // Wheel zoom should be immediate
    );
  }

  /// Pinch zoom handling
  void handlePinchZoom({
    required double scale,
    required Offset focalPoint,
  }) {
    final newZoom = (_zoomLevel * scale).clamp(minZoom, maxZoom);
    zoomToPoint(
      targetZoom: newZoom,
      focalPoint: focalPoint,
      animate: false,
    );
  }

  /// Pan the canvas
  void pan(Offset delta) {
    _panOffset += delta;
    notifyListeners();
  }

  /// Reset zoom and pan
  void reset({bool animate = true}) {
    if (animate && _animationController != null) {
      _animateToZoom(1.0, Offset.zero);
    } else {
      _zoomLevel = 1.0;
      _panOffset = Offset.zero;
      notifyListeners();
    }
  }

  /// Fit canvas to screen
  void fitToScreen(Size screenSize, {bool animate = true}) {
    if (_canvasSize == Size.zero || screenSize == Size.zero) return;

    final scaleX = screenSize.width / _canvasSize.width;
    final scaleY = screenSize.height / _canvasSize.height;
    final scale = math.min(scaleX, scaleY) * 0.9; // 90% to add padding

    final centeredOffset = Offset(
      (screenSize.width - _canvasSize.width * scale) / 2,
      (screenSize.height - _canvasSize.height * scale) / 2,
    );

    if (animate && _animationController != null) {
      _animateToZoom(scale, centeredOffset);
    } else {
      _zoomLevel = scale;
      _panOffset = centeredOffset;
      notifyListeners();
    }
  }

  /// Transform screen point to canvas coordinates
  Offset screenToCanvas(Offset screenPoint) {
    return (screenPoint - _panOffset) / _zoomLevel;
  }

  /// Transform canvas point to screen coordinates
  Offset canvasToScreen(Offset canvasPoint) {
    return canvasPoint * _zoomLevel + _panOffset;
  }

  /// Check if point is visible on screen
  bool isPointVisible(Offset canvasPoint, Size screenSize) {
    final screenPoint = canvasToScreen(canvasPoint);
    return screenPoint.dx >= 0 &&
        screenPoint.dy >= 0 &&
        screenPoint.dx <= screenSize.width &&
        screenPoint.dy <= screenSize.height;
  }

  // Private methods

  Offset _getCanvasCenter() {
    return Offset(
      _canvasSize.width / 2,
      _canvasSize.height / 2,
    );
  }

  double _calculateSmartZoomLevel(double currentZoom, bool zoomIn) {
    // Smart zoom levels for better UX
    const zoomLevels = [0.1, 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0, 15.0, 20.0];

    if (zoomIn) {
      // Find next higher zoom level
      for (final level in zoomLevels) {
        if (level > currentZoom + 0.01) {
          // Small epsilon for floating point comparison
          return level;
        }
      }
      return maxZoom;
    } else {
      // Find next lower zoom level
      for (final level in zoomLevels.reversed) {
        if (level < currentZoom - 0.01) {
          return level;
        }
      }
      return minZoom;
    }
  }

  void _animateToZoom(double targetZoom, Offset targetOffset) {
    if (_animationController == null) return;

    final startZoom = _zoomLevel;
    final startOffset = _panOffset;

    _zoomAnimation = Tween<double>(
      begin: startZoom,
      end: targetZoom,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));

    _offsetAnimation = Tween<Offset>(
      begin: startOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));

    void animationListener() {
      _zoomLevel = _zoomAnimation!.value;
      _panOffset = _offsetAnimation!.value;
      notifyListeners();
    }

    void animationStatusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _animationController!.removeListener(animationListener);
        _animationController!.removeStatusListener(animationStatusListener);
      }
    }

    _animationController!.addListener(animationListener);
    _animationController!.addStatusListener(animationStatusListener);
    _animationController!.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

/// Widget that provides smooth zoom and pan functionality
class SmoothZoomWidget extends StatefulWidget {
  final Widget child;
  final ZoomController? controller;
  final Function(ZoomController)? onControllerCreated;
  final bool enableMouseWheel;
  final bool enableKeyboardShortcuts;

  const SmoothZoomWidget({
    super.key,
    required this.child,
    this.controller,
    this.onControllerCreated,
    this.enableMouseWheel = true,
    this.enableKeyboardShortcuts = true,
  });

  @override
  State<SmoothZoomWidget> createState() => _SmoothZoomWidgetState();
}

class _SmoothZoomWidgetState extends State<SmoothZoomWidget> with TickerProviderStateMixin {
  late ZoomController _controller;
  late AnimationController _animationController;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _controller = widget.controller ?? ZoomController();
    _controller.setAnimationController(_animationController);

    widget.onControllerCreated?.call(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = context.size;
      if (size != null) {
        _controller.setCanvasSize(size);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: widget.enableKeyboardShortcuts ? _handleKeyEvent : null,
      child: Listener(
        onPointerSignal: widget.enableMouseWheel ? _handlePointerSignal : null,
        child: GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform(
                transform: Matrix4.identity()
                  ..translate(_controller.panOffset.dx, _controller.panOffset.dy)
                  ..scale(_controller.zoomLevel),
                child: widget.child,
              );
            },
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final renderBox = context.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final localPosition = renderBox.globalToLocal(event.position);
        _controller.handleWheelZoom(event, localPosition);
      }
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final isCtrlPressed = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;

      if (isCtrlPressed) {
        switch (event.logicalKey) {
          case LogicalKeyboardKey.equal:
          case LogicalKeyboardKey.numpadAdd:
            _controller.zoomIn();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.minus:
          case LogicalKeyboardKey.numpadSubtract:
            _controller.zoomOut();
            return KeyEventResult.handled;
          case LogicalKeyboardKey.digit0:
          case LogicalKeyboardKey.numpad0:
            _controller.reset();
            return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  Offset? _panStartOffset;
  double? _scaleStart;

  void _handleScaleStart(ScaleStartDetails details) {
    _panStartOffset = _controller.panOffset;
    _scaleStart = _controller.zoomLevel;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (details.pointerCount == 1) {
      // Panning
      if (_panStartOffset != null) {
        final delta = details.focalPoint - details.localFocalPoint;
        _controller.pan(delta);
      }
    } else if (details.pointerCount == 2) {
      // Pinch zoom
      if (_scaleStart != null) {
        _controller.handlePinchZoom(
          scale: details.scale,
          focalPoint: details.localFocalPoint,
        );
      }
    }
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _panStartOffset = null;
    _scaleStart = null;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
