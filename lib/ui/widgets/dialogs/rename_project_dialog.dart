import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../l10n/strings.dart';

class RenameProjectDialog extends HookWidget {
  const RenameProjectDialog({super.key, this.onRename});

  final Function(String name)? onRename;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();

    return AlertDialog(
      title: Text(Strings.of(context).renameProject),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: Strings.of(context).projectName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(Strings.of(context).cancel),
        ),
        TextButton(
          onPressed: () {
            if (controller.text.isEmpty) {
              return;
            }

            Navigator.of(context).pop();
            onRename?.call(controller.text);
          },
          child: Text(Strings.of(context).rename),
        ),
      ],
    );
  }
}
