// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'community_projects_providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CommunityProjectsState {
  List<ApiProject> get projects => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingMore => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  int get currentPage => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  ProjectFilters get filters => throw _privateConstructorUsedError;
  List<ApiTag> get popularTags => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CommunityProjectsStateCopyWith<CommunityProjectsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommunityProjectsStateCopyWith<$Res> {
  factory $CommunityProjectsStateCopyWith(CommunityProjectsState value,
          $Res Function(CommunityProjectsState) then) =
      _$CommunityProjectsStateCopyWithImpl<$Res, CommunityProjectsState>;
  @useResult
  $Res call(
      {List<ApiProject> projects,
      bool isLoading,
      bool isLoadingMore,
      bool hasMore,
      int currentPage,
      String? error,
      ProjectFilters filters,
      List<ApiTag> popularTags});

  $ProjectFiltersCopyWith<$Res> get filters;
}

/// @nodoc
class _$CommunityProjectsStateCopyWithImpl<$Res,
        $Val extends CommunityProjectsState>
    implements $CommunityProjectsStateCopyWith<$Res> {
  _$CommunityProjectsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? projects = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? currentPage = null,
    Object? error = freezed,
    Object? filters = null,
    Object? popularTags = null,
  }) {
    return _then(_value.copyWith(
      projects: null == projects
          ? _value.projects
          : projects // ignore: cast_nullable_to_non_nullable
              as List<ApiProject>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as ProjectFilters,
      popularTags: null == popularTags
          ? _value.popularTags
          : popularTags // ignore: cast_nullable_to_non_nullable
              as List<ApiTag>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ProjectFiltersCopyWith<$Res> get filters {
    return $ProjectFiltersCopyWith<$Res>(_value.filters, (value) {
      return _then(_value.copyWith(filters: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommunityProjectsStateImplCopyWith<$Res>
    implements $CommunityProjectsStateCopyWith<$Res> {
  factory _$$CommunityProjectsStateImplCopyWith(
          _$CommunityProjectsStateImpl value,
          $Res Function(_$CommunityProjectsStateImpl) then) =
      __$$CommunityProjectsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ApiProject> projects,
      bool isLoading,
      bool isLoadingMore,
      bool hasMore,
      int currentPage,
      String? error,
      ProjectFilters filters,
      List<ApiTag> popularTags});

  @override
  $ProjectFiltersCopyWith<$Res> get filters;
}

/// @nodoc
class __$$CommunityProjectsStateImplCopyWithImpl<$Res>
    extends _$CommunityProjectsStateCopyWithImpl<$Res,
        _$CommunityProjectsStateImpl>
    implements _$$CommunityProjectsStateImplCopyWith<$Res> {
  __$$CommunityProjectsStateImplCopyWithImpl(
      _$CommunityProjectsStateImpl _value,
      $Res Function(_$CommunityProjectsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? projects = null,
    Object? isLoading = null,
    Object? isLoadingMore = null,
    Object? hasMore = null,
    Object? currentPage = null,
    Object? error = freezed,
    Object? filters = null,
    Object? popularTags = null,
  }) {
    return _then(_$CommunityProjectsStateImpl(
      projects: null == projects
          ? _value._projects
          : projects // ignore: cast_nullable_to_non_nullable
              as List<ApiProject>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingMore: null == isLoadingMore
          ? _value.isLoadingMore
          : isLoadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      currentPage: null == currentPage
          ? _value.currentPage
          : currentPage // ignore: cast_nullable_to_non_nullable
              as int,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      filters: null == filters
          ? _value.filters
          : filters // ignore: cast_nullable_to_non_nullable
              as ProjectFilters,
      popularTags: null == popularTags
          ? _value._popularTags
          : popularTags // ignore: cast_nullable_to_non_nullable
              as List<ApiTag>,
    ));
  }
}

/// @nodoc

class _$CommunityProjectsStateImpl implements _CommunityProjectsState {
  const _$CommunityProjectsStateImpl(
      {final List<ApiProject> projects = const [],
      this.isLoading = false,
      this.isLoadingMore = false,
      this.hasMore = false,
      this.currentPage = 1,
      this.error,
      this.filters = const ProjectFilters(),
      final List<ApiTag> popularTags = const []})
      : _projects = projects,
        _popularTags = popularTags;

  final List<ApiProject> _projects;
  @override
  @JsonKey()
  List<ApiProject> get projects {
    if (_projects is EqualUnmodifiableListView) return _projects;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_projects);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingMore;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final int currentPage;
  @override
  final String? error;
  @override
  @JsonKey()
  final ProjectFilters filters;
  final List<ApiTag> _popularTags;
  @override
  @JsonKey()
  List<ApiTag> get popularTags {
    if (_popularTags is EqualUnmodifiableListView) return _popularTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_popularTags);
  }

  @override
  String toString() {
    return 'CommunityProjectsState(projects: $projects, isLoading: $isLoading, isLoadingMore: $isLoadingMore, hasMore: $hasMore, currentPage: $currentPage, error: $error, filters: $filters, popularTags: $popularTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommunityProjectsStateImpl &&
            const DeepCollectionEquality().equals(other._projects, _projects) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingMore, isLoadingMore) ||
                other.isLoadingMore == isLoadingMore) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.currentPage, currentPage) ||
                other.currentPage == currentPage) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.filters, filters) || other.filters == filters) &&
            const DeepCollectionEquality()
                .equals(other._popularTags, _popularTags));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_projects),
      isLoading,
      isLoadingMore,
      hasMore,
      currentPage,
      error,
      filters,
      const DeepCollectionEquality().hash(_popularTags));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommunityProjectsStateImplCopyWith<_$CommunityProjectsStateImpl>
      get copyWith => __$$CommunityProjectsStateImplCopyWithImpl<
          _$CommunityProjectsStateImpl>(this, _$identity);
}

abstract class _CommunityProjectsState implements CommunityProjectsState {
  const factory _CommunityProjectsState(
      {final List<ApiProject> projects,
      final bool isLoading,
      final bool isLoadingMore,
      final bool hasMore,
      final int currentPage,
      final String? error,
      final ProjectFilters filters,
      final List<ApiTag> popularTags}) = _$CommunityProjectsStateImpl;

  @override
  List<ApiProject> get projects;
  @override
  bool get isLoading;
  @override
  bool get isLoadingMore;
  @override
  bool get hasMore;
  @override
  int get currentPage;
  @override
  String? get error;
  @override
  ProjectFilters get filters;
  @override
  List<ApiTag> get popularTags;
  @override
  @JsonKey(ignore: true)
  _$$CommunityProjectsStateImplCopyWith<_$CommunityProjectsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
