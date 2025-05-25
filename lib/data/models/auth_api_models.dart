import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_api_models.freezed.dart';
part 'auth_api_models.g.dart';

@freezed
class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String message,
    required ApiUser user,
    required String token,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

@freezed
abstract class ApiUser with _$ApiUser {
  const factory ApiUser({
    required int id,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'is_verified', fromJson: AuthConverters.boolFromJson) @Default(false) bool isVerified,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'followers_count') @Default(0) int followersCount,
    @JsonKey(name: 'following_count') @Default(0) int followingCount,
    @JsonKey(name: 'public_projects_count') @Default(0) int publicProjectsCount,
    @JsonKey(name: 'is_following', fromJson: AuthConverters.boolFromJson) bool? isFollowing,
  }) = _ApiUser;

  factory ApiUser.fromJson(Map<String, dynamic> json) => _$ApiUserFromJson(json);
}

@freezed
class ProfileUpdateResponse with _$ProfileUpdateResponse {
  const factory ProfileUpdateResponse({
    required String message,
    required ApiUser user,
  }) = _ProfileUpdateResponse;

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) => _$ProfileUpdateResponseFromJson(json);
}

@freezed
class RefreshTokenResponse with _$RefreshTokenResponse {
  const factory RefreshTokenResponse({
    required String token,
  }) = _RefreshTokenResponse;

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) => _$RefreshTokenResponseFromJson(json);
}

// Auth converters
class AuthConverters {
  static AuthResponse authResponse(dynamic data) => AuthResponse.fromJson(data as Map<String, dynamic>);

  static ProfileUpdateResponse profileUpdateResponse(dynamic data) =>
      ProfileUpdateResponse.fromJson(data as Map<String, dynamic>);

  static RefreshTokenResponse refreshTokenResponse(dynamic data) =>
      RefreshTokenResponse.fromJson(data as Map<String, dynamic>);

  static List<ApiUser> usersList(dynamic data) {
    return (data['users'] as List).map((item) => ApiUser.fromJson(item)).toList();
  }

  static ApiUser user(dynamic data) => ApiUser.fromJson(data as Map<String, dynamic>);

  static bool boolFromJson(dynamic data) {
    if (data is bool) {
      return data;
    } else if (data is String) {
      return data.toLowerCase() == 'true';
    } else if (data is int) {
      return data != 0;
    }
    return false;
  }
}
