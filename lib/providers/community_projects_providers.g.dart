// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'community_projects_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$communityProjectsHash() => r'81b59bbc15a043e15a297e57279679b0eff47eb6';

/// See also [CommunityProjects].
@ProviderFor(CommunityProjects)
final communityProjectsProvider = AutoDisposeNotifierProvider<CommunityProjects,
    CommunityProjectsState>.internal(
  CommunityProjects.new,
  name: r'communityProjectsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$communityProjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CommunityProjects = AutoDisposeNotifier<CommunityProjectsState>;
String _$featuredProjectsHash() => r'89828d4edc07e82c7a452025d3301f7da640f4e4';

/// See also [FeaturedProjects].
@ProviderFor(FeaturedProjects)
final featuredProjectsProvider = AutoDisposeAsyncNotifierProvider<
    FeaturedProjects, List<ApiProject>>.internal(
  FeaturedProjects.new,
  name: r'featuredProjectsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredProjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$FeaturedProjects = AutoDisposeAsyncNotifier<List<ApiProject>>;
String _$trendingProjectsHash() => r'1eb09445fdec29cf112c7939941e9bd80f36d813';

/// See also [TrendingProjects].
@ProviderFor(TrendingProjects)
final trendingProjectsProvider = AutoDisposeAsyncNotifierProvider<
    TrendingProjects, List<ApiProject>>.internal(
  TrendingProjects.new,
  name: r'trendingProjectsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trendingProjectsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrendingProjects = AutoDisposeAsyncNotifier<List<ApiProject>>;
String _$communityProjectHash() => r'79f5787219ff0a373f6fdd7368f165cce2642d68';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$CommunityProject
    extends BuildlessAutoDisposeAsyncNotifier<ApiProject> {
  late final int projectId;
  late final bool includeData;

  FutureOr<ApiProject> build(
    int projectId, {
    bool includeData = false,
  });
}

/// See also [CommunityProject].
@ProviderFor(CommunityProject)
const communityProjectProvider = CommunityProjectFamily();

/// See also [CommunityProject].
class CommunityProjectFamily extends Family<AsyncValue<ApiProject>> {
  /// See also [CommunityProject].
  const CommunityProjectFamily();

  /// See also [CommunityProject].
  CommunityProjectProvider call(
    int projectId, {
    bool includeData = false,
  }) {
    return CommunityProjectProvider(
      projectId,
      includeData: includeData,
    );
  }

  @override
  CommunityProjectProvider getProviderOverride(
    covariant CommunityProjectProvider provider,
  ) {
    return call(
      provider.projectId,
      includeData: provider.includeData,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'communityProjectProvider';
}

/// See also [CommunityProject].
class CommunityProjectProvider
    extends AutoDisposeAsyncNotifierProviderImpl<CommunityProject, ApiProject> {
  /// See also [CommunityProject].
  CommunityProjectProvider(
    int projectId, {
    bool includeData = false,
  }) : this._internal(
          () => CommunityProject()
            ..projectId = projectId
            ..includeData = includeData,
          from: communityProjectProvider,
          name: r'communityProjectProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$communityProjectHash,
          dependencies: CommunityProjectFamily._dependencies,
          allTransitiveDependencies:
              CommunityProjectFamily._allTransitiveDependencies,
          projectId: projectId,
          includeData: includeData,
        );

  CommunityProjectProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
    required this.includeData,
  }) : super.internal();

  final int projectId;
  final bool includeData;

  @override
  FutureOr<ApiProject> runNotifierBuild(
    covariant CommunityProject notifier,
  ) {
    return notifier.build(
      projectId,
      includeData: includeData,
    );
  }

  @override
  Override overrideWith(CommunityProject Function() create) {
    return ProviderOverride(
      origin: this,
      override: CommunityProjectProvider._internal(
        () => create()
          ..projectId = projectId
          ..includeData = includeData,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
        includeData: includeData,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<CommunityProject, ApiProject>
      createElement() {
    return _CommunityProjectProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CommunityProjectProvider &&
        other.projectId == projectId &&
        other.includeData == includeData;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);
    hash = _SystemHash.combine(hash, includeData.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CommunityProjectRef on AutoDisposeAsyncNotifierProviderRef<ApiProject> {
  /// The parameter `projectId` of this provider.
  int get projectId;

  /// The parameter `includeData` of this provider.
  bool get includeData;
}

class _CommunityProjectProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<CommunityProject,
        ApiProject> with CommunityProjectRef {
  _CommunityProjectProviderElement(super.provider);

  @override
  int get projectId => (origin as CommunityProjectProvider).projectId;
  @override
  bool get includeData => (origin as CommunityProjectProvider).includeData;
}

String _$projectCommentsHash() => r'fbdcc5d4879f6d194191128c92ca88aef9da9b3d';

abstract class _$ProjectComments
    extends BuildlessAutoDisposeAsyncNotifier<List<ApiComment>> {
  late final int projectId;

  FutureOr<List<ApiComment>> build(
    int projectId,
  );
}

/// See also [ProjectComments].
@ProviderFor(ProjectComments)
const projectCommentsProvider = ProjectCommentsFamily();

/// See also [ProjectComments].
class ProjectCommentsFamily extends Family<AsyncValue<List<ApiComment>>> {
  /// See also [ProjectComments].
  const ProjectCommentsFamily();

  /// See also [ProjectComments].
  ProjectCommentsProvider call(
    int projectId,
  ) {
    return ProjectCommentsProvider(
      projectId,
    );
  }

  @override
  ProjectCommentsProvider getProviderOverride(
    covariant ProjectCommentsProvider provider,
  ) {
    return call(
      provider.projectId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'projectCommentsProvider';
}

/// See also [ProjectComments].
class ProjectCommentsProvider extends AutoDisposeAsyncNotifierProviderImpl<
    ProjectComments, List<ApiComment>> {
  /// See also [ProjectComments].
  ProjectCommentsProvider(
    int projectId,
  ) : this._internal(
          () => ProjectComments()..projectId = projectId,
          from: projectCommentsProvider,
          name: r'projectCommentsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$projectCommentsHash,
          dependencies: ProjectCommentsFamily._dependencies,
          allTransitiveDependencies:
              ProjectCommentsFamily._allTransitiveDependencies,
          projectId: projectId,
        );

  ProjectCommentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.projectId,
  }) : super.internal();

  final int projectId;

  @override
  FutureOr<List<ApiComment>> runNotifierBuild(
    covariant ProjectComments notifier,
  ) {
    return notifier.build(
      projectId,
    );
  }

  @override
  Override overrideWith(ProjectComments Function() create) {
    return ProviderOverride(
      origin: this,
      override: ProjectCommentsProvider._internal(
        () => create()..projectId = projectId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        projectId: projectId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ProjectComments, List<ApiComment>>
      createElement() {
    return _ProjectCommentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProjectCommentsProvider && other.projectId == projectId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, projectId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ProjectCommentsRef
    on AutoDisposeAsyncNotifierProviderRef<List<ApiComment>> {
  /// The parameter `projectId` of this provider.
  int get projectId;
}

class _ProjectCommentsProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ProjectComments,
        List<ApiComment>> with ProjectCommentsRef {
  _ProjectCommentsProviderElement(super.provider);

  @override
  int get projectId => (origin as ProjectCommentsProvider).projectId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
