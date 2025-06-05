import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/pixel/effects/effects.dart';

import '../../../data.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/subscription_provider.dart';
import '../dialogs.dart';
import 'effect_list_item.dart';
import 'effects_editor_dialog.dart';
import 'effects_empty_widget.dart';
import 'effects_selector_dialog.dart';

class EffectsSidePanel extends StatefulHookConsumerWidget {
  final Layer layer;
  final int width;
  final int height;
  final Function(Layer)? onLayerUpdated;

  const EffectsSidePanel({
    super.key,
    required this.layer,
    required this.width,
    required this.height,
    this.onLayerUpdated,
  });

  @override
  ConsumerState<EffectsSidePanel> createState() => _EffectsSidePanelState();
}

class _EffectsSidePanelState extends ConsumerState<EffectsSidePanel> {
  late List<Effect> _effects;
  int? _selectedEffectIndex;

  @override
  void initState() {
    super.initState();
    _effects = List<Effect>.from(widget.layer.effects);
  }

  @override
  void didUpdateWidget(EffectsSidePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.layer != widget.layer) {
      setState(() {
        _effects = List<Effect>.from(widget.layer.effects);
        _selectedEffectIndex = null;
      });
    }
  }

  void _updateLayer() {
    if (widget.onLayerUpdated != null) {
      final updatedLayer = widget.layer.copyWith(effects: _effects);
      widget.onLayerUpdated!(updatedLayer);
    }
  }

  void _addEffect() {
    showDialog(
      context: context,
      builder: (context) => EffectSelectorDialog(
        onEffectSelected: (effect) {
          setState(() {
            _effects.add(effect);
          });
          _updateLayer();
        },
      ),
    );
  }

  void _editEffect(int index) {
    if (index >= 0 && index < _effects.length) {
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
            });
            _updateLayer();
          },
        ),
      );
    }
  }

  void _removeEffect(int index) {
    if (index >= 0 && index < _effects.length) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Remove Effect'),
          content: Text('Are you sure you want to remove the "${_effects[index].name}" effect?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _effects.removeAt(index);
                  if (_selectedEffectIndex == index) {
                    _selectedEffectIndex = null;
                  } else if (_selectedEffectIndex != null && _selectedEffectIndex! > index) {
                    _selectedEffectIndex = _selectedEffectIndex! - 1;
                  }
                });
                _updateLayer();
              },
              child: const Text('Remove'),
            ),
          ],
        ),
      );
    }
  }

  void _removeSelectedEffect() {
    if (_selectedEffectIndex != null) {
      _removeEffect(_selectedEffectIndex!);
    }
  }

  void _clearAllEffects() {
    if (_effects.isEmpty) return;

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
              });
              _updateLayer();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscription = ref.watch(subscriptionStateProvider);

    return Column(
      children: [
        // Action buttons bar
        _buildActionButtonsBar(context, subscription),

        // Effects list
        if (_effects.isEmpty)
          Expanded(
            child: EffectsEmptyWidget(
              addEffect: _addEffect,
            ),
          )
        else
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _effects.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final item = _effects.removeAt(oldIndex);
                  _effects.insert(newIndex, item);

                  // Update selected index if needed
                  if (_selectedEffectIndex == oldIndex) {
                    _selectedEffectIndex = newIndex;
                  } else if (_selectedEffectIndex != null) {
                    if (oldIndex < _selectedEffectIndex! && newIndex >= _selectedEffectIndex!) {
                      _selectedEffectIndex = _selectedEffectIndex! - 1;
                    } else if (oldIndex > _selectedEffectIndex! && newIndex <= _selectedEffectIndex!) {
                      _selectedEffectIndex = _selectedEffectIndex! + 1;
                    }
                  }
                });
                _updateLayer();
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
                  showRemoveButton: false,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtonsBar(BuildContext context, UserSubscription subscription) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Add Effect Button
          _buildActionButton(
            context: context,
            icon: Icons.add,
            label: 'Add',
            color: Colors.green,
            onPressed: _addEffect,
          ),
          const SizedBox(width: 8),

          // Delete Selected Button
          _buildActionButton(
            context: context,
            icon: Icons.delete_outline,
            label: 'Remove',
            color: Colors.red,
            onPressed: _selectedEffectIndex != null ? _removeSelectedEffect : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool badge = false,
  }) {
    final isEnabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isEnabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
              width: 1,
            ),
            color: isEnabled ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.05),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: isEnabled ? color : Colors.grey.shade400,
                  ),
                  if (badge)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isEnabled ? color : Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
