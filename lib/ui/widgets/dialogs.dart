import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../core/utils.dart';
import '../../data/models/subscription_model.dart';
import '../../pixel/image_painter.dart';
import '../../pixel/providers/pixel_notifier_provider.dart';
import '../../data.dart';
import '../widgets.dart';
import 'animation_timeline.dart';

Future<void> showSaveImageDialog(
  BuildContext context, {
  required PixelDrawState state,
  required final UserSubscription subscription,
  required Function(Map<String, dynamic>) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SaveImageBottomSheet(
        state: state,
        subscription: subscription,
        onSave: onSave,
      ),
    ),
  );
}

class SaveImageBottomSheet extends StatefulWidget {
  const SaveImageBottomSheet({
    super.key,
    this.format,
    required this.state,
    required this.subscription,
    required this.onSave,
  });

  final String? format;
  final PixelDrawState state;
  final UserSubscription subscription;
  final Function(Map<String, dynamic>) onSave;

  @override
  State<SaveImageBottomSheet> createState() => _SaveImageBottomSheetState();
}

class _SaveImageBottomSheetState extends State<SaveImageBottomSheet> {
  late String format = widget.format ?? 'png';
  bool transparent = true;
  Color backgroundColor = Colors.white;
  int spriteSheetColumns = 4;
  int spriteSheetSpacing = 0;
  bool includeAllFrames = false;
  List<int> columnOptions = [2, 4, 8, 16];
  final previewKey = GlobalKey();
  late double width = widget.state.width.toDouble();
  late double height = widget.state.height.toDouble();

  final widthController = TextEditingController();
  final heightController = TextEditingController();

  UserSubscription get subscription => widget.subscription;

  @override
  void initState() {
    final framesLength = widget.state.currentFrames.length;
    if (!columnOptions.contains(framesLength)) {
      columnOptions.add(framesLength);
      columnOptions.sort();
    }
    spriteSheetColumns = framesLength;
    widthController.text = width.toString();
    heightController.text = height.toString();
    super.initState();
  }

  void _savePreviewImage() async {
    final boundary = previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();

    await FileUtils(context).saveUIImage(
      image,
      'pixelverse_${DateTime.now().microsecondsSinceEpoch}.png',
    );

    Navigator.of(context).pop();
  }

  double _calcSpriteSheetHeight() {
    double originalRatio = widget.state.width / widget.state.height;
    return (400 / spriteSheetColumns) / originalRatio;
  }

  @override
  Widget build(BuildContext context) {
    final hasExportFormats = subscription.hasFeatureAccess(
      SubscriptionFeature.advancedTools,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Save',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(),
            // Content
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  RadioListTile(
                    title: const Text('PNG'),
                    value: 'png',
                    groupValue: format,
                    onChanged: (value) => setState(() => format = value!),
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile(
                    title: const Text('Animated GIF'),
                    subtitle: subscription.isPro
                        ? null
                        : const Text(
                            'Pro Plan Required',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                    value: 'gif',
                    groupValue: format,
                    onChanged: subscription.isPro ? (String? value) => setState(() => format = value!) : null,
                    contentPadding: EdgeInsets.zero,
                  ),
                  RadioListTile(
                    title: const Text('Sprite Sheet'),
                    subtitle: subscription.plan == SubscriptionPlan.proYearly
                        ? null
                        : const Text(
                            'Pro Yearly Plan Required',
                            style: TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                    value: 'sprite-sheet',
                    groupValue: format,
                    onChanged: subscription.plan == SubscriptionPlan.proYearly
                        ? (String? value) => setState(() => format = value!)
                        : null,
                    contentPadding: EdgeInsets.zero,
                  ),

                  const Divider(),

                  // Background Options
                  SwitchListTile(
                    title: const Text(
                      'Transparent Background',
                      style: TextStyle(fontSize: 14),
                    ),
                    value: transparent,
                    onChanged: (value) => setState(() => transparent = value),
                    activeColor: Theme.of(context).colorScheme.onPrimary,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (format == 'sprite-sheet') ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Sprite Sheet Options',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                            items: columnOptions.map((int value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value'),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => spriteSheetColumns = value!),
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
                            onChanged: (value) => setState(() => spriteSheetSpacing = int.tryParse(value) ?? 0),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Size',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Width',
                          ),
                          controller: widthController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              width = double.tryParse(value) ?? widget.state.width.toDouble();

                              double originalRatio = widget.state.width / widget.state.height;
                              height = width / originalRatio;

                              heightController.text = height.toString();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Height',
                          ),
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              height = double.tryParse(value) ?? widget.state.height.toDouble();
                              double originalRatio = widget.state.width / widget.state.height;
                              width = height / originalRatio;

                              widthController.text = width.toString();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ColoredBox(
                    color: backgroundColor,
                    child: RepaintBoundary(
                      key: previewKey,
                      child: () {
                        if (format == 'png') {
                          return AspectRatio(
                            aspectRatio: widget.state.width / widget.state.height,
                            child: LayersPreview(
                              width: widget.state.width,
                              height: widget.state.height,
                              layers: widget.state.layers,
                              builder: (context, image) {
                                return image != null
                                    ? CustomPaint(painter: ImagePainter(image))
                                    : const ColoredBox(color: Colors.white);
                              },
                            ),
                          );
                        } else if (format == 'gif') {
                          return AnimationPreview(
                            width: widget.state.width,
                            height: widget.state.height,
                            frames: widget.state.currentFrames,
                          );
                        } else {
                          return SizedBox(
                            width: 400,
                            height: _calcSpriteSheetHeight(),
                            child: SpriteSheetPreview(
                              width: widget.state.width,
                              height: widget.state.height,
                              frames: widget.state.currentFrames,
                              columns: spriteSheetColumns,
                              spacing: spriteSheetSpacing,
                              includeAllFrames: includeAllFrames,
                            ),
                          );
                        }
                      }(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            // Action buttons at the bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () {
                      if (format == 'sprite-sheet') {
                        _savePreviewImage();
                        return;
                      }

                      widget.onSave({
                        'format': format,
                        'transparent': transparent,
                        'backgroundColor': backgroundColor.value,
                        'exportWidth': width,
                        'exportHeight': height,
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
            ),
          ],
        );
      },
    );
  }
}

class SpriteSheetPreview extends StatelessWidget {
  const SpriteSheetPreview({
    super.key,
    required this.width,
    required this.height,
    required this.frames,
    required this.columns,
    required this.spacing,
    required this.includeAllFrames,
  });

  final int width;
  final int height;
  final List<AnimationFrame> frames;
  final int columns;
  final int spacing;
  final bool includeAllFrames;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing.toDouble(),
        mainAxisSpacing: spacing.toDouble(),
      ),
      itemCount: frames.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final frame = frames[index];
        return LayersPreview(
          width: width,
          height: height,
          layers: frame.layers,
          builder: (context, image) {
            return image != null ? CustomPaint(painter: ImagePainter(image)) : const ColoredBox(color: Colors.white);
          },
        );
      },
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
