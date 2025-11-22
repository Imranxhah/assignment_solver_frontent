import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/app_version_model.dart';
import '../utils/error_handler.dart';
import 'api_service.dart';

class AppService {
  static Future<Map<String, dynamic>> getAppVersion() async {
    try {
      // Assuming the API is running on the same host as the other endpoints
      final response = await ApiService.get(
        '/api/assignments/app-version/?platform=android', // Hardcoding android for now
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'version': AppVersion.fromJson(response.data),
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Get app version DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Get app version error: $e');
      return {
        'success': false,
        'message': 'Failed to check for updates.',
      };
    }
  }
}