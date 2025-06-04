import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../animated_background.dart';
import '../../../pixel/effects/effects.dart';
import '../../../data/models/layer.dart';
import '../dialogs.dart';

class EffectsPanel extends StatefulWidget {
  final Layer layer;
  final Function(Layer) onLayerUpdated;
  final int width;
  final int height;
  final bool isDialog;
  final VoidCallback? onClose;

  const EffectsPanel({
    super.key,
    required this.layer,
    required this.onLayerUpdated,
    required this.width,
    required this.height,
    this.isDialog = false,
    this.onClose,
  });

  @override
  State<EffectsPanel> createState() => _EffectsPanelState();
}

class _EffectsPanelState extends State<EffectsPanel> {
  late List<Effect> _effects;
  Uint32List? _previewPixels;
  int? _selectedEffectIndex;

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

    _previewPixels = EffectsManager.applyMultipleEffects(
      widget.layer.pixels,
      widget.width,
      widget.height,
      _effects,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we're on a mobile device
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;

    return LayoutBuilder(builder: (context, constraints) {
      if (isMobile) {
        return _buildMobileLayout(context);
      } else if (isTablet) {
        return _buildTabletLayout(context);
      } else {
        return _buildDesktopLayout(context);
      }
    });
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppBar(
          title: Text(
            'Effects for ${widget.layer.name}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: widget.isDialog
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addEffect,
              tooltip: 'Add effect',
            ),
          ],
        ),

        // Preview area
        if (_previewPixels != null) ...[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Theme.of(context).canvasColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _buildPreview(),
              ),
            ),
          ),
        ],

        // Effects list
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Applied Effects',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                '${_effects.length} effect${_effects.length != 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        ),

        Expanded(
          child: _effects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Feather.droplet,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No effects applied',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Effect'),
                        onPressed: _addEffect,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _effects.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedEffectIndex == index;
                    return EffectListItem(
                      effect: _effects[index],
                      isSelected: isSelected,
                      onSelect: () {
                        setState(() {
                          _selectedEffectIndex = isSelected ? null : index;
                        });
                      },
                      onEdit: () => _editEffect(index),
                      onRemove: () => _removeEffect(index),
                    );
                  },
                ),
        ),

        // Bottom action bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _applyChanges,
              child: const Text('Apply Changes', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        // Left panel - Preview and buttons
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: Text(
                  'Effects Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: widget.isDialog
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                      )
                    : null,
              ),
              Expanded(
                child: Center(
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      color: Theme.of(context).canvasColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildPreview(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Effect'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _addEffect,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: _applyChanges,
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),

        // Right panel - Effects list
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: Text(
                  'Effects for ${widget.layer.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                automaticallyImplyLeading: false,
                actions: [
                  Text(
                    '${_effects.length} effect${_effects.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              Expanded(
                child: _effects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Feather.droplet,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No effects applied',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _effects.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedEffectIndex == index;
                          return EffectListItem(
                            effect: _effects[index],
                            isSelected: isSelected,
                            onSelect: () {
                              setState(() {
                                _selectedEffectIndex = isSelected ? null : index;
                              });
                            },
                            onEdit: () => _editEffect(index),
                            onRemove: () => _removeEffect(index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left panel - Preview and before/after
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: Text(
                  'Effect Preview',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: widget.isDialog
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: widget.onClose ?? () => Navigator.of(context).pop(),
                      )
                    : null,
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Main preview
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                'Final Result',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 300,
                                height: 300,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  color: Theme.of(context).canvasColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _buildPreview(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Before & After comparison
                      if (_effects.isNotEmpty) ...[
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Before & After',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            color: Theme.of(context).canvasColor,
                                          ),
                                          child: CustomPaint(
                                            painter: PixelPreviewPainter(
                                              pixels: widget.layer.pixels,
                                              width: widget.width,
                                              height: widget.height,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('Original'),
                                      ],
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          width: 120,
                                          height: 120,
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.shade300),
                                            color: Theme.of(context).canvasColor,
                                          ),
                                          child: _buildPreview(size: 120),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('With Effects'),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add Effect'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _addEffect,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: _applyChanges,
                        child: const Text('Apply Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Divider
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).dividerColor,
        ),

        // Right panel - Effects list and management
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppBar(
                title: Text(
                  'Effects for ${widget.layer.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                automaticallyImplyLeading: false,
                actions: [
                  _effects.isNotEmpty
                      ? OutlinedButton.icon(
                          icon: const Icon(Icons.clear_all),
                          label: const Text('Clear All'),
                          onPressed: _clearAllEffects,
                        )
                      : const SizedBox(),
                  const SizedBox(width: 16),
                ],
              ),

              // Effects count and sorting
              if (_effects.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_effects.length} effect${_effects.length != 1 ? 's' : ''} applied',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.help_outline, size: 16),
                        label: const Text('Effects are applied in order'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Effects are applied from top to bottom. Drag to reorder.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

              // Effects list
              Expanded(
                child: _effects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Feather.droplet,
                              size: 64,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No effects applied',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Add your first effect'),
                              onPressed: _addEffect,
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        itemCount: _effects.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (oldIndex < newIndex) {
                              newIndex -= 1;
                            }
                            final item = _effects.removeAt(oldIndex);
                            _effects.insert(newIndex, item);
                            _updatePreview();
                          });
                        },
                        itemBuilder: (context, index) {
                          final isSelected = _selectedEffectIndex == index;
                          return EffectListItem(
                            key: ValueKey(_effects[index].type.toString() + index.toString()),
                            effect: _effects[index],
                            isSelected: isSelected,
                            onSelect: () {
                              setState(() {
                                _selectedEffectIndex = isSelected ? null : index;
                              });
                            },
                            onEdit: () => _editEffect(index),
                            onRemove: () => _removeEffect(index),
                            showDragHandle: true,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreview({double? size}) {
    if (_previewPixels == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomPaint(
      painter: PixelPreviewPainter(
        pixels: _previewPixels!,
        width: widget.width,
        height: widget.height,
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
        layerWidth: widget.width,
        layerHeight: widget.height,
        layerPixels: widget.layer.pixels,
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
      if (_selectedEffectIndex == index) {
        _selectedEffectIndex = null;
      } else if (_selectedEffectIndex != null && _selectedEffectIndex! > index) {
        _selectedEffectIndex = _selectedEffectIndex! - 1;
      }
      _updatePreview();
    });
  }

  void _clearAllEffects() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Effects'),
        content: const Text('Are you sure you want to remove all effects from this layer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _effects.clear();
                _selectedEffectIndex = null;
                _updatePreview();
              });
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _applyChanges() {
    final updatedLayer = widget.layer.copyWith(effects: _effects);
    widget.onLayerUpdated(updatedLayer);
    if (widget.isDialog) {
      Navigator.of(context).pop();
    }
  }
}

class EffectListItem extends StatelessWidget {
  final Effect effect;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final bool showDragHandle;

  const EffectListItem({
    super.key,
    required this.effect,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onRemove,
    this.showDragHandle = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectIcon = _getEffectIcon(effect.type);
    final effectColor = _getEffectColor(effect.type, context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: effectColor.withOpacity(0.2),
              child: Icon(effectIcon, color: effectColor),
            ),
            title: Text(
              effect.name.capitalize(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            // subtitle: Text(
            //   _formatParameters(effect.parameters),
            //   style: const TextStyle(fontSize: 10),
            // ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Edit effect',
                  onPressed: onEdit,
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Remove effect',
                  onPressed: onRemove,
                  iconSize: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getEffectIcon(EffectType type) {
    switch (type) {
      case EffectType.brightness:
        return Icons.brightness_6;
      case EffectType.contrast:
        return Icons.contrast;
      case EffectType.invert:
        return Icons.invert_colors;
      case EffectType.grayscale:
        return Icons.monochrome_photos;
      case EffectType.sepia:
        return Icons.filter_vintage;
      case EffectType.threshold:
        return Icons.tonality;
      case EffectType.pixelate:
        return Icons.grid_on;
      case EffectType.blur:
        return Icons.blur_on;
      case EffectType.sharpen:
        return Icons.blur_linear;
      case EffectType.emboss:
        return Icons.layers;
      case EffectType.vignette:
        return Icons.vignette;
      case EffectType.noise:
        return Icons.grain;
      case EffectType.colorBalance:
        return Icons.tune;
      case EffectType.dithering:
        return Icons.texture;
      case EffectType.outline:
        return Icons.border_style;
      case EffectType.paletteReduction:
        return Icons.palette;
      case EffectType.watercolor:
        return Icons.water_drop;
      case EffectType.halftone:
        return Icons.circle;
      case EffectType.glow:
        return Icons.star;
      case EffectType.oilPaint:
        return Icons.brush;
      case EffectType.gradient:
        return Icons.gradient;
      default:
        return Icons.auto_fix_high;
    }
  }

  Color _getEffectColor(EffectType type, BuildContext context) {
    switch (type) {
      case EffectType.brightness:
      case EffectType.contrast:
        return Colors.amber;
      case EffectType.invert:
      case EffectType.grayscale:
      case EffectType.sepia:
      case EffectType.threshold:
        return Colors.purple;
      case EffectType.pixelate:
      case EffectType.blur:
      case EffectType.sharpen:
        return Colors.blue;
      case EffectType.emboss:
      case EffectType.vignette:
        return Colors.teal;
      case EffectType.noise:
      case EffectType.dithering:
        return Colors.orange;
      case EffectType.colorBalance:
      case EffectType.paletteReduction:
        return Colors.green;
      case EffectType.outline:
        return Colors.red;
      case EffectType.watercolor:
        return Colors.teal;
      case EffectType.halftone:
        return Colors.cyan;
      case EffectType.glow:
        return Colors.yellow;
      case EffectType.oilPaint:
        return Colors.pink;
      case EffectType.gradient:
        return Colors.deepPurple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatParameters(Map<String, dynamic> params) {
    final buffer = StringBuffer();
    params.forEach((key, value) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      if (value is double) {
        buffer.write('$key: ${value.toStringAsFixed(2)}');
      } else {
        buffer.write('$key: $value');
      }
    });

    return buffer.isEmpty ? 'Default settings' : buffer.toString();
  }
}

// Extension for string capitalization
extension StringCapitalize on String {
  String capitalize() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
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
    // Create a checkerboard background for transparent areas
    final checkerPaint1 = Paint()..color = Colors.grey.shade200;
    final checkerPaint2 = Paint()..color = Colors.grey.shade100;

    final checkerSize = size.width / 10;
    for (int y = 0; y < 10; y++) {
      for (int x = 0; x < 10; x++) {
        canvas.drawRect(
          Rect.fromLTWH(
            x * checkerSize,
            y * checkerSize,
            checkerSize,
            checkerSize,
          ),
          (x + y) % 2 == 0 ? checkerPaint1 : checkerPaint2,
        );
      }
    }

    // Draw the pixels
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
  bool shouldRepaint(covariant PixelPreviewPainter oldDelegate) {
    return oldDelegate.pixels != pixels;
  }
}

class EffectSelectorDialog extends StatefulWidget {
  final Function(Effect) onEffectSelected;

  const EffectSelectorDialog({
    super.key,
    required this.onEffectSelected,
  });

  @override
  State<EffectSelectorDialog> createState() => _EffectSelectorDialogState();
}

class _EffectSelectorDialogState extends State<EffectSelectorDialog> {
  String _searchQuery = '';
  int _selectedCategoryIndex = 0;

  final _categories = [
    'All',
    'Color',
    'Blur & Sharpen',
    'Artistic',
    'Special',
  ];

  List<EffectType> get _filteredEffects {
    const allEffects = EffectType.values;

    // First filter by category
    List<EffectType> categoryFiltered;

    switch (_selectedCategoryIndex) {
      case 1: // Color
        categoryFiltered = [
          EffectType.brightness,
          EffectType.contrast,
          EffectType.invert,
          EffectType.grayscale,
          EffectType.sepia,
          EffectType.colorBalance,
          EffectType.threshold,
          EffectType.gradient,
        ];
        break;
      case 2: // Blur & Sharpen
        categoryFiltered = [
          EffectType.blur,
          EffectType.sharpen,
          EffectType.pixelate,
        ];
        break;
      case 3: // Artistic
        categoryFiltered = [
          EffectType.emboss,
          EffectType.vignette,
          EffectType.outline,
          EffectType.dithering,
          EffectType.paletteReduction,
          EffectType.watercolor,
          EffectType.halftone,
          EffectType.glow,
          EffectType.oilPaint,
        ];
        break;
      case 4: // Special
        categoryFiltered = [
          EffectType.noise,
        ];
        break;
      default: // All
        categoryFiltered = allEffects;
    }

    // Then filter by search
    if (_searchQuery.isEmpty) {
      return categoryFiltered;
    }

    return categoryFiltered.where((type) {
      final name = type.toString().split('.').last;
      return name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

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
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: Text(
                    'Select Effect',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),

            const Divider(),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search effects...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),

            // Categories
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedCategoryIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(_categories[index]),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryIndex = index;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ),

            // Effects grid
            Expanded(
              child: _filteredEffects.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.filter_list_off,
                            size: 48,
                            color: Theme.of(context).disabledColor,
                          ),
                          const SizedBox(height: 16),
                          const Text('No effects match your search'),
                        ],
                      ),
                    )
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 3,
                        childAspectRatio: 1.2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        mainAxisExtent: 150,
                      ),
                      itemCount: _filteredEffects.length,
                      itemBuilder: (context, index) {
                        final effectType = _filteredEffects[index];
                        final name = effectType.toString().split('.').last.capitalize();
                        final effect = EffectsManager.createEffect(effectType);

                        return _buildEffectCard(context, name, effectType, effect);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEffectCard(BuildContext context, String name, EffectType type, Effect effect) {
    final icon = _getEffectIcon(type);
    final color = _getEffectColor(type, context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          widget.onEffectSelected(effect);
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.2),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getEffectDescription(type),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEffectIcon(EffectType type) {
    switch (type) {
      case EffectType.brightness:
        return Icons.brightness_6;
      case EffectType.contrast:
        return Icons.contrast;
      case EffectType.invert:
        return Icons.invert_colors;
      case EffectType.grayscale:
        return Icons.monochrome_photos;
      case EffectType.sepia:
        return Icons.filter_vintage;
      case EffectType.threshold:
        return Icons.tonality;
      case EffectType.pixelate:
        return Icons.grid_on;
      case EffectType.blur:
        return Icons.blur_on;
      case EffectType.sharpen:
        return Icons.blur_linear;
      case EffectType.emboss:
        return Icons.layers;
      case EffectType.vignette:
        return Icons.vignette;
      case EffectType.noise:
        return Icons.grain;
      case EffectType.colorBalance:
        return Icons.tune;
      case EffectType.dithering:
        return Icons.texture;
      case EffectType.outline:
        return Icons.border_style;
      case EffectType.paletteReduction:
        return Icons.palette;
      case EffectType.halftone:
        return Icons.grid_3x3;
      case EffectType.glow:
        return Icons.light_mode;
      case EffectType.watercolor:
        return Icons.water_drop;
      case EffectType.oilPaint:
        return Icons.brush;
      case EffectType.gradient:
        return Icons.gradient;
      default:
        return Icons.auto_fix_high;
    }
  }

  Color _getEffectColor(EffectType type, BuildContext context) {
    switch (type) {
      case EffectType.brightness:
      case EffectType.contrast:
        return Colors.amber;
      case EffectType.invert:
      case EffectType.grayscale:
      case EffectType.sepia:
      case EffectType.threshold:
        return Colors.purple;
      case EffectType.pixelate:
      case EffectType.blur:
      case EffectType.sharpen:
        return Colors.blue;
      case EffectType.emboss:
      case EffectType.vignette:
        return Colors.teal;
      case EffectType.noise:
      case EffectType.dithering:
        return Colors.orange;
      case EffectType.colorBalance:
      case EffectType.paletteReduction:
        return Colors.green;
      case EffectType.outline:
        return Colors.red;
      case EffectType.halftone:
        return Colors.indigo;
      case EffectType.glow:
        return Colors.cyan;
      case EffectType.watercolor:
        return Colors.teal;
      case EffectType.oilPaint:
        return Colors.brown;
      case EffectType.gradient:
        return Colors.pink;
      default:
        return Theme.of(context).colorScheme.primary;
    }
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
      case EffectType.colorBalance:
        return 'Adjust color channels';
      case EffectType.dithering:
        return 'Apply dithering pattern';
      case EffectType.outline:
        return 'Add outline to shapes';
      case EffectType.paletteReduction:
        return 'Reduce to limited color palette';
      case EffectType.watercolor:
        return 'Create soft, blended watercolor effect';
      case EffectType.halftone:
        return 'Simulate comic book or newspaper printing';
      case EffectType.glow:
        return 'Add light halo around bright areas';
      case EffectType.oilPaint:
        return 'Simulate oil painting with brush strokes';
      case EffectType.gradient:
        return 'Apply gradient color effect';
      default:
        return 'Apply effect to layer';
    }
  }
}

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
                    style: Theme.of(context).textTheme.headlineSmall,
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
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: _buildPreview(),
                ),
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

// Extension for ShowDialog for the effect panel
extension EffectPanelDialogExtension on BuildContext {
  Future<void> showEffectsPanel({
    required Layer layer,
    required int width,
    required int height,
    required Function(Layer) onLayerUpdated,
  }) {
    return showDialog(
      context: this,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width < 600 ? double.infinity : 900,
            maxHeight: MediaQuery.of(context).size.width < 600 ? double.infinity : 900,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AnimatedBackground(
              child: EffectsPanel(
                layer: layer,
                width: width,
                height: height,
                onLayerUpdated: onLayerUpdated,
                isDialog: true,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
