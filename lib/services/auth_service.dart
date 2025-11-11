import 'dart:convert';
//import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/error_handler.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  // Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiService.post(
        AppConstants.registerUrl,
        {
          'email': email,
          'username': username,
          'password': password,
          're_password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message':
              'Registration successful! Please verify your email to continue.',
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
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Activate email
  static Future<Map<String, dynamic>> activateEmail({
    required String uid,
    required String token,
  }) async {
    try {
      final response = await ApiService.post(
        '${AppConstants.activateUrl}$uid/$token/',
        {},
        requiresAuth: false,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Email verified successfully!',
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
      final response = await ApiService.post(
        AppConstants.loginUrl,
        {
          'email': email,
          'password': password,
        },
        requiresAuth: false,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await StorageService.saveTokens(data['access'], data['refresh']);
        return {
          'success': true,
          'message': 'Login successful',
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
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Get user info
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await ApiService.get(
        AppConstants.userInfoUrl,
        requiresAuth: true,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        await StorageService.saveUser(user);
        return {
          'success': true,
          'user': user,
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
      final response = await ApiService.patch(
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
          'message': ApiService.handleError(response),
        };
      }
    } catch (e) {
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
      final response = await ApiService.patch(
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
          'message': ApiService.handleError(response),
        };
      }
    } catch (e) {
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
      return true;
    } catch (e) {
      // Still return true to allow user to proceed to login screen
      // even if local storage clearing fails
      return true;
    }
  }
}
