import 'package:flutter/material.dart';
import '../../../data.dart';

/// A separate widget to display and handle selection overlay with animated marching ants
class SelectionOverlay extends StatefulWidget {
  final SelectionModel? selection;
  final double zoomLevel;
  final Offset canvasOffset;
  final int canvasWidth;
  final int canvasHeight;
  final Size canvasSize;
  final Function(SelectionModel)? onSelectionMove;
  final Function()? onSelectionEnd;

  const SelectionOverlay({
    super.key,
    required this.selection,
    required this.zoomLevel,
    required this.canvasOffset,
    required this.canvasWidth,
    required this.canvasHeight,
    required this.canvasSize,
    this.onSelectionMove,
    this.onSelectionEnd,
  });

  @override
  State<SelectionOverlay> createState() => _SelectionOverlayState();
}

class _SelectionOverlayState extends State<SelectionOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  Offset _panStartLocalOffset = Offset.zero;
  SelectionModel? _originalSelectionOnPanStart;

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

  @override
  Widget build(BuildContext context) {
    if (widget.selection == null || widget.canvasSize.width == 0 || widget.canvasSize.height == 0) {
      return const SizedBox.shrink();
    }

    // Calculate selection rectangle in screen coordinates
    final screenLeft = (widget.selection!.x * widget.zoomLevel) + widget.canvasOffset.dx;
    final screenTop = (widget.selection!.y * widget.zoomLevel) + widget.canvasOffset.dy;
    final screenWidth = widget.selection!.width * widget.zoomLevel;
    final screenHeight = widget.selection!.height * widget.zoomLevel;

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
    if (widget.selection == null) return;
    _originalSelectionOnPanStart = widget.selection!.copyWith();
    _panStartLocalOffset = details.localPosition;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (widget.selection == null || _originalSelectionOnPanStart == null || widget.zoomLevel == 0) {
      return;
    }

    final currentPanLocalOffset = details.localPosition;

    final dxScreen = currentPanLocalOffset.dx - _panStartLocalOffset.dx;
    final dyScreen = currentPanLocalOffset.dy - _panStartLocalOffset.dy;

    final dxCanvas = dxScreen / widget.zoomLevel;
    final dyCanvas = dyScreen / widget.zoomLevel;

    final newX = _originalSelectionOnPanStart!.x + dxCanvas;
    final newY = _originalSelectionOnPanStart!.y + dyCanvas;

    final newSelection = SelectionModel(
      x: newX.round(),
      y: newY.round(),
      width: _originalSelectionOnPanStart!.width,
      height: _originalSelectionOnPanStart!.height,
      canvasSize: widget.canvasSize,
    );

    widget.onSelectionMove?.call(newSelection);
  }

  void _handlePanEnd(DragEndDetails details) {
    _panStartLocalOffset = Offset.zero;
    _originalSelectionOnPanStart = null;
    widget.onSelectionEnd?.call();
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
