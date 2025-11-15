import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Central error handling service for the application
/// Provides consistent error handling, logging, and user feedback
class ErrorHandlerService {
  static const String _tag = '❌ ErrorHandler';

  /// Handle API errors with retry mechanism
  static Future<T?> handleApiCall<T>({
    required Future<T> Function() apiCall,
    String? errorMessage,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool showSnackbar = true,
  }) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        attempts++;
        final result = await apiCall();
        return result;
      } catch (e) {
        if (kDebugMode) {
          print('$_tag Attempt $attempts/$maxRetries failed: $e');
        }

        // If this is the last attempt, show error to user
        if (attempts >= maxRetries) {
          final message = errorMessage ?? _getErrorMessage(e);
          if (showSnackbar) {
            _showErrorSnackbar('خطأ', message);
          }
          _logError(e, StackTrace.current);
          return null;
        }

        // Wait before retrying
        if (attempts < maxRetries) {
          await Future.delayed(retryDelay * attempts);
        }
      }
    }
    return null;
  }

  /// Handle errors with custom error messages
  static void handleError(
    dynamic error, {
    String? customMessage,
    StackTrace? stackTrace,
    bool showSnackbar = true,
  }) {
    final message = customMessage ?? _getErrorMessage(error);

    if (showSnackbar) {
      _showErrorSnackbar('خطأ', message);
    }

    _logError(error, stackTrace ?? StackTrace.current);
  }

  /// Get user-friendly error message in Arabic
  static String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Network errors
    if (errorString.contains('socket') || errorString.contains('network')) {
      return 'فشل الاتصال بالإنترنت. يرجى التحقق من الاتصال والمحاولة مرة أخرى';
    }

    // Timeout errors
    if (errorString.contains('timeout')) {
      return 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى';
    }

    // Authentication errors
    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى';
    }

    // Permission errors
    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'ليس لديك صلاحية للقيام بهذا الإجراء';
    }

    // Not found errors
    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'البيانات المطلوبة غير موجودة';
    }

    // Server errors
    if (errorString.contains('500') || errorString.contains('server error')) {
      return 'خطأ في الخادم. يرجى المحاولة لاحقاً';
    }

    // Validation errors
    if (errorString.contains('validation')) {
      return 'البيانات المدخلة غير صحيحة. يرجى التحقق والمحاولة مرة أخرى';
    }

    // Database errors
    if (errorString.contains('database') || errorString.contains('sql')) {
      return 'حدث خطأ في قاعدة البيانات';
    }

    // Default error message
    return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى';
  }

  /// Show error snackbar to user
  static void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  /// Log error to console (in debug mode) and to analytics (in production)
  static void _logError(dynamic error, StackTrace stackTrace) {
    if (kDebugMode) {
      print('$_tag Error: $error');
      print('$_tag StackTrace: $stackTrace');
    } else {
      // In production, send to analytics service
      // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }
  }

  /// Show success message
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primaryContainer,
      colorText: Get.theme.colorScheme.onPrimaryContainer,
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }

  /// Show info message
  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }

  /// Show warning message
  static void showWarning(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.secondaryContainer,
      colorText: Get.theme.colorScheme.onSecondaryContainer,
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }

  /// Validate internet connection
  static Future<bool> hasInternetConnection() async {
    try {
      // You can use connectivity_plus package for better detection
      // For now, we'll return true and let the API call fail
      return true;
    } catch (e) {
      return false;
    }
  }
}
