import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../../pixel/effects/effects.dart';
import '../app_icon.dart';

class EffectListItem extends StatelessWidget {
  final Effect effect;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback? onApply;
  final VoidCallback? onAnimate;
  final bool showDragHandle;
  final bool showRemoveButton;
  final bool showApplyButton;

  const EffectListItem({
    super.key,
    required this.effect,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onRemove,
    this.onApply,
    this.onAnimate,
    this.showDragHandle = false,
    this.showRemoveButton = true,
    this.showApplyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectColor = effect.getColor(context);
    final effectIcon = effect.getIcon(color: effectColor, size: 18);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: effectColor.withOpacity(0.2),
            radius: 15,
            child: effectIcon,
          ),
          title: Text(
            effect.getName(context),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const AppIcon(AppIcons.settings_2),
                tooltip: 'Edit effect',
                onPressed: onEdit,
                iconSize: 16,
              ),
              if (showApplyButton && onApply != null)
                Tooltip(
                  message: 'Apply this effect to layer pixels and remove from effects list',
                  child: IconButton(
                    icon: Icon(
                      Feather.check_circle,
                      color: Colors.green.shade600,
                    ),
                    tooltip: 'Apply effect',
                    onPressed: onApply,
                    iconSize: 18,
                  ),
                ),
              if (showRemoveButton)
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
    );
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
