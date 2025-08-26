import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core.dart';
import '../../data/models/template.dart';
import '../../pixel/services/template_service.dart';
import 'animated_background.dart';

/// Dialog for selecting and applying templates to the canvas
class TemplatesDialog extends StatefulWidget {
  final Function(Template template) onTemplateSelected;

  const TemplatesDialog({
    super.key,
    required this.onTemplateSelected,
  });

  static Future<void> show(BuildContext context, Function(Template template) onTemplateSelected) async {
    showDialog(
      context: context,
      builder: (context) {
        return TemplatesDialog(onTemplateSelected: onTemplateSelected);
      },
    );
  }

  @override
  State<TemplatesDialog> createState() => _TemplatesDialogState();
}

class _TemplatesDialogState extends State<TemplatesDialog> with SingleTickerProviderStateMixin {
  final TemplateService _templateService = TemplateService();
  final TextEditingController _searchController = TextEditingController();

  TemplateCollection? _templates;
  List<Template> _filteredTemplates = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  bool _isLoading = true;
  String _error = '';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplates() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final templates = await _templateService.getTemplates();
      final categories = ['All', ..._templateService.getTemplateCategories()];

      _tabController = TabController(length: categories.length, vsync: this);

      setState(() {
        _templates = templates;
        _categories = categories;
        _filteredTemplates = templates.templates;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load templates: $e';
        _isLoading = false;
      });
    }
  }

  void _filterTemplates() {
    if (_templates == null) return;

    List<Template> filtered = _templates!.templates;

    // Apply category filter
    if (_selectedCategory != 'All') {
      filtered = _templateService.getTemplatesByCategory(_selectedCategory);
    }

    // Apply search filter
    final searchQuery = _searchController.text.trim();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((template) {
        return template.name.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredTemplates = filtered;
    });
  }

  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 800,
          maxHeight: 600,
          minWidth: 600,
          minHeight: 400,
        ),
        child: AnimatedBackground(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.add,
                      size: 28,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Templates',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ],
                ),
              ),

              // Search bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterTemplates(),
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                ),
              ),

              // Category tabs
              if (_categories.isNotEmpty && !_isLoading)
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  onTap: (index) => _onCategoryChanged(_categories[index]),
                  tabs: _categories.map((category) => Tab(text: category)).toList(),
                ),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading templates...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTemplates,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filteredTemplates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No templates found for "${_searchController.text}"'
                  : 'No templates available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemCount: _filteredTemplates.length,
        itemBuilder: (context, index) {
          final template = _filteredTemplates[index];
          return _TemplateCard(
            template: template,
            onTap: () {
              widget.onTemplateSelected(template);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }
}

/// Individual template card widget
class _TemplateCard extends StatefulWidget {
  final Template template;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.onTap,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  ui.Image? _previewImage;
  bool _isLoadingPreview = true;

  @override
  void initState() {
    super.initState();
    _generatePreview();
  }

  Future<void> _generatePreview() async {
    try {
      final image = await ImageHelper.createImageFromPixels(
        widget.template.pixelsAsUint32List,
        widget.template.width,
        widget.template.height,
      );

      if (mounted) {
        setState(() {
          _previewImage = image;
          _isLoadingPreview = false;
        });
      }
    } catch (e) {
      debugPrint('Error generating template preview: $e');
      if (mounted) {
        setState(() {
          _isLoadingPreview = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _previewImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Preview
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  child: _buildPreview(),
                ),
              ),

              const SizedBox(height: 8),

              // Template info
              Text(
                widget.template.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                '${widget.template.width}×${widget.template.height}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (_isLoadingPreview) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_previewImage == null) {
      return Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: Theme.of(context).colorScheme.outline,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomPaint(
        painter: _TemplatePreviewPainter(_previewImage!),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// Custom painter for rendering template preview
class _TemplatePreviewPainter extends CustomPainter {
  final ui.Image image;

  _TemplatePreviewPainter(this.image);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.none; // Keep pixels crisp

    // Draw checkerboard background for transparency
    _drawCheckerboard(canvas, size);

    // Draw the template image scaled to fit
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = _calculateDestRect(size);

    canvas.drawImageRect(image, src, dst, paint);
  }

  void _drawCheckerboard(Canvas canvas, Size size) {
    const checkerSize = 8.0;
    final paint = Paint();

    for (double y = 0; y < size.height; y += checkerSize) {
      for (double x = 0; x < size.width; x += checkerSize) {
        final isEven = ((x / checkerSize).floor() + (y / checkerSize).floor()) % 2 == 0;
        paint.color = isEven ? const Color(0xFFE0E0E0) : const Color(0xFFF5F5F5);

        canvas.drawRect(
          Rect.fromLTWH(
            x,
            y,
            (x + checkerSize > size.width) ? size.width - x : checkerSize,
            (y + checkerSize > size.height) ? size.height - y : checkerSize,
          ),
          paint,
        );
      }
    }
  }

  Rect _calculateDestRect(Size size) {
    final imageAspectRatio = image.width / image.height;
    final containerAspectRatio = size.width / size.height;

    late double width, height, left, top;

    if (imageAspectRatio > containerAspectRatio) {
      // Image is wider, fit to width
      width = size.width;
      height = size.width / imageAspectRatio;
      left = 0;
      top = (size.height - height) / 2;
    } else {
      // Image is taller, fit to height
      width = size.height * imageAspectRatio;
      height = size.height;
      left = (size.width - width) / 2;
      top = 0;
    }

    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  bool shouldRepaint(covariant _TemplatePreviewPainter oldDelegate) {
    return oldDelegate.image != image;
  }
}

/// Show the templates dialog
Future<void> showTemplatesDialog(
  BuildContext context, {
  required Function(Template template) onTemplateSelected,
}) {
  return showDialog(
    context: context,
    builder: (context) => TemplatesDialog(
      onTemplateSelected: onTemplateSelected,
    ),
  );
}
