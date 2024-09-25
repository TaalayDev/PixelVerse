import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPalettePanel extends HookWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;

  const ColorPalettePanel({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final customColors = useState<List<Color>>([]);

    final Set<Color> _predefinedColors = {
      Colors.white,
      Colors.black,
      const Color(0xFF333333),
      const Color(0xFF666666),
      const Color(0xFF999999),
      const Color(0xFFCCCCCC),
      const Color(0xFFEEEEEE),
      Colors.red,
      Colors.red.shade900,
      Colors.red.shade800,
      Colors.red.shade600,
      Colors.red.shade400,
      Colors.red.shade200,
      Colors.red.shade100,
      Colors.pink,
      Colors.pink.shade900,
      Colors.pink.shade800,
      Colors.pink.shade600,
      Colors.pink.shade400,
      Colors.pink.shade200,
      Colors.pink.shade100,
      Colors.purple,
      Colors.purple.shade900,
      Colors.purple.shade800,
      Colors.purple.shade600,
      Colors.purple.shade400,
      Colors.purple.shade200,
      Colors.purple.shade100,
      Colors.deepPurple,
      Colors.deepPurple.shade900,
      Colors.deepPurple.shade800,
      Colors.deepPurple.shade600,
      Colors.deepPurple.shade400,
      Colors.deepPurple.shade200,
      Colors.deepPurple.shade100,
      Colors.indigo,
      Colors.indigo.shade900,
      Colors.indigo.shade800,
      Colors.indigo.shade600,
      Colors.indigo.shade400,
      Colors.indigo.shade200,
      Colors.indigo.shade100,
      Colors.blue,
      Colors.blue.shade900,
      Colors.blue.shade800,
      Colors.blue.shade600,
      Colors.blue.shade400,
      Colors.blue.shade200,
      Colors.blue.shade100,
      Colors.lightBlue,
      Colors.lightBlue.shade900,
      Colors.lightBlue.shade800,
      Colors.lightBlue.shade600,
      Colors.lightBlue.shade400,
      Colors.lightBlue.shade200,
      Colors.lightBlue.shade100,
      Colors.cyan,
      Colors.cyan.shade900,
      Colors.cyan.shade800,
      Colors.cyan.shade600,
      Colors.cyan.shade400,
      Colors.cyan.shade200,
      Colors.cyan.shade100,
      Colors.teal,
      Colors.teal.shade900,
      Colors.teal.shade800,
      Colors.teal.shade600,
      Colors.teal.shade400,
      Colors.teal.shade200,
      Colors.teal.shade100,
      Colors.green,
      Colors.green.shade900,
      Colors.green.shade800,
      Colors.green.shade600,
      Colors.green.shade400,
      Colors.green.shade200,
      Colors.green.shade100,
      Colors.lightGreen,
      Colors.lightGreen.shade900,
      Colors.lightGreen.shade800,
      Colors.lightGreen.shade600,
      Colors.lightGreen.shade400,
      Colors.lightGreen.shade200,
      Colors.lightGreen.shade100,
      Colors.lime,
      Colors.lime.shade900,
      Colors.lime.shade800,
      Colors.lime.shade600,
      Colors.lime.shade400,
      Colors.lime.shade200,
      Colors.lime.shade100,
      Colors.yellow,
      Colors.yellow.shade900,
      Colors.yellow.shade800,
      Colors.yellow.shade600,
      Colors.yellow.shade400,
      Colors.yellow.shade200,
      Colors.yellow.shade100,
      Colors.amber,
      Colors.amber.shade900,
      Colors.amber.shade800,
      Colors.amber.shade600,
      Colors.amber.shade400,
      Colors.amber.shade200,
      Colors.amber.shade100,
      Colors.orange,
      Colors.orange.shade900,
      Colors.orange.shade800,
      Colors.orange.shade600,
      Colors.orange.shade400,
      Colors.orange.shade200,
      Colors.orange.shade100,
      Colors.deepOrange,
      Colors.deepOrange.shade900,
      Colors.deepOrange.shade800,
      Colors.deepOrange.shade600,
      Colors.deepOrange.shade400,
      Colors.deepOrange.shade200,
      Colors.deepOrange.shade100,
      Colors.brown,
      Colors.brown.shade900,
      Colors.brown.shade800,
      Colors.brown.shade600,
      Colors.brown.shade400,
      Colors.brown.shade200,
      Colors.brown.shade100,
      Colors.grey,
      Colors.grey.shade900,
      Colors.grey.shade800,
      Colors.grey.shade600,
      Colors.grey.shade400,
      Colors.grey.shade200,
      Colors.grey.shade100,
      Colors.blueGrey,
      Colors.blueGrey.shade900,
      Colors.blueGrey.shade800,
      Colors.blueGrey.shade600,
      Colors.blueGrey.shade400,
      Colors.blueGrey.shade200,
      Colors.blueGrey.shade100,
    };

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Color Palette',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount:
                  _predefinedColors.length + customColors.value.length + 1,
              itemBuilder: (context, index) {
                if (index < _predefinedColors.length) {
                  return _buildColorItem(_predefinedColors.elementAt(index));
                } else if (index <
                    _predefinedColors.length + customColors.value.length) {
                  return _buildColorItem(
                    customColors.value[index - _predefinedColors.length],
                  );
                } else {
                  return _buildAddColorButton(context, customColors);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Current Color',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: currentColor,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(Color color) {
    return GestureDetector(
      onTap: () => onColorSelected(color),
      child: Container(
        decoration: BoxDecoration(
          color: color,
        ),
      ),
    );
  }

  Widget _buildAddColorButton(
    BuildContext context,
    ValueNotifier<List<Color>> customColors,
  ) {
    return GestureDetector(
      onTap: () => _showColorPicker(context, customColors),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: const Icon(Icons.add, color: Colors.grey),
      ),
    );
  }

  void _showColorPicker(
      BuildContext context, ValueNotifier<List<Color>> customColors) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color pickerColor = Colors.blue;
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                customColors.value = [...customColors.value, pickerColor];
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
