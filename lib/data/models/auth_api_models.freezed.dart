// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_api_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) {
  return _AuthResponse.fromJson(json);
}

/// @nodoc
mixin _$AuthResponse {
  String get message => throw _privateConstructorUsedError;
  ApiUser get user => throw _privateConstructorUsedError;
  String get token => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AuthResponseCopyWith<AuthResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseCopyWith<$Res> {
  factory $AuthResponseCopyWith(
          AuthResponse value, $Res Function(AuthResponse) then) =
      _$AuthResponseCopyWithImpl<$Res, AuthResponse>;
  @useResult
  $Res call({String message, ApiUser user, String token});

  $ApiUserCopyWith<$Res> get user;
}

/// @nodoc
class _$AuthResponseCopyWithImpl<$Res, $Val extends AuthResponse>
    implements $AuthResponseCopyWith<$Res> {
  _$AuthResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? user = null,
    Object? token = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as ApiUser,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ApiUserCopyWith<$Res> get user {
    return $ApiUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseImplCopyWith<$Res>
    implements $AuthResponseCopyWith<$Res> {
  factory _$$AuthResponseImplCopyWith(
          _$AuthResponseImpl value, $Res Function(_$AuthResponseImpl) then) =
      __$$AuthResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, ApiUser user, String token});

  @override
  $ApiUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$AuthResponseImplCopyWithImpl<$Res>
    extends _$AuthResponseCopyWithImpl<$Res, _$AuthResponseImpl>
    implements _$$AuthResponseImplCopyWith<$Res> {
  __$$AuthResponseImplCopyWithImpl(
      _$AuthResponseImpl _value, $Res Function(_$AuthResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? user = null,
    Object? token = null,
  }) {
    return _then(_$AuthResponseImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as ApiUser,
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseImpl implements _AuthResponse {
  const _$AuthResponseImpl(
      {required this.message, required this.user, required this.token});

  factory _$AuthResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseImplFromJson(json);

  @override
  final String message;
  @override
  final ApiUser user;
  @override
  final String token;

  @override
  String toString() {
    return 'AuthResponse(message: $message, user: $user, token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message, user, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      __$$AuthResponseImplCopyWithImpl<_$AuthResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseImplToJson(
      this,
    );
  }
}

abstract class _AuthResponse implements AuthResponse {
  const factory _AuthResponse(
      {required final String message,
      required final ApiUser user,
      required final String token}) = _$AuthResponseImpl;

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =
      _$AuthResponseImpl.fromJson;

  @override
  String get message;
  @override
  ApiUser get user;
  @override
  String get token;
  @override
  @JsonKey(ignore: true)
  _$$AuthResponseImplCopyWith<_$AuthResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiUser _$ApiUserFromJson(Map<String, dynamic> json) {
  return _ApiUser.fromJson(json);
}

/// @nodoc
mixin _$ApiUser {
  int get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String? get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
  bool get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime? get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'followers_count')
  int get followersCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'following_count')
  int get followingCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'public_projects_count')
  int get publicProjectsCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
  bool? get isFollowing => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApiUserCopyWith<ApiUser> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiUserCopyWith<$Res> {
  factory $ApiUserCopyWith(ApiUser value, $Res Function(ApiUser) then) =
      _$ApiUserCopyWithImpl<$Res, ApiUser>;
  @useResult
  $Res call(
      {int id,
      String username,
      @JsonKey(name: 'display_name') String? displayName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? bio,
      @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
      bool isVerified,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'followers_count') int followersCount,
      @JsonKey(name: 'following_count') int followingCount,
      @JsonKey(name: 'public_projects_count') int publicProjectsCount,
      @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
      bool? isFollowing});
}

/// @nodoc
class _$ApiUserCopyWithImpl<$Res, $Val extends ApiUser>
    implements $ApiUserCopyWith<$Res> {
  _$ApiUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? isVerified = null,
    Object? createdAt = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? publicProjectsCount = null,
    Object? isFollowing = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      publicProjectsCount: null == publicProjectsCount
          ? _value.publicProjectsCount
          : publicProjectsCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: freezed == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ApiUserImplCopyWith<$Res> implements $ApiUserCopyWith<$Res> {
  factory _$$ApiUserImplCopyWith(
          _$ApiUserImpl value, $Res Function(_$ApiUserImpl) then) =
      __$$ApiUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String username,
      @JsonKey(name: 'display_name') String? displayName,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      String? bio,
      @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
      bool isVerified,
      @JsonKey(name: 'created_at') DateTime? createdAt,
      @JsonKey(name: 'followers_count') int followersCount,
      @JsonKey(name: 'following_count') int followingCount,
      @JsonKey(name: 'public_projects_count') int publicProjectsCount,
      @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
      bool? isFollowing});
}

/// @nodoc
class __$$ApiUserImplCopyWithImpl<$Res>
    extends _$ApiUserCopyWithImpl<$Res, _$ApiUserImpl>
    implements _$$ApiUserImplCopyWith<$Res> {
  __$$ApiUserImplCopyWithImpl(
      _$ApiUserImpl _value, $Res Function(_$ApiUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? bio = freezed,
    Object? isVerified = null,
    Object? createdAt = freezed,
    Object? followersCount = null,
    Object? followingCount = null,
    Object? publicProjectsCount = null,
    Object? isFollowing = freezed,
  }) {
    return _then(_$ApiUserImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: freezed == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: null == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followersCount: null == followersCount
          ? _value.followersCount
          : followersCount // ignore: cast_nullable_to_non_nullable
              as int,
      followingCount: null == followingCount
          ? _value.followingCount
          : followingCount // ignore: cast_nullable_to_non_nullable
              as int,
      publicProjectsCount: null == publicProjectsCount
          ? _value.publicProjectsCount
          : publicProjectsCount // ignore: cast_nullable_to_non_nullable
              as int,
      isFollowing: freezed == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiUserImpl implements _ApiUser {
  const _$ApiUserImpl(
      {required this.id,
      required this.username,
      @JsonKey(name: 'display_name') this.displayName,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      this.bio,
      @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
      this.isVerified = false,
      @JsonKey(name: 'created_at') this.createdAt,
      @JsonKey(name: 'followers_count') this.followersCount = 0,
      @JsonKey(name: 'following_count') this.followingCount = 0,
      @JsonKey(name: 'public_projects_count') this.publicProjectsCount = 0,
      @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
      this.isFollowing});

  factory _$ApiUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiUserImplFromJson(json);

  @override
  final int id;
  @override
  final String username;
  @override
  @JsonKey(name: 'display_name')
  final String? displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final String? bio;
  @override
  @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
  final bool isVerified;
  @override
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @override
  @JsonKey(name: 'followers_count')
  final int followersCount;
  @override
  @JsonKey(name: 'following_count')
  final int followingCount;
  @override
  @JsonKey(name: 'public_projects_count')
  final int publicProjectsCount;
  @override
  @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
  final bool? isFollowing;

  @override
  String toString() {
    return 'ApiUser(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, bio: $bio, isVerified: $isVerified, createdAt: $createdAt, followersCount: $followersCount, followingCount: $followingCount, publicProjectsCount: $publicProjectsCount, isFollowing: $isFollowing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.followersCount, followersCount) ||
                other.followersCount == followersCount) &&
            (identical(other.followingCount, followingCount) ||
                other.followingCount == followingCount) &&
            (identical(other.publicProjectsCount, publicProjectsCount) ||
                other.publicProjectsCount == publicProjectsCount) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      username,
      displayName,
      avatarUrl,
      bio,
      isVerified,
      createdAt,
      followersCount,
      followingCount,
      publicProjectsCount,
      isFollowing);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiUserImplCopyWith<_$ApiUserImpl> get copyWith =>
      __$$ApiUserImplCopyWithImpl<_$ApiUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiUserImplToJson(
      this,
    );
  }
}

abstract class _ApiUser implements ApiUser {
  const factory _ApiUser(
      {required final int id,
      required final String username,
      @JsonKey(name: 'display_name') final String? displayName,
      @JsonKey(name: 'avatar_url') final String? avatarUrl,
      final String? bio,
      @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
      final bool isVerified,
      @JsonKey(name: 'created_at') final DateTime? createdAt,
      @JsonKey(name: 'followers_count') final int followersCount,
      @JsonKey(name: 'following_count') final int followingCount,
      @JsonKey(name: 'public_projects_count') final int publicProjectsCount,
      @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
      final bool? isFollowing}) = _$ApiUserImpl;

  factory _ApiUser.fromJson(Map<String, dynamic> json) = _$ApiUserImpl.fromJson;

  @override
  int get id;
  @override
  String get username;
  @override
  @JsonKey(name: 'display_name')
  String? get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  String? get bio;
  @override
  @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson)
  bool get isVerified;
  @override
  @JsonKey(name: 'created_at')
  DateTime? get createdAt;
  @override
  @JsonKey(name: 'followers_count')
  int get followersCount;
  @override
  @JsonKey(name: 'following_count')
  int get followingCount;
  @override
  @JsonKey(name: 'public_projects_count')
  int get publicProjectsCount;
  @override
  @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson)
  bool? get isFollowing;
  @override
  @JsonKey(ignore: true)
  _$$ApiUserImplCopyWith<_$ApiUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProfileUpdateResponse _$ProfileUpdateResponseFromJson(
    Map<String, dynamic> json) {
  return _ProfileUpdateResponse.fromJson(json);
}

/// @nodoc
mixin _$ProfileUpdateResponse {
  String get message => throw _privateConstructorUsedError;
  ApiUser get user => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ProfileUpdateResponseCopyWith<ProfileUpdateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileUpdateResponseCopyWith<$Res> {
  factory $ProfileUpdateResponseCopyWith(ProfileUpdateResponse value,
          $Res Function(ProfileUpdateResponse) then) =
      _$ProfileUpdateResponseCopyWithImpl<$Res, ProfileUpdateResponse>;
  @useResult
  $Res call({String message, ApiUser user});

  $ApiUserCopyWith<$Res> get user;
}

/// @nodoc
class _$ProfileUpdateResponseCopyWithImpl<$Res,
        $Val extends ProfileUpdateResponse>
    implements $ProfileUpdateResponseCopyWith<$Res> {
  _$ProfileUpdateResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? user = null,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as ApiUser,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ApiUserCopyWith<$Res> get user {
    return $ApiUserCopyWith<$Res>(_value.user, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ProfileUpdateResponseImplCopyWith<$Res>
    implements $ProfileUpdateResponseCopyWith<$Res> {
  factory _$$ProfileUpdateResponseImplCopyWith(
          _$ProfileUpdateResponseImpl value,
          $Res Function(_$ProfileUpdateResponseImpl) then) =
      __$$ProfileUpdateResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message, ApiUser user});

  @override
  $ApiUserCopyWith<$Res> get user;
}

/// @nodoc
class __$$ProfileUpdateResponseImplCopyWithImpl<$Res>
    extends _$ProfileUpdateResponseCopyWithImpl<$Res,
        _$ProfileUpdateResponseImpl>
    implements _$$ProfileUpdateResponseImplCopyWith<$Res> {
  __$$ProfileUpdateResponseImplCopyWithImpl(_$ProfileUpdateResponseImpl _value,
      $Res Function(_$ProfileUpdateResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? user = null,
  }) {
    return _then(_$ProfileUpdateResponseImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as ApiUser,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileUpdateResponseImpl implements _ProfileUpdateResponse {
  const _$ProfileUpdateResponseImpl(
      {required this.message, required this.user});

  factory _$ProfileUpdateResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileUpdateResponseImplFromJson(json);

  @override
  final String message;
  @override
  final ApiUser user;

  @override
  String toString() {
    return 'ProfileUpdateResponse(message: $message, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileUpdateResponseImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, message, user);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileUpdateResponseImplCopyWith<_$ProfileUpdateResponseImpl>
      get copyWith => __$$ProfileUpdateResponseImplCopyWithImpl<
          _$ProfileUpdateResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileUpdateResponseImplToJson(
      this,
    );
  }
}

abstract class _ProfileUpdateResponse implements ProfileUpdateResponse {
  const factory _ProfileUpdateResponse(
      {required final String message,
      required final ApiUser user}) = _$ProfileUpdateResponseImpl;

  factory _ProfileUpdateResponse.fromJson(Map<String, dynamic> json) =
      _$ProfileUpdateResponseImpl.fromJson;

  @override
  String get message;
  @override
  ApiUser get user;
  @override
  @JsonKey(ignore: true)
  _$$ProfileUpdateResponseImplCopyWith<_$ProfileUpdateResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}

RefreshTokenResponse _$RefreshTokenResponseFromJson(Map<String, dynamic> json) {
  return _RefreshTokenResponse.fromJson(json);
}

/// @nodoc
mixin _$RefreshTokenResponse {
  String get token => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RefreshTokenResponseCopyWith<RefreshTokenResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefreshTokenResponseCopyWith<$Res> {
  factory $RefreshTokenResponseCopyWith(RefreshTokenResponse value,
          $Res Function(RefreshTokenResponse) then) =
      _$RefreshTokenResponseCopyWithImpl<$Res, RefreshTokenResponse>;
  @useResult
  $Res call({String token});
}

/// @nodoc
class _$RefreshTokenResponseCopyWithImpl<$Res,
        $Val extends RefreshTokenResponse>
    implements $RefreshTokenResponseCopyWith<$Res> {
  _$RefreshTokenResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RefreshTokenResponseImplCopyWith<$Res>
    implements $RefreshTokenResponseCopyWith<$Res> {
  factory _$$RefreshTokenResponseImplCopyWith(_$RefreshTokenResponseImpl value,
          $Res Function(_$RefreshTokenResponseImpl) then) =
      __$$RefreshTokenResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token});
}

/// @nodoc
class __$$RefreshTokenResponseImplCopyWithImpl<$Res>
    extends _$RefreshTokenResponseCopyWithImpl<$Res, _$RefreshTokenResponseImpl>
    implements _$$RefreshTokenResponseImplCopyWith<$Res> {
  __$$RefreshTokenResponseImplCopyWithImpl(_$RefreshTokenResponseImpl _value,
      $Res Function(_$RefreshTokenResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_$RefreshTokenResponseImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RefreshTokenResponseImpl implements _RefreshTokenResponse {
  const _$RefreshTokenResponseImpl({required this.token});

  factory _$RefreshTokenResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$RefreshTokenResponseImplFromJson(json);

  @override
  final String token;

  @override
  String toString() {
    return 'RefreshTokenResponse(token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshTokenResponseImpl &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshTokenResponseImplCopyWith<_$RefreshTokenResponseImpl>
      get copyWith =>
          __$$RefreshTokenResponseImplCopyWithImpl<_$RefreshTokenResponseImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RefreshTokenResponseImplToJson(
      this,
    );
  }
}

abstract class _RefreshTokenResponse implements RefreshTokenResponse {
  const factory _RefreshTokenResponse({required final String token}) =
      _$RefreshTokenResponseImpl;

  factory _RefreshTokenResponse.fromJson(Map<String, dynamic> json) =
      _$RefreshTokenResponseImpl.fromJson;

  @override
  String get token;
  @override
  @JsonKey(ignore: true)
  _$$RefreshTokenResponseImplCopyWith<_$RefreshTokenResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
