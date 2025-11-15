// ════════════════════════════════════════════════════════════
// GlobalErrorHandler - معالجة الأخطاء على مستوى التطبيق
// ════════════════════════════════════════════════════════════
//
// يلتقط جميع الأخطاء غير المعالجة ويمنع crash التطبيق
// يرسل التقارير للـ monitoring services
//
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════
// Error Types
// ════════════════════════════════════════════════════════════

enum ErrorSeverity {
  low,      // معلومات فقط
  medium,   // تحذير
  high,     // خطأ يؤثر على الوظيفة
  critical, // خطأ حرج قد يؤدي لـ crash
}

class AppError {
  final String message;
  final Object? error;
  final StackTrace? stackTrace;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  AppError({
    required this.message,
    this.error,
    this.stackTrace,
    this.severity = ErrorSeverity.medium,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'message': message,
        'error': error?.toString(),
        'stackTrace': stackTrace?.toString(),
        'severity': severity.name,
        'timestamp': timestamp.toIso8601String(),
        'context': context,
      };
}

// ════════════════════════════════════════════════════════════
// Global Error Handler
// ════════════════════════════════════════════════════════════

class GlobalErrorHandler {
  GlobalErrorHandler._();

  static final GlobalErrorHandler instance = GlobalErrorHandler._();

  // ════════════════════════════════════════════════════════════
  // Error Storage
  // ════════════════════════════════════════════════════════════

  final List<AppError> _errors = [];
  final int _maxErrors = 100; // الاحتفاظ بآخر 100 خطأ فقط

  // ════════════════════════════════════════════════════════════
  // Callbacks
  // ════════════════════════════════════════════════════════════

  Function(AppError)? onError;
  Function(AppError)? onCriticalError;

  // ════════════════════════════════════════════════════════════
  // Setup
  // ════════════════════════════════════════════════════════════

  /// إعداد معالج الأخطاء العام
  static void setup() {
    // معالجة أخطاء Flutter Framework
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);

      instance.recordError(
        AppError(
          message: 'Flutter Framework Error',
          error: details.exception,
          stackTrace: details.stack,
          severity: ErrorSeverity.high,
          context: {
            'library': details.library,
            'context': details.context?.toString(),
          },
        ),
      );
    };

    // معالجة أخطاء خارج Flutter Framework
    PlatformDispatcher.instance.onError = (error, stack) {
      instance.recordError(
        AppError(
          message: 'Platform Error',
          error: error,
          stackTrace: stack,
          severity: ErrorSeverity.critical,
        ),
      );

      return true; // منع crash
    };

    // معالجة أخطاء Zone
    runZonedGuarded(
      () {
        // التطبيق يعمل هنا
      },
      (error, stack) {
        instance.recordError(
          AppError(
            message: 'Zone Error',
            error: error,
            stackTrace: stack,
            severity: ErrorSeverity.high,
          ),
        );
      },
    );

    if (kDebugMode) {
      print('✅ Global Error Handler initialized');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Error Recording
  // ════════════════════════════════════════════════════════════

  /// تسجيل خطأ
  void recordError(AppError error) {
    // إضافة للقائمة
    _errors.add(error);

    // الاحتفاظ بآخر N خطأ فقط
    if (_errors.length > _maxErrors) {
      _errors.removeAt(0);
    }

    // طباعة في Debug mode
    if (kDebugMode) {
      _printError(error);
    }

    // استدعاء callbacks
    onError?.call(error);

    if (error.severity == ErrorSeverity.critical) {
      onCriticalError?.call(error);
      _handleCriticalError(error);
    }

    // إرسال للـ monitoring service
    _sendToMonitoring(error);
  }

  /// معالجة خطأ حرج
  void _handleCriticalError(AppError error) {
    // عرض dialog للمستخدم
    if (Get.context != null) {
      _showErrorDialog(error);
    }
  }

  /// عرض dialog الخطأ
  void _showErrorDialog(AppError error) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: _getSeverityColor(error.severity),
            ),
            const SizedBox(width: 8),
            const Text('خطأ غير متوقع'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(error.message),
            if (kDebugMode && error.error != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'تفاصيل تقنية:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  error.error.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (kDebugMode)
            TextButton(
              onPressed: () {
                Get.back();
                printErrorDetails(error);
              },
              child: const Text('طباعة التفاصيل'),
            ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('حسناً'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Monitoring Integration
  // ════════════════════════════════════════════════════════════

  /// إرسال للـ monitoring service
  void _sendToMonitoring(AppError error) {
    if (kReleaseMode) {
      // إرسال لـ Firebase Crashlytics
      // FirebaseCrashlytics.instance.recordError(
      //   error.error,
      //   error.stackTrace,
      //   reason: error.message,
      //   fatal: error.severity == ErrorSeverity.critical,
      // );

      // إرسال لـ Sentry
      // Sentry.captureException(
      //   error.error,
      //   stackTrace: error.stackTrace,
      // );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Error Retrieval
  // ════════════════════════════════════════════════════════════

  /// الحصول على جميع الأخطاء
  List<AppError> getAllErrors() => List.unmodifiable(_errors);

  /// الحصول على الأخطاء حسب الشدة
  List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errors.where((e) => e.severity == severity).toList();
  }

  /// الحصول على آخر N خطأ
  List<AppError> getRecentErrors(int count) {
    final startIndex = _errors.length - count;
    return _errors.sublist(startIndex > 0 ? startIndex : 0);
  }

  /// مسح جميع الأخطاء
  void clearErrors() {
    _errors.clear();
  }

  // ════════════════════════════════════════════════════════════
  // Statistics
  // ════════════════════════════════════════════════════════════

  /// إحصائيات الأخطاء
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'total': _errors.length,
      'bySeverity': {},
      'recent': getRecentErrors(10).map((e) => e.toJson()).toList(),
    };

    for (final severity in ErrorSeverity.values) {
      final count = _errors.where((e) => e.severity == severity).length;
      stats['bySeverity'][severity.name] = count;
    }

    return stats;
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  Color _getSeverityColor(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.low:
        return Colors.blue;
      case ErrorSeverity.medium:
        return Colors.orange;
      case ErrorSeverity.high:
        return Colors.deepOrange;
      case ErrorSeverity.critical:
        return Colors.red;
    }
  }

  void _printError(AppError error) {
    print('═══════════════════════════════════════════════════════');
    print('❌ Error: ${error.message}');
    print('Severity: ${error.severity.name}');
    print('Timestamp: ${error.timestamp}');
    if (error.error != null) {
      print('Exception: ${error.error}');
    }
    if (error.stackTrace != null) {
      print('Stack Trace:\n${error.stackTrace}');
    }
    if (error.context != null) {
      print('Context: ${error.context}');
    }
    print('═══════════════════════════════════════════════════════');
  }

  void printErrorDetails(AppError error) {
    _printError(error);
  }

  void printAllErrors() {
    print('═══════════════════════════════════════════════════════');
    print('📊 All Errors (${_errors.length})');
    print('═══════════════════════════════════════════════════════');

    for (var i = 0; i < _errors.length; i++) {
      print('\n[$i] ${_errors[i].message} (${_errors[i].severity.name})');
    }

    print('═══════════════════════════════════════════════════════');
  }
}

// ════════════════════════════════════════════════════════════
// Error Boundary Widget
// ════════════════════════════════════════════════════════════

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(Object error, StackTrace? stack)? errorBuilder;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, _stackTrace) ??
          _defaultErrorWidget();
    }

    return widget.child;
  }

  Widget _defaultErrorWidget() {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'عذراً، حدث خطأ غير متوقع',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'يرجى إعادة تشغيل التطبيق',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  _error.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
