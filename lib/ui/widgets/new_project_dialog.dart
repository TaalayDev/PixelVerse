import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

const kMaxPixelWidth = 5024;
const kMaxPixelHeight = 5024;

class ProjectTemplate {
  final String name;
  final int width;
  final int height;

  ProjectTemplate(
      {required this.name, required this.width, required this.height});
}

class NewProjectDialog extends StatefulWidget {
  const NewProjectDialog({super.key});

  @override
  _NewProjectDialogState createState() => _NewProjectDialogState();
}

class _NewProjectDialogState extends State<NewProjectDialog> {
  final _formKey = GlobalKey<FormState>();
  String _projectName = '';
  int _width = 32;
  int _height = 32;

  final List<ProjectTemplate> _templates = [
    ProjectTemplate(name: 'Tiny Icon', width: 16, height: 16),
    ProjectTemplate(name: 'Small Sprite', width: 32, height: 32),
    ProjectTemplate(name: 'Medium Character', width: 64, height: 64),
    ProjectTemplate(name: 'Large Scene', width: 128, height: 128),
    ProjectTemplate(name: 'Custom', width: 32, height: 32),
  ];

  int _selectedTemplateIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'New Project',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.create),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a project name';
                  }
                  return null;
                },
                onSaved: (value) => _projectName = value!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  labelText: 'Template',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Octicons.repo_template),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                value: _selectedTemplateIndex,
                items: List.generate(_templates.length, (index) {
                  final template = _templates[index];
                  return DropdownMenuItem(
                    value: index,
                    child: Text(
                      '${template.name} (${template.width}x${template.height})',
                    ),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _selectedTemplateIndex = value!;
                    if (_selectedTemplateIndex != _templates.length - 1) {
                      _width = _templates[_selectedTemplateIndex].width;
                      _height = _templates[_selectedTemplateIndex].height;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_selectedTemplateIndex == _templates.length - 1)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Width',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.width_normal),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        initialValue: _width.toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter width';
                          }
                          int? width = int.tryParse(value);
                          if (width == null ||
                              width < 1 ||
                              width > kMaxPixelWidth) {
                            return 'Width: 1-$kMaxPixelWidth';
                          }
                          return null;
                        },
                        onSaved: (value) => _width = int.parse(value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Height',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.height),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        initialValue: _height.toString(),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Enter height';
                          }
                          int? height = int.tryParse(value);
                          if (height == null ||
                              height < 1 ||
                              height > kMaxPixelHeight) {
                            return 'Height: 1-$kMaxPixelHeight';
                          }
                          return null;
                        },
                        onSaved: (value) => _height = int.parse(value!),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: const Text('Create'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              Navigator.of(context).pop((
                name: _projectName,
                width: _width,
                height: _height,
              ));
            }
          },
        ),
      ],
    );
  }
}
