import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pixelverse/data/models/subscription_model.dart';
import 'package:pixelverse/ui/widgets/subscription/feature_gate.dart';

import '../../core/theme/theme.dart';
import '../../pixel/tools.dart';
import '../../providers/subscription_provider.dart';
import 'theme_selector.dart';

class StyledToolBottomSheet extends HookConsumerWidget {
  final ValueNotifier<PixelTool> currentTool;

  const StyledToolBottomSheet({
    super.key,
    required this.currentTool,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final subscription = ref.watch(subscriptionStateProvider);
    final hasProFeature = subscription.hasFeatureAccess(
      SubscriptionFeature.advancedTools,
    );

    // Define all tools with their icons and labels
    final tools = [
      _ToolItem(
        PixelTool.pencil,
        Icons.edit,
        'Pencil',
        'Basic drawing tool',
      ),
      _ToolItem(
        PixelTool.brush,
        Icons.brush,
        'Brush',
        'Smooth brushing tool',
      ),
      _ToolItem(
        PixelTool.sprayPaint,
        MaterialCommunityIcons.spray,
        'Spray',
        'Creates a spray effect',
      ),
      _ToolItem(
        PixelTool.fill,
        Icons.format_color_fill,
        'Fill',
        'Fill areas with color',
      ),
      _ToolItem(
        PixelTool.eraser,
        MaterialCommunityIcons.eraser,
        'Eraser',
        'Erase pixels',
      ),
      _ToolItem(
        PixelTool.line,
        Icons.show_chart,
        'Line',
        'Draw straight lines',
      ),
      _ToolItem(
        PixelTool.rectangle,
        Icons.crop_square,
        'Rectangle',
        'Draw rectangles',
      ),
      _ToolItem(
        PixelTool.circle,
        Icons.radio_button_unchecked,
        'Circle',
        'Draw circles',
      ),
      _ToolItem(
        PixelTool.pen,
        CupertinoIcons.pencil,
        'Pen',
        'Freehand drawing tool',
        isPro: !hasProFeature,
      ),
      _ToolItem(
        PixelTool.select,
        Icons.crop,
        'Select',
        'Select an area',
        isPro: !hasProFeature,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle for dragging
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.isDark ? Colors.grey[700] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Select Tool',
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          // Grid of tools
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return _buildToolItem(context, tool, theme);
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildToolItem(BuildContext context, _ToolItem tool, AppTheme theme) {
    final isSelected = currentTool.value == tool.tool;

    return Tooltip(
      message: tool.tooltip,
      preferBelow: false,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: tool.isPro
              ? null
              : () {
                  currentTool.value = tool.tool;
                  Navigator.of(context).pop(tool.tool);
                },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.primaryColor.withOpacity(0.2)
                  : theme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: theme.primaryColor, width: 2)
                  : Border.all(color: theme.divider, width: 1),
            ),
            child: ProBadge(
              show: tool.isPro,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tool.icon,
                      color:
                          isSelected ? theme.primaryColor : theme.inactiveIcon,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tool.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? theme.primaryColor
                            : theme.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolItem {
  final PixelTool tool;
  final IconData icon;
  final String label;
  final String tooltip;
  final bool isPro;

  _ToolItem(
    this.tool,
    this.icon,
    this.label,
    this.tooltip, {
    this.isPro = false,
  });
}
