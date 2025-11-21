import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import '../models/assignment_model.dart';
import '../utils/error_handler.dart';
import 'api_service.dart';

class AssignmentService {
  // Check submission limit
  static Future<Map<String, dynamic>> checkSubmissionLimit() async {
    try {
      final Response response =
          await ApiService.get(AppConstants.checkLimitUrl);

      if (response.statusCode == 200) {
        final limit = SubmissionLimit.fromJson(response.data);
        return {
          'success': true,
          'limit': limit,
        };
      } else {
        // ✅ FIX: Use ErrorHandler.parseApiError instead of ApiService.handleError
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      // ✅ FIX: Handle DioException properly
      debugPrint('❌ Check limit DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Check limit error: $e');
      return {
        'success': false,
        'message': 'Failed to check submission limit.',
      };
    }
  }

  // Submit assignment (handles both file and text)
  static Future<Map<String, dynamic>> submitAssignment(
    AssignmentSubmission submission,
  ) async {
    try {
      final fields = {
        'subject_name': submission.subjectName,
        'assignment_number': submission.assignmentNumber,
        'tutor_name': submission.tutorName,
      };

      Response response;

      // Check if file upload or text mode
      if (submission.filePath != null && submission.filePath!.isNotEmpty) {
        // FILE mode
        fields['type'] = 'FILE';
        response = await ApiService.multipartPost(
          AppConstants.submitAssignmentUrl,
          fields,
          submission.filePath!,
          'file',
        );
      } else {
        // TEXT mode
        fields['type'] = 'TEXT';
        fields['text_content'] = submission.assignmentText ?? '';
        response = await ApiService.multipartPost(
          AppConstants.submitAssignmentUrl,
          fields,
          null, // No file
          'file',
        );
      }

      if (response.statusCode == 200) {
        final assignmentResponse = AssignmentResponse.fromJson(response.data);
        return {
          'success': true,
          'response': assignmentResponse,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit assignment.',
        };
      }
    } on DioException catch (e) {
      // ✅ FIX: Handle DioException properly with ErrorHandler
      debugPrint('❌ Submit assignment DioException: ${e.response?.statusCode}');
      debugPrint('❌ Error details: ${e.response?.data}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } on TimeoutException {
      return {
        'success': false,
        'message':
            'Request timed out. Please check your connection and try again.',
      };
    } on SocketException {
      return {
        'success': false,
        'message': 'No internet connection. Please check your network.',
      };
    } catch (e) {
      debugPrint('❌ Submit assignment error type: ${e.runtimeType}');
      debugPrint('❌ Submit assignment error details: $e');
      return {
        'success': false,
        'message': 'Network error. Please try again.',
      };
    }
  }

  // Get download URL
  static String getDownloadUrl(String downloadPath) {
    return '${AppConstants.baseUrl}$downloadPath';
  }
}
