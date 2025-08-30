// lib/core/http_client.dart
import 'package:dio/dio.dart';

Dio makeDio() {
  final base = const String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://bcad3ddmbc.execute-api.us-east-2.amazonaws.com/Prod',
  );
  final dio = Dio(
    BaseOptions(
      baseUrl: base,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}
