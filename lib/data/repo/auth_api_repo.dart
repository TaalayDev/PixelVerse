import 'package:logging/logging.dart';

import '../../core/utils/api_client.dart';
import '../models/api_models.dart';
import '../models/auth_api_models.dart';
import '../models/project_api_models.dart';
import '../storage/local_storage.dart';

class AuthAPIRepo {
  final ApiClient _apiClient;
  final LocalStorage _localStorage;
  final Logger _logger = Logger('AuthRepository');

  AuthAPIRepo(this._apiClient, this._localStorage);

  /// Register a new user
  Future<ApiResponse<AuthResponse>> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final data = {
        'username': username,
        'email': email,
        'password': password,
        if (displayName != null) 'display_name': displayName,
      };

      final response = await _apiClient.post<AuthResponse>(
        '/api/v1/auth/register',
        data: data,
        converter: AuthConverters.authResponse,
      );

      // Save token if registration successful
      if (response.data?.token != null) {
        _localStorage.setToken(response.data!.token);
      }

      return response;
    } catch (e) {
      _logger.severe('Error registering user: $e');
      rethrow;
    }
  }

  /// Login user
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    try {
      final data = {
        'username': username,
        'password': password,
      };

      final response = await _apiClient.post<AuthResponse>(
        '/api/v1/auth/login',
        data: data,
        converter: AuthConverters.authResponse,
      );

      // Save token if login successful
      if (response.data?.token != null) {
        _localStorage.setToken(response.data!.token);
      }

      return response;
    } catch (e) {
      _logger.severe('Error logging in user: $e');
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      _localStorage.clearToken();
      _logger.info('User logged out successfully');
    } catch (e) {
      _logger.severe('Error logging out user: $e');
      rethrow;
    }
  }

  /// Get current user profile
  Future<ApiResponse<ApiUser>> getProfile() async {
    try {
      return await _apiClient.get<ApiUser>(
        '/api/v1/auth/profile',
        converter: AuthConverters.user,
      );
    } catch (e) {
      _logger.severe('Error getting user profile: $e');
      rethrow;
    }
  }

  /// Update user profile
  Future<ApiResponse<ProfileUpdateResponse>> updateProfile({
    String? displayName,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (displayName != null) data['display_name'] = displayName;
      if (bio != null) data['bio'] = bio;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;

      return await _apiClient.put<ProfileUpdateResponse>(
        '/api/v1/auth/profile',
        data: data,
        converter: AuthConverters.profileUpdateResponse,
      );
    } catch (e) {
      _logger.severe('Error updating profile: $e');
      rethrow;
    }
  }

  /// Change password
  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final data = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };

      return await _apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/change-password',
        data: data,
        converter: ProjectConverters.simpleMap,
      );
    } catch (e) {
      _logger.severe('Error changing password: $e');
      rethrow;
    }
  }

  /// Refresh JWT token
  Future<ApiResponse<RefreshTokenResponse>> refreshToken() async {
    try {
      final response = await _apiClient.post<RefreshTokenResponse>(
        '/api/v1/auth/refresh',
        converter: AuthConverters.refreshTokenResponse,
      );

      // Update stored token
      if (response.data?.token != null) {
        _localStorage.setToken(response.data!.token);
      }

      return response;
    } catch (e) {
      _logger.severe('Error refreshing token: $e');
      rethrow;
    }
  }

  Future<ApiResponse<AuthResponse>> loginWithGoogle({
    required String idToken,
    required String email,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final data = {
        'id_token': idToken,
        'email': email,
        'display_name': displayName,
        'photo_url': photoUrl,
      };

      final response = await _apiClient.post<AuthResponse>(
        '/api/v1/auth/google',
        data: data,
        converter: AuthConverters.authResponse,
      );

      // Save token if login successful
      if (response.data?.token != null) {
        _localStorage.setToken(response.data!.token);
      }

      return response;
    } catch (e) {
      _logger.severe('Error logging in with Google: $e');
      rethrow;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteAccount() async {
    try {
      return await _apiClient.delete<Map<String, dynamic>>(
        '/api/v1/auth/account',
        converter: (data) => data as Map<String, dynamic>,
      );
    } catch (e) {
      _logger.severe('Error deleting account: $e');
      rethrow;
    }
  }

  /// Check if user is logged in
  bool get isLoggedIn => _localStorage.token != null;

  /// Get stored auth token
  String? get token => _localStorage.token;
}
