import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import 'storage_service.dart';

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);

  static Future<Map<String, String>> _getHeaders({
    bool includeAuth = false,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await StorageService.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Refresh access token using refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.refreshUrl}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await StorageService.saveTokens(data['access'], refreshToken);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // GET Request with auto token refresh and better error handling
  static Future<http.Response> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: requiresAuth);

    try {
      var response = await http.get(url, headers: headers).timeout(_timeout,
          onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry request with new token
          final newHeaders = await _getHeaders(includeAuth: true);
          response = await http.get(url, headers: newHeaders).timeout(_timeout,
              onTimeout: () {
            throw TimeoutException('Request timed out');
          });
        }
      }

      return response;
    } on SocketException {
      throw SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } on HttpException {
      throw HttpException('Could not connect to server');
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // POST Request with auto token refresh and better error handling
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: requiresAuth);

    try {
      var response = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry request with new token
          final newHeaders = await _getHeaders(includeAuth: true);
          response = await http
              .post(
            url,
            headers: newHeaders,
            body: jsonEncode(body),
          )
              .timeout(_timeout, onTimeout: () {
            throw TimeoutException('Request timed out');
          });
        }
      }

      return response;
    } on SocketException {
      throw SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } on HttpException {
      throw HttpException('Could not connect to server');
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // PATCH Request with auto token refresh and better error handling
  static Future<http.Response> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final headers = await _getHeaders(includeAuth: requiresAuth);

    try {
      var response = await http
          .patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // If unauthorized, try refreshing token
      if (response.statusCode == 401 && requiresAuth) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Retry request with new token
          final newHeaders = await _getHeaders(includeAuth: true);
          response = await http
              .patch(
            url,
            headers: newHeaders,
            body: jsonEncode(body),
          )
              .timeout(_timeout, onTimeout: () {
            throw TimeoutException('Request timed out');
          });
        }
      }

      return response;
    } on SocketException {
      throw SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } on HttpException {
      throw HttpException('Could not connect to server');
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // Multipart Request with auto token refresh and better error handling
  static Future<http.StreamedResponse> multipartPost(
    String endpoint,
    Map<String, String> fields,
    String filePath,
    String fileFieldName,
  ) async {
    final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
    final token = await StorageService.getAccessToken();

    try {
      var request = http.MultipartRequest('POST', url);

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add fields
      request.fields.addAll(fields);

      // Add file
      request.files
          .add(await http.MultipartFile.fromPath(fileFieldName, filePath));

      var response = await request.send().timeout(_timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });

      // If unauthorized, try refreshing token and retry
      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          // Create new request with refreshed token
          final newToken = await StorageService.getAccessToken();
          var newRequest = http.MultipartRequest('POST', url);

          if (newToken != null) {
            newRequest.headers['Authorization'] = 'Bearer $newToken';
          }

          newRequest.fields.addAll(fields);
          newRequest.files
              .add(await http.MultipartFile.fromPath(fileFieldName, filePath));

          response = await newRequest.send().timeout(_timeout, onTimeout: () {
            throw TimeoutException('Request timed out');
          });
        }
      }

      return response;
    } on SocketException {
      throw SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } on HttpException {
      throw HttpException('Could not connect to server');
    } on FileSystemException {
      throw FileSystemException('Could not read file');
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }

  // Send OTP verification code to email
  static Future<http.Response> sendVerificationCode(String email) async {
    return post(
      '/accounts/send-code/',
      {'email': email},
      requiresAuth: false,
    );
  }

  // Verify OTP code
  static Future<http.Response> verifyCode(String email, String code) async {
    return post(
      '/accounts/verify-code/',
      {'email': email, 'code': code},
      requiresAuth: false,
    );
  }

  // Handle API Errors - Improved
  static String handleError(http.Response response) {
    try {
      final Map<String, dynamic> error = jsonDecode(response.body);

      // Check for various error message fields
      if (error.containsKey('message')) {
        return ErrorHandler.getErrorMessage(error['message']);
      } else if (error.containsKey('detail')) {
        return ErrorHandler.getErrorMessage(error['detail']);
      } else if (error.containsKey('error')) {
        return ErrorHandler.getErrorMessage(error['error']);
      }
    } catch (e) {
      // If parsing fails, use status code based message
      return ErrorHandler.parseApiError(response);
    }

    return ErrorHandler.parseApiError(response);
  }

  // Check app version for force update
  static Future<http.Response> checkVersion(String version) async {
    final url = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.checkVersionUrl}?version=$version',
    );

    try {
      return await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      ).timeout(_timeout, onTimeout: () {
        throw TimeoutException('Request timed out');
      });
    } on SocketException {
      throw SocketException('No internet connection');
    } on TimeoutException {
      throw TimeoutException('Request timed out');
    } on HttpException {
      throw HttpException('Could not connect to server');
    } catch (e) {
      throw Exception(ErrorHandler.getErrorMessage(e));
    }
  }
}
