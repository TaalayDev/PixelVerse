import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

Future<void> showSaveImageDialog(
  BuildContext context, {
  required Function(Map<String, dynamic>) onSave,
}) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Save Image'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Export Format',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SaveImageDialog(
              onSave: onSave,
            ),
          ],
        ),
      ),
    ),
  );
}

class SaveImageDialog extends StatefulWidget {
  const SaveImageDialog({
    super.key,
    this.format,
    required this.onSave,
  });

  final String? format;
  final Function(Map<String, dynamic>) onSave;

  @override
  State<SaveImageDialog> createState() => _SaveImageDialogState();
}

class _SaveImageDialogState extends State<SaveImageDialog> {
  late String format = widget.format ?? 'png';
  bool transparent = true;
  Color backgroundColor = Colors.white;
  int spriteSheetColumns = 4;
  int spriteSheetSpacing = 0;
  bool includeAllFrames = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile(
          title: const Text('PNG'),
          value: 'png',
          groupValue: format,
          onChanged: (value) => setState(() => format = value!),
        ),
        RadioListTile(
          title: const Text('Animated GIF'),
          value: 'gif',
          groupValue: format,
          onChanged: (value) => setState(() => format = value!),
        ),
        RadioListTile(
          title: const Text('Sprite Sheet'),
          value: 'sprite-sheet',
          groupValue: format,
          onChanged: (value) => setState(() => format = value!),
        ),

        const Divider(),

        // Background Options
        SwitchListTile(
          title: const Text('Transparent Background'),
          value: transparent,
          onChanged: (value) => setState(() => transparent = value),
        ),

        if (format == 'sprite-sheet') ...[
          const Divider(),
          const Text(
            'Sprite Sheet Options',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Columns',
                  ),
                  value: spriteSheetColumns,
                  items: [2, 4, 8, 16].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => spriteSheetColumns = value!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Spacing (px)',
                  ),
                  initialValue: spriteSheetSpacing.toString(),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(
                      () => spriteSheetSpacing = int.tryParse(value) ?? 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Include all animation frames'),
            value: includeAllFrames,
            onChanged: (value) => setState(() => includeAllFrames = value),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () {
                widget.onSave({
                  'format': format,
                  'transparent': transparent,
                  'backgroundColor': backgroundColor.value,
                  if (format == 'sprite-sheet')
                    'spriteSheetOptions': {
                      'columns': spriteSheetColumns,
                      'spacing': spriteSheetSpacing,
                      'includeAllFrames': includeAllFrames,
                    },
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper function to show color picker
void showColorPicker(
  BuildContext context,
  Color initialColor,
  Function(Color) onColorChanged,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: initialColor,
          onColorChanged: onColorChanged,
          pickerAreaHeightPercent: 0.8,
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Done'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
