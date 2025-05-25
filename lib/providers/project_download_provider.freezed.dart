// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_download_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProjectDownloadState {
  bool get isDownloading => throw _privateConstructorUsedError;
  double get downloadProgress => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isSuccess => throw _privateConstructorUsedError;
  Project? get downloadedProject => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ProjectDownloadStateCopyWith<ProjectDownloadState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectDownloadStateCopyWith<$Res> {
  factory $ProjectDownloadStateCopyWith(ProjectDownloadState value,
          $Res Function(ProjectDownloadState) then) =
      _$ProjectDownloadStateCopyWithImpl<$Res, ProjectDownloadState>;
  @useResult
  $Res call(
      {bool isDownloading,
      double downloadProgress,
      String? error,
      bool isSuccess,
      Project? downloadedProject});
}

/// @nodoc
class _$ProjectDownloadStateCopyWithImpl<$Res,
        $Val extends ProjectDownloadState>
    implements $ProjectDownloadStateCopyWith<$Res> {
  _$ProjectDownloadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDownloading = null,
    Object? downloadProgress = null,
    Object? error = freezed,
    Object? isSuccess = null,
    Object? downloadedProject = freezed,
  }) {
    return _then(_value.copyWith(
      isDownloading: null == isDownloading
          ? _value.isDownloading
          : isDownloading // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadProgress: null == downloadProgress
          ? _value.downloadProgress
          : downloadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadedProject: freezed == downloadedProject
          ? _value.downloadedProject
          : downloadedProject // ignore: cast_nullable_to_non_nullable
              as Project?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProjectDownloadStateImplCopyWith<$Res>
    implements $ProjectDownloadStateCopyWith<$Res> {
  factory _$$ProjectDownloadStateImplCopyWith(_$ProjectDownloadStateImpl value,
          $Res Function(_$ProjectDownloadStateImpl) then) =
      __$$ProjectDownloadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isDownloading,
      double downloadProgress,
      String? error,
      bool isSuccess,
      Project? downloadedProject});
}

/// @nodoc
class __$$ProjectDownloadStateImplCopyWithImpl<$Res>
    extends _$ProjectDownloadStateCopyWithImpl<$Res, _$ProjectDownloadStateImpl>
    implements _$$ProjectDownloadStateImplCopyWith<$Res> {
  __$$ProjectDownloadStateImplCopyWithImpl(_$ProjectDownloadStateImpl _value,
      $Res Function(_$ProjectDownloadStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isDownloading = null,
    Object? downloadProgress = null,
    Object? error = freezed,
    Object? isSuccess = null,
    Object? downloadedProject = freezed,
  }) {
    return _then(_$ProjectDownloadStateImpl(
      isDownloading: null == isDownloading
          ? _value.isDownloading
          : isDownloading // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadProgress: null == downloadProgress
          ? _value.downloadProgress
          : downloadProgress // ignore: cast_nullable_to_non_nullable
              as double,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isSuccess: null == isSuccess
          ? _value.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      downloadedProject: freezed == downloadedProject
          ? _value.downloadedProject
          : downloadedProject // ignore: cast_nullable_to_non_nullable
              as Project?,
    ));
  }
}

/// @nodoc

class _$ProjectDownloadStateImpl
    with DiagnosticableTreeMixin
    implements _ProjectDownloadState {
  const _$ProjectDownloadStateImpl(
      {this.isDownloading = false,
      this.downloadProgress = 0.0,
      this.error,
      this.isSuccess = false,
      this.downloadedProject});

  @override
  @JsonKey()
  final bool isDownloading;
  @override
  @JsonKey()
  final double downloadProgress;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final Project? downloadedProject;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ProjectDownloadState(isDownloading: $isDownloading, downloadProgress: $downloadProgress, error: $error, isSuccess: $isSuccess, downloadedProject: $downloadedProject)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ProjectDownloadState'))
      ..add(DiagnosticsProperty('isDownloading', isDownloading))
      ..add(DiagnosticsProperty('downloadProgress', downloadProgress))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isSuccess', isSuccess))
      ..add(DiagnosticsProperty('downloadedProject', downloadedProject));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectDownloadStateImpl &&
            (identical(other.isDownloading, isDownloading) ||
                other.isDownloading == isDownloading) &&
            (identical(other.downloadProgress, downloadProgress) ||
                other.downloadProgress == downloadProgress) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.downloadedProject, downloadedProject) ||
                other.downloadedProject == downloadedProject));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isDownloading, downloadProgress,
      error, isSuccess, downloadedProject);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectDownloadStateImplCopyWith<_$ProjectDownloadStateImpl>
      get copyWith =>
          __$$ProjectDownloadStateImplCopyWithImpl<_$ProjectDownloadStateImpl>(
              this, _$identity);
}

abstract class _ProjectDownloadState implements ProjectDownloadState {
  const factory _ProjectDownloadState(
      {final bool isDownloading,
      final double downloadProgress,
      final String? error,
      final bool isSuccess,
      final Project? downloadedProject}) = _$ProjectDownloadStateImpl;

  @override
  bool get isDownloading;
  @override
  double get downloadProgress;
  @override
  String? get error;
  @override
  bool get isSuccess;
  @override
  Project? get downloadedProject;
  @override
  @JsonKey(ignore: true)
  _$$ProjectDownloadStateImplCopyWith<_$ProjectDownloadStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
