import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../data.dart';
import '../../pixel_point.dart';

const _centerHandleSize = 18.0;
const _handleSize = 8.0;

/// A separate widget to display and handle selection overlay with animated marching ants
class SelectionOverlay extends StatefulWidget {
  final List<PixelPoint<int>>? selection;
  final double zoomLevel;
  final Offset canvasOffset;
  final int canvasWidth;
  final int canvasHeight;
  final Size canvasSize;
  final Function(List<PixelPoint<int>>, math.Point delta)? onSelectionMove;
  final Function(List<PixelPoint<int>>, double angle)? onSelectionRotate;
  final Function()? onSelectionMoveEnd;

  const SelectionOverlay({
    super.key,
    required this.selection,
    required this.zoomLevel,
    required this.canvasOffset,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.canvasSize,
    this.onSelectionMove,
    this.onSelectionRotate,
    this.onSelectionMoveEnd,
  });

  @override
  State<SelectionOverlay> createState() => _SelectionOverlayState();
}

class _SelectionOverlayState extends State<SelectionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Offset _lastPanPosition = Offset.zero;
  List<PixelPoint<int>>? _originalSelection;
  double _rotationAngle = 0.0;
  double _initialRotationAngle = 0.0;
  bool _isRotating = false;
  Offset? _centerPoint;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  /// Get the center point of the selection in screen coordinates
  Offset _getSelectionCenter(double screenLeft, double screenTop, double screenWidth, double screenHeight) {
    return Offset(
      screenLeft + screenWidth / 2,
      screenTop + screenHeight / 2,
    );
  }

  /// Rotate a point around a center point by the given angle
  PixelPoint<int> _rotatePoint(PixelPoint<int> point, PixelPoint<int> center, double angle) {
    final cos = math.cos(angle);
    final sin = math.sin(angle);

    final translatedX = point.x - center.x;
    final translatedY = point.y - center.y;

    final rotatedX = translatedX * cos - translatedY * sin;
    final rotatedY = translatedX * sin + translatedY * cos;

    return PixelPoint<int>(
      (rotatedX + center.x).round(),
      (rotatedY + center.y).round(),
    );
  }

  /// Get the center point of the selection in pixel coordinates
  PixelPoint<int>? _getSelectionCenterInPixels() {
    if (widget.selection == null || widget.selection!.isEmpty) {
      return null;
    }

    final points = widget.selection!;
    int minX = points.first.x;
    int minY = points.first.y;
    int maxX = points.first.x;
    int maxY = points.first.y;

    for (final point in points) {
      minX = math.min(minX, point.x);
      maxX = math.max(maxX, point.x);
      minY = math.min(minY, point.y);
      maxY = math.max(maxY, point.y);
    }

    return PixelPoint<int>(
      ((minX + maxX) / 2).round(),
      ((minY + maxY) / 2).round(),
    );
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
    final screenWidth = selectionBounds.width.toDouble();
    final screenHeight = selectionBounds.height.toDouble();

    // Store center point for rotation calculations
    _centerPoint = _getSelectionCenter(screenLeft, screenTop, screenWidth, screenHeight);

    return Stack(
      children: [
        // Selection rectangle with marching ants (not draggable when center handle is being used)
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

        // Rotation handle
        _buildRotationHandle(screenLeft, screenTop, screenWidth, screenHeight),
      ],
    );
  }

  List<Widget> _buildSelectionHandles(double left, double top, double width, double height) {
    const handleHalfSize = _handleSize / 2;

    return [
      // Top-left
      _buildHandle(left - handleHalfSize, top - handleHalfSize),
      // Top-center
      _buildHandle(left + width / 2 - handleHalfSize, top - handleHalfSize),
      // Top-right
      _buildHandle(left + width - handleHalfSize, top - handleHalfSize),
      // Right-center
      _buildHandle(left + width - handleHalfSize, top + height / 2 - handleHalfSize),
      // Bottom-right
      _buildHandle(left + width - handleHalfSize, top + height - handleHalfSize),
      // Bottom-center
      _buildHandle(left + width / 2 - handleHalfSize, top + height - handleHalfSize),
      // Bottom-left
      _buildHandle(left - handleHalfSize, top + height - handleHalfSize),
      // Left-center
      _buildHandle(left - handleHalfSize, top + height / 2 - handleHalfSize),
      // Center Handle (now draggable)
      _buildDraggableCenterHandle(
        left + width / 2 - (_centerHandleSize / 2),
        top + height / 2 - (_centerHandleSize / 2),
      ),
    ];
  }

  Widget _buildHandle(double left, double top) {
    return Positioned(
      left: left,
      top: top,
      width: _handleSize,
      height: _handleSize,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.blue,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableCenterHandle(double left, double top) {
    return Positioned(
      left: left,
      top: top,
      width: _centerHandleSize,
      height: _centerHandleSize,
      child: GestureDetector(
        onPanStart: _handleCenterPanStart,
        onPanUpdate: _handleCenterPanUpdate,
        onPanEnd: _handleCenterPanEnd,
        child: Container(
          width: _centerHandleSize,
          height: _centerHandleSize,
          decoration: BoxDecoration(
            color: Colors.blueAccent,
            border: Border.all(
              color: Colors.white,
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
    );
  }

  Widget _buildRotationHandle(double left, double top, double width, double height) {
    const handleSize = 14.0;
    const handleDistance = 30.0; // Distance from center

    final centerX = left + width / 2;
    final centerY = top + height / 2;

    // Position rotation handle above the center
    final rotationHandleX = centerX - handleSize / 2;
    final rotationHandleY = centerY - handleDistance - handleSize / 2;

    return Positioned(
      left: rotationHandleX,
      top: rotationHandleY,
      width: handleSize,
      height: handleSize,
      child: GestureDetector(
        onPanStart: _handleRotationStart,
        onPanUpdate: _handleRotationUpdate,
        onPanEnd: _handleRotationEnd,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border.all(
              color: Colors.white,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(handleSize / 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: const Icon(
            Icons.rotate_right,
            size: 6,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Original selection area pan handlers
  void _handlePanStart(DragStartDetails details) {
    _lastPanPosition = details.localPosition;
    _originalSelection = widget.selection?.map((point) => PixelPoint<int>(point.x, point.y)).toList();
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_originalSelection == null || _originalSelection!.isEmpty) {
      return;
    }

    final totalDelta = details.localPosition - _lastPanPosition;

    final pixelDeltaX = (totalDelta.dx / widget.zoomLevel).round();
    final pixelDeltaY = (totalDelta.dy / widget.zoomLevel).round();

    final newSelection = _originalSelection!.map((point) {
      return PixelPoint<int>(
        point.x + pixelDeltaX * widget.canvasWidth ~/ widget.canvasSize.width,
        point.y + pixelDeltaY * widget.canvasHeight ~/ widget.canvasSize.height,
      );
    }).toList();

    widget.onSelectionMove?.call(
      newSelection,
      math.Point(
        pixelDeltaX * widget.canvasWidth ~/ widget.canvasSize.width,
        pixelDeltaY * widget.canvasHeight ~/ widget.canvasSize.height,
      ),
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    _lastPanPosition = Offset.zero;
    _originalSelection = null;
    widget.onSelectionMoveEnd?.call();
  }

  // Center handle pan handlers
  void _handleCenterPanStart(DragStartDetails details) {}

  void _handleCenterPanUpdate(DragUpdateDetails details) {}

  void _handleCenterPanEnd(DragEndDetails details) {}

  // Rotation handle handlers
  void _handleRotationStart(DragStartDetails details) {
    _isRotating = true;
    _originalSelection = widget.selection?.map((point) => PixelPoint<int>(point.x, point.y)).toList();

    if (_centerPoint != null) {
      final angle = math.atan2(
        details.globalPosition.dy - _centerPoint!.dy,
        details.globalPosition.dx - _centerPoint!.dx,
      );
      _initialRotationAngle = angle;
      _rotationAngle = 0.0;
    }
  }

  void _handleRotationUpdate(DragUpdateDetails details) {
    if (_originalSelection == null || _originalSelection!.isEmpty || _centerPoint == null || !_isRotating) {
      return;
    }

    // Calculate current angle
    final currentAngle = math.atan2(
      details.globalPosition.dy - _centerPoint!.dy,
      details.globalPosition.dx - _centerPoint!.dx,
    );

    // Calculate rotation delta
    _rotationAngle = currentAngle - _initialRotationAngle;

    // Get center in pixel coordinates
    final centerInPixels = _getSelectionCenterInPixels();
    if (centerInPixels == null) return;

    // Rotate all points around the center
    final rotatedSelection = _originalSelection!.map((point) {
      return _rotatePoint(point, centerInPixels, _rotationAngle);
    }).toList();

    widget.onSelectionRotate?.call(rotatedSelection, _rotationAngle);
  }

  void _handleRotationEnd(DragEndDetails details) {
    _isRotating = false;
    _rotationAngle = 0.0;
    _originalSelection = null;
    widget.onSelectionMoveEnd?.call();
  }
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
