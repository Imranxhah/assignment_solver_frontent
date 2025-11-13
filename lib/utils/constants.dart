class AppConstants {
  // API Configuration
  //static const String baseUrl =
  //'https://solveit.pythonanywhere.com'; // Android emulator
  //static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  static const String baseUrl = 'http://10.0.2.2:8000'; // Physical device

  // ============ Authentication Endpoints (Djoser) ============
  static const String registerUrl = '/auth/users/';
  static const String activateUrl = '/auth/users/activation/';
  static const String loginUrl = '/auth/jwt/create/';
  static const String refreshUrl = '/auth/jwt/refresh/';
  static const String logoutUrl = '/auth/jwt/logout/';
  static const String userInfoUrl = '/auth/users/me/';
  static const String checkVersionUrl = '/api/accounts/check-version/';

  // ============ Profile Endpoints ============
  static const String getProfileUrl = '/api/accounts/profile/';
  static const String completeProfileUrl = '/api/accounts/profile/complete/';
  static const String checkProfileCompletionUrl =
      '/api/accounts/profile/check-completion/';
  static const String updateProfileUrl = '/api/accounts/profile/update/';

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
