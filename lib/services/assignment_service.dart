import 'dart:io';
import 'dart:async'; // ✅ ADDED - For TimeoutException
import 'package:dio/dio.dart';
import '../utils/constants.dart';
import '../models/assignment_model.dart';
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
        return {
          'success': false,
          'message': ApiService.handleError(response),
        };
      }
    } catch (e) {
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

      // ✅ Check if file upload or text mode
      if (submission.filePath != null && submission.filePath!.isNotEmpty) {
        // ✅ FILE mode
        fields['type'] = 'FILE';
        response = await ApiService.multipartPost(
          AppConstants.submitAssignmentUrl,
          fields,
          submission.filePath!,
          'file',
        );
      } else {
        // ✅ TEXT mode
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
      print('🔴 ERROR TYPE: ${e.runtimeType}');
      print('🔴 ERROR DETAILS: $e');

      return {
        'success': false,
        'message': 'Network error: ${e.toString()}', // Show actual error
      };
    }
  }

  // Get download URL
  static String getDownloadUrl(String downloadPath) {
    return '${AppConstants.baseUrl}$downloadPath';
  }
}
