import 'package:dio/dio.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

class ApiService {
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

  static String? _cachedToken;
  static DateTime? _tokenExpiry;

  static Future<String?> _getValidToken() async {
    if (_cachedToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(_tokenExpiry!)) {
        return _cachedToken;
      }
    }

    final token = await StorageService.getAccessToken();

    if (token != null) {
      _cachedToken = token;
      _tokenExpiry = DateTime.now().add(const Duration(minutes: 50));
      return token;
    }

    final refreshSuccess = await refreshToken();
    if (refreshSuccess) {
      return await StorageService.getAccessToken();
    }

    return null;
  }

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
        options: Options(headers: {}),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        await StorageService.saveTokens(newAccessToken, refreshToken);
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

  static Future<Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      Options? options;

      if (requiresAuth) {
        final token = await _getValidToken();
        if (token != null) {
          options = Options(headers: {'Authorization': 'Bearer $token'});
        }
      }

      var response = await _dio.get(endpoint, options: options);

      // ✅ FIX: Don't check status code here - let DioException handle it
      return response;
    } on DioException catch (e) {
      // ✅ For 401 on authenticated endpoints, try refreshing once
      if (e.response?.statusCode == 401 && requiresAuth) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          final retryOptions =
              Options(headers: {'Authorization': 'Bearer $newToken'});
          return await _dio.get(endpoint, options: retryOptions);
        }
      }

      // ✅ Re-throw DioException to preserve response data
      rethrow;
    }
  }

  static Future<Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      Options? options;

      if (requiresAuth) {
        final token = await _getValidToken();
        if (token != null) {
          options = Options(headers: {'Authorization': 'Bearer $token'});
        }
      }

      var response = await _dio.post(endpoint, data: body, options: options);
      return response;
    } on DioException catch (e) {
      // ✅ For 401 on authenticated endpoints, try refreshing once
      if (e.response?.statusCode == 401 && requiresAuth) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          final retryOptions =
              Options(headers: {'Authorization': 'Bearer $newToken'});
          return await _dio.post(endpoint, data: body, options: retryOptions);
        }
      }

      // ✅ Re-throw DioException to preserve response data
      rethrow;
    }
  }

  static Future<Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      Options? options;

      if (requiresAuth) {
        final token = await _getValidToken();
        if (token != null) {
          options = Options(headers: {'Authorization': 'Bearer $token'});
        }
      }

      var response = await _dio.patch(endpoint, data: body, options: options);
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && requiresAuth) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          final retryOptions =
              Options(headers: {'Authorization': 'Bearer $newToken'});
          return await _dio.patch(endpoint, data: body, options: retryOptions);
        }
      }

      rethrow;
    }
  }

  static Future<Response> multipartPost(
    String endpoint,
    Map<String, dynamic> fields,
    String? filePath,
    String fileFieldName,
  ) async {
    try {
      final token = await _getValidToken();
      Map<String, String> headers = {};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      Map<String, dynamic> formDataMap = {};
      fields.forEach((key, value) {
        formDataMap[key] = value;
      });

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

      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('⚠️ 401 Unauthorized - Attempting token refresh...');

        _cachedToken = null;
        _tokenExpiry = null;

        final refreshed = await refreshToken();
        if (refreshed) {
          final newToken = await _getValidToken();
          final headers = {'Authorization': 'Bearer $newToken'};

          Map<String, dynamic> formDataMap = {};
          fields.forEach((key, value) {
            formDataMap[key] = value;
          });

          if (filePath != null && filePath.isNotEmpty) {
            formDataMap[fileFieldName] = await MultipartFile.fromFile(filePath);
          }

          FormData formData = FormData.fromMap(formDataMap);

          return await _dio.post(
            endpoint,
            data: formData,
            options: Options(
              headers: headers,
              sendTimeout: const Duration(seconds: 180),
              receiveTimeout: const Duration(seconds: 180),
            ),
          );
        }
      }

      rethrow;
    }
  }

  static Future<Response> checkVersion(String version) async {
    try {
      return await _dio.get(
        '${AppConstants.checkVersionUrl}?version=$version',
      );
    } on DioException {
      rethrow;
    }
  }

  static void clearTokenCache() {
    _cachedToken = null;
    _tokenExpiry = null;
  }
}

extension ExtraApiService on ApiService {
  static Future<Response> sendVerificationCode(String email) async {
    return ApiService.post(
      '/auth/send-verification-email/',
      {'email': email},
      requiresAuth: false,
    );
  }

  static Future<Response> verifyCode(String email, String code) async {
    return ApiService.post(
      '/auth/verify-email/',
      {'email': email, 'code': code},
      requiresAuth: false,
    );
  }

  static Future<Response> verifyPasswordResetCode(String email, String code) async {
    return ApiService.post(
      AppConstants.verifyPasswordResetCodeUrl,
      {'email': email, 'code': code},
      requiresAuth: false,
    );
  }
}
