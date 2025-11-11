import 'dart:convert';
import '../utils/constants.dart';
import '../models/assignment_model.dart';
import 'api_service.dart';

class AssignmentService {
  // Check submission limit
  static Future<Map<String, dynamic>> checkSubmissionLimit() async {
    try {
      final response = await ApiService.get(AppConstants.checkLimitUrl);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final limit = SubmissionLimit.fromJson(data);

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

  // Submit assignment
  static Future<Map<String, dynamic>> submitAssignment(
    AssignmentSubmission submission,
  ) async {
    try {
      final fields = {
        'subject_name': submission.subjectName,
        'assignment_number': submission.assignmentNumber,
        'tutor_name': submission.tutorName,
      };

      final response = await ApiService.multipartPost(
        AppConstants.submitAssignmentUrl,
        fields,
        submission.filePath,
        'file',
      );

      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        final assignmentResponse = AssignmentResponse.fromJson(data);

        return {
          'success': true,
          'response': assignmentResponse,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit assignment.',
        };
      }
    } catch (e) {
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
