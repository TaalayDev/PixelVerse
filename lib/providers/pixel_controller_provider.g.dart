// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pixel_controller_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pixelDrawNotifierHash() => r'a8b6eb8f64d9a4906c1f20349202a45acf5fdd81';

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
  late final int width;
  late final int height;

  PixelDrawState build({
    int width = 32,
    int height = 32,
  });
}

/// See also [PixelDrawNotifier].
@ProviderFor(PixelDrawNotifier)
const pixelDrawNotifierProvider = PixelDrawNotifierFamily();

/// See also [PixelDrawNotifier].
class PixelDrawNotifierFamily extends Family<PixelDrawState> {
  /// See also [PixelDrawNotifier].
  const PixelDrawNotifierFamily();

  /// See also [PixelDrawNotifier].
  PixelDrawNotifierProvider call({
    int width = 32,
    int height = 32,
  }) {
    return PixelDrawNotifierProvider(
      width: width,
      height: height,
    );
  }

  @override
  PixelDrawNotifierProvider getProviderOverride(
    covariant PixelDrawNotifierProvider provider,
  ) {
    return call(
      width: provider.width,
      height: provider.height,
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
  PixelDrawNotifierProvider({
    int width = 32,
    int height = 32,
  }) : this._internal(
          () => PixelDrawNotifier()
            ..width = width
            ..height = height,
          from: pixelDrawNotifierProvider,
          name: r'pixelDrawNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$pixelDrawNotifierHash,
          dependencies: PixelDrawNotifierFamily._dependencies,
          allTransitiveDependencies:
              PixelDrawNotifierFamily._allTransitiveDependencies,
          width: width,
          height: height,
        );

  PixelDrawNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.width,
    required this.height,
  }) : super.internal();

  final int width;
  final int height;

  @override
  PixelDrawState runNotifierBuild(
    covariant PixelDrawNotifier notifier,
  ) {
    return notifier.build(
      width: width,
      height: height,
    );
  }

  @override
  Override overrideWith(PixelDrawNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: PixelDrawNotifierProvider._internal(
        () => create()
          ..width = width
          ..height = height,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        width: width,
        height: height,
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
    return other is PixelDrawNotifierProvider &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, width.hashCode);
    hash = _SystemHash.combine(hash, height.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PixelDrawNotifierRef on AutoDisposeNotifierProviderRef<PixelDrawState> {
  /// The parameter `width` of this provider.
  int get width;

  /// The parameter `height` of this provider.
  int get height;
}

class _PixelDrawNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<PixelDrawNotifier,
        PixelDrawState> with PixelDrawNotifierRef {
  _PixelDrawNotifierProviderElement(super.provider);

  @override
  int get width => (origin as PixelDrawNotifierProvider).width;
  @override
  int get height => (origin as PixelDrawNotifierProvider).height;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
