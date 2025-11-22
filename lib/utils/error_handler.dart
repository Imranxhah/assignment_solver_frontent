import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

class ErrorHandler {
  /// Convert technical errors into user-friendly messages
  static String getErrorMessage(dynamic error) {
    // Handle Dio-specific errors
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Request timed out. Please check your connection and try again.';
        case DioExceptionType.connectionError:
          return 'No internet connection. Please check your network and try again.';
        case DioExceptionType.badResponse:
          if (error.response != null) {
            return parseApiError(error.response!);
          }
          return 'Server error. Please try again later.';
        case DioExceptionType.cancel:
          return 'Request cancelled.';
        case DioExceptionType.badCertificate:
          return 'Connection security error. Please try again.';
        case DioExceptionType.unknown:
          return 'Network error. Please try again.';
      }
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is HttpException) {
      return 'Unable to connect to server. Please try again later.';
    }

    if (error is FormatException) {
      return 'Invalid data received. Please try again.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Handle string errors from API
    if (error is String) {
      return cleanErrorMessage(error);
    }

    // Fallback for unknown errors
    return 'Something went wrong. Please try again.';
  }

  /// Parse Dio Response errors
  static String parseApiError(Response response) {
    try {
      final statusCode = response.statusCode;
      String? detailMessage;

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('detail')) {
          detailMessage = data['detail'].toString();
        } else if (data.containsKey('error')) {
          detailMessage = data['error'].toString();
        } else if (data.containsKey('message')) {
          detailMessage = data['message'].toString();
        } else if (data.isNotEmpty) {
          // Handle field-specific errors like {'email': ['...']}
          final firstValue = data.values.first;
          if (firstValue is List && firstValue.isNotEmpty) {
            detailMessage = firstValue.first.toString();
          } else {
            detailMessage = firstValue.toString();
          }
        }
      }

      if (statusCode == 401 && detailMessage != null && detailMessage.isNotEmpty) {
        return detailMessage;
      }

      switch (statusCode) {
        case 400:
          return detailMessage ?? 'Invalid request. Please check your input and try again.';
        case 401:
          return detailMessage ?? 'Session expired. Please login again.';
        case 403:
          return detailMessage ?? 'You don\'t have permission to perform this action.';
        case 404:
          return 'The requested resource was not found.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        case 500:
          return 'Server error. Our team has been notified. Please try again later.';
        case 503:
          return 'Service temporarily unavailable. Please try again in a few minutes.';
        default:
          if (statusCode != null && statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
          return detailMessage ?? 'An error occurred. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Clean up technical error messages
  static String cleanErrorMessage(String message) {
    // Remove common technical prefixes
    message = message.replaceAll('Exception: ', '');
    message = message.replaceAll('Error: ', '');
    message = message.replaceAll('Network error: ', '');

    // Check for common patterns and return friendly messages
    if (message.toLowerCase().contains('socket')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (message.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (message.toLowerCase().contains('ssl') ||
        message.toLowerCase().contains('certificate')) {
      return 'Connection security error. Please try again.';
    }

    // If message is already user-friendly, return it
    if (message.length < 100 &&
        !message.contains('Exception') &&
        !message.contains('.dart')) {
      return message;
    }

    return 'Something went wrong. Please try again.';
  }

  // Private helper to show AwesomeSnackbar
  static void _showAwesomeSnackBar(
    BuildContext context, {
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        // Add a more subtle background color for the snackbar
        color: contentType == ContentType.failure
            ? const Color(0xFF2E0C0C)
            : contentType == ContentType.success
                ? const Color(0xFF0F2D1F)
                : const Color(0xFF0E2537),
      ),
      // Position the snackbar at the top
      margin: const EdgeInsets.only(top: 70, left: 12, right: 12),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
  }) {
    _showAwesomeSnackBar(
      context,
      title: 'Oh Snap!',
      message: message,
      contentType: ContentType.failure,
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
  }) {
    _showAwesomeSnackBar(
      context,
      title: 'Well Done!',
      message: message,
      contentType: ContentType.success,
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(
    BuildContext context, {
    required String message,
  }) {
    _showAwesomeSnackBar(
      context,
      title: 'Heads Up!',
      message: message,
      contentType: ContentType.help,
    );
  }

  /// Show error dialog with more details
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.shade700,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Keep your custom TimeoutException class
class TimeoutException implements Exception {
  final String message;

  TimeoutException([this.message = 'Operation timed out']);

  @override
  String toString() => message;
}
