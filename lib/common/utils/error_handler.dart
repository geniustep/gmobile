// ════════════════════════════════════════════════════════════
// Unified Error Handler
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

enum ErrorType {
  network,
  timeout,
  authentication,
  authorization,
  validation,
  server,
  circuitBreaker,
  unknown,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final dynamic originalError;
  final StackTrace? stackTrace;
  final bool isRetryable;

  AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.originalError,
    this.stackTrace,
    this.isRetryable = false,
  });

  @override
  String toString() {
    return 'AppError(type: $type, message: $message)';
  }
}

class ErrorHandler {
  ErrorHandler._();

  static final ErrorHandler instance = ErrorHandler._();

  // ════════════════════════════════════════════════════════════
  // Handle Error
  // ════════════════════════════════════════════════════════════

  AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ ErrorHandler: Handling error: $error');
      if (stackTrace != null) {
        print('Stack trace: $stackTrace');
      }
    }

    // Parse error
    if (error is DioException) {
      return _handleDioError(error, stackTrace);
    } else if (error is String) {
      return _handleStringError(error, stackTrace);
    } else if (error is Exception) {
      return _handleException(error, stackTrace);
    } else {
      return AppError(
        type: ErrorType.unknown,
        message: 'حدث خطأ غير متوقع',
        technicalDetails: error.toString(),
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: false,
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Handle Dio Error
  // ════════════════════════════════════════════════════════════

  AppError _handleDioError(DioException error, StackTrace? stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.timeout,
          message: 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.',
          technicalDetails: error.message,
          originalError: error,
          stackTrace: stackTrace,
          isRetryable: true,
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 401) {
          return AppError(
            type: ErrorType.authentication,
            message: 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
            technicalDetails: 'HTTP 401: Unauthorized',
            originalError: error,
            stackTrace: stackTrace,
            isRetryable: false,
          );
        } else if (statusCode == 403) {
          return AppError(
            type: ErrorType.authorization,
            message: 'ليس لديك صلاحية للقيام بهذا الإجراء.',
            technicalDetails: 'HTTP 403: Forbidden',
            originalError: error,
            stackTrace: stackTrace,
            isRetryable: false,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return AppError(
            type: ErrorType.server,
            message: 'خطأ في الخادم. يرجى المحاولة لاحقاً.',
            technicalDetails: 'HTTP $statusCode: ${error.response?.statusMessage}',
            originalError: error,
            stackTrace: stackTrace,
            isRetryable: true,
          );
        } else {
          return AppError(
            type: ErrorType.server,
            message: 'حدث خطأ في معالجة الطلب.',
            technicalDetails: 'HTTP $statusCode: ${error.response?.statusMessage}',
            originalError: error,
            stackTrace: stackTrace,
            isRetryable: false,
          );
        }

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return AppError(
          type: ErrorType.network,
          message: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
          technicalDetails: error.message,
          originalError: error,
          stackTrace: stackTrace,
          isRetryable: true,
        );

      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.unknown,
          message: 'تم إلغاء العملية',
          technicalDetails: 'Request cancelled',
          originalError: error,
          stackTrace: stackTrace,
          isRetryable: false,
        );

      default:
        return AppError(
          type: ErrorType.unknown,
          message: 'حدث خطأ غير متوقع',
          technicalDetails: error.message,
          originalError: error,
          stackTrace: stackTrace,
          isRetryable: false,
        );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Handle String Error
  // ════════════════════════════════════════════════════════════

  AppError _handleStringError(String error, StackTrace? stackTrace) {
    final lowerError = error.toLowerCase();

    if (lowerError.contains('circuit breaker')) {
      return AppError(
        type: ErrorType.circuitBreaker,
        message: 'الخدمة غير متوفرة مؤقتاً. يرجى المحاولة بعد قليل.',
        technicalDetails: error,
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: true,
      );
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return AppError(
        type: ErrorType.network,
        message: 'تحقق من اتصالك بالإنترنت.',
        technicalDetails: error,
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: true,
      );
    } else if (lowerError.contains('timeout')) {
      return AppError(
        type: ErrorType.timeout,
        message: 'انتهت مهلة الاتصال.',
        technicalDetails: error,
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: true,
      );
    } else if (lowerError.contains('unauthorized') || lowerError.contains('authentication')) {
      return AppError(
        type: ErrorType.authentication,
        message: 'يرجى تسجيل الدخول مرة أخرى.',
        technicalDetails: error,
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: false,
      );
    } else if (lowerError.contains('validation') || lowerError.contains('invalid')) {
      return AppError(
        type: ErrorType.validation,
        message: 'البيانات المدخلة غير صحيحة.',
        technicalDetails: error,
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: false,
      );
    } else {
      return AppError(
        type: ErrorType.unknown,
        message: error,
        technicalDetails: error,
        originalError: error,
        stackTrace: stackTrace,
        isRetryable: false,
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Handle Exception
  // ════════════════════════════════════════════════════════════

  AppError _handleException(Exception error, StackTrace? stackTrace) {
    final errorString = error.toString();

    return _handleStringError(errorString, stackTrace);
  }

  // ════════════════════════════════════════════════════════════
  // Show Error Dialog
  // ════════════════════════════════════════════════════════════

  void showErrorDialog(AppError error, {VoidCallback? onRetry}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getErrorIcon(error.type),
              color: _getErrorColor(error.type),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getErrorTitle(error.type),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              error.message,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
            if (!kReleaseMode && error.technicalDetails != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'تفاصيل تقنية:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  error.technicalDetails!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (error.isRetryable && onRetry != null) ...[
            TextButton(
              onPressed: () {
                Get.back();
                onRetry();
              },
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Show Error Snackbar
  // ════════════════════════════════════════════════════════════

  void showErrorSnackbar(AppError error) {
    Get.snackbar(
      _getErrorTitle(error.type),
      error.message,
      icon: Icon(_getErrorIcon(error.type), color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _getErrorColor(error.type),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════

  IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.timeout:
        return Icons.access_time;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.authorization:
        return Icons.block;
      case ErrorType.validation:
        return Icons.warning_amber;
      case ErrorType.server:
        return Icons.error_outline;
      case ErrorType.circuitBreaker:
        return Icons.power_off;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.timeout:
        return Colors.amber;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.authorization:
        return Colors.deepOrange;
      case ErrorType.validation:
        return Colors.orange;
      case ErrorType.server:
        return Colors.purple;
      case ErrorType.circuitBreaker:
        return Colors.red;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'مشكلة في الاتصال';
      case ErrorType.timeout:
        return 'انتهت مهلة الاتصال';
      case ErrorType.authentication:
        return 'خطأ في المصادقة';
      case ErrorType.authorization:
        return 'غير مصرح';
      case ErrorType.validation:
        return 'خطأ في التحقق';
      case ErrorType.server:
        return 'خطأ في الخادم';
      case ErrorType.circuitBreaker:
        return 'الخدمة غير متوفرة';
      case ErrorType.unknown:
        return 'خطأ';
    }
  }
}
