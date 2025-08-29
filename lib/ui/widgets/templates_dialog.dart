import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import '../../core.dart';
import '../../data/models/template.dart';
import '../../pixel/services/template_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';
import 'animated_background.dart';
import 'app_icon.dart';

/// Dialog for selecting and applying templates to the canvas
class TemplatesDialog extends HookConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final templateService = ref.watch(templateServiceProvider);
    final authState = ref.watch(authProvider);
    final searchController = useTextEditingController();

    // State management
    final currentTab = useState<TemplateTab>(TemplateTab.all);
    final localTemplates = useState<List<Template>>([]);
    final apiTemplates = useState<List<Template>>([]);
    final filteredTemplates = useState<List<Template>>([]);
    final categories = useState<List<TemplateCategory>>([]);
    final selectedCategory = useState<String?>('All');

    final isLoading = useState(false);
    final isLoadingMore = useState(false);
    final errorMessage = useState<String?>(null);
    final currentPage = useState(1);
    final hasMorePages = useState(true);
    final totalCount = useState(0);

    final scrollController = useScrollController();

    // Load initial data
    useEffect(() {
      _loadInitialData(
        templateService,
        localTemplates,
        apiTemplates,
        filteredTemplates,
        categories,
        isLoading,
        errorMessage,
        authState.isSignedIn,
      );
      return null;
    }, []);

    // Setup scroll listener for pagination
    useEffect(() {
      void scrollListener() {
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
          if (!isLoadingMore.value && hasMorePages.value && currentTab.value == TemplateTab.community) {
            _loadMoreTemplates(
              templateService,
              apiTemplates,
              filteredTemplates,
              currentPage,
              hasMorePages,
              isLoadingMore,
              selectedCategory.value,
              searchController.text,
            );
          }
        }
      }

      scrollController.addListener(scrollListener);
      return () => scrollController.removeListener(scrollListener);
    }, [scrollController]);

    // Filter templates when search or category changes
    useEffect(() {
      _filterTemplates(
        currentTab.value,
        localTemplates.value,
        apiTemplates.value,
        selectedCategory.value,
        searchController.text,
        filteredTemplates,
      );
      return null;
    }, [currentTab.value, localTemplates.value, apiTemplates.value, selectedCategory.value]);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        constraints: const BoxConstraints(
          maxWidth: 900,
          maxHeight: 700,
          minWidth: 700,
          minHeight: 500,
        ),
        child: AnimatedBackground(
          child: Column(
            children: [
              // Header
              _buildHeader(context),

              // Tab Bar
              _buildTabBar(context, currentTab, authState.isSignedIn),

              // Search and Filters
              _buildSearchAndFilters(
                context,
                searchController,
                categories.value,
                selectedCategory,
                () => _filterTemplates(
                  currentTab.value,
                  localTemplates.value,
                  apiTemplates.value,
                  selectedCategory.value,
                  searchController.text,
                  filteredTemplates,
                ),
              ),

              // Content
              Expanded(
                child: _buildContent(
                  context,
                  currentTab.value,
                  filteredTemplates.value,
                  isLoading.value,
                  isLoadingMore.value,
                  errorMessage.value,
                  scrollController,
                  totalCount.value,
                  () => _loadInitialData(
                    templateService,
                    localTemplates,
                    apiTemplates,
                    filteredTemplates,
                    categories,
                    isLoading,
                    errorMessage,
                    authState.isSignedIn,
                  ),
                ),
              ),

              // Footer with stats
              _buildFooter(context, filteredTemplates.value.length, totalCount.value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: Row(
        children: [
          AppIcon(
            AppIcons.gallery_wide,
            size: 28,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 12),
          Text(
            'Template Gallery',
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
    );
  }

  Widget _buildTabBar(BuildContext context, ValueNotifier<TemplateTab> currentTab, bool isSignedIn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildTabButton(
            context,
            'All Templates',
            TemplateTab.all,
            currentTab,
            Feather.grid,
          ),
          const SizedBox(width: 12),
          _buildTabButton(
            context,
            'Local',
            TemplateTab.local,
            currentTab,
            Feather.hard_drive,
          ),
          const SizedBox(width: 12),
          _buildTabButton(
            context,
            'Community',
            TemplateTab.community,
            currentTab,
            Feather.cloud,
          ),
          if (isSignedIn) ...[
            const SizedBox(width: 12),
            _buildTabButton(
              context,
              'My Templates',
              TemplateTab.mine,
              currentTab,
              Feather.user,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    String title,
    TemplateTab tab,
    ValueNotifier<TemplateTab> currentTab,
    IconData icon,
  ) {
    final isSelected = currentTab.value == tab;
    return Expanded(
      child: InkWell(
        onTap: () => currentTab.value = tab,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    color:
                        isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    TextEditingController searchController,
    List<TemplateCategory> categories,
    ValueNotifier<String?> selectedCategory,
    VoidCallback onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: searchController,
            onChanged: (_) => onChanged(),
            decoration: InputDecoration(
              hintText: 'Search templates...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onChanged();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
            ),
          ),

          const SizedBox(height: 12),

          // Category filter
          if (categories.isNotEmpty) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip(
                    context,
                    'All',
                    selectedCategory.value == 'All',
                    () {
                      selectedCategory.value = 'All';
                      onChanged();
                    },
                  ),
                  const SizedBox(width: 8),
                  ...categories
                      .map((category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildCategoryChip(
                              context,
                              category.name,
                              selectedCategory.value == category.slug,
                              () {
                                selectedCategory.value = category.slug;
                                onChanged();
                              },
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    TemplateTab currentTab,
    List<Template> templates,
    bool isLoading,
    bool isLoadingMore,
    String? errorMessage,
    ScrollController scrollController,
    int totalCount,
    VoidCallback onRetry,
  ) {
    if (isLoading) {
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

    if (errorMessage != null) {
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
              errorMessage,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (templates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(currentTab),
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(currentTab),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Templates Grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GridView.builder(
              controller: scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: templates.length + (isLoadingMore ? 4 : 0), // Add loading placeholders
              itemBuilder: (context, index) {
                if (index >= templates.length) {
                  // Loading placeholder
                  return _buildLoadingPlaceholder(context);
                }

                final template = templates[index];
                return _TemplateCard(
                  template: template,
                  onTap: () {
                    onTemplateSelected(template);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ),

        // Loading indicator for pagination
        if (isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, int displayedCount, int totalCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $displayedCount${totalCount > 0 ? ' of $totalCount' : ''} templates',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
          ),
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              const SizedBox(width: 4),
              Text(
                'Click a template to apply it',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getEmptyStateIcon(TemplateTab tab) {
    switch (tab) {
      case TemplateTab.local:
        return Feather.hard_drive;
      case TemplateTab.community:
        return Feather.cloud;
      case TemplateTab.mine:
        return Feather.user;
      case TemplateTab.all:
        return Feather.grid;
    }
  }

  String _getEmptyStateMessage(TemplateTab tab) {
    switch (tab) {
      case TemplateTab.local:
        return 'No local templates found.\nCreate your first template from a layer!';
      case TemplateTab.community:
        return 'No community templates found.\nTry adjusting your search or filters.';
      case TemplateTab.mine:
        return 'You haven\'t uploaded any templates yet.\nShare your creations with the community!';
      case TemplateTab.all:
        return 'No templates found.\nTry adjusting your search or filters.';
    }
  }

  // Helper methods for data loading
  Future<void> _loadInitialData(
    TemplateService templateService,
    ValueNotifier<List<Template>> localTemplates,
    ValueNotifier<List<Template>> apiTemplates,
    ValueNotifier<List<Template>> filteredTemplates,
    ValueNotifier<List<TemplateCategory>> categories,
    ValueNotifier<bool> isLoading,
    ValueNotifier<String?> errorMessage,
    bool isSignedIn,
  ) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      // Load local templates
      final local = await templateService.getLocalTemplates();
      localTemplates.value = local;

      // Load categories
      final cats = await templateService.getTemplateCategories();
      categories.value = cats;

      // Load API templates if available
      if (isSignedIn) {
        try {
          final apiResponse = await templateService.getTemplatesFromAPI(limit: 20);
          apiTemplates.value = apiResponse.templates;
        } catch (e) {
          debugPrint('Error loading API templates: $e');
        }
      }

      // Initialize filtered templates
      filteredTemplates.value = [...local, ...apiTemplates.value];
    } catch (e) {
      errorMessage.value = 'Failed to load templates: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMoreTemplates(
    TemplateService templateService,
    ValueNotifier<List<Template>> apiTemplates,
    ValueNotifier<List<Template>> filteredTemplates,
    ValueNotifier<int> currentPage,
    ValueNotifier<bool> hasMorePages,
    ValueNotifier<bool> isLoadingMore,
    String? selectedCategory,
    String searchQuery,
  ) async {
    isLoadingMore.value = true;

    try {
      final response = await templateService.getTemplatesFromAPI(
        page: currentPage.value + 1,
        limit: 20,
        category: selectedCategory != 'All' ? selectedCategory : null,
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );

      apiTemplates.value = [...apiTemplates.value, ...response.templates];
      currentPage.value = response.page;
      hasMorePages.value = response.hasMore;

      // Update filtered templates
      // This should be replaced with proper filtering logic
      filteredTemplates.value = [...filteredTemplates.value, ...response.templates];
    } catch (e) {
      debugPrint('Error loading more templates: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _filterTemplates(
    TemplateTab currentTab,
    List<Template> localTemplates,
    List<Template> apiTemplates,
    String? selectedCategory,
    String searchQuery,
    ValueNotifier<List<Template>> filteredTemplates,
  ) {
    List<Template> baseTemplates;

    switch (currentTab) {
      case TemplateTab.local:
        baseTemplates = localTemplates;
        break;
      case TemplateTab.community:
        baseTemplates = apiTemplates.where((t) => !t.isLocal).toList();
        break;
      case TemplateTab.mine:
        baseTemplates = apiTemplates.where((t) => !t.isLocal).toList(); // Filter by current user
        break;
      case TemplateTab.all:
      default:
        baseTemplates = [...localTemplates, ...apiTemplates];
        break;
    }

    List<Template> filtered = baseTemplates;

    // Apply category filter
    if (selectedCategory != null && selectedCategory != 'All') {
      filtered = filtered.where((template) => template.category == selectedCategory).toList();
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((template) => template.matchesSearch(searchQuery)).toList();
    }

    filteredTemplates.value = filtered;
  }
}

enum TemplateTab { all, local, community, mine }

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
                  child: Stack(
                    children: [
                      _buildPreview(),
                      // Template source indicator
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color:
                                widget.template.isLocal ? Colors.green.withOpacity(0.9) : Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.template.isLocal ? Feather.hard_drive : Feather.cloud,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                widget.template.isLocal ? 'Local' : 'Cloud',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.template.sizeString,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  if (widget.template.category != null)
                    Text(
                      widget.template.categoryDisplayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 10,
                          ),
                    ),
                ],
              ),

              // Stats for remote templates
              if (!widget.template.isLocal && widget.template.likeCount > 0) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      size: 12,
                      color: Colors.red.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.template.likeCount}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 10,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (widget.template.thumbnailImageUrl != null) {
      return Image.network(
        widget.template.thumbnailImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

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
