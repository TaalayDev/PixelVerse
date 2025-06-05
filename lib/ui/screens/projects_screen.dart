import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../data/models/subscription_model.dart';
import '../../data/models/project_api_models.dart';
import '../../l10n/strings.dart';
import '../../data.dart';
import '../../core.dart';
import '../../pixel/image_painter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/ad/interstitial_ad_controller.dart';
import '../../providers/project_upload_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/community_projects_providers.dart';
import '../../providers/providers.dart';
import '../../providers/subscription_provider.dart';
import '../widgets/auth_dialog.dart';
import '../widgets/animated_pro_button.dart';
import '../widgets/animated_background.dart';
import '../widgets/community_project_card.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/project_upload_dialog.dart';
import '../widgets/subscription/subscription_menu.dart';
import '../widgets/theme_selector.dart';
import '../widgets.dart';
import 'subscription_screen.dart';
import 'about_screen.dart';
import 'pixel_draw_screen.dart';
import 'project_detail_screen.dart';

class ProjectsScreen extends HookConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider).theme;
    final projects = ref.watch(projectsProvider);
    final overlayLoader = useState<OverlayEntry?>(null);

    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final showBadge = useState(false);
    final subscription = ref.watch(subscriptionStateProvider);

    final authState = ref.watch(authProvider);
    final showProfileIcon = useState(false);

    final tabController = useTabController(initialLength: 2);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        checkAndShowReviewDialog(context, ref);
      });

      return () {
        if (overlayLoader.value?.mounted == true) {
          overlayLoader.value?.remove();
        }
      };
    }, []);

    final tabListener = useCallback(() {
      if (authState.isSignedIn && tabController.index == 1) {
        showProfileIcon.value = true;
      } else {
        showProfileIcon.value = false;
      }
    }, [authState, tabController]);

    useEffect(() {
      tabController.removeListener(tabListener);

      // Listen for tab changes
      tabController.addListener(tabListener);
      return null;
    }, [authState]);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Row(
            children: [
              const SizedBox(width: 16),
              TextButton.icon(
                label: const Icon(Feather.file),
                onPressed: () async {
                  final error = await ref.read(projectsProvider.notifier).importProject(context);
                  if (error != null) {
                    switch (error) {
                      default:
                        showTopFlushbar(
                          context,
                          message: Text(Strings.of(context).invalidFileContent),
                        );
                        break;
                    }
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                label: const Icon(Feather.info),
                onPressed: () {
                  if (kIsWeb || Platform.isMacOS || Platform.isWindows) {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog(
                        child: ClipRRect(
                          clipBehavior: Clip.antiAlias,
                          borderRadius: BorderRadius.circular(16),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: const AboutScreen(),
                          ),
                        ),
                      ),
                    );
                    return;
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AboutScreen(),
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
          ),
          leadingWidth: 200,
          actions: [
            if (!subscription.isPro && !showBadge.value) ...[
              AnimatedProButton(
                onTap: () => _showSubscriptionScreen(context),
                theme: theme,
              ),
              const SizedBox(width: 8),
            ],
            const ThemeSelector(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: showProfileIcon.value && authState.isSignedIn
                  ? PopupMenuButton<String>(
                      icon: authState.apiUser?.avatarUrl != null
                          ? CircleAvatar(
                              backgroundImage: authState.apiUser?.avatarUrl != null
                                  ? NetworkImage(authState.apiUser!.avatarUrl!)
                                  : const AssetImage('assets/images/default_avatar.png'),
                              radius: 15,
                            )
                          : const Icon(Feather.user),
                      offset: const Offset(0, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: Theme.of(context).shadowColor.withOpacity(0.3),
                      surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
                      onSelected: (value) {
                        if (value == 'delete_account') {
                          DeleteAccountDialog.show(
                            context,
                            onSuccess: () {},
                          );
                        } else if (value == 'logout') {
                          ref.read(authProvider.notifier).signOut();
                        }
                      },
                      itemBuilder: (context) => [
                        if (authState.apiUser?.displayName != null)
                          PopupMenuItem(
                            enabled: false,
                            height: 56,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (authState.apiUser?.displayName != null)
                                  Text(
                                    authState.apiUser!.displayName!,
                                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context).colorScheme.onSurface,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        if (authState.apiUser?.displayName != null) const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Feather.log_out,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Strings.of(context).logout,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete_account',
                          height: 48,
                          child: Row(
                            children: [
                              Icon(
                                Feather.trash_2,
                                size: 18,
                                color: Theme.of(context).colorScheme.error,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                Strings.of(context).deleteAccount,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.error,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : IconButton(
                      icon: const Icon(Feather.plus),
                      onPressed: () => _navigateToNewProject(context, ref, subscription),
                    ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SizedBox(
                height: 58,
                child: TabBar(
                  controller: tabController,
                  tabs: const [
                    Tab(
                      icon: Icon(Feather.hard_drive),
                      text: 'Local',
                    ),
                    Tab(
                      icon: Icon(Feather.cloud),
                      text: 'Cloud',
                    ),
                  ],
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            if (!subscription.isPro && showBadge.value) ...[
              SubscriptionPromoBanner(
                onDismiss: () {
                  showBadge.value = false;
                },
              ),
            ],
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  // Local Projects Tab
                  _buildLocalProjectsTab(
                    context,
                    ref,
                    projects,
                    subscription,
                    overlayLoader,
                    authState,
                  ),

                  // Cloud Projects Tab
                  _buildCloudProjectsTab(context, ref, theme, subscription),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalProjectsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Project>> projects,
    UserSubscription subscription,
    ValueNotifier<OverlayEntry?> overlayLoader,
    AuthState authState,
  ) {
    return projects.when(
      data: (projects) => AdaptiveProjectGrid(
        projects: projects,
        onCreateNew: () => _navigateToNewProject(context, ref, subscription),
        onTapProject: (project) {
          _openProject(context, ref, project.id, overlayLoader);
        },
        onDeleteProject: (project) {
          ref.read(projectsProvider.notifier).deleteProject(project);
        },
        onEditProject: (project) {
          ref.read(projectsProvider.notifier).renameProject(project.id, project.name);
        },
        onUploadProject: (project) {
          _onUploadProject(context, ref, project, authState);
        },
        onUpdateProject: (project) {
          _onUpdateProject(context, ref, project, authState);
        },
        onDeleteCloudProject: (project) {
          _onDeleteCloudProject(context, ref, project, authState);
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Feather.alert_circle,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              Strings.of(context).anErrorOccurred,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Feather.refresh_cw, color: Theme.of(context).colorScheme.onPrimary),
              label: Text(Strings.of(context).tryAgain),
              onPressed: () => ref.refresh(projectsProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloudProjectsTab(
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
    UserSubscription subscription,
  ) {
    return CloudProjectsView(
      theme: theme,
      subscription: subscription,
    );
  }

  void _showSubscriptionScreen(BuildContext context) {
    SubscriptionOfferScreen.show(context);
  }

  void _navigateToNewProject(
    BuildContext context,
    WidgetRef ref,
    UserSubscription subscription,
  ) async {
    final result = await showDialog<({String name, int width, int height})>(
      context: context,
      builder: (BuildContext context) => NewProjectDialog(
        subscription: subscription,
      ),
    );

    if (result != null && context.mounted) {
      final project = Project(
        id: 0,
        name: result.name,
        width: result.width,
        height: result.height,
        createdAt: DateTime.now(),
        editedAt: DateTime.now(),
      );

      final loader = showLoader(
        context,
        loadingText: Strings.of(context).creatingProject,
      );
      final newProject = await ref.read(projectsProvider.notifier).addProject(project);

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

  void _openProject(
    BuildContext context,
    WidgetRef ref,
    int projectId,
    ValueNotifier<OverlayEntry?> loader,
  ) async {
    loader.value = showLoader(
      context,
      loadingText: Strings.of(context).openingProject,
    );

    final project = await ref.read(projectsProvider.notifier).getProject(projectId);

    if (project != null && context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PixelDrawScreen(project: project),
        ),
      );
    }

    loader.value?.remove();
  }

  Future<void> checkAndShowReviewDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final reviewService = ref.read(inAppReviewProvider);
    final shouldRequest = await reviewService.shouldRequestReview();

    if (shouldRequest && context.mounted) {
      Future.delayed(const Duration(seconds: 1), () {
        if (context.mounted) {
          reviewService.requestReview();
        }
      });
    }
  }

  Future<void> _onUploadProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
    AuthState authState,
  ) async {
    if (authState.isSignedIn) {
      ProjectUploadDialog.show(context, project);
    } else {
      final auth = await AuthDialog.show(context);
      if (!context.mounted) return;
      if (auth == true) {
        ProjectUploadDialog.show(context, project);
      } else {
        showTopFlushbar(
          context,
          message: const Text('Please sign in to upload projects'),
        );
      }
    }
  }

  Future<void> _onUpdateProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
    AuthState authState,
  ) async {
    if (!authState.isSignedIn) {
      showTopFlushbar(
        context,
        message: const Text('Please sign in to update projects'),
      );
      return;
    }

    if (!project.isCloudSynced || project.remoteId == null) {
      showTopFlushbar(
        context,
        message: const Text('Project is not synced to cloud'),
      );
      return;
    }

    showTopFlushbar(
      context,
      message: const Text('Syncing project to cloud...'),
    );

    ref.read(projectUploadProvider.notifier).updateProject(localProject: project);
  }

  Future<void> _onDeleteCloudProject(
    BuildContext context,
    WidgetRef ref,
    Project project,
    AuthState authState,
  ) async {
    if (!authState.isSignedIn) {
      showTopFlushbar(
        context,
        message: const Text('Please sign in to remove cloud projects'),
      );
      return;
    }

    if (!project.isCloudSynced || project.remoteId == null) {
      showTopFlushbar(
        context,
        message: const Text('Project is not synced to cloud'),
      );
      return;
    }

    try {
      final loader = showLoader(
        context,
        loadingText: 'Removing from cloud...',
      );

      await ref.read(projectUploadProvider.notifier).deleteCloudProject(
            localProject: project,
          );

      if (context.mounted) {
        loader.remove();
        showTopFlushbar(
          context,
          message: const Text('Project removed from cloud successfully'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        showTopFlushbar(
          context,
          message: Text('Failed to remove from cloud: $e'),
        );
      }
    }
  }
}

class CloudProjectsView extends HookConsumerWidget {
  final AppTheme theme;
  final UserSubscription subscription;

  const CloudProjectsView({
    super.key,
    required this.theme,
    required this.subscription,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communityState = ref.watch(communityProjectsProvider);
    final searchController = useTextEditingController();
    final scrollController = useScrollController();
    final showSearch = useState(false);
    final selectedSort = useState('recent');

    // Handle infinite scroll
    useEffect(() {
      void onScroll() {
        if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
          ref.read(communityProjectsProvider.notifier).loadMore();
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    return Column(
      children: [
        // Search and Sort Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Row(
            children: [
              Expanded(
                child: showSearch.value
                    ? TextField(
                        controller: searchController,
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search projects...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onSubmitted: (value) {
                          ref.read(communityProjectsProvider.notifier).searchProjects(value);
                        },
                      )
                    : Text(
                        'Discover amazing pixel art',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  showSearch.value ? Icons.close : Icons.search,
                  color: theme.activeIcon,
                ),
                onPressed: () {
                  showSearch.value = !showSearch.value;
                  if (!showSearch.value) {
                    searchController.clear();
                    ref.read(communityProjectsProvider.notifier).searchProjects('');
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.sort, color: theme.activeIcon),
                tooltip: 'Sort by',
                onSelected: (value) {
                  selectedSort.value = value;
                  ref.read(communityProjectsProvider.notifier).setSortOrder(value);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'recent', child: Text('Most Recent')),
                  const PopupMenuItem(value: 'popular', child: Text('Most Popular')),
                  const PopupMenuItem(value: 'views', child: Text('Most Viewed')),
                  const PopupMenuItem(value: 'likes', child: Text('Most Liked')),
                  const PopupMenuItem(value: 'title', child: Text('Title A-Z')),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: theme.activeIcon),
                onPressed: () => ref.read(communityProjectsProvider.notifier).refresh(),
              ),
            ],
          ),
        ),

        // Filter chips
        if (communityState.popularTags.isNotEmpty) _buildFilterChips(context, ref, communityState, theme),

        // Featured projects section
        _buildFeaturedSection(context, ref, theme),

        // Main projects grid
        Expanded(
          child: _buildProjectsGrid(
            context,
            ref,
            communityState,
            scrollController,
            theme,
            subscription,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(
    BuildContext context,
    WidgetRef ref,
    CommunityProjectsState state,
    AppTheme theme,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.popularTags.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: const Text('All'),
                selected: state.filters.tags.isEmpty,
                selectedColor: theme.primaryColor.withOpacity(0.2),
                labelStyle: TextStyle(
                  color: state.filters.tags.isEmpty ? theme.primaryColor : theme.textPrimary,
                ),
                iconTheme: IconThemeData(
                  color: state.filters.tags.isEmpty ? theme.primaryColor : theme.textPrimary,
                ),
                onSelected: (selected) {
                  if (selected) {
                    ref.read(communityProjectsProvider.notifier).clearFilters();
                  }
                },
              ),
            );
          }

          final tag = state.popularTags[index - 1];
          final isSelected = state.filters.tags.contains(tag.slug);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(tag.name),
              selected: isSelected,
              selectedColor: theme.primaryColor.withOpacity(0.2),
              labelStyle: TextStyle(
                color: isSelected ? theme.primaryColor : theme.textPrimary,
              ),
              iconTheme: IconThemeData(
                color: isSelected ? theme.primaryColor : theme.textPrimary,
              ),
              onSelected: (selected) {
                final newTags = List<String>.from(state.filters.tags);
                if (selected) {
                  newTags.add(tag.slug);
                } else {
                  newTags.remove(tag.slug);
                }
                ref.read(communityProjectsProvider.notifier).filterByTags(newTags);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    WidgetRef ref,
    AppTheme theme,
  ) {
    final featuredProjects = ref.watch(featuredProjectsProvider);

    return featuredProjects.when(
      data: (projects) {
        if (projects.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.star, color: theme.warning, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Featured Projects',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: CommunityProjectCard(
                      project: projects[index],
                      isFeatured: true,
                      onTap: () => _openProjectDetail(context, ref, projects[index], subscription),
                      onLike: (project) => ref.read(communityProjectsProvider.notifier).toggleLike(project),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildProjectsGrid(
    BuildContext context,
    WidgetRef ref,
    CommunityProjectsState state,
    ScrollController scrollController,
    AppTheme theme,
    UserSubscription subscription,
  ) {
    if (state.isLoading && state.projects.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final adLoaded = ref.watch(interstitialAdProvider);

    if (state.error != null && state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Feather.alert_circle,
              size: 64,
              color: theme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading projects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              style: TextStyle(color: theme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () => ref.read(communityProjectsProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    if (state.projects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Feather.search,
              size: 64,
              color: theme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No projects found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 600 ? 2 : (width < 1200 ? 3 : 5);

        return MasonryGridView.count(
          controller: scrollController,
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          padding: const EdgeInsets.all(16),
          itemCount: state.projects.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= state.projects.length) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final project = state.projects[index];
            return CommunityProjectCard(
              key: ValueKey(project.id),
              project: project,
              onTap: () => _openProjectDetail(context, ref, project, subscription),
              onLike: (project) => ref.read(communityProjectsProvider.notifier).toggleLike(project),
              onUserTap: (username) {
                ref.read(communityProjectsProvider.notifier).filterByUser(username);
              },
            );
          },
        );
      },
    );
  }

  void _openProjectDetail(
    BuildContext context,
    WidgetRef ref,
    ApiProject project,
    UserSubscription subscription,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProjectDetailScreen(project: project),
      ),
    );
    if (!subscription.isPro) {
      ref.read(interstitialAdProvider.notifier).showAdIfLoaded(() {});
    }
  }
}

// Keep existing classes unchanged
class AdaptiveProjectGrid extends StatelessWidget {
  final List<Project> projects;
  final Function()? onCreateNew;
  final Function(Project)? onTapProject;
  final Function(Project)? onDeleteProject;
  final Function(Project)? onEditProject;
  final Function(Project)? onUploadProject;
  final Function(Project)? onUpdateProject;
  final Function(Project)? onDeleteCloudProject;

  const AdaptiveProjectGrid({
    super.key,
    required this.projects,
    this.onCreateNew,
    this.onTapProject,
    this.onDeleteProject,
    this.onEditProject,
    this.onUploadProject,
    this.onUpdateProject,
    this.onDeleteCloudProject,
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
              Strings.of(context).noProjectsFound,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(
                Feather.plus,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              label: Text(Strings.of(context).createNewProject),
              onPressed: onCreateNew,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width < 600 ? 2 : (width < 1200 ? 3 : 5);

        return MasonryGridView.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            return ProjectCard(
              key: ValueKey(projects[index].id),
              project: projects[index],
              onTapProject: onTapProject,
              onDeleteProject: onDeleteProject,
              onEditProject: onEditProject,
              onUploadProject: onUploadProject,
              onUpdateProject: onUpdateProject,
              onDeleteCloudProject: onDeleteCloudProject,
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
  final Function(Project)? onDeleteProject;
  final Function(Project)? onEditProject;
  final Function(Project)? onUploadProject;
  final Function(Project)? onUpdateProject;
  final Function(Project)? onDeleteCloudProject;

  const ProjectCard({
    super.key,
    required this.project,
    this.onTapProject,
    this.onDeleteProject,
    this.onEditProject,
    this.onUploadProject,
    this.onUpdateProject,
    this.onDeleteCloudProject,
  });

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kIsWeb || !Platform.isAndroid) const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            project.name,
                            style: MediaQuery.sizeOf(context).adaptiveValue(
                              Theme.of(context).textTheme.titleSmall,
                              {
                                ScreenSize.md: Theme.of(context).textTheme.titleMedium,
                                ScreenSize.lg: Theme.of(context).textTheme.titleMedium,
                                ScreenSize.xl: Theme.of(context).textTheme.titleLarge,
                              },
                            )?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Cloud sync indicator
                        if (project.isCloudSynced) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Feather.cloud,
                                  size: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Synced',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(Feather.more_vertical),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(25, 25),
                      iconSize: 20,
                    ),
                    itemBuilder: (context) {
                      return _buildMenuItems(context);
                    },
                    onSelected: (value) {
                      _handleMenuAction(context, value);
                    },
                  ),
                  if (kIsWeb || !Platform.isAndroid) const SizedBox(width: 8),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          label: _formatLastEdited(context, project.editedAt),
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(BuildContext context) {
    final items = <PopupMenuEntry<String>>[];

    // Rename option (always available)
    items.add(
      PopupMenuItem(
        value: 'rename',
        child: Row(
          children: [
            const Icon(Feather.edit_2),
            const SizedBox(width: 8),
            Text(Strings.of(context).rename),
          ],
        ),
      ),
    );

    // Edit option (always available)
    items.add(
      PopupMenuItem(
        value: 'edit',
        child: Row(
          children: [
            const Icon(Feather.edit),
            const SizedBox(width: 8),
            Text(Strings.of(context).edit),
          ],
        ),
      ),
    );

    // Cloud-related options
    if (project.isCloudSynced) {
      // Update cloud project
      items.add(
        const PopupMenuItem(
          value: 'update',
          child: Row(
            children: [
              Icon(Feather.upload_cloud),
              SizedBox(width: 8),
              Text('Resync with cloud'),
            ],
          ),
        ),
      );
    } else if (project.remoteId == null) {
      // Upload to cloud
      items.add(
        const PopupMenuItem(
          value: 'upload',
          child: Row(
            children: [
              Icon(Feather.upload),
              SizedBox(width: 8),
              Text('Sync to cloud'),
            ],
          ),
        ),
      );
    }

    // Separator
    items.add(const PopupMenuDivider());

    // Delete local project
    items.add(
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            const Icon(Feather.trash_2, color: Colors.red),
            const SizedBox(width: 8),
            Text(
              Strings.of(context).delete,
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );

    return items;
  }

  void _handleMenuAction(BuildContext context, String value) {
    switch (value) {
      case 'edit':
        onTapProject?.call(project);
        break;
      case 'rename':
        showDialog(
          context: context,
          builder: (context) => RenameProjectDialog(
            onRename: (name) {
              onEditProject?.call(
                project.copyWith(name: name),
              );
            },
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
      case 'upload':
        onUploadProject?.call(project);
        break;
      case 'update':
        onUpdateProject?.call(project);
        break;
      case 'delete_cloud':
        _showDeleteCloudConfirmation(context);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          Strings.of(context).deleteProject,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Strings.of(context).areYouSureWantToDeleteProject,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            if (project.isCloudSynced) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Feather.alert_triangle, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This project is synced to the cloud. Deleting locally will not affect the cloud version.',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
              Navigator.of(context).pop();
              onDeleteProject?.call(project);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Strings.of(context).delete),
          ),
        ],
      ),
    );
  }

  void _showDeleteCloudConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Cloud'),
        content: const Text(
          'This will remove the project from the cloud and make it local-only. '
          'Your local copy will remain unchanged. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteCloudProject?.call(project);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Remove from Cloud'),
          ),
        ],
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatLastEdited(BuildContext context, DateTime lastEdited) {
    final now = DateTime.now();
    final difference = now.difference(lastEdited);

    if (difference.inDays > 0) {
      return Strings.of(context).timeAgo('${difference.inDays}d.');
    } else if (difference.inHours > 0) {
      return Strings.of(context).timeAgo('${difference.inHours}h.');
    } else if (difference.inMinutes > 0) {
      return Strings.of(context).timeAgo('${difference.inMinutes}m.');
    } else {
      return Strings.of(context).justNow;
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: CheckerboardPainter(
                cellSize: 8,
                color1: Colors.grey.shade100,
                color2: Colors.grey.shade50,
              ),
            ),
            if (_image != null)
              CustomPaint(painter: ImagePainter(_image!))
            else
              const Center(
                child: Icon(Feather.image, size: 48),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _createImageFromPixels() async {
    final pixels = widget.project.thumbnail;
    if (pixels == null) {
      return;
    }

    final image = await ImageHelper.createImageFrom(
      pixels,
      widget.project.width,
      widget.project.height,
    );
    if (mounted) {
      setState(() {
        _image = image;
      });
    }
  }
}

class CheckerboardPainter extends CustomPainter {
  final double cellSize;
  final Color color1;
  final Color color2;

  CheckerboardPainter({
    required this.cellSize,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final rows = (size.height / cellSize).ceil();
    final cols = (size.width / cellSize).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final color = (row + col) % 2 == 0 ? color1 : color2;
        paint.color = color;

        canvas.drawRect(
          Rect.fromLTWH(
            col * cellSize,
            row * cellSize,
            cellSize,
            cellSize,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
