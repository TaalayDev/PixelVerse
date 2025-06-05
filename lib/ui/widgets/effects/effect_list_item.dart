import 'package:flutter/material.dart';

import '../../../core/extensions/primitive_extensions.dart';
import '../../../pixel/effects/effects.dart';

class EffectListItem extends StatelessWidget {
  final Effect effect;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final bool showDragHandle;
  final bool showRemoveButton;

  const EffectListItem({
    super.key,
    required this.effect,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.onRemove,
    this.showDragHandle = false,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectIcon = _getEffectIcon(effect.type);
    final effectColor = _getEffectColor(effect.type, context);

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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: effectColor.withOpacity(0.2),
              radius: 15,
              child: Icon(effectIcon, color: effectColor, size: 18),
            ),
            title: Text(
              effect.name.capitalize(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
