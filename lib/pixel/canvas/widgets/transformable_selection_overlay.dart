import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data.dart';
import '../../pixel_point.dart';

enum HandleType {
  topLeft,
  topCenter,
  topRight,
  rightCenter,
  bottomRight,
  bottomCenter,
  bottomLeft,
  leftCenter,
  rotation,
  center,
}

enum HandleOperation {
  move,
  resize,
  rotate,
  moveCenter,
}

/// A separate widget to display and handle selection overlay with animated marching ants
class TransformableSelectionOverlay extends StatefulWidget {
  final List<PixelPoint<int>>? selection;
  final double zoomLevel;
  final Offset canvasOffset;
  final int canvasWidth;
  final int canvasHeight;
  final Size canvasSize;
  final Function(List<PixelPoint<int>>, math.Point delta)? onSelectionMove;
  final Function(List<PixelPoint<int>>, Rect newBounds, Offset? center)? onSelectionResize;
  final Function(List<PixelPoint<int>>, double angle, Offset? center)? onSelectionRotate;
  final Function()? onSelectionMoveEnd;

  const TransformableSelectionOverlay({
    super.key,
    required this.selection,
    required this.zoomLevel,
    required this.canvasOffset,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.canvasSize,
    this.onSelectionMove,
    this.onSelectionResize,
    this.onSelectionRotate,
    this.onSelectionMoveEnd,
  });

  @override
  State<TransformableSelectionOverlay> createState() => _TransformableSelectionOverlayState();
}

class _TransformableSelectionOverlayState extends State<TransformableSelectionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Offset _lastPanPosition = Offset.zero;
  List<PixelPoint<int>>? _originalSelection;
  HandleOperation _currentOperation = HandleOperation.move;
  HandleType? _activeHandle;
  Rect? _originalBounds;
  double _rotationAngle = 0.0;

  // Transform center point (in canvas coordinates)
  Offset? _transformCenter;
  bool _showCenterPoint = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void didUpdateWidget(TransformableSelectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selection != widget.selection) {
      _originalSelection = widget.selection;
      // Reset and recalculate transform center when selection changes
      _resetTransformCenter();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Reset transform center to geometric center of current selection
  void _resetTransformCenter() {
    final selectionBounds = _getSelectionBounds();
    if (selectionBounds != null) {
      _transformCenter = Offset(
        selectionBounds.x + selectionBounds.width / 2,
        selectionBounds.y + selectionBounds.height / 2,
      );
    } else {
      _transformCenter = null;
    }
  }

  /// Calculate bounding rectangle from list of pixel points
  SelectionModel? _getSelectionBounds() {
    if (widget.selection == null || widget.selection!.isEmpty) {
      return null;
    }

    return fromPointsToSelection(widget.selection!, widget.canvasSize);
  }

  SelectionModel? fromPointsToSelection(List<PixelPoint<int>> points, Size canvasSize) {
    if (points.isEmpty ||
        widget.canvasWidth <= 0 ||
        widget.canvasHeight <= 0 ||
        canvasSize.width <= 0 ||
        canvasSize.height <= 0) {
      return null;
    }

    // Calculate pixel size in canvas coordinates
    final pixelWidth = canvasSize.width / widget.canvasWidth;
    final pixelHeight = canvasSize.height / widget.canvasHeight;

    // Find bounds in pixel coordinates
    int minPixelX = points.first.x;
    int minPixelY = points.first.y;
    int maxPixelX = points.first.x;
    int maxPixelY = points.first.y;

    for (final point in points) {
      minPixelX = math.min(minPixelX, point.x);
      maxPixelX = math.max(maxPixelX, point.x);
      minPixelY = math.min(minPixelY, point.y);
      maxPixelY = math.max(maxPixelY, point.y);
    }

    // Convert to canvas coordinates
    final canvasX = minPixelX * pixelWidth;
    final canvasY = minPixelY * pixelHeight;
    final canvasWidth = (maxPixelX - minPixelX + 1) * pixelWidth;
    final canvasHeight = (maxPixelY - minPixelY + 1) * pixelHeight;

    return SelectionModel(
      x: canvasX.toInt(),
      y: canvasY.toInt(),
      width: canvasWidth.toInt(),
      height: canvasHeight.toInt(),
      canvasSize: canvasSize,
    );
  }

  /// Get the current transform center point in screen coordinates
  Offset _getTransformCenter(double screenLeft, double screenTop, double screenWidth, double screenHeight) {
    if (_transformCenter != null) {
      return Offset(
        _transformCenter!.dx * widget.zoomLevel,
        _transformCenter!.dy * widget.zoomLevel,
      );
    }

    // Default to geometric center
    return Offset(
      screenLeft + screenWidth / 2,
      screenTop + screenHeight / 2,
    );
  }

  /// Initialize transform center to geometric center if not set
  void _initializeTransformCenter(double screenLeft, double screenTop, double screenWidth, double screenHeight) {
    if (_transformCenter == null) {
      final geometricCenter = Offset(
        (screenLeft + screenWidth / 2) / widget.zoomLevel,
        (screenTop + screenHeight / 2) / widget.zoomLevel,
      );
      _transformCenter = geometricCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionBounds = _getSelectionBounds();

    if (selectionBounds == null ||
        widget.canvasSize.width == 0 ||
        widget.canvasSize.height == 0 ||
        widget.zoomLevel <= 0) {
      return const SizedBox.shrink();
    }

    // Calculate selection rectangle in screen coordinates
    final screenLeft = (selectionBounds.x * widget.zoomLevel);
    final screenTop = (selectionBounds.y * widget.zoomLevel);
    final screenWidth = selectionBounds.width * widget.zoomLevel;
    final screenHeight = selectionBounds.height * widget.zoomLevel;

    // Initialize transform center if needed
    _initializeTransformCenter(screenLeft, screenTop, screenWidth, screenHeight);

    return MouseRegion(
      onEnter: (_) => setState(() => _showCenterPoint = true),
      onExit: (_) => setState(() => _showCenterPoint = false),
      child: Stack(
        children: [
          // Selection rectangle with marching ants
          Positioned(
            left: screenLeft,
            top: screenTop,
            width: screenWidth,
            height: screenHeight,
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.blue,
                        width: 2.0,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Marching ants effect
                        Positioned.fill(
                          child: CustomPaint(
                            painter: MarchingAntsPainter(
                              progress: _animationController.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Selection handles
          ..._buildSelectionHandles(screenLeft, screenTop, screenWidth, screenHeight),

          // Transform center point
          if (_showCenterPoint || _currentOperation == HandleOperation.moveCenter)
            _buildTransformCenter(screenLeft, screenTop, screenWidth, screenHeight),
        ],
      ),
    );
  }

  List<Widget> _buildSelectionHandles(double left, double top, double width, double height) {
    const handleSize = 10.0;
    const handleHalfSize = handleSize / 2;
    const rotationHandleOffset = 25.0;

    final centerPoint = _getTransformCenter(left, top, width, height);

    return [
      // Corner resize handles
      _buildResizeHandle(HandleType.topLeft, left - handleHalfSize, top - handleHalfSize),
      _buildResizeHandle(HandleType.topRight, left + width - handleHalfSize, top - handleHalfSize),
      _buildResizeHandle(HandleType.bottomRight, left + width - handleHalfSize, top + height - handleHalfSize),
      _buildResizeHandle(HandleType.bottomLeft, left - handleHalfSize, top + height - handleHalfSize),

      // Edge resize handles
      _buildResizeHandle(HandleType.topCenter, left + width / 2 - handleHalfSize, top - handleHalfSize),
      _buildResizeHandle(HandleType.rightCenter, left + width - handleHalfSize, top + height / 2 - handleHalfSize),
      _buildResizeHandle(HandleType.bottomCenter, left + width / 2 - handleHalfSize, top + height - handleHalfSize),
      _buildResizeHandle(HandleType.leftCenter, left - handleHalfSize, top + height / 2 - handleHalfSize),

      // Rotation handle (positioned relative to center point)
      _buildRotationHandle(
        centerPoint.dx - handleHalfSize,
        centerPoint.dy - rotationHandleOffset - handleHalfSize,
      ),

      // Connection line from center to rotation handle
      _buildRotationLine(
        centerPoint.dx,
        centerPoint.dy,
        centerPoint.dx,
        centerPoint.dy - rotationHandleOffset,
      ),
    ];
  }

  Widget _buildResizeHandle(HandleType handleType, double left, double top) {
    const handleSize = 10.0;

    // Determine cursor style based on handle type
    SystemMouseCursor cursor = _getHandleCursor(handleType);

    return Positioned(
      left: left,
      top: top,
      width: handleSize,
      height: handleSize,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          onPanStart: (details) => _handleResizeStart(details, handleType),
          onPanUpdate: (details) => _handleResizeUpdate(details, handleType),
          onPanEnd: _handleResizeEnd,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.blue,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(2.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotationHandle(double left, double top) {
    const handleSize = 12.0;

    return Positioned(
      left: left,
      top: top,
      width: handleSize,
      height: handleSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: GestureDetector(
          onPanStart: _handleRotationStart,
          onPanUpdate: _handleRotationUpdate,
          onPanEnd: _handleRotationEnd,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              border: Border.all(
                color: Colors.green.shade800,
                width: 2.0,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 8.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransformCenter(
      double selectionLeft, double selectionTop, double selectionWidth, double selectionHeight) {
    const centerSize = 16.0;
    const centerHalfSize = centerSize / 2;

    final centerPoint = _getTransformCenter(selectionLeft, selectionTop, selectionWidth, selectionHeight);

    return Positioned(
      left: centerPoint.dx - centerHalfSize,
      top: centerPoint.dy - centerHalfSize,
      width: centerSize,
      height: centerSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.move,
        child: GestureDetector(
          onPanStart: _handleCenterStart,
          onPanUpdate: _handleCenterUpdate,
          onPanEnd: _handleCenterEnd,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.9),
              border: Border.all(
                color: Colors.deepOrange,
                width: 2.0,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 3,
                  offset: const Offset(1, 1),
                ),
              ],
            ),
            child: CustomPaint(
              painter: CrosshairPainter(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRotationLine(double x1, double y1, double x2, double y2) {
    return Positioned(
      left: math.min(x1, x2),
      top: math.min(y1, y2),
      child: CustomPaint(
        size: Size((x2 - x1).abs(), (y2 - y1).abs()),
        painter: RotationLinePainter(
          start: Offset(x1 < x2 ? 0 : (x1 - x2).abs(), y1 < y2 ? 0 : (y1 - y2).abs()),
          end: Offset(x1 < x2 ? (x2 - x1).abs() : 0, y1 < y2 ? (y2 - y1).abs() : 0),
        ),
      ),
    );
  }

  SystemMouseCursor _getHandleCursor(HandleType handleType) {
    switch (handleType) {
      case HandleType.topLeft:
      case HandleType.bottomRight:
        return SystemMouseCursors.resizeUpLeftDownRight;
      case HandleType.topRight:
      case HandleType.bottomLeft:
        return SystemMouseCursors.resizeUpRightDownLeft;
      case HandleType.topCenter:
      case HandleType.bottomCenter:
        return SystemMouseCursors.resizeUpDown;
      case HandleType.leftCenter:
      case HandleType.rightCenter:
        return SystemMouseCursors.resizeLeftRight;
      case HandleType.rotation:
        return SystemMouseCursors.grab;
      case HandleType.center:
        return SystemMouseCursors.move;
    }
  }

  void _handlePanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;
    _originalSelection = widget.selection?.map((point) => PixelPoint<int>(point.x, point.y)).toList();
    _currentOperation = HandleOperation.move;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_originalSelection == null || _originalSelection!.isEmpty) {
      return;
    }

    final totalDelta = details.localPosition - _lastPanPosition;

    // Convert canvas delta to pixel delta
    final pixelWidth = widget.canvasSize.width / widget.canvasWidth;
    final pixelHeight = widget.canvasSize.height / widget.canvasHeight;

    final pixelDeltaX = (totalDelta.dx / pixelWidth).round();
    final pixelDeltaY = (totalDelta.dy / pixelHeight).round();

    final newSelection = _originalSelection!.map((point) {
      return PixelPoint<int>(
        (point.x + pixelDeltaX).clamp(0, widget.canvasWidth - 1),
        (point.y + pixelDeltaY).clamp(0, widget.canvasHeight - 1),
      );
    }).toList();

    widget.onSelectionMove?.call(
      newSelection,
      math.Point(pixelDeltaX, pixelDeltaY),
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = Offset.zero;
    _originalSelection = null;
    widget.onSelectionMoveEnd?.call();
  }

  void _handleResizeStart(DragStartDetails details, HandleType handleType) {
    _lastPanPosition = details.globalPosition;
    _originalSelection = widget.selection?.map((point) => PixelPoint<int>(point.x, point.y)).toList();
    _activeHandle = handleType;
    _currentOperation = HandleOperation.resize;
    _originalBounds = _getSelectionBounds()?.let((bounds) =>
        Rect.fromLTWH(bounds.x.toDouble(), bounds.y.toDouble(), bounds.width.toDouble(), bounds.height.toDouble()));
  }

  void _handleResizeUpdate(DragUpdateDetails details, HandleType handleType) {
    if (_originalBounds == null || _originalSelection == null) return;

    final delta = details.globalPosition - _lastPanPosition;
    final newBounds = _calculateNewBounds(_originalBounds!, handleType, delta);

    // Convert transform center to pixel coordinates
    final pixelWidth = widget.canvasSize.width / widget.canvasWidth;
    final pixelHeight = widget.canvasSize.height / widget.canvasHeight;

    final pixelCenter = _transformCenter != null
        ? Offset(
            _transformCenter!.dx / pixelWidth,
            _transformCenter!.dy / pixelHeight,
          )
        : null;

    // Convert bounds to pixel coordinates
    final pixelBounds = Rect.fromLTRB(
      newBounds.left / pixelWidth,
      newBounds.top / pixelHeight,
      newBounds.right / pixelWidth,
      newBounds.bottom / pixelHeight,
    );

    // Create new selection from bounds
    final newSelection = _createSelectionFromPixelBounds(pixelBounds);
    widget.onSelectionResize?.call(newSelection, pixelBounds, pixelCenter);
  }

  void _handleResizeEnd(DragEndDetails details) {
    _lastPanPosition = Offset.zero;
    _originalSelection = null;
    _activeHandle = null;
    _originalBounds = null;
    widget.onSelectionMoveEnd?.call();
  }

  void _handleRotationStart(DragStartDetails details) {
    _lastPanPosition = details.globalPosition;
    _originalSelection = widget.selection?.map((point) => PixelPoint<int>(point.x, point.y)).toList();
    _currentOperation = HandleOperation.rotate;

    // Calculate initial angle using transform center
    if (_transformCenter != null) {
      final center = Offset(
        _transformCenter!.dx * widget.zoomLevel,
        _transformCenter!.dy * widget.zoomLevel,
      );
      final startVector = details.globalPosition - center;
      _rotationAngle = math.atan2(startVector.dy, startVector.dx);
    }
  }

  void _handleRotationUpdate(DragUpdateDetails details) {
    if (_transformCenter == null || _originalSelection == null) return;

    final center = Offset(
      _transformCenter!.dx * widget.zoomLevel,
      _transformCenter!.dy * widget.zoomLevel,
    );

    final currentVector = details.globalPosition - center;
    final currentAngle = math.atan2(currentVector.dy, currentVector.dx);
    final deltaAngle = currentAngle - _rotationAngle;

    // Convert transform center to pixel coordinates
    final pixelWidth = widget.canvasSize.width / widget.canvasWidth;
    final pixelHeight = widget.canvasSize.height / widget.canvasHeight;

    final pixelCenter = Offset(
      _transformCenter!.dx / pixelWidth,
      _transformCenter!.dy / pixelHeight,
    );

    // Use original selection for rotation
    widget.onSelectionRotate?.call(_originalSelection!, deltaAngle, pixelCenter);
  }

  void _handleRotationEnd(DragEndDetails details) {
    _lastPanPosition = Offset.zero;
    _originalSelection = null;
    widget.onSelectionMoveEnd?.call();
  }

  void _handleCenterStart(DragStartDetails details) {
    _lastPanPosition = details.globalPosition;
    _currentOperation = HandleOperation.moveCenter;
  }

  void _handleCenterUpdate(DragUpdateDetails details) {
    final delta = details.globalPosition - _lastPanPosition;
    final canvasDelta = delta / widget.zoomLevel;

    setState(() {
      if (_transformCenter != null) {
        _transformCenter = _transformCenter! + canvasDelta;
      }
    });

    _lastPanPosition = details.globalPosition;
  }

  void _handleCenterEnd(DragEndDetails details) {
    _lastPanPosition = Offset.zero;
    widget.onSelectionMoveEnd?.call();
  }

  Rect _calculateNewBounds(Rect originalBounds, HandleType handleType, Offset delta) {
    double left = originalBounds.left;
    double top = originalBounds.top;
    double right = originalBounds.right;
    double bottom = originalBounds.bottom;

    final scaledDelta = delta / widget.zoomLevel;

    switch (handleType) {
      case HandleType.topLeft:
        left += scaledDelta.dx;
        top += scaledDelta.dy;
        break;
      case HandleType.topCenter:
        top += scaledDelta.dy;
        break;
      case HandleType.topRight:
        right += scaledDelta.dx;
        top += scaledDelta.dy;
        break;
      case HandleType.rightCenter:
        right += scaledDelta.dx;
        break;
      case HandleType.bottomRight:
        right += scaledDelta.dx;
        bottom += scaledDelta.dy;
        break;
      case HandleType.bottomCenter:
        bottom += scaledDelta.dy;
        break;
      case HandleType.bottomLeft:
        left += scaledDelta.dx;
        bottom += scaledDelta.dy;
        break;
      case HandleType.leftCenter:
        left += scaledDelta.dx;
        break;
      case HandleType.rotation:
      case HandleType.center:
        break;
    }

    // Ensure minimum size
    const minSize = 10.0;
    if (right - left < minSize) {
      if (handleType == HandleType.topLeft ||
          handleType == HandleType.bottomLeft ||
          handleType == HandleType.leftCenter) {
        left = right - minSize;
      } else {
        right = left + minSize;
      }
    }

    if (bottom - top < minSize) {
      if (handleType == HandleType.topLeft || handleType == HandleType.topCenter || handleType == HandleType.topRight) {
        top = bottom - minSize;
      } else {
        bottom = top + minSize;
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  List<PixelPoint<int>> _createSelectionFromPixelBounds(Rect pixelBounds) {
    final selection = <PixelPoint<int>>[];

    final minX = pixelBounds.left.round().clamp(0, widget.canvasWidth - 1);
    final maxX = pixelBounds.right.round().clamp(1, widget.canvasWidth);
    final minY = pixelBounds.top.round().clamp(0, widget.canvasHeight - 1);
    final maxY = pixelBounds.bottom.round().clamp(1, widget.canvasHeight);

    for (int y = minY; y < maxY; y++) {
      for (int x = minX; x < maxX; x++) {
        selection.add(PixelPoint<int>(x, y));
      }
    }

    return selection;
  }

  /// Reset transform center to geometric center
  void resetTransformCenter() {
    _resetTransformCenter();
    setState(() {});
  }
}

// Rest of the classes remain the same...
class SelectionModel {
  final int x;
  final int y;
  final int width;
  final int height;
  final Size canvasSize;

  SelectionModel({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.canvasSize,
  });
}

/// Custom painter for marching ants effect
class MarchingAntsPainter extends CustomPainter {
  final double progress;

  MarchingAntsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    const totalDashLength = dashWidth + dashSpace;
    final offset = progress * totalDashLength;

    // Draw dashed border with animated offset
    _drawDashedRect(canvas, Rect.fromLTWH(0, 0, size.width, size.height), paint, dashWidth, dashSpace, offset);
  }

  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint, double dashWidth, double dashSpace, double offset) {
    // Top edge
    _drawDashedLine(canvas, rect.topLeft, rect.topRight, paint, dashWidth, dashSpace, offset);
    // Right edge
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, paint, dashWidth, dashSpace, offset);
    // Bottom edge
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, paint, dashWidth, dashSpace, offset);
    // Left edge
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, paint, dashWidth, dashSpace, offset);
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint, double dashWidth, double dashSpace, double offset) {
    final distance = (end - start).distance;
    if (distance == 0) return; // Avoid division by zero

    final unitVector = (end - start) / distance;

    double currentDistance = -offset;
    bool isDash = true;

    while (currentDistance < distance) {
      final segmentLength = isDash ? dashWidth : dashSpace;
      final segmentStart = (currentDistance).clamp(0.0, distance);
      final segmentEnd = (currentDistance + segmentLength).clamp(0.0, distance);

      if (isDash && segmentStart < distance && segmentEnd > 0) {
        final startPoint = start + unitVector * segmentStart;
        final endPoint = start + unitVector * segmentEnd;
        canvas.drawLine(startPoint, endPoint, paint);
      }

      currentDistance += segmentLength;
      isDash = !isDash;
    }
  }

  @override
  bool shouldRepaint(covariant MarchingAntsPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

/// Custom painter for rotation handle connection line
class RotationLinePainter extends CustomPainter {
  final Offset start;
  final Offset end;

  RotationLinePainter({required this.start, required this.end});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant RotationLinePainter oldDelegate) {
    return start != oldDelegate.start || end != oldDelegate.end;
  }
}

/// Custom painter for crosshair in transform center
class CrosshairPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final center = Offset(size.width / 2, size.height / 2);
    const crossSize = 6.0;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - crossSize, center.dy),
      Offset(center.dx + crossSize, center.dy),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - crossSize),
      Offset(center.dx, center.dy + crossSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CrosshairPainter oldDelegate) {
    return false;
  }
}

// Extension to help with null safety
extension NullableExtension<T> on T? {
  R? let<R>(R Function(T) transform) {
    final value = this;
    return value != null ? transform(value) : null;
  }
}
