import 'package:flutter/material.dart';
import 'package:pixelverse/core/extensions/primitive_extensions.dart';

import '../../../pixel/effects/effects.dart';

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
