import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../l10n/strings.dart';
import '../../config/assets.dart';
import '../../data/models/subscription_model.dart';
import '../../pixel/tools.dart';
import '../../pixel/tools/texture_brush_tool.dart';
import 'app_icon.dart';
import 'menu_value_field.dart';
import 'texture_brush_panel.dart';

class ToolBar extends StatelessWidget {
  final ValueNotifier<PixelTool> currentTool;
  final ValueNotifier<PixelModifier> currentModifier;
  final ValueNotifier<int> brushSize;
  final ValueNotifier<int> sprayIntensity;
  final bool showPrevFrames;
  final Function(PixelTool) onSelectTool;
  final Function(PixelModifier) onSelectModifier;
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? import;
  final VoidCallback? export;
  final VoidCallback? exportAsImage;
  final VoidCallback? onShare;
  final VoidCallback? onEffects;
  final Function(TexturePattern, BlendMode)? onTextureSelected;
  final Color currentColor;
  final Function() onColorPicker;
  final Function()? showPrevFramesOpacity;
  final bool currentLayerHasEffects; // Added flag to show if layer has effects
  final UserSubscription subscription;

  const ToolBar({
    super.key,
    required this.currentTool,
    required this.currentModifier,
    required this.brushSize,
    required this.sprayIntensity,
    required this.onSelectTool,
    required this.onSelectModifier,
    required this.onUndo,
    required this.onRedo,
    this.showPrevFrames = false,
    this.onZoomIn,
    this.onZoomOut,
    this.import,
    this.export,
    this.exportAsImage,
    this.onShare,
    this.onEffects,
    this.onTextureSelected,
    required this.currentColor,
    required this.onColorPicker,
    this.showPrevFramesOpacity,
    this.currentLayerHasEffects = false,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: double.infinity,
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ValueListenableBuilder<PixelTool>(
                valueListenable: currentTool,
                builder: (context, tool, child) {
                  return Row(
                    children: [
                      const SizedBox(width: 4),
                      PopupMenuButton(
                        icon: const Icon(Feather.save, size: 18),
                        tooltip: Strings.of(context).fileMenu,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'import',
                            child: ListTile(
                              leading: const AppIcon(AppIcons.album),
                              title: Text(Strings.of(context).open),
                            ),
                          ),
                          if (kIsWeb ||
                              defaultTargetPlatform == TargetPlatform.macOS ||
                              defaultTargetPlatform == TargetPlatform.windows)
                            PopupMenuItem(
                              value: 'export',
                              child: ListTile(
                                leading: const AppIcon(AppIcons.archive_down),
                                title: Text(Strings.of(context).save),
                              ),
                            ),
                          PopupMenuItem(
                            value: 'exportAsImage',
                            child: ListTile(
                              leading: const AppIcon(AppIcons.archive_down),
                              title: Text(Strings.of(context).saveAs),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: ListTile(
                              leading: const AppIcon(AppIcons.share),
                              title: Text(Strings.of(context).share),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'projects',
                            child: ListTile(
                              leading: const AppIcon(AppIcons.home),
                              title: Text(Strings.of(context).projects),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'import':
                              import?.call();
                              break;
                            case 'export':
                              export?.call();
                              break;
                            case 'exportAsImage':
                              exportAsImage?.call();
                              break;
                            case 'projects':
                              Navigator.of(context).pop();
                              break;
                            case 'share':
                              onShare?.call();
                              break;
                          }
                        },
                      ),
                      VerticalDivider(
                        width: 0,
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                      ),
                      const SizedBox(width: 8),
                      ValueListenableBuilder(
                        valueListenable: currentModifier,
                        builder: (context, modifier, child) {
                          return IconButton(
                            icon: SvgPicture.asset(
                              Assets.vectors.reflectSymmetry,
                              color: modifier == PixelModifier.mirror ? Colors.blue : IconTheme.of(context).color,
                              width: 24,
                              height: 24,
                            ),
                            onPressed: () {
                              onSelectModifier(
                                modifier == PixelModifier.mirror ? PixelModifier.none : PixelModifier.mirror,
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      // effects button
                      IconButton(
                        icon: Stack(
                          children: [
                            const Icon(Icons.auto_fix_high),
                            if (currentLayerHasEffects)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        tooltip: 'Layer Effects',
                        onPressed: onEffects,
                      ),
                      const SizedBox(width: 8),
                      // zoom in and out
                      if (MediaQuery.of(context).size.width > 600) ...[
                        IconButton(
                          icon: const Icon(Feather.zoom_in),
                          onPressed: onZoomIn,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Feather.zoom_out),
                          onPressed: onZoomOut,
                        ),
                        const SizedBox(width: 8),
                      ],
                      SizedBox(
                        height: 30,
                        child: VerticalDivider(width: 0, color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        icon: const Icon(Icons.animation_rounded),
                        onPressed: showPrevFramesOpacity,
                        splashColor: Colors.transparent,
                        style: IconButton.styleFrom(
                          backgroundColor: showPrevFrames ? null : Colors.transparent,
                        ),
                      ),
                      if (MediaQuery.of(context).size.width > 600) ...[
                        const SizedBox(width: 8),
                        if (tool == PixelTool.brush ||
                            tool == PixelTool.eraser ||
                            tool == PixelTool.sprayPaint ||
                            tool == PixelTool.pencil) ...[
                          MenuToolValueField(
                            value: brushSize.value,
                            min: 1,
                            max: 10,
                            icon: const Icon(Icons.brush, size: 18),
                            child: Text('${brushSize.value}px'),
                            onChanged: (value) {
                              brushSize.value = value;
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (tool == PixelTool.sprayPaint) ...[
                          MenuToolValueField(
                            value: sprayIntensity.value,
                            min: 1,
                            max: 10,
                            icon: const Icon(MaterialCommunityIcons.spray),
                            child: Text('${sprayIntensity.value}'),
                            onChanged: (value) {
                              sprayIntensity.value = value;
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.undo, color: onUndo != null ? null : Colors.grey),
                onPressed: onUndo,
                tooltip: Strings.of(context).undo,
              ),
              IconButton(
                icon: Icon(Icons.redo, color: onRedo != null ? null : Colors.grey),
                onPressed: onRedo,
                tooltip: Strings.of(context).redo,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
