import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pixelverse/core/extensions/primitive_extensions.dart';

import '../../../pixel/effects/effects.dart';
import '../dialogs.dart';
import 'pixlel_preview_painter.dart';

class EffectEditorDialog extends StatefulWidget {
  final Effect effect;
  final int layerWidth;
  final int layerHeight;
  final Uint32List layerPixels;
  final Function(Effect) onEffectUpdated;

  const EffectEditorDialog({
    super.key,
    required this.effect,
    required this.layerWidth,
    required this.layerHeight,
    required this.layerPixels,
    required this.onEffectUpdated,
  });

  @override
  State<EffectEditorDialog> createState() => _EffectEditorDialogState();
}

class _EffectEditorDialogState extends State<EffectEditorDialog> {
  late Map<String, dynamic> _parameters;
  Uint32List? _previewPixels;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _parameters = Map<String, dynamic>.from(widget.effect.parameters);
    _updatePreview();
  }

  Future<void> _updatePreview() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    await Future.microtask(() {
      final effect = EffectsManager.createEffect(widget.effect.type, _parameters);
      _previewPixels = effect.apply(
        widget.layerPixels,
        widget.layerWidth,
        widget.layerHeight,
      );
    });

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final effectName = widget.effect.name.capitalize();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isMobile ? double.infinity : 600,
        height: isMobile ? double.infinity : 500,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    'Edit $effectName Effect',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _getEffectDescription(widget.effect.type),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const Divider(),

            // Content - Different layouts for mobile and desktop
            Expanded(
              child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _applyChanges,
                    child: const Text('Apply Changes'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        // Preview
        Container(
          height: 150,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: _buildPreview(),
        ),

        // Parameters
        Expanded(
          child: ListView(
            children: _buildParameterWidgets(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Preview
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Text(
                'Preview',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildPreview(),
              ),

              // Before/After slider will go here in a future enhancement
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Right side - Parameters
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Parameters',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: _buildParameterWidgets(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_isProcessing) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_previewPixels == null) {
      return const Center(child: Text('Preview not available'));
    }

    return CustomPaint(
      painter: PixelPreviewPainter(
        pixels: _previewPixels!,
        width: widget.layerWidth,
        height: widget.layerHeight,
      ),
    );
  }

  List<Widget> _buildParameterWidgets() {
    final widgets = <Widget>[];

    _parameters.forEach((key, value) {
      if (value is double) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key.capitalize(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value.toStringAsFixed(2),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: value,
                min: _getMinValue(key, widget.effect.type),
                max: _getMaxValue(key, widget.effect.type),
                divisions: 100,
                label: value.toStringAsFixed(2),
                onChanged: (newValue) {
                  setState(() {
                    _parameters[key] = newValue;
                  });
                  _updatePreview();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      } else if (value is int) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    key.capitalize(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    value.toString(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              _buildSelector(key, widget.effect.type, value),
              const SizedBox(height: 16),
            ],
          ),
        );
      } else if (value is bool) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SwitchListTile(
              title: Text(
                key.capitalize(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              value: value,
              onChanged: (newValue) {
                setState(() {
                  _parameters[key] = newValue;
                });
                _updatePreview();
              },
            ),
          ),
        );
      }
    });

    return widgets;
  }

  Widget _buildSelector(String paramName, EffectType type, dynamic value) {
    return switch (paramName) {
      'startColor' => InkWell(
          onTap: () {
            // Open color picker dialog
            showColorPicker(
              context,
              Color(value),
              (color) {
                setState(() {
                  _parameters[paramName] = color.value;
                });
                _updatePreview();
              },
            );
          },
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Color(value),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
      'endColor' => InkWell(
          onTap: () {
            // Open color picker dialog
            showColorPicker(
              context,
              Color(value),
              (color) {
                setState(() {
                  _parameters[paramName] = color.value;
                });
                _updatePreview();
              },
            );
          },
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Color(value),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
        ),
      _ => Slider(
          value: value.toDouble(),
          min: _getMinValue(paramName, widget.effect.type),
          max: _getMaxValue(paramName, widget.effect.type),
          divisions:
              _getMaxValue(paramName, widget.effect.type).toInt() - _getMinValue(paramName, widget.effect.type).toInt(),
          label: value.toString(),
          onChanged: (newValue) {
            setState(() {
              _parameters[paramName] = newValue.toInt();
            });
            _updatePreview();
          },
        ),
    };
  }

  double _getMinValue(String paramName, EffectType type) {
    if (paramName == 'value' && (type == EffectType.brightness || type == EffectType.contrast)) {
      return -1.0;
    } else if (paramName == 'colors' && type == EffectType.paletteReduction) {
      return 2.0;
    } else if (paramName == 'startColor' || paramName == 'endColor') {
      return 0.0;
    } else if (paramName == 'radius' || paramName == 'blockSize') {
      return 1.0;
    } else if (paramName == 'strength') {
      return 0.0;
    } else if (paramName == 'direction') {
      return -3.0;
    }
    return 0.0;
  }

  double _getMaxValue(String paramName, EffectType type) {
    switch (paramName) {
      case 'radius':
        return 10.0;
      case 'blockSize':
        return 10.0;
      case 'strength':
        return 5.0;
      case 'direction':
        return 7.0;
      case 'colors':
        return type == EffectType.paletteReduction ? 64 : 1.0;
      case 'endColor':
        return 0x7FFFFFFFFFFFFFFF.toDouble();
      case 'startColor':
        return 0x7FFFFFFFFFFFFFFF.toDouble();
      case 'colorSteps':
        return 255;
      default:
        return 1.0;
    }
  }

  String _getEffectDescription(EffectType type) {
    switch (type) {
      case EffectType.brightness:
        return 'Adjust the brightness of pixels. Positive values make the image brighter, negative values make it darker.';
      case EffectType.contrast:
        return 'Adjust the contrast between light and dark areas. Positive values increase contrast, negative values decrease it.';
      case EffectType.invert:
        return 'Invert all pixel colors, creating a negative image effect.';
      case EffectType.grayscale:
        return 'Convert the image to grayscale, removing all color information.';
      case EffectType.sepia:
        return 'Apply a vintage sepia tone effect, giving the image a warm, brownish tint.';
      case EffectType.threshold:
        return 'Create a high-contrast black and white image based on a threshold value.';
      case EffectType.pixelate:
        return 'Create larger blocks of pixels, reducing detail and creating a retro 8-bit look.';
      case EffectType.blur:
        return 'Apply a blur effect to soften the image by averaging neighboring pixels.';
      case EffectType.sharpen:
        return 'Enhance the edges in an image by increasing contrast between adjacent pixels.';
      case EffectType.emboss:
        return 'Create a 3D embossed effect by highlighting edges in a specific direction.';
      case EffectType.vignette:
        return 'Darken the edges of the image, drawing attention to the center.';
      case EffectType.noise:
        return 'Add random noise to pixels, creating a grainy or textured look.';
      case EffectType.colorBalance:
        return 'Adjust the balance of red, green, and blue channels in the image.';
      case EffectType.dithering:
        return 'Apply a dithering pattern to create the illusion of more colors using a limited palette.';
      case EffectType.outline:
        return 'Add an outline to shapes by detecting edges and tracing them.';
      case EffectType.paletteReduction:
        return 'Reduce the image to a limited color palette, great for creating retro pixel art.';
      case EffectType.watercolor:
        return 'Create a soft, blended watercolor effect by simulating brush strokes.';
      default:
        return 'Apply effect to layer';
    }
  }

  void _applyChanges() {
    // Create a new effect with updated parameters
    final updatedEffect = EffectsManager.createEffect(widget.effect.type, _parameters);

    widget.onEffectUpdated(updatedEffect);
    Navigator.of(context).pop();
  }
}
