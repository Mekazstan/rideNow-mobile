import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ridenowappsss/modules/authentication/data/models/auth_models.dart';
import 'package:ridenowappsss/core/utils/constants/api_constant.dart';

class DioClient {
  static const String baseUrl = ApiConstants.baseUrl;

  late final Dio _dio;

  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  // Add this getter to expose the Dio instance
  Dio get dio => _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 50),
        receiveTimeout: const Duration(seconds: 50),
        sendTimeout: const Duration(seconds: 50),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final exception = _handleDioError(error);
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection and try again.',
        );

      case DioExceptionType.sendTimeout:
        return NetworkException(
          'Request timeout. The server is taking too long to respond.',
        );

      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Response timeout. Please check your internet connection.',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection. Please check your network settings and try again.',
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      case DioExceptionType.cancel:
        return NetworkException('Request was cancelled.');

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Security certificate error. Please try again later.',
        );

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true ||
            error.message?.contains('HandshakeException') == true ||
            error.message?.contains('HttpException') == true) {
          return NetworkException(
            'Network error. Please check your internet connection.',
          );
        }
        return NetworkException(
          'An unexpected error occurred. Please try again.',
        );
    }
  }

  Exception _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;
    try {
      if (data is Map<String, dynamic>) {
        String message = _getDefaultHttpErrorMessage(statusCode);
        List<String>? errors;
        String? code;
        if (data.containsKey('message')) {
          final msgData = data['message'];
          if (msgData is List && msgData.isNotEmpty) {
            message = _getUserFriendlyMessage(
              msgData.first.toString(),
              statusCode,
            );
          } else {
            message = _getUserFriendlyMessage(
              msgData.toString(),
              statusCode,
            );
          }
        } else if (data.containsKey('error')) {
          message = _getUserFriendlyMessage(
            data['error'] as String,
            statusCode,
          );
        }

        if (data.containsKey('errors')) {
          if (data['errors'] is List) {
            errors = (data['errors'] as List).cast<String>();
          } else if (data['errors'] is Map) {
            final errorMap = data['errors'] as Map<String, dynamic>;
            errors =
                errorMap.values
                    .expand((value) => value is List ? value : [value])
                    .cast<String>()
                    .toList();
          }
        }

        if (data.containsKey('code')) {
          code = data['code'] as String;
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          errors: errors,
          code: code,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing API response: $e');
      }
    }

    return ApiException(
      message: _getDefaultHttpErrorMessage(statusCode),
      statusCode: statusCode,
    );
  }

  String _getUserFriendlyMessage(String originalMessage, int statusCode) {
    final lowerMessage = originalMessage.toLowerCase();
    if (statusCode == 401) {
      return 'The password you entered is incorrect. Please double-check and try again.';
    }

    if (lowerMessage.contains('invalid credentials') ||
        lowerMessage.contains('unauthorized') ||
        lowerMessage.contains('authentication failed')) {
      return 'The password you entered is incorrect. Please double-check and try again.';
    }

    if (lowerMessage.contains('user not found') ||
        lowerMessage.contains('account not found')) {
      return 'No account found with this email address.';
    }

    if (lowerMessage.contains('account disabled') ||
        lowerMessage.contains('account suspended')) {
      return 'Your account has been disabled. Please contact support.';
    }

    if (lowerMessage.contains('too many attempts') ||
        lowerMessage.contains('rate limit')) {
      return 'Too many login attempts. Please try again later.';
    }

    if (lowerMessage.contains('email not verified')) {
      return 'Please verify your email address before signing in.';
    }

    return originalMessage;
  }

  String _getDefaultHttpErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input and try again.';
      case 401:
        return 'The password you entered is incorrect. Please double-check and try again.';
      case 402:
        return 'Payment is required to access this service.';
      case 403:
        return 'Access denied. Please contact support if this continues.';
      case 404:
        return 'Service not found. Please try again later.';
      case 405:
        return 'This action is not supported. Please try a different approach.';
      case 406:
        return 'The request format is not supported.';
      case 408:
        return 'Request timeout. Please try again.';
      case 409:
        return 'There was a conflict with your request. The resource may already exist.';
      case 410:
        return 'This resource is no longer available.';
      case 422:
        return 'Please check your input. Some fields contain invalid data.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
        return 'Server error. Please try again in a few minutes.';
      case 501:
        return 'This feature is not yet implemented. Please try again later.';
      case 502:
        return 'Our servers are experiencing issues. Please try again in a few minutes.';
      case 503:
        return 'Service temporarily unavailable. Please try again shortly.';
      case 504:
        return 'The server is taking too long to respond. Please try again later.';
      default:
        if (statusCode >= 400 && statusCode < 500) {
          return 'Request failed with status $statusCode. Please check your input.';
        } else if (statusCode >= 500) {
          return 'Server error ($statusCode). Please try again later.';
        } else {
          return 'Something went wrong. Please try again.';
        }
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException {
      rethrow;
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
