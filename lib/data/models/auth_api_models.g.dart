// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AuthResponseImpl _$$AuthResponseImplFromJson(Map<String, dynamic> json) =>
    _$AuthResponseImpl(
      message: json['message'] as String,
      user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token'] as String,
    );

Map<String, dynamic> _$$AuthResponseImplToJson(_$AuthResponseImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
      'token': instance.token,
    };

_$ApiUserImpl _$$ApiUserImplFromJson(Map<String, dynamic> json) =>
    _$ApiUserImpl(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      isVerified: json['is_verified'] == null
          ? false
          : AuthConverters.boolFromJson(json['is_verified']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      followersCount: (json['followers_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      publicProjectsCount:
          (json['public_projects_count'] as num?)?.toInt() ?? 0,
      isFollowing: AuthConverters.boolFromJson(json['is_following']),
    );

Map<String, dynamic> _$$ApiUserImplToJson(_$ApiUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'bio': instance.bio,
      'is_verified': instance.isVerified,
      'created_at': instance.createdAt?.toIso8601String(),
      'followers_count': instance.followersCount,
      'following_count': instance.followingCount,
      'public_projects_count': instance.publicProjectsCount,
      'is_following': instance.isFollowing,
    };

_$ProfileUpdateResponseImpl _$$ProfileUpdateResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$ProfileUpdateResponseImpl(
      message: json['message'] as String,
      user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ProfileUpdateResponseImplToJson(
        _$ProfileUpdateResponseImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'user': instance.user,
    };

_$RefreshTokenResponseImpl _$$RefreshTokenResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$RefreshTokenResponseImpl(
      token: json['token'] as String,
    );

Map<String, dynamic> _$$RefreshTokenResponseImplToJson(
        _$RefreshTokenResponseImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
    };
