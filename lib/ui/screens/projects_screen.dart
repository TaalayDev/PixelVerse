import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pixelverse/core.dart';
import 'package:uuid/uuid.dart';

import '../../data.dart';
import '../../providers/projects_provider.dart';
import '../widgets.dart';
import 'about_screen.dart';
import 'pixel_draw_screen.dart';

class ProjectsScreen extends HookConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Row(
          children: [
            const SizedBox(width: 16),
            TextButton.icon(
              icon: const Icon(Feather.info),
              label: const Text('About'),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AboutScreen(),
                ));
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
        leadingWidth: 290,
        actions: [
          IconButton(
            icon: const Icon(Feather.plus),
            onPressed: () => _navigateToNewProject(context, ref),
          ),
        ],
      ),
      body: AdaptiveProjectGrid(
        projects: projects,
        onCreateNew: () => _navigateToNewProject(context, ref),
        onRefresh: () => ref.read(projectsProvider.notifier).refresh(),
      ),
    );
  }

  void _navigateToNewProject(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<({String name, int width, int height})>(
      context: context,
      builder: (BuildContext context) => const NewProjectDialog(),
    );

    if (result != null && context.mounted) {
      final project = Project(
        id: const Uuid().v4(),
        name: result.name,
        width: result.width,
        height: result.height,
        createdAt: DateTime.now(),
        editedAt: DateTime.now(),
        layers: [
          Layer(1, 'Layer 1', Uint32List(result.width * result.height)),
        ],
      );

      ref.read(projectsProvider.notifier).addProject(project);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PixelDrawScreen(project: project),
        ),
      );

      if (context.mounted) {
        ref.read(projectsProvider.notifier).refresh();
      }
    }
  }
}

class AdaptiveProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final Function()? onCreateNew;
  final Function()? onRefresh;

  const AdaptiveProjectGrid({
    super.key,
    required this.projects,
    this.onCreateNew,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Feather.folder, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Feather.plus),
              label: const Text('Create New'),
              onPressed: onCreateNew,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 600 ? 2 : (width < 1200 ? 3 : 4);

        return MasonryGridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return ProjectCard(
              project: projects[index],
              onRefresh: onRefresh,
            );
          },
        );
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final Function()? onRefresh;

  const ProjectCard({super.key, required this.project, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PixelDrawScreen(project: project),
            ),
          );

          onRefresh?.call();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        project.name,
                        style: MediaQuery.sizeOf(context).adaptiveValue(
                          Theme.of(context).textTheme.titleSmall,
                          {
                            ScreenSize.md:
                                Theme.of(context).textTheme.titleMedium,
                            ScreenSize.lg:
                                Theme.of(context).textTheme.titleMedium,
                            ScreenSize.xl:
                                Theme.of(context).textTheme.titleLarge,
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: project.width / project.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: LayersPreview(
                      width: project.width,
                      height: project.height,
                      layers: project.layers,
                      builder: (context, image) {
                        return image != null
                            ? RawImage(
                                image: image,
                                fit: BoxFit.cover,
                              )
                            : const ColoredBox(color: Colors.white);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInfoChip(
                      context,
                      icon: Feather.grid,
                      label: '${project.width}x${project.height}',
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    _buildInfoChip(
                      context,
                      icon: Feather.clock,
                      label: _formatLastEdited(project.editedAt),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatLastEdited(DateTime lastEdited) {
    final now = DateTime.now();
    final difference = now.difference(lastEdited);

    if (difference.inDays > 0) {
      return '${difference.inDays}d. ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h. ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m. ago';
    } else {
      return 'Just now';
    }
  }
}
