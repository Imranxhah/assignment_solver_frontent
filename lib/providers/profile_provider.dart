import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ProfileProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Complete profile
  Future<bool> completeProfile({
    required String fullName,
    required String universityName,
    required String registrationNumber,
    required String departmentName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await AuthService.completeProfile(
      fullName: fullName,
      universityName: universityName,
      registrationNumber: registrationNumber,
      departmentName: departmentName,
    );

    _isLoading = false;

    if (result['success']) {
      _successMessage = result['message'];
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
      _successMessage = null;
    }

    notifyListeners();
    return result['success'];
  }

  // ✅ NEW METHOD: Update profile
  Future<bool> updateProfile({
    required String fullName,
    required String universityName,
    required String registrationNumber,
    required String departmentName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    final result = await AuthService.updateProfile(
      fullName: fullName,
      universityName: universityName,
      registrationNumber: registrationNumber,
      departmentName: departmentName,
    );

    _isLoading = false;

    if (result['success']) {
      _successMessage = result['message'];
      _errorMessage = null;
    } else {
      _errorMessage = result['message'];
      _successMessage = null;
    }

    notifyListeners();
    return result['success'];
  }

  // Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
