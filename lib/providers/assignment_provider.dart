import 'package:flutter/material.dart';
import '../models/assignment_model.dart';
import '../services/assignment_service.dart';

class AssignmentProvider with ChangeNotifier {
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  SubmissionLimit? _submissionLimit;
  AssignmentResponse? _lastSubmission;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  SubmissionLimit? get submissionLimit => _submissionLimit;
  AssignmentResponse? get lastSubmission => _lastSubmission;

  // Check submission limit
  Future<bool> checkLimit() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AssignmentService.checkSubmissionLimit();

    _isLoading = false;

    if (result['success']) {
      _submissionLimit = result['limit'];
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result['success'];
  }

  // Submit assignment
  Future<bool> submitAssignment(AssignmentSubmission submission) async {
    _isSubmitting = true;
    _errorMessage = null;
    _lastSubmission = null;
    notifyListeners();

    final result = await AssignmentService.submitAssignment(submission);

    _isSubmitting = false;

    if (result['success']) {
      _lastSubmission = result['response'];
      _errorMessage = null;

      // Refresh submission limit
      await checkLimit();
    } else {
      _errorMessage = result['message'];
    }

    notifyListeners();
    return result['success'];
  }

  // Get download URL
  String getDownloadUrl(String downloadPath) {
    return AssignmentService.getDownloadUrl(downloadPath);
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear last submission
  void clearLastSubmission() {
    _lastSubmission = null;
    notifyListeners();
  }
}
