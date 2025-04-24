import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../../data/models/layer.dart';
import '../../../../pixel/effects/effects.dart';

class EffectsPanel extends StatefulWidget {
  final Layer layer;
  final Function(Layer) onLayerUpdated;

  const EffectsPanel({
    super.key,
    required this.layer,
    required this.onLayerUpdated,
  });

  @override
  State<EffectsPanel> createState() => _EffectsPanelState();
}

class _EffectsPanelState extends State<EffectsPanel> {
  late List<Effect> _effects;
  Uint32List? _previewPixels;

  @override
  void initState() {
    super.initState();
    _effects = List<Effect>.from(widget.layer.effects);
    _updatePreview();
  }

  void _updatePreview() {
    if (_effects.isEmpty) {
      _previewPixels = widget.layer.pixels;
      return;
    }

    // Calculate width/height from pixel count
    final pixelCount = widget.layer.pixels.length;
    final width = sqrt(pixelCount).toInt();

    _previewPixels = EffectsManager.applyMultipleEffects(
      widget.layer.pixels,
      width,
      width, // Assuming square image
      _effects,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Effects for ${widget.layer.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Preview
          if (_previewPixels != null) ...[
            Text(
              'Preview',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.transparent,
                ),
                child: _buildPreview(),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Effects list
          Text(
            'Applied Effects',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _effects.isEmpty
                ? const Center(child: Text('No effects applied'))
                : ListView.builder(
                    itemCount: _effects.length,
                    itemBuilder: (context, index) {
                      return EffectListItem(
                        effect: _effects[index],
                        onEdit: () => _editEffect(index),
                        onRemove: () => _removeEffect(index),
                      );
                    },
                  ),
          ),

          // Buttons
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Add Effect'),
                onPressed: _addEffect,
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedLayer = widget.layer.copyWith(effects: _effects);
                  widget.onLayerUpdated(updatedLayer);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_previewPixels == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Calculate width/height from pixel count
    final pixelCount = _previewPixels!.length;
    final width = sqrt(pixelCount).toInt();

    return ColoredBox(
      color: Colors.white,
      child: CustomPaint(
        painter: PixelPreviewPainter(
          pixels: _previewPixels!,
          width: width,
          height: width, // Assuming square image
        ),
      ),
    );
  }

  void _addEffect() {
    showDialog(
      context: context,
      builder: (context) => EffectSelectorDialog(
        onEffectSelected: (effect) {
          setState(() {
            _effects.add(effect);
            _updatePreview();
          });
        },
      ),
    );
  }

  void _editEffect(int index) {
    showDialog(
      context: context,
      builder: (context) => EffectEditorDialog(
        effect: _effects[index],
        onEffectUpdated: (updatedEffect) {
          setState(() {
            _effects[index] = updatedEffect;
            _updatePreview();
          });
        },
      ),
    );
  }

  void _removeEffect(int index) {
    setState(() {
      _effects.removeAt(index);
      _updatePreview();
    });
  }
}

class PixelPreviewPainter extends CustomPainter {
  final Uint32List pixels;
  final int width;
  final int height;

  PixelPreviewPainter({
    required this.pixels,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final pixelWidth = size.width / width;
    final pixelHeight = size.height / height;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final index = y * width + x;
        if (index < pixels.length) {
          final color = Color(pixels[index]);
          if (color.alpha == 0) continue;

          paint.color = color;
          canvas.drawRect(
            Rect.fromLTWH(
              x * pixelWidth,
              y * pixelHeight,
              pixelWidth,
              pixelHeight,
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class EffectListItem extends StatelessWidget {
  final Effect effect;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const EffectListItem({
    super.key,
    required this.effect,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(effect.name.capitalize()),
        subtitle: Text(_formatParameters(effect.parameters)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
              onPressed: onRemove,
              tooltip: 'Remove',
            ),
          ],
        ),
        onTap: onEdit,
      ),
    );
  }

  String _formatParameters(Map<String, dynamic> params) {
    final buffer = StringBuffer();
    params.forEach((key, value) {
      if (buffer.length > 0) buffer.write(', ');
      buffer.write('$key: ${value is double ? value.toStringAsFixed(2) : value}');
    });
    return buffer.toString();
  }
}

// Extension for string capitalization
extension StringCapitalize on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class EffectSelectorDialog extends StatelessWidget {
  final Function(Effect) onEffectSelected;

  const EffectSelectorDialog({
    Key? key,
    required this.onEffectSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Effect'),
      content: SizedBox(
        width: 300,
        height: 400,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: EffectType.values.length,
          itemBuilder: (context, index) {
            final effectType = EffectType.values[index];
            final name = effectType.toString().split('.').last.capitalize();
            final effect = EffectsManager.createEffect(effectType);

            return ListTile(
              title: Text(name),
              subtitle: Text(_getEffectDescription(effectType)),
              onTap: () {
                onEffectSelected(effect);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _getEffectDescription(EffectType type) {
    switch (type) {
      case EffectType.brightness:
        return 'Adjust pixel brightness';
      case EffectType.contrast:
        return 'Adjust pixel contrast';
      case EffectType.invert:
        return 'Invert pixel colors';
      case EffectType.grayscale:
        return 'Convert to grayscale';
      case EffectType.sepia:
        return 'Apply vintage sepia tone';
      case EffectType.threshold:
        return 'Create high-contrast black and white';
      case EffectType.pixelate:
        return 'Create larger blocks of pixels';
      case EffectType.blur:
        return 'Apply blur effect';
      case EffectType.sharpen:
        return 'Enhance pixel edges';
      case EffectType.emboss:
        return 'Create a 3D embossed effect';
      case EffectType.vignette:
        return 'Darken edges of the layer';
      case EffectType.noise:
        return 'Add random noise to pixels';
      default:
        return 'Apply effect to layer';
    }
  }
}

class EffectEditorDialog extends StatefulWidget {
  final Effect effect;
  final Function(Effect) onEffectUpdated;

  const EffectEditorDialog({
    super.key,
    required this.effect,
    required this.onEffectUpdated,
  });

  @override
  State<EffectEditorDialog> createState() => _EffectEditorDialogState();
}

class _EffectEditorDialogState extends State<EffectEditorDialog> {
  late Map<String, dynamic> _parameters;

  @override
  void initState() {
    super.initState();
    _parameters = Map<String, dynamic>.from(widget.effect.parameters);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.effect.name.capitalize()}'),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildParameterWidgets(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _applyChanges,
          child: const Text('Apply'),
        ),
      ],
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
              Text(key.capitalize()),
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
                },
              ),
              Text('Value: ${value.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
            ],
          ),
        );
      } else if (value is int) {
        widgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(key.capitalize()),
              Slider(
                value: value.toDouble(),
                min: _getMinValue(key, widget.effect.type),
                max: _getMaxValue(key, widget.effect.type),
                divisions: _getMaxValue(key, widget.effect.type).toInt(),
                label: value.toString(),
                onChanged: (newValue) {
                  setState(() {
                    _parameters[key] = newValue.toInt();
                  });
                },
              ),
              Text('Value: $value'),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    });

    return widgets;
  }

  double _getMinValue(String paramName, EffectType type) {
    if (paramName == 'value' && (type == EffectType.brightness || type == EffectType.contrast)) {
      return -1.0;
    } else if (paramName == 'colors' && type == EffectType.paletteReduction) {
      return 2.0;
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
      default:
        return 1.0;
    }
  }

  void _applyChanges() {
    // Create a new effect with updated parameters
    final updatedEffect = EffectsManager.createEffect(widget.effect.type, _parameters);

    widget.onEffectUpdated(updatedEffect);
    Navigator.of(context).pop();
  }
}

// Effects dialog to show from toolbar
class EffectsDialog extends StatelessWidget {
  final Layer layer;
  final Function(Layer) onLayerUpdated;

  const EffectsDialog({
    Key? key,
    required this.layer,
    required this.onLayerUpdated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(16),
        child: EffectsPanel(
          layer: layer,
          onLayerUpdated: onLayerUpdated,
        ),
      ),
    );
  }
}
