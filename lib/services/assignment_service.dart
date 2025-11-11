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
        // ✅ response.data is already parsed JSON (no jsonDecode needed)
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

      // ✅ Add assignment text if provided (text mode)
      if (submission.assignmentText != null &&
          submission.assignmentText!.isNotEmpty) {
        fields['assignment_text'] = submission.assignmentText!;
      }

      Response response;

      // ✅ Check if file upload or text mode
      if (submission.filePath != null && submission.filePath!.isNotEmpty) {
        // File upload mode
        response = await ApiService.multipartPost(
          AppConstants.submitAssignmentUrl,
          fields,
          submission.filePath!,
          'file',
        );
      } else {
        // Text mode - use multipart POST without file
        response = await ApiService.multipartPost(
          AppConstants.submitAssignmentUrl,
          fields,
          null, // ✅ No file
          'file',
        );
      }

      // ✅ Dio automatically parses JSON, no need for bytesToString or jsonDecode
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
