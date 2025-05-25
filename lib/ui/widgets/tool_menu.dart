import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../data/models/subscription_model.dart';
import '../../l10n/strings.dart';
import '../../pixel/tools.dart';
import 'subscription/feature_gate.dart';

class ToolMenu extends StatelessWidget {
  final ValueNotifier<PixelTool> currentTool;
  final Function(PixelTool) onSelectTool;
  final Function() onColorPicker;
  final Color currentColor;
  final UserSubscription subscription;

  const ToolMenu({
    super.key,
    required this.currentTool,
    required this.onSelectTool,
    required this.onColorPicker,
    required this.currentColor,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PixelTool>(
      valueListenable: currentTool,
      builder: (context, tool, child) {
        return IconButtonTheme(
          data: IconButtonThemeData(
            style: IconButton.styleFrom(
              padding: const EdgeInsets.all(8),
              iconSize: 18,
            ),
          ),
          child: Column(
            spacing: 15,
            children: [
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: tool == PixelTool.pencil ? Colors.blue : null,
                ),
                onPressed: () => onSelectTool(PixelTool.pencil),
              ),
              IconButton(
                icon: Icon(
                  Icons.brush,
                  color: tool == PixelTool.brush ? Colors.blue : null,
                ),
                onPressed: () => onSelectTool(PixelTool.brush),
              ),
              IconButton(
                icon: Icon(
                  Icons.format_color_fill,
                  color: tool == PixelTool.fill ? Colors.blue : null,
                ),
                onPressed: () => onSelectTool(PixelTool.fill),
              ),
              IconButton(
                icon: Icon(
                  Fontisto.eraser,
                  color: tool == PixelTool.eraser ? Colors.blue : null,
                ),
                onPressed: () => onSelectTool(PixelTool.eraser),
              ),
              ShapesMenuButton(
                currentTool: currentTool,
                onSelectTool: onSelectTool,
              ),
              // selection tool
              ProBadge(
                show: !subscription.isPro,
                child: IconButton(
                  icon: Icon(
                    Icons.crop,
                    color: tool == PixelTool.select ? Colors.blue : null,
                  ),
                  onPressed: !subscription.isPro ? null : () => onSelectTool(PixelTool.select),
                ),
              ),
              ProBadge(
                show: !subscription.isPro,
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.pencil,
                    color: tool == PixelTool.pen ? Colors.blue : null,
                  ),
                  onPressed: !subscription.isPro ? null : () => onSelectTool(PixelTool.pen),
                ),
              ),
              ProBadge(
                show: !subscription.isPro,
                child: IconButton(
                  icon: Icon(
                    Feather.move,
                    color: tool == PixelTool.drag ? Colors.blue : null,
                  ),
                  onPressed: !subscription.isPro ? null : () => onSelectTool(PixelTool.drag),
                ),
              ),
              IconButton(
                icon: Icon(
                  MaterialCommunityIcons.spray,
                  color: tool == PixelTool.sprayPaint ? Colors.blue : null,
                ),
                onPressed: () => onSelectTool(PixelTool.sprayPaint),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ShapesMenuButton extends StatelessWidget {
  final ValueNotifier<PixelTool> currentTool;
  final Function(PixelTool) onSelectTool;

  const ShapesMenuButton({
    super.key,
    required this.currentTool,
    required this.onSelectTool,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PixelTool>(
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            currentTool.value == PixelTool.line
                ? Icons.show_chart
                : currentTool.value == PixelTool.rectangle
                    ? Icons.crop_square
                    : Icons.radio_button_unchecked,
            color: _isShapeTool(currentTool.value) ? Colors.blue : null,
          ),
          Positioned(
            right: -5,
            bottom: -5,
            child: Transform.rotate(
              angle: -0.785398,
              child: const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      onSelected: (PixelTool result) {
        onSelectTool(result);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<PixelTool>>[
        PopupMenuItem<PixelTool>(
          value: PixelTool.line,
          child: ListTile(
            leading: const Icon(Icons.show_chart),
            title: Text(Strings.of(context).lineTool),
          ),
        ),
        PopupMenuItem<PixelTool>(
          value: PixelTool.rectangle,
          child: ListTile(
            leading: const Icon(Icons.crop_square),
            title: Text(Strings.of(context).rectangleTool),
          ),
        ),
        PopupMenuItem<PixelTool>(
          value: PixelTool.circle,
          child: ListTile(
            leading: const Icon(Icons.radio_button_unchecked),
            title: Text(Strings.of(context).circleTool),
          ),
        ),
      ],
    );
  }

  bool _isShapeTool(PixelTool tool) {
    return tool == PixelTool.line || tool == PixelTool.rectangle || tool == PixelTool.circle;
  }
}
