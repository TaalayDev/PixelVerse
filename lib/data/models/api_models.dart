import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_models.freezed.dart';

@freezed
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    T? data,
    String? error,
    dynamic details,
    required int timestamp,
  }) = _ApiResponse<T>;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}
