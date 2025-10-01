import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../../core/colors.dart';
import '../../../l10n/strings.dart';

/// Utility class to generate different types of color palettes
class ColorPaletteGenerator {
  /// Generate shades and tints of a color
  static List<Color> generateShades(Color baseColor, int count) {
    final List<Color> colors = [];
    final HSLColor hslColor = HSLColor.fromColor(baseColor);

    // Add darker shades (decreasing lightness)
    for (int i = count ~/ 2; i > 0; i--) {
      final double lightness = (hslColor.lightness - (i * 0.1)).clamp(0.0, 1.0);
      colors.add(hslColor.withLightness(lightness).toColor());
    }

    // Add the base color
    colors.add(baseColor);

    // Add lighter tints (increasing lightness)
    for (int i = 1; i <= count ~/ 2; i++) {
      final double lightness = (hslColor.lightness + (i * 0.1)).clamp(0.0, 1.0);
      colors.add(hslColor.withLightness(lightness).toColor());
    }

    return colors;
  }

  /// Generate complementary colors (colors opposite on the color wheel)
  static List<Color> generateComplementary(Color baseColor) {
    final HSLColor hslColor = HSLColor.fromColor(baseColor);
    final double complementaryHue = (hslColor.hue + 180) % 360;

    final complementaryColor = HSLColor.fromAHSL(
      hslColor.alpha,
      complementaryHue,
      hslColor.saturation,
      hslColor.lightness,
    ).toColor();

    return [
      baseColor,
      complementaryColor,
      // Add shades of complementary color
      HSLColor.fromAHSL(
        hslColor.alpha,
        complementaryHue,
        hslColor.saturation,
        (hslColor.lightness - 0.2).clamp(0.0, 1.0),
      ).toColor(),
      HSLColor.fromAHSL(
        hslColor.alpha,
        complementaryHue,
        hslColor.saturation,
        (hslColor.lightness + 0.2).clamp(0.0, 1.0),
      ).toColor(),
    ];
  }

  /// Generate analogous colors (colors adjacent on the color wheel)
  static List<Color> generateAnalogous(Color baseColor, int count) {
    final List<Color> colors = [];
    final HSLColor hslColor = HSLColor.fromColor(baseColor);

    final double hueStep = 30; // 30 degrees on the color wheel

    for (int i = -count ~/ 2; i <= count ~/ 2; i++) {
      final double hue = (hslColor.hue + (i * hueStep)) % 360;
      colors.add(HSLColor.fromAHSL(
        hslColor.alpha,
        hue,
        hslColor.saturation,
        hslColor.lightness,
      ).toColor());
    }

    return colors;
  }

  /// Generate triadic colors (three colors equally spaced on the color wheel)
  static List<Color> generateTriadic(Color baseColor) {
    final HSLColor hslColor = HSLColor.fromColor(baseColor);

    final List<Color> colors = [
      baseColor,
      HSLColor.fromAHSL(
        hslColor.alpha,
        (hslColor.hue + 120) % 360,
        hslColor.saturation,
        hslColor.lightness,
      ).toColor(),
      HSLColor.fromAHSL(
        hslColor.alpha,
        (hslColor.hue + 240) % 360,
        hslColor.saturation,
        hslColor.lightness,
      ).toColor(),
    ];

    return colors;
  }

  /// Generate a monochromatic palette (same hue, different saturation/lightness)
  static List<Color> generateMonochromatic(Color baseColor, int count) {
    final List<Color> colors = [];
    final HSLColor hslColor = HSLColor.fromColor(baseColor);

    // Vary saturation and lightness while keeping the same hue
    for (int i = 0; i < count; i++) {
      final double saturation = 0.1 + (i / count * 0.9);
      final double lightness = 0.1 + (i / count * 0.8);

      colors.add(HSLColor.fromAHSL(
        hslColor.alpha,
        hslColor.hue,
        saturation,
        lightness,
      ).toColor());
    }

    // Add the base color if it's not already in the list
    if (!colors.contains(baseColor)) {
      colors.add(baseColor);
    }

    return colors;
  }
}

class ColorPalettePanel extends HookWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;
  final Function() onSelectEyedropper;
  final bool isEyedropperSelected;
  final ScrollController? scrollController;

  const ColorPalettePanel({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
    required this.onSelectEyedropper,
    required this.isEyedropperSelected,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = useState<List<Color>>([]);
    final selectedTab = useState(0);

    final tabs = [
      const _PaletteTab(icon: Icons.palette, label: 'Basic'),
      const _PaletteTab(icon: Icons.tonality, label: 'Shades'),
      const _PaletteTab(icon: Icons.flip, label: 'Complementary'),
      const _PaletteTab(icon: Icons.compare_arrows, label: 'Analogous'),
      const _PaletteTab(icon: Icons.change_history, label: 'Triadic'),
      const _PaletteTab(icon: Icons.gradient, label: 'Monochromatic'),
      const _PaletteTab(icon: Icons.bookmark, label: 'Custom'),
    ];

    List<Color> getTabColors() {
      switch (selectedTab.value) {
        case 0:
          return kBasicColors;
        case 1:
          return ColorPaletteGenerator.generateShades(currentColor, 10);
        case 2:
          return ColorPaletteGenerator.generateComplementary(currentColor);
        case 3:
          return ColorPaletteGenerator.generateAnalogous(currentColor, 5);
        case 4:
          return ColorPaletteGenerator.generateTriadic(currentColor);
        case 5:
          return ColorPaletteGenerator.generateMonochromatic(currentColor, 10);
        case 6:
          return customColors.value;
        default:
          return kBasicColors;
      }
    }

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showColorPicker(context, customColors),
                  child: Container(
                    width: double.infinity,
                    height: 35,
                    decoration: BoxDecoration(
                      color: currentColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '#${currentColor.value.toRadixString(16).toUpperCase().substring(2)}',
                        style: TextStyle(
                          color: currentColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  // Add current color to custom palette
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    tooltip: 'Add to custom palette',
                    onPressed: () {
                      if (!customColors.value.contains(currentColor)) {
                        customColors.value = [...customColors.value, currentColor];
                      }
                    },
                  ),
                  // Eyedropper tool
                  IconButton(
                    icon: Icon(
                      MaterialCommunityIcons.eyedropper,
                      color: isEyedropperSelected ? Colors.blue : null,
                      size: 18,
                    ),
                    onPressed: onSelectEyedropper,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Tabs for different palette types
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: ChoiceChip(
                    avatar: Icon(
                      tabs[index].icon,
                      size: 16,
                      color: selectedTab.value == index
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).iconTheme.color,
                    ),
                    label: Text(
                      tabs[index].label,
                      style: TextStyle(
                        fontSize: 12,
                        color: selectedTab.value == index ? Theme.of(context).colorScheme.onPrimary : null,
                      ),
                    ),
                    selected: selectedTab.value == index,
                    showCheckmark: false,
                    onSelected: (selected) {
                      if (selected) {
                        selectedTab.value = index;
                      }
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Color palette grid
          Expanded(
            child: selectedTab.value == 6 && customColors.value.isEmpty
                ? Center(
                    child: Text(
                      'No custom colors added yet.\nAdd colors using the + button above.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  )
                : GridView.builder(
                    controller: scrollController,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 8 : 12,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: getTabColors().length + (selectedTab.value == 6 ? 1 : 0),
                    itemBuilder: (context, index) {
                      final colors = getTabColors();
                      if (selectedTab.value == 6 && index == colors.length) {
                        return _buildAddColorButton(context, customColors);
                      } else if (index < colors.length) {
                        return _buildColorItem(
                          colors[index],
                          customColors,
                          selectedTab.value == 6,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(
    Color color,
    ValueNotifier<List<Color>> customColors,
    bool showDeleteOption,
  ) {
    return InkWell(
      onTap: () => onColorSelected(color),
      borderRadius: BorderRadius.circular(4),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: color == currentColor ? Colors.blue : Colors.grey.withOpacity(0.3),
                width: color == currentColor ? 2 : 1,
              ),
            ),
          ),
          if (showDeleteOption && customColors.value.contains(color))
            Positioned(
              top: 1,
              right: 1,
              child: GestureDetector(
                onTap: () {
                  final newList = List<Color>.from(customColors.value);
                  newList.remove(color);
                  customColors.value = newList;
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(2),
                  child: const Icon(Icons.close, size: 10, color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAddColorButton(
    BuildContext context,
    ValueNotifier<List<Color>> customColors,
  ) {
    return InkWell(
      onTap: () => _showColorPicker(context, customColors),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.add, size: 16),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    ValueNotifier<List<Color>> customColors,
  ) {
    Color pickerColor = currentColor;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Strings.of(context).pickAColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: true,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(Strings.of(context).cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save to Palette'),
              onPressed: () {
                if (!customColors.value.contains(pickerColor)) {
                  customColors.value = [...customColors.value, pickerColor];
                }
                onColorSelected(pickerColor);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(Strings.of(context).gotIt),
              onPressed: () {
                onColorSelected(pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

/// Helper class for palette tabs
class _PaletteTab {
  final IconData icon;
  final String label;

  const _PaletteTab({
    required this.icon,
    required this.label,
  });
}
