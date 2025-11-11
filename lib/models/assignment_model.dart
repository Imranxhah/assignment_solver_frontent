class AssignmentSubmission {
  final String subjectName;
  final String assignmentNumber;
  final String tutorName;
  final String filePath;

  AssignmentSubmission({
    required this.subjectName,
    required this.assignmentNumber,
    required this.tutorName,
    required this.filePath,
  });
}

class AssignmentResponse {
  final String downloadUrl;
  final String filename;
  final int expiresIn;
  final int wordCount;
  final int submissionsRemaining;

  AssignmentResponse({
    required this.downloadUrl,
    required this.filename,
    required this.expiresIn,
    required this.wordCount,
    required this.submissionsRemaining,
  });

  factory AssignmentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AssignmentResponse(
      downloadUrl: data['download_url'],
      filename: data['filename'],
      expiresIn: data['expires_in'],
      wordCount: data['word_count'],
      submissionsRemaining: data['submissions_remaining'],
    );
  }
}

class SubmissionLimit {
  final bool canSubmit;
  final int submissionsToday;
  final int maxSubmissions;
  final int remaining;

  SubmissionLimit({
    required this.canSubmit,
    required this.submissionsToday,
    required this.maxSubmissions,
    required this.remaining,
  });

  factory SubmissionLimit.fromJson(Map<String, dynamic> json) {
    return SubmissionLimit(
      canSubmit: json['can_submit'],
      submissionsToday: json['submissions_today'],
      maxSubmissions: json['max_submissions'],
      remaining: json['remaining'],
    );
  }
}
