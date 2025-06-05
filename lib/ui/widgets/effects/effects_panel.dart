import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:pixelverse/core/extensions.dart';

import '../animated_background.dart';
import '../../../pixel/effects/effects.dart';
import '../../../data/models/layer.dart';
import '../dialogs.dart';
import 'effect_list_item.dart';
import 'effects_editor_dialog.dart';
import 'effects_selector_dialog.dart';
import 'pixlel_preview_painter.dart';

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
