import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // Register without username
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await ApiService.post(
        '/auth/register/',
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 201) {
        final data = response.data;
        return {
          'success': true, // Treat as success to trigger verification
          'needsVerification': data['needsVerification'] ?? false,
          'email': data['email'],
          'message': data['message'],
        };
      } else {
        // Fallback for unexpected success codes
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Register DioException: ${e.response}');
      if (e.response != null) {
        final response = e.response!;
        final data = response.data;

        // Handle 409 Conflict for existing, unverified user
        if (response.statusCode == 409 && data is Map) {
          return {
            'success': true, // Treat as success to trigger verification
            'needsVerification': data['needsVerification'] ?? false,
            'email': data['email'],
            'message': data['message'],
          };
        }
        
        // Handle other errors (e.g., 400 for existing, verified user)
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }

      // Handle network or other Dio errors without a response
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Register error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Verify email
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    try {
      final Response response = await ApiService.post(
        '/auth/verify-email/',
        {'email': email, 'code': code},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully!',
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Verify email DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Verify email error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Send verification email
  static Future<Map<String, dynamic>> sendVerificationEmail(
      String email) async {
    try {
      final Response response = await ApiService.post(
        '/auth/send-verification-email/',
        {'email': email},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'Verification code sent!',
        };
      } else {
        return {
          'success': false,
          'message': response.data['error'] ?? 'Failed to send verification',
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Send verification email DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Send verification email error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Get user info
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final Response response = await ApiService.get(
        AppConstants.userInfoUrl,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        // response.data is already parsed (no jsonDecode needed)
        final user = User.fromJson(response.data);
        await StorageService.saveUser(user);
        return {
          'success': true,
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Get user info DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Get user info error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final Response response = await ApiService.post(
        '/auth/login/',
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        await StorageService.saveTokens(
          response.data['access'],
          response.data['refresh'],
        );
        return {
          'success': true,
          'message': 'Login successful',
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Login DioException: ${e.message}');
      // Custom error handling for 'Email not verified'
      if (e.response != null &&
          e.response!.data != null &&
          e.response!.data is Map &&
          e.response!.data.containsKey('error') &&
          (e.response!.data['error'] as String).startsWith('Email not verified')) {
        return {
          'success': false,
          'needsVerification': true,
          'message': e.response!.data['error'],
        };
      }
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Login error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await StorageService.getAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Complete profile
  static Future<Map<String, dynamic>> completeProfile({
    required String fullName,
    required String universityName,
    required String registrationNumber,
    required String departmentName,
  }) async {
    try {
      final Response response = await ApiService.patch(
        AppConstants.completeProfileUrl,
        {
          'full_name': fullName,
          'university_name': universityName,
          'registration_number': registrationNumber,
          'department_name': departmentName,
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile completed successfully',
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Complete profile DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Complete profile error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Update profile (for editing existing profile)
  static Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String universityName,
    required String registrationNumber,
    required String departmentName,
  }) async {
    try {
      final Response response = await ApiService.patch(
        AppConstants.updateProfileUrl,
        {
          'full_name': fullName,
          'university_name': universityName,
          'registration_number': registrationNumber,
          'department_name': departmentName,
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Profile updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response),
        };
      }
    } on DioException catch (e) {
      debugPrint('❌ Update profile DioException: ${e.message}');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    } catch (e) {
      debugPrint('❌ Update profile error: $e');
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Logout
  static Future<bool> logout() async {
    try {
      await StorageService.clearAll();
      ApiService.clearTokenCache();
      return true;
    } catch (e) {
      // Still return true to allow user to proceed to login screen
      // even if local storage clearing fails
      debugPrint('❌ Logout error: $e');
      return true;
    }
  }

  // Forgot password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await ApiService.post(
        '/auth/forgot-password/',
        {'email': email},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {
          'success': true, 
          'message': response.data['message'] ?? 'Password reset email sent!',
          'needsVerification': false,
        };
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response)
        };
      }
    } on DioException catch (e) {
       if (e.response != null && e.response!.statusCode == 409) {
        final data = e.response!.data;
        return {
          'success': true, // Still a success for the flow
          'needsVerification': data['needsVerification'] ?? false,
          'email': data['email'],
          'message': data['message'],
        };
      }
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Verify password reset code
  static Future<Map<String, dynamic>> verifyPasswordResetCode(
      String email, String code) async {
    try {
      final response = await ApiService.post(
        '/auth/reset-password/',
        {'email': email, 'code': code},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response)
        };
      }
    } on DioException catch (e) {
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/reset-password/',
        {
          'email': email,
          'code': code,
          'password': newPassword,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response)
        };
      }
    } on DioException catch (e) {
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  static Future<Map<String, dynamic>> checkUserStatus(String email) async {
    try {
      final response = await ApiService.post(
        '/api/accounts/check-status/',
        {'email': email},
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'status': response.data['status']};
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response)
        };
      }
    } on DioException catch (e) {
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.post(
        '/auth/change-password/',
        {
          'old_password': currentPassword,
          'new_password': newPassword,
        },
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': response.data['message']};
      } else {
        return {
          'success': false,
          'message': ErrorHandler.parseApiError(response)
        };
      }
    } on DioException catch (e) {
      return {'success': false, 'message': ErrorHandler.getErrorMessage(e)};
    } catch (e) {
      return {'success': false, 'message': 'An unexpected error occurred.'};
    }
  }
}
