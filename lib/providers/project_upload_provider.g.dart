// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$projectUploadHash() => r'ede3cdc471b5c2233e6cd992bc8722b0701b0518';

/// See also [ProjectUpload].
@ProviderFor(ProjectUpload)
final projectUploadProvider =
    AutoDisposeNotifierProvider<ProjectUpload, ProjectUploadState>.internal(
  ProjectUpload.new,
  name: r'projectUploadProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$projectUploadHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ProjectUpload = AutoDisposeNotifier<ProjectUploadState>;
String _$popularProjectTagsHash() =>
    r'0908e9ee767ebc920215bc0d71ea2acc887e5ee4';

/// See also [PopularProjectTags].
@ProviderFor(PopularProjectTags)
final popularProjectTagsProvider =
    AutoDisposeAsyncNotifierProvider<PopularProjectTags, List<ApiTag>>.internal(
  PopularProjectTags.new,
  name: r'popularProjectTagsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$popularProjectTagsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PopularProjectTags = AutoDisposeAsyncNotifier<List<ApiTag>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
