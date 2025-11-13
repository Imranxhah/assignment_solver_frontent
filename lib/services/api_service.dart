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
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 180),
      sendTimeout: const Duration(seconds: 180),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // ✅ Token cache to avoid redundant refresh calls
  static String? _cachedToken;
  static DateTime? _tokenExpiry;

  // ✅ Smart token getter with automatic refresh
  static Future<String?> _getValidToken() async {
    // Check if cached token is still valid
    if (_cachedToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!)) {
        return _cachedToken; // Use cached token
      }
    }

    // Cache expired or missing, get fresh token
    final token = await StorageService.getAccessToken();

    if (token != null) {
      // Cache the token for 50 minutes (JWT default is 60 min)
      _cachedToken = token;
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 50));
      return token;
    }

    // No access token, try refresh
    final refreshSuccess = await refreshToken();
    if (refreshSuccess) {
      return await StorageService.getAccessToken();
    }

    return null;
  }

  // ✅ Enhanced refresh token method with caching
  static Future<bool> refreshToken() async {
    try {
      print('🔄 Refreshing access token...');

      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        print('❌ No refresh token available');
        return false;
      }

      final response = await _dio.post(
        AppConstants.refreshUrl,
        data: {'refresh': refreshToken},
        options: Options(
          headers: {}, // No auth needed for refresh
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];

        // Save new token
        await StorageService.saveTokens(newAccessToken, refreshToken);

        // Cache token with 50-minute expiry
        _cachedToken = newAccessToken;
        _tokenExpiry = DateTime.now().add(const Duration(minutes: 50));

        print('✅ Token refreshed successfully');
        return true;
      }

      print('❌ Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Token refresh error: $e');
      return false;
    }
  }

  // ✅ GET Request with auto token refresh
  static Future<Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      // Set authorization header if needed
      if (requiresAuth) {
        final token = await _getValidToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        _dio.options.headers.remove('Authorization');
      }

      var response = await _dio.get(endpoint);

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        // Clear cache
        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          response = await _dio.get(endpoint);
        } else {
          throw Exception('Session expired. Please login again.');
        }
      }
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ✅ POST Request with auto token refresh
  static Future<Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      // Set authorization header if needed
      if (requiresAuth) {
        final token = await _getValidToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        _dio.options.headers.remove('Authorization');
      }

      var response = await _dio.post(endpoint, data: body);

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        // Clear cache
        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          response = await _dio.post(endpoint, data: body);
        } else {
          throw Exception('Session expired. Please login again.');
        }
      }
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ✅ PATCH Request with auto token refresh
  static Future<Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      // Set authorization header if needed
      if (requiresAuth) {
        final token = await _getValidToken();
        if (token != null) {
          _dio.options.headers['Authorization'] = 'Bearer $token';
        }
      } else {
        _dio.options.headers.remove('Authorization');
      }

      var response = await _dio.patch(endpoint, data: body);

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        // Clear cache
        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          _dio.options.headers['Authorization'] = 'Bearer $newToken';
          response = await _dio.patch(endpoint, data: body);
        } else {
          throw Exception('Session expired. Please login again.');
        }
      }
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ✅ Multipart POST with auto token refresh
  static Future<Response> multipartPost(
    String endpoint,
    Map<String, dynamic> fields,
    String? filePath,
    String fileFieldName,
  ) async {
    try {
      final token = await _getValidToken();
      Map<String, dynamic> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
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

      var response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          headers: headers,
          sendTimeout: const Duration(seconds: 180),
          receiveTimeout: const Duration(seconds: 180),
        ),
      );

      // If unauthorized, try refreshing token and retry
      if (response.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        // Clear cache
        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          headers['Authorization'] = 'Bearer $newToken';

          // Rebuild FormData
          formDataMap = {};
          fields.forEach((key, value) {
            formDataMap[key] = value;
          });

          if (filePath != null && filePath.isNotEmpty) {
            formDataMap[fileFieldName] = await MultipartFile.fromFile(filePath);
          }

          formData = FormData.fromMap(formDataMap);

          response = await _dio.post(
            endpoint,
            data: formData,
            options: Options(
              headers: headers,
              sendTimeout: const Duration(seconds: 180),
              receiveTimeout: const Duration(seconds: 180),
            ),
          );
        } else {
          throw Exception('Session expired. Please login again.');
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

  // Handle API Errors
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

  // ✅ Enhanced DioException handler
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

  // ✅ Manual cache clear (call this on logout)
  static void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}
