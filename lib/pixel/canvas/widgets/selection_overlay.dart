import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pixelverse/pixel/pixel_point.dart';
import '../../../data.dart';

/// A separate widget to display and handle selection overlay with animated marching ants
class SelectionOverlay extends StatefulWidget {
  final List<PixelPoint<int>>? selection;
  final double zoomLevel;
  final Offset canvasOffset;
  final int canvasWidth;
  final int canvasHeight;
  final Size canvasSize;
  final Function(List<PixelPoint<int>>, math.Point delta)? onSelectionMove;
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
    this.onSelectionMoveEnd,
  });

  @override
  State<SelectionOverlay> createState() => _SelectionOverlayState();
}

class _SelectionOverlayState extends State<SelectionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Offset _lastPanPosition = Offset.zero;
  List<PixelPoint<int>>? _originalSelection;

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

    return Stack(
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
      ],
    );
  }

  List<Widget> _buildSelectionHandles(double left, double top, double width, double height) {
    const handleSize = 8.0;
    const handleHalfSize = handleSize / 2;

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
    ];
  }

  Widget _buildHandle(double left, double top) {
    const handleSize = 8.0;

    return Positioned(
      left: left,
      top: top,
      width: handleSize,
      height: handleSize,
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
