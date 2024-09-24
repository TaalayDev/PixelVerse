import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:uuid/uuid.dart';

import '../../data.dart';
import '../../core.dart';
import '../../providers/projects_provider.dart';
import '../widgets.dart';
import 'about_screen.dart';
import 'pixel_draw_screen.dart';

class ProjectsScreen extends HookConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final overlayLoader = useState<OverlayEntry?>(null);

    useEffect(() {
      return () {
        if (overlayLoader.value?.mounted == true) {
          overlayLoader.value?.remove();
        }
      };
    }, []);

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
      body: projects.when(
        data: (projects) => AdaptiveProjectGrid(
          projects: projects,
          onCreateNew: () => _navigateToNewProject(context, ref),
          onTapProject: (project) {
            overlayLoader.value = _openProject(context, ref, project.id);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Feather.alert_circle, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'An error occurred',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Feather.refresh_cw),
                label: const Text('Try Again'),
                onPressed: () => ref.refresh(projectsProvider),
              ),
            ],
          ),
        ),
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
        id: 0,
        name: result.name,
        width: result.width,
        height: result.height,
        createdAt: DateTime.now(),
        editedAt: DateTime.now(),
        layers: [
          Layer(
            layerId: 0,
            id: const Uuid().v4(),
            name: 'Layer 1',
            pixels: Uint32List(result.width * result.height),
          ),
        ],
      );

      final loader = showLoader(context, loadingText: 'Creating project...');
      final newProject =
          await ref.read(projectsProvider.notifier).addProject(project);

      if (context.mounted) {
        loader.remove();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PixelDrawScreen(project: newProject),
          ),
        );
      }
    }
  }

  OverlayEntry _openProject(
    BuildContext context,
    WidgetRef ref,
    int projectId,
  ) {
    final loader = showLoader(context, loadingText: 'Opening project...');

    ref.read(projectsProvider.notifier).getProject(projectId).then((project) {
      loader.remove();
      if (project != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PixelDrawScreen(project: project),
          ),
        );
      }
    });

    return loader;
  }
}

class AdaptiveProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final Function()? onCreateNew;
  final Function(Project)? onTapProject;

  const AdaptiveProjectGrid({
    super.key,
    required this.projects,
    this.onCreateNew,
    this.onTapProject,
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
              onTapProject: onTapProject,
            );
          },
        );
      },
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final Function(Project)? onTapProject;

  const ProjectCard({super.key, required this.project, this.onTapProject});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          onTapProject?.call(project);
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
                  child: ProjectThumbnailWidget(project: project),
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

class ProjectThumbnailWidget extends StatefulWidget {
  const ProjectThumbnailWidget({
    super.key,
    required this.project,
  });

  final Project project;

  @override
  State<ProjectThumbnailWidget> createState() => _ProjectThumbnailWidgetState();
}

class _ProjectThumbnailWidgetState extends State<ProjectThumbnailWidget> {
  ui.Image? _image;

  @override
  void initState() {
    _createImageFromPixels();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProjectThumbnailWidget oldWidget) {
    if (oldWidget.project.thumbnail != widget.project.thumbnail) {
      _createImageFromPixels();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: _image != null && context.mounted
          ? RawImage(image: _image, fit: BoxFit.cover)
          : const Center(
              child: Icon(Feather.image, size: 48),
            ),
    );
  }

  Future<void> _createImageFromPixels() async {
    if (widget.project.thumbnail == null) {
      return;
    }

    ui.decodeImageFromPixels(
      widget.project.thumbnail!,
      widget.project.width,
      widget.project.height,
      ui.PixelFormat.rgba8888,
      (ui.Image img) {
        setState(() {
          _image = img;
        });
      },
    );
  }
}