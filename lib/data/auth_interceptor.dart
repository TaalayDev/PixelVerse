import 'dart:io';

import 'package:dio/dio.dart';

import 'storage/local_storage.dart';

class AuthInterceptor extends Interceptor {
  final LocalStorage _localStorage;
  final Function()? onUnauthorized;

  int _refreshRetryCount = 0;

  AuthInterceptor(this._localStorage, {this.onUnauthorized});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_localStorage.token != null && options.headers[HttpHeaders.authorizationHeader] == null) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer ${_localStorage.token}';
    }

    return handler.next(options);
  }

  @override
  void onError(DioError error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 401) {
      if (_refreshRetryCount >= 1) {
        _refreshRetryCount = 0;
        return handler.next(error);
      }

      try {
        _refreshRetryCount++;
        final dio = Dio(BaseOptions(baseUrl: error.requestOptions.baseUrl));
        final refreshed = await _refreshToken(dio, _localStorage);
        if (refreshed) {
          // Retry the original request
          final options = error.requestOptions;
          options.headers['Authorization'] = 'Bearer ${_localStorage.token}';
          final response = await dio.fetch(options);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        print('Token refresh failed: $e');
        // Refresh failed, clear token and proceed with error
        _localStorage.clearToken();
      }
    }
    handler.next(error);
  }

  static Future<bool> _refreshToken(Dio dio, LocalStorage storage) async {
    try {
      final response = await dio.post('/api/v1/auth/refresh');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final newToken = response.data['data']['token'];
        storage.setToken(newToken);
        return true;
      }
    } catch (e) {
      // Refresh failed
    }
    return false;
  }
}
