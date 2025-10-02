import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../core/utils.dart';
import '../../../data/models/subscription_model.dart';
import '../../../pixel/image_painter.dart';
import '../../../pixel/pixel_canvas_state.dart';
import '../../../data.dart';
import '../../widgets.dart';
import '../animation_timeline.dart';

Future<void> showSaveImageWindow(
  BuildContext context, {
  required PixelCanvasState state,
  required final UserSubscription subscription,
  required Function(Map<String, dynamic>) onSave,
}) {
  final size = MediaQuery.sizeOf(context);
  final isMobile = size.width < 600;
  final isTablet = size.width >= 600 && size.width < 1200;
  final isDesktop = size.width >= 1200;

  if (isDesktop) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SaveImageDesktop(
          state: state,
          subscription: subscription,
          onSave: onSave,
        ),
      ),
    );
  }

  if (isTablet) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: SaveImageTablet(
          state: state,
          subscription: subscription,
          onSave: onSave,
        ),
      ),
    );
  }

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
  final PixelCanvasState state;
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

  double _calcSpriteSheetHeight(double width) {
    double originalRatio = widget.state.width / widget.state.height;
    return (width / spriteSheetColumns) / originalRatio;
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
        return Focus(
          autofocus: true,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
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
              ),
              const SliverToBoxAdapter(child: Divider()),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
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
                      subtitle: subscription.plan == SubscriptionPlan.proPurchase
                          ? null
                          : const Text(
                              'Pro Plan Required',
                              style: TextStyle(fontSize: 12, color: Colors.blue),
                            ),
                      value: 'sprite-sheet',
                      groupValue: format,
                      onChanged: subscription.plan == SubscriptionPlan.proPurchase
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
                              width = double.tryParse(value) ?? widget.state.width.toDouble();

                              double originalRatio = widget.state.width / widget.state.height;
                              height = width / originalRatio;

                              heightController.text = height.toString();
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
                              height = double.tryParse(value) ?? widget.state.height.toDouble();
                              double originalRatio = widget.state.width / widget.state.height;
                              width = height / originalRatio;

                              widthController.text = width.toString();
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
                            return Center(
                              child: AnimationPreview(
                                width: widget.state.width,
                                height: widget.state.height,
                                frames: widget.state.currentFrames,
                              ),
                            );
                          } else {
                            return LayoutBuilder(builder: (context, constraints) {
                              return SizedBox(
                                width: 400,
                                height: _calcSpriteSheetHeight(constraints.maxWidth),
                                child: SpriteSheetPreview(
                                  width: widget.state.width,
                                  height: widget.state.height,
                                  frames: widget.state.currentFrames,
                                  columns: spriteSheetColumns,
                                  spacing: spriteSheetSpacing,
                                  includeAllFrames: includeAllFrames,
                                ),
                              );
                            });
                          }
                        }(),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
              // Action buttons at the bottom
              SliverToBoxAdapter(
                child: Padding(
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
              ),
            ],
          ),
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

class SaveImageDesktop extends StatefulWidget {
  const SaveImageDesktop({
    super.key,
    this.format,
    required this.state,
    required this.subscription,
    required this.onSave,
  });

  final String? format;
  final PixelCanvasState state;
  final UserSubscription subscription;
  final Function(Map<String, dynamic>) onSave;

  @override
  State<SaveImageDesktop> createState() => _SaveImageDesktopState();
}

class _SaveImageDesktopState extends State<SaveImageDesktop> {
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

  double _calcSpriteSheetHeight(double width) {
    double originalRatio = widget.state.width / widget.state.height;
    return (width / spriteSheetColumns) / originalRatio;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 900,
      height: 650,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Text(
                  'Save',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left panel - Options
                SizedBox(
                  width: 350,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Format Section
                        Text(
                          'Format',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            _buildFormatOption('png', 'PNG', null),
                            _buildFormatOption(
                              'gif',
                              'GIF',
                              subscription.isPro ? null : 'Pro Plan Required',
                            ),
                            _buildFormatOption(
                              'sprite-sheet',
                              'Sprite',
                              subscription.plan == SubscriptionPlan.proPurchase ? null : 'Pro Plan Required',
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        const Divider(),

                        // Background Options

                        SwitchListTile(
                          title: const Text('Transparent'),
                          value: transparent,
                          onChanged: (value) => setState(() => transparent = value),
                          contentPadding: EdgeInsets.zero,
                          activeColor: Theme.of(context).colorScheme.primary,
                          thumbColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                        ),

                        if (format == 'sprite-sheet') ...[
                          const Divider(),
                          const SizedBox(height: 5),

                          // Sprite Sheet Options
                          Text(
                            'Sprite Sheet Options',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Columns',
                              border: OutlineInputBorder(),
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
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Spacing (px)',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: spriteSheetSpacing.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(() => spriteSheetSpacing = int.tryParse(value) ?? 0),
                          ),
                        ],

                        const Divider(),
                        const SizedBox(height: 24),

                        // Size Section
                        Text(
                          'Export Size',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Width',
                                  border: OutlineInputBorder(),
                                  suffixText: 'px',
                                ),
                                controller: widthController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  width = double.tryParse(value) ?? widget.state.width.toDouble();
                                  double originalRatio = widget.state.width / widget.state.height;
                                  height = width / originalRatio;
                                  heightController.text = height.toStringAsFixed(0);
                                },
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.close, size: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Height',
                                  border: OutlineInputBorder(),
                                  suffixText: 'px',
                                ),
                                controller: heightController,
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  height = double.tryParse(value) ?? widget.state.height.toDouble();
                                  double originalRatio = widget.state.width / widget.state.height;
                                  width = height * originalRatio;
                                  widthController.text = width.toStringAsFixed(0);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const VerticalDivider(width: 1),

                // Right panel - Preview
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: ColoredBox(
                              color: transparent ? Colors.grey.shade200 : backgroundColor,
                              child: RepaintBoundary(
                                key: previewKey,
                                child: _buildPreview(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Footer with actions
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatOption(String value, String title, String? subtitle) {
    final isEnabled = subtitle == null;
    return InkWell(
      onTap: isEnabled ? () => setState(() => format = value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: format == value ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: format == value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
          color: format == value ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: value,
              groupValue: format,
              onChanged: isEnabled ? (val) => setState(() => format = val!) : null,
            ),
            Text(
              title,
              style: TextStyle(
                fontWeight: format == value ? FontWeight.w600 : FontWeight.normal,
                color: isEnabled ? null : Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (format == 'png') {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 400),
        child: AspectRatio(
          aspectRatio: widget.state.width / widget.state.height,
          child: LayersPreview(
            width: widget.state.width,
            height: widget.state.height,
            layers: widget.state.layers,
            builder: (context, image) {
              return image != null ? CustomPaint(painter: ImagePainter(image)) : const ColoredBox(color: Colors.white);
            },
          ),
        ),
      );
    } else if (format == 'gif') {
      return Center(
        child: AnimationPreview(
          width: widget.state.width,
          height: widget.state.height,
          frames: widget.state.currentFrames,
        ),
      );
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: 400,
          height: _calcSpriteSheetHeight(400),
          child: SpriteSheetPreview(
            width: widget.state.width,
            height: widget.state.height,
            frames: widget.state.currentFrames,
            columns: spriteSheetColumns,
            spacing: spriteSheetSpacing,
            includeAllFrames: includeAllFrames,
          ),
        );
      });
    }
  }

  void _handleSave() {
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
  }
}

class SaveImageTablet extends StatefulWidget {
  const SaveImageTablet({
    super.key,
    this.format,
    required this.state,
    required this.subscription,
    required this.onSave,
  });

  final String? format;
  final PixelCanvasState state;
  final UserSubscription subscription;
  final Function(Map<String, dynamic>) onSave;

  @override
  State<SaveImageTablet> createState() => _SaveImageTabletState();
}

class _SaveImageTabletState extends State<SaveImageTablet> {
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

  double _calcSpriteSheetHeight(double width) {
    double originalRatio = widget.state.width / widget.state.height;
    return (width / spriteSheetColumns) / originalRatio;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 700,
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  'Save',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Format and Options
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Format',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 12),
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
                                      style: TextStyle(fontSize: 11, color: Colors.blue),
                                    ),
                              value: 'gif',
                              groupValue: format,
                              onChanged: subscription.isPro ? (String? value) => setState(() => format = value!) : null,
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile(
                              title: const Text('Sprite Sheet'),
                              subtitle: subscription.plan == SubscriptionPlan.proPurchase
                                  ? null
                                  : const Text(
                                      'Pro Plan Required',
                                      style: TextStyle(fontSize: 11, color: Colors.blue),
                                    ),
                              value: 'sprite-sheet',
                              groupValue: format,
                              onChanged: subscription.plan == SubscriptionPlan.proPurchase
                                  ? (String? value) => setState(() => format = value!)
                                  : null,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Options',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            SwitchListTile(
                              title: const Text('Transparent Background'),
                              value: transparent,
                              onChanged: (value) => setState(() => transparent = value),
                              contentPadding: EdgeInsets.zero,
                              activeColor: Theme.of(context).colorScheme.primary,
                              thumbColor: MaterialStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Width',
                                      suffixText: 'px',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: widthController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      width = double.tryParse(value) ?? widget.state.width.toDouble();
                                      double originalRatio = widget.state.width / widget.state.height;
                                      height = width / originalRatio;
                                      heightController.text = height.toStringAsFixed(0);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Height',
                                      suffixText: 'px',
                                      border: OutlineInputBorder(),
                                    ),
                                    controller: heightController,
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      height = double.tryParse(value) ?? widget.state.height.toDouble();
                                      double originalRatio = widget.state.width / widget.state.height;
                                      width = height * originalRatio;
                                      widthController.text = width.toStringAsFixed(0);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  if (format == 'sprite-sheet') ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 20),
                    Text(
                      'Sprite Sheet Options',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              labelText: 'Columns',
                              border: OutlineInputBorder(),
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
                              border: OutlineInputBorder(),
                            ),
                            initialValue: spriteSheetSpacing.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => setState(() => spriteSheetSpacing = int.tryParse(value) ?? 0),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  Center(
                    child: ColoredBox(
                      color: transparent ? Colors.grey.shade200 : backgroundColor,
                      child: RepaintBoundary(
                        key: previewKey,
                        child: _buildPreview(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (format == 'png') {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300, maxHeight: 300),
        child: AspectRatio(
          aspectRatio: widget.state.width / widget.state.height,
          child: LayersPreview(
            width: widget.state.width,
            height: widget.state.height,
            layers: widget.state.layers,
            builder: (context, image) {
              return image != null ? CustomPaint(painter: ImagePainter(image)) : const ColoredBox(color: Colors.white);
            },
          ),
        ),
      );
    } else if (format == 'gif') {
      return Center(
        child: AnimationPreview(
          width: widget.state.width,
          height: widget.state.height,
          frames: widget.state.currentFrames,
        ),
      );
    } else {
      return LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: 300,
          height: _calcSpriteSheetHeight(300),
          child: SpriteSheetPreview(
            width: widget.state.width,
            height: widget.state.height,
            frames: widget.state.currentFrames,
            columns: spriteSheetColumns,
            spacing: spriteSheetSpacing,
            includeAllFrames: includeAllFrames,
          ),
        );
      });
    }
  }

  void _handleSave() {
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
