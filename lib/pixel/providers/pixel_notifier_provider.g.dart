// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pixel_notifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pixelDrawNotifierHash() => r'498b0c98bb852287e2de5b6d74a9ab4298da1413';

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

abstract class _$PixelDrawNotifier
    extends BuildlessAutoDisposeNotifier<PixelDrawState> {
  late final Project project;

  PixelDrawState build(
    Project project,
  );
}

/// See also [PixelDrawNotifier].
@ProviderFor(PixelDrawNotifier)
const pixelDrawNotifierProvider = PixelDrawNotifierFamily();

/// See also [PixelDrawNotifier].
class PixelDrawNotifierFamily extends Family<PixelDrawState> {
  /// See also [PixelDrawNotifier].
  const PixelDrawNotifierFamily();

  /// See also [PixelDrawNotifier].
  PixelDrawNotifierProvider call(
    Project project,
  ) {
    return PixelDrawNotifierProvider(
      project,
    );
  }

  @override
  PixelDrawNotifierProvider getProviderOverride(
    covariant PixelDrawNotifierProvider provider,
  ) {
    return call(
      provider.project,
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
  String? get name => r'pixelDrawNotifierProvider';
}

/// See also [PixelDrawNotifier].
class PixelDrawNotifierProvider
    extends AutoDisposeNotifierProviderImpl<PixelDrawNotifier, PixelDrawState> {
  /// See also [PixelDrawNotifier].
  PixelDrawNotifierProvider(
    Project project,
  ) : this._internal(
          () => PixelDrawNotifier()..project = project,
          from: pixelDrawNotifierProvider,
          name: r'pixelDrawNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pixelDrawNotifierHash,
          dependencies: PixelDrawNotifierFamily._dependencies,
          allTransitiveDependencies:
              PixelDrawNotifierFamily._allTransitiveDependencies,
          project: project,
        );

  PixelDrawNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.project,
  }) : super.internal();

  final Project project;

  @override
  PixelDrawState runNotifierBuild(
    covariant PixelDrawNotifier notifier,
  ) {
    return notifier.build(
      project,
    );
  }

  @override
  Override overrideWith(PixelDrawNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PixelDrawNotifierProvider._internal(
        () => create()..project = project,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        project: project,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<PixelDrawNotifier, PixelDrawState>
      createElement() {
    return _PixelDrawNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PixelDrawNotifierProvider && other.project == project;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, project.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PixelDrawNotifierRef on AutoDisposeNotifierProviderRef<PixelDrawState> {
  /// The parameter `project` of this provider.
  Project get project;
}

class _PixelDrawNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<PixelDrawNotifier,
        PixelDrawState> with PixelDrawNotifierRef {
  _PixelDrawNotifierProviderElement(super.provider);

  @override
  Project get project => (origin as PixelDrawNotifierProvider).project;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
