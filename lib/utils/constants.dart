class AppConstants {
  // API Configuration
  //static const String baseUrl =
  //'https://solveit.pythonanywhere.com'; // Android emulator
  //static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  static const String baseUrl = 'http://10.0.2.2:8000'; // Physical device

  // ============ Authentication Endpoints ============
  static const String registerUrl = '/auth/register/';
  static const String loginUrl = '/auth/login/';
  static const String verifyEmailUrl = '/auth/verify-email/';
  static const String sendVerificationEmailUrl = '/auth/send-verification-email/';
  static const String forgotPasswordUrl = '/auth/forgot-password/';
  static const String resetPasswordUrl = '/auth/reset-password/';
  static const String changePasswordUrl = '/auth/change-password/';
  static const String refreshUrl = '/auth/jwt/refresh/';
  static const String userInfoUrl = '/auth/user/';
  static const String verifyPasswordResetCodeUrl = '/api/accounts/verify-password-reset-code/';
  static const String checkVersionUrl = '/api/accounts/check-version/';


  // ============ Profile Endpoints ============
  static const String getProfileUrl = '/api/profile/';
  static const String completeProfileUrl = '/auth/complete-profile/';
  static const String checkProfileCompletionUrl = '/api/profile/check-completion/';
  static const String updateProfileUrl = '/api/profile/update/';

  // ============ Submission/Assignment Endpoints ============
  static const String checkLimitUrl = '/api/submissions/check-limit/';
  static const String submitAssignmentUrl = '/api/assignments/submit/';
  static const String downloadAssignmentUrl = '/api/assignments/download/';

  // ============ Storage Keys (REQUIRED) ============
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data'; // ✅ This was missing

  // ============ App Settings ============
  static const int maxWordCount = 2000;
  static const int maxDailySubmissions = 3;
  static const List<String> supportedFileTypes = ['pdf', 'docx'];

  // ============ Deep Link ============
  static const String deepLinkScheme = 'assignmentsolver';
}
