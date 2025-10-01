import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SliderStyle {
  gradient,
  glass,
  neon,
}

class CustomSlider extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String? label;
  final Color? color;
  final SliderStyle style;

  const CustomSlider({
    Key? key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.label,
    this.color,
    this.style = SliderStyle.gradient,
  }) : super(key: key);

  @override
  State<CustomSlider> createState() => _CustomSliderState();
}

class _CustomSliderState extends State<CustomSlider> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get primaryColor => widget.color ?? Colors.blue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.value.round()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            height: 60,
            child: _buildSliderByStyle(),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderByStyle() {
    switch (widget.style) {
      case SliderStyle.gradient:
        return _buildGradientSlider();
      case SliderStyle.glass:
        return _buildGlassSlider();
      case SliderStyle.neon:
        return _buildNeonSlider();
    }
  }

  Widget _buildGradientSlider() {
    return GestureDetector(
      onHorizontalDragStart: (_) {
        setState(() => _isDragging = true);
        _controller.forward();
      },
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final percentage = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
        widget.onChanged(
          widget.min + (widget.max - widget.min) * percentage,
        );
      },
      onHorizontalDragEnd: (_) {
        setState(() => _isDragging = false);
        _controller.reverse();
      },
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background track
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Active gradient track
          FractionallySizedBox(
            widthFactor: (widget.value - widget.min) / (widget.max - widget.min),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // Thumb
          Positioned(
            left: ((widget.value - widget.min) / (widget.max - widget.min)) * (MediaQuery.of(context).size.width - 96) -
                16,
            child: AnimatedScale(
              scale: _isDragging ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassSlider() {
    return GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _isDragging = true),
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final percentage = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
        widget.onChanged(widget.min + (widget.max - widget.min) * percentage);
      },
      onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Background
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Active track with glass effect
          FractionallySizedBox(
            widthFactor: (widget.value - widget.min) / (widget.max - widget.min),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.6),
                    primaryColor.withOpacity(0.3),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // Thumb with glass effect
          Positioned(
            left: ((widget.value - widget.min) / (widget.max - widget.min)) * (MediaQuery.of(context).size.width - 96) -
                18,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isDragging ? 40 : 36,
              height: _isDragging ? 40 : 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.8),
                    primaryColor.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonSlider() {
    return GestureDetector(
      onHorizontalDragStart: (_) => setState(() => _isDragging = true),
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final percentage = (localPosition.dx / box.size.width).clamp(0.0, 1.0);
        widget.onChanged(widget.min + (widget.max - widget.min) * percentage);
      },
      onHorizontalDragEnd: (_) => setState(() => _isDragging = false),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background track
            Container(
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[800]?.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Neon active track
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FractionallySizedBox(
                widthFactor: (widget.value - widget.min) / (widget.max - widget.min),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.8),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: primaryColor,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Neon thumb
            Positioned(
              left:
                  ((widget.value - widget.min) / (widget.max - widget.min)) * (MediaQuery.of(context).size.width - 96) -
                      14,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _isDragging ? 32 : 28,
                height: _isDragging ? 32 : 28,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.8),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: primaryColor,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.5),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
