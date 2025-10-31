// ════════════════════════════════════════════════════════════
// error_handler.dart - إدارة مركزية للأخطاء
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════
// أنواع الأخطاء
// ════════════════════════════════════════════════════════════

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  timeout,
  odoo,
  unknown,
}

// ════════════════════════════════════════════════════════════
// نموذج الخطأ
// ════════════════════════════════════════════════════════════

class AppError {
  final ErrorType type;
  final String code;
  final String message;
  final dynamic data;
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.code,
    required this.message,
    this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

// ════════════════════════════════════════════════════════════
// مدير الأخطاء
// ════════════════════════════════════════════════════════════

class ErrorHandler {
  ErrorHandler._();

  // خريطة الأخطاء المخصصة
  static final Map<String, String> _errorMessages = {
    // أخطاء الشبكة
    'NO_INTERNET': 'لا يوجد اتصال بالإنترنت',
    'CONNECTION_FAILED': 'فشل الاتصال بالخادم',
    'CONNECTION_TIMEOUT': 'انتهت مهلة الاتصال',
    'SEND_TIMEOUT': 'انتهت مهلة إرسال البيانات',
    'RECEIVE_TIMEOUT': 'انتهت مهلة استقبال البيانات',
    'HOST_LOOKUP_FAILED': 'فشل في العثور على الخادم',

    // أخطاء المصادقة
    'SESSION_EXPIRED': 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى',
    'INVALID_CREDENTIALS': 'بيانات الدخول غير صحيحة',
    'UNAUTHORIZED': 'غير مصرح لك بالوصول',
    'TOKEN_EXPIRED': 'انتهت صلاحية الرمز',

    // أخطاء التحقق
    'VALIDATION_ERROR': 'خطأ في التحقق من البيانات',
    'MISSING_FIELD': 'حقل مطلوب مفقود',
    'INVALID_FORMAT': 'تنسيق البيانات غير صحيح',

    // أخطاء الخادم
    'SERVER_ERROR': 'خطأ في الخادم',
    'BAD_RESPONSE': 'استجابة غير صحيحة من الخادم',
    'INTERNAL_ERROR': 'خطأ داخلي في الخادم',

    // أخطاء أودو
    'ODOO_ERROR': 'خطأ من نظام أودو',
    'ODOO_ACCESS_DENIED': 'تم رفض الوصول من أودو',
    'ODOO_VALIDATION': 'خطأ في التحقق من بيانات أودو',
    'ODOO_WARNING': 'تحذير من أودو',

    // أخطاء عامة
    'UNKNOWN_ERROR': 'حدث خطأ غير متوقع',
    'REQUEST_CANCELLED': 'تم إلغاء الطلب',
    'PARSE_ERROR': 'خطأ في تحليل البيانات',
  };

  // خريطة أكواد أخطاء أودو
  static final Map<int, String> _odooErrorCodes = {
    100: 'SESSION_EXPIRED',
    200: 'ODOO_ACCESS_DENIED',
    300: 'ODOO_VALIDATION',
    400: 'ODOO_WARNING',
    500: 'INTERNAL_ERROR',
  };

  // ════════════════════════════════════════════════════════════
  // إضافة أو تحديث رسالة خطأ
  // ════════════════════════════════════════════════════════════

  static void addErrorMessage(String code, String message) {
    _errorMessages[code] = message;
  }

  static void addErrorMessages(Map<String, String> messages) {
    _errorMessages.addAll(messages);
  }

  // ════════════════════════════════════════════════════════════
  // الحصول على رسالة الخطأ
  // ════════════════════════════════════════════════════════════

  static String getErrorMessage(String code) {
    return _errorMessages[code] ?? _errorMessages['UNKNOWN_ERROR']!;
  }

  // ════════════════════════════════════════════════════════════
  // معالجة خطأ Dio
  // ════════════════════════════════════════════════════════════

  static AppError handleDioError(dynamic error) {
    if (error.toString().contains('Failed host lookup')) {
      return AppError(
        type: ErrorType.network,
        code: 'NO_INTERNET',
        message: getErrorMessage('NO_INTERNET'),
      );
    }

    if (error.toString().contains('SocketException')) {
      return AppError(
        type: ErrorType.network,
        code: 'CONNECTION_FAILED',
        message: getErrorMessage('CONNECTION_FAILED'),
      );
    }

    return AppError(
      type: ErrorType.unknown,
      code: 'UNKNOWN_ERROR',
      message: getErrorMessage('UNKNOWN_ERROR'),
    );
  }

  // ════════════════════════════════════════════════════════════
  // معالجة خطأ أودو
  // ════════════════════════════════════════════════════════════

  static AppError handleOdooError(Map<String, dynamic> errorData) {
    if (errorData.containsKey('code')) {
      final code = errorData['code'];
      final errorCode = _odooErrorCodes[code] ?? 'ODOO_ERROR';

      return AppError(
        type: ErrorType.odoo,
        code: errorCode,
        message: errorData['message'] ?? getErrorMessage(errorCode),
        data: errorData,
      );
    }

    if (errorData.containsKey('data')) {
      final data = errorData['data'];
      if (data is Map && data.containsKey('message')) {
        return AppError(
          type: ErrorType.odoo,
          code: 'ODOO_ERROR',
          message: data['message'],
          data: errorData,
        );
      }
    }

    return AppError(
      type: ErrorType.odoo,
      code: 'ODOO_ERROR',
      message: getErrorMessage('ODOO_ERROR'),
      data: errorData,
    );
  }

  // ════════════════════════════════════════════════════════════
  // معالجة خطأ من كود
  // ════════════════════════════════════════════════════════════

  static AppError handleErrorCode(String code, {String? customMessage}) {
    return AppError(
      type: _getErrorType(code),
      code: code,
      message: customMessage ?? getErrorMessage(code),
    );
  }

  static ErrorType _getErrorType(String code) {
    if (code.contains('INTERNET') ||
        code.contains('CONNECTION') ||
        code.contains('TIMEOUT')) {
      return ErrorType.network;
    }
    if (code.contains('SESSION') ||
        code.contains('AUTH') ||
        code.contains('TOKEN')) {
      return ErrorType.authentication;
    }
    if (code.contains('VALIDATION') || code.contains('FORMAT')) {
      return ErrorType.validation;
    }
    if (code.contains('SERVER')) {
      return ErrorType.server;
    }
    if (code.contains('ODOO')) {
      return ErrorType.odoo;
    }
    return ErrorType.unknown;
  }

  // ════════════════════════════════════════════════════════════
  // عرض الأخطاء
  // ════════════════════════════════════════════════════════════

  static void showError(AppError error, {bool useDialog = false}) {
    if (useDialog) {
      _showErrorDialog(error);
    } else {
      _showErrorSnackbar(error);
    }
  }

  static void _showErrorSnackbar(AppError error) {
    Get.snackbar(
      _getErrorTitle(error.type),
      error.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _getErrorColor(error.type),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: Icon(_getErrorIcon(error.type), color: Colors.white),
      shouldIconPulse: true,
    );
  }

  static void _showErrorDialog(AppError error) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(_getErrorIcon(error.type), color: _getErrorColor(error.type)),
            const SizedBox(width: 8),
            Text(_getErrorTitle(error.type)),
          ],
        ),
        content: Text(error.message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('حسناً')),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // معالجة مباشرة من رسالة نصية
  // ════════════════════════════════════════════════════════════

  static void showErrorMessage(
    String message, {
    ErrorType type = ErrorType.unknown,
    bool useDialog = false,
  }) {
    final error = AppError(type: type, code: 'CUSTOM', message: message);
    showError(error, useDialog: useDialog);
  }

  // ════════════════════════════════════════════════════════════
  // مساعدات العرض
  // ════════════════════════════════════════════════════════════

  static String _getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'خطأ في الاتصال';
      case ErrorType.authentication:
        return 'خطأ في المصادقة';
      case ErrorType.validation:
        return 'خطأ في البيانات';
      case ErrorType.server:
        return 'خطأ في الخادم';
      case ErrorType.timeout:
        return 'انتهت المهلة';
      case ErrorType.odoo:
        return 'خطأ من أودو';
      case ErrorType.unknown:
        return 'خطأ';
    }
  }

  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.authentication:
        return Colors.red;
      case ErrorType.validation:
        return Colors.amber;
      case ErrorType.server:
        return Colors.deepOrange;
      case ErrorType.timeout:
        return Colors.brown;
      case ErrorType.odoo:
        return Colors.purple;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }

  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.server:
        return Icons.dns;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.odoo:
        return Icons.warning;
      case ErrorType.unknown:
        return Icons.help_outline;
    }
  }

  // ════════════════════════════════════════════════════════════
  // معالجة سريعة
  // ════════════════════════════════════════════════════════════

  static void handleError(
    dynamic error, {
    String? customMessage,
    bool useDialog = false,
  }) {
    AppError appError;

    if (error is AppError) {
      appError = error;
    } else if (error is Map<String, dynamic>) {
      appError = handleOdooError(error);
    } else if (error is String) {
      appError = handleErrorCode(error, customMessage: customMessage);
    } else {
      appError = handleDioError(error);
    }

    showError(appError, useDialog: useDialog);
  }

  // ════════════════════════════════════════════════════════════
  // تسجيل الأخطاء (اختياري)
  // ════════════════════════════════════════════════════════════

  static void logError(AppError error) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🔴 ERROR LOG');
    print('Type: ${error.type}');
    print('Code: ${error.code}');
    print('Message: ${error.message}');
    print('Time: ${error.timestamp}');
    if (error.data != null) {
      print('Data: ${error.data}');
    }
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }
}
