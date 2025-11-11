import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ErrorHandler {
  /// Convert technical errors into user-friendly messages
  static String getErrorMessage(dynamic error) {
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
      return _cleanErrorMessage(error);
    }

    // Fallback for unknown errors
    return 'Something went wrong. Please try again.';
  }

  /// Parse HTTP response errors
  static String parseApiError(http.Response response) {
    try {
      final statusCode = response.statusCode;

      // Handle specific status codes
      switch (statusCode) {
        case 400:
          return 'Invalid request. Please check your input and try again.';
        case 401:
          return 'Session expired. Please login again.';
        case 403:
          return 'You don\'t have permission to perform this action.';
        case 404:
          return 'The requested resource was not found.';
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
        case 500:
          return 'Server error. Our team has been notified. Please try again later.';
        case 503:
          return 'Service temporarily unavailable. Please try again in a few minutes.';
        default:
          if (statusCode >= 500) {
            return 'Server error. Please try again later.';
          }
          return 'An error occurred. Please try again.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Clean up technical error messages
  static String _cleanErrorMessage(String message) {
    // Remove common technical prefixes
    message = message.replaceAll('Exception: ', '');
    message = message.replaceAll('Error: ', '');
    message = message.replaceAll('Network error:', '');

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
        !message.contains('(') &&
        !message.contains('.dart')) {
      return message;
    }

    return 'Something went wrong. Please try again.';
  }

  /// Show error snackbar with retry option
  static void showErrorSnackBar(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
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

class TimeoutException implements Exception {
  final String message;
  TimeoutException([this.message = 'Operation timed out']);

  @override
  String toString() => message;
}
