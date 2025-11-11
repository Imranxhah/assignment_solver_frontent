import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import 'storage_service.dart';

class ApiService {
  // ✅ Initialize Dio with timeout configuration
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 130),
      receiveTimeout: const Duration(seconds: 130),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Refresh access token using refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        AppConstants.refreshUrl,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        await StorageService.saveTokens(
          response.data['access'],
          refreshToken,
        );
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // GET Request with auto token refresh and better error handling
  static Future<Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      // Set authorization header if needed
      if (requiresAuth) {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        _dio.options.headers.remove('Authorization');
      }

      var response = await _dio.get(endpoint);

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await StorageService.getAccessToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          response = await _dio.get(endpoint);
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // POST Request with auto token refresh and better error handling
  static Future<Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      // Set authorization header if needed
      if (requiresAuth) {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        _dio.options.headers.remove('Authorization');
      }

      var response = await _dio.post(endpoint, data: body);

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await StorageService.getAccessToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          response = await _dio.post(endpoint, data: body);
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // PATCH Request with auto token refresh and better error handling
  static Future<Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      // Set authorization header if needed
      if (requiresAuth) {
        final token = await StorageService.getAccessToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        _dio.options.headers.remove('Authorization');
      }

      var response = await _dio.patch(endpoint, data: body);

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await StorageService.getAccessToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          response = await _dio.patch(endpoint, data: body);
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ✅ Multipart Request with OPTIONAL file upload
  static Future<Response> multipartPost(
    String endpoint,
    Map<String, String> fields,
    String? filePath, // Optional file
    String fileFieldName,
  ) async {
    try {
      final token = await StorageService.getAccessToken();
      if (token != null) {
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }

      // Build FormData
      Map<String, dynamic> formDataMap = {};

      // Add all fields
      fields.forEach((key, value) {
        formDataMap[key] = value;
      });

      // Add file only if provided
      if (filePath != null && filePath.isNotEmpty) {
        formDataMap[fileFieldName] = await MultipartFile.fromFile(filePath);
      }

      FormData formData = FormData.fromMap(formDataMap);

      var response = await _dio.post(endpoint, data: formData);

      // If unauthorized, try refreshing token and retry
      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await StorageService.getAccessToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';

          // Rebuild FormData
          formDataMap = {};
          fields.forEach((key, value) {
            formDataMap[key] = value;
          });
          if (filePath != null && filePath.isNotEmpty) {
            formDataMap[fileFieldName] = await MultipartFile.fromFile(filePath);
          }
          formData = FormData.fromMap(formDataMap);

          response = await _dio.post(endpoint, data: formData);
        }
      }

      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Send OTP verification code to email
  static Future<Response> sendVerificationCode(String email) async {
    return post(
      '/accounts/send-code/',
      {'email': email},
      requiresAuth: false,
    );
  }

  // Verify OTP code
  static Future<Response> verifyCode(String email, String code) async {
    return post(
      '/accounts/verify-code/',
      {'email': email, 'code': code},
      requiresAuth: false,
    );
  }

  // Handle API Errors - Improved for Dio
  static String handleError(Response response) {
    try {
      final error = response.data;

      // Check for various error message fields
      if (error is Map) {
        if (error.containsKey('message')) {
          return ErrorHandler.getErrorMessage(error['message']);
        } else if (error.containsKey('detail')) {
          return ErrorHandler.getErrorMessage(error['detail']);
        } else if (error.containsKey('error')) {
          return ErrorHandler.getErrorMessage(error['error']);
        }
      }
    } catch (e) {
      // If parsing fails, use status code based message
      return ErrorHandler.parseApiError(response);
    }

    return ErrorHandler.parseApiError(response);
  }

  // ✅ Handle Dio-specific errors
  static Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException('Request timed out');

      case DioExceptionType.connectionError:
        return const SocketException('No internet connection');

      case DioExceptionType.badResponse:
        if (e.response != null) {
          return HttpException('Server error: ${e.response?.statusCode}');
        }
        return const HttpException('Could not connect to server');

      case DioExceptionType.cancel:
        return Exception('Request cancelled');

      default:
        return Exception(ErrorHandler.getErrorMessage(e.message));
    }
  }

  // Check app version for force update
  static Future<Response> checkVersion(String version) async {
    try {
      return await _dio.get(
        '${AppConstants.checkVersionUrl}?version=$version',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
