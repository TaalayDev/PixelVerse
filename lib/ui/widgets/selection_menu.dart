import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

/// A menu that appears when a selection is active, providing actions for that selection
class SelectionActionsMenu extends StatelessWidget {
  final Function() onCut;
  final Function() onCopy;
  final Function() onPaste;
  final Function() onDelete;
  final Function() onClearSelection;
  final bool canPaste;

  const SelectionActionsMenu({
    super.key,
    required this.onCut,
    required this.onCopy,
    required this.onPaste,
    required this.onDelete,
    required this.onClearSelection,
    this.canPaste = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              context,
              icon: Feather.scissors,
              label: 'Cut',
              onPressed: onCut,
            ),
            _buildActionButton(
              context,
              icon: Feather.copy,
              label: 'Copy',
              onPressed: onCopy,
            ),
            _buildActionButton(
              context,
              icon: Feather.clipboard,
              label: 'Paste',
              onPressed: canPaste ? onPaste : null,
            ),
            _buildActionButton(
              context,
              icon: Feather.trash_2,
              label: 'Delete',
              onPressed: onDelete,
              isDestructive: true,
            ),
            _buildActionButton(
              context,
              icon: Feather.x,
              label: 'Deselect',
              onPressed: onClearSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Function()? onPressed,
    bool isDestructive = false,
  }) {
    final Color color = isDestructive
        ? Colors.red
        : onPressed == null
            ? Theme.of(context).disabledColor
            : Theme.of(context).colorScheme.primary;

    return Tooltip(
      message: label,
      child: IconButton(
        icon: Icon(icon, size: 16, color: color),
        onPressed: onPressed,
      ),
    );
  }
}

/// A floating button for handling selection actions
class SelectionFloatingButton extends StatelessWidget {
  final Function() onTap;
  final bool hasSelection;

  const SelectionFloatingButton({
    super.key,
    required this.onTap,
    required this.hasSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSelection) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FloatingActionButton.small(
        onPressed: onTap,
        child: const Icon(Feather.edit_2),
      ),
    );
  }
}
