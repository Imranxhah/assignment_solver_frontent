import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/error_handler.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isEmailVerified = false;
  bool _isProfileCompleted = false;
  bool _initialized = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  bool get isEmailVerified => _isEmailVerified;
  bool get isProfileCompleted => _isProfileCompleted;
  bool get canSubmitAssignments => _isEmailVerified && _isProfileCompleted;
  bool get isInitialized => _initialized;

  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loggedIn = await AuthService.isLoggedIn();
      if (loggedIn) {
        _user = await StorageService.getUser();

        // Always fetch fresh data from API when app starts
        final result = await AuthService.getUserInfo();
        if (result['success']) {
          _user = result['user'];
          _isEmailVerified = _user?.isEmailVerified ?? false;
          _isProfileCompleted = _user?.profileCompleted ?? false;
        } else {
          // If API call fails, use cached data if available
          if (_user != null) {
            _isEmailVerified = _user?.isEmailVerified ?? false;
            _isProfileCompleted = _user?.profileCompleted ?? false;
          }
        }
      }
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      // Use cached data if available
      if (_user != null) {
        _isEmailVerified = _user?.isEmailVerified ?? false;
        _isProfileCompleted = _user?.profileCompleted ?? false;
      }
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.register(
      email: email,
      password: password,
    );

    _isLoading = false;
    if (!result['success']) {
      _errorMessage = result['message'];
    } else {
      _errorMessage = null; // Clear previous error on success
    }
    notifyListeners();
    return result;
  }

  // Verify email
  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.verifyEmail(
        email: email,
        code: code,
      );

      _isLoading = false;
      if (result['success']) {
        _isEmailVerified = true;
        _errorMessage = null;
      } else {
        _errorMessage = result['message'];
      }
      notifyListeners();
      return result['success'];
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }



  // Login
  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.login(email: email, password: password);

    if (result['success']) {
      // Directly fetch user info here to ensure we have the latest data
      final userInfoResult = await AuthService.getUserInfo();
      if (userInfoResult['success']) {
        _user = userInfoResult['user'];
        _isEmailVerified = _user?.isEmailVerified ?? false;
        _isProfileCompleted = _user?.profileCompleted ?? false;
        _errorMessage = null;
      } else {
        // Handle failure to fetch user info after login
        _errorMessage = userInfoResult['message'];
      }
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Refresh user info
  Future<void> refreshUser() async {
    try {
      final result = await AuthService.getUserInfo();
      if (result['success']) {
        _user = result['user'];
        _isEmailVerified = _user?.isEmailVerified ?? false;
        _isProfileCompleted = _user?.profileCompleted ?? false;
        _errorMessage = null;
        notifyListeners();
      } else {
        _errorMessage = result['message'];
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      notifyListeners();
    }
  }

  // Complete profile
  Future<bool> completeProfile({
    required String fullName,
    required String universityName,
    required String registrationNumber,
    required String departmentName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.completeProfile(
        fullName: fullName,
        universityName: universityName,
        registrationNumber: registrationNumber,
        departmentName: departmentName,
      );

      _isLoading = false;
      if (result['success']) {
        _isProfileCompleted = true;
        _errorMessage = null;
        if (_user != null) {
          _user = User(
            id: _user!.id,
            email: _user!.email,
            username: _user!.username,
            isEmailVerified: _user!.isEmailVerified,
            profileCompleted: true,
            profile: _user!.profile,
          );
        }
      } else {
        _errorMessage = result['message'];
      }
      notifyListeners();
      return result['success'];
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await AuthService.logout();
      _user = null;
      _isEmailVerified = false;
      _isProfileCompleted = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await AuthService.forgotPassword(email);
    
    _isLoading = false;
    if (!result['success']) {
      _errorMessage = result['message'];
    } else {
      _errorMessage = null;
    }
    notifyListeners();
    return result;
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      if (!result['success']) {
        _errorMessage = result['message'];
      }
      _isLoading = false;
      notifyListeners();
      return result['success'];
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }

  // Verify password reset code
  Future<bool> verifyPasswordResetCode(String email, String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.verifyPasswordResetCode(email, code);
      if (result['success']) {
        // Here, the backend returns a message on success, not a token
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = ErrorHandler.getErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (result['success']) {
        return true;
      } else {
        _errorMessage = result['message'];
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = ErrorHandler.getErrorMessage(e);
      notifyListeners();
      return false;
    }
  }
}
