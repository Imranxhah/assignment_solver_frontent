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

  // Register
  Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.register(
        email: email,
        username: username,
        password: password,
      );

      _isLoading = false;
      if (result['success']) {
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

  // Activate email
  Future<bool> activateEmail({
    required String uid,
    required String token,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.activateEmail(
        uid: uid,
        token: token,
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
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await AuthService.login(
        email: email,
        password: password,
      );

      if (result['success']) {
        final userResult = await AuthService.getUserInfo();
        if (userResult['success']) {
          _user = userResult['user'];
          _isEmailVerified = _user?.isEmailVerified ?? false;
          _isProfileCompleted = _user?.profileCompleted ?? false;
          _errorMessage = null;
        } else {
          _errorMessage = userResult['message'];
        }
      } else {
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
}
