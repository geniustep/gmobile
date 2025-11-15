// ════════════════════════════════════════════════════════════
// SessionManager - إدارة الجلسات المحسّنة
// ════════════════════════════════════════════════════════════
//
// - مراقبة نشاط المستخدم
// - تحذير قبل انتهاء الجلسة
// - تجديد تلقائي للجلسة
// - معالجة انتهاء الصلاحية بشكل صحيح
//
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/security/secure_token_storage.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class SessionManager {
  SessionManager._();

  static final SessionManager instance = SessionManager._();

  // ════════════════════════════════════════════════════════════
  // Configuration
  // ════════════════════════════════════════════════════════════

  /// مدة الجلسة (30 دقيقة)
  static const Duration sessionDuration = Duration(minutes: 30);

  /// وقت التحذير قبل انتهاء الجلسة (25 دقيقة)
  static const Duration warningThreshold = Duration(minutes: 25);

  /// فترة التحقق (كل دقيقة)
  static const Duration checkInterval = Duration(minutes: 1);

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  Timer? _sessionTimer;
  bool _isWarningShown = false;
  bool _isMonitoring = false;

  final SecureTokenStorage _storage = SecureTokenStorage.instance;

  // ════════════════════════════════════════════════════════════
  // Callbacks
  // ════════════════════════════════════════════════════════════

  VoidCallback? onSessionExpired;
  VoidCallback? onSessionWarning;
  VoidCallback? onSessionRefreshed;

  // ════════════════════════════════════════════════════════════
  // Session Monitoring
  // ════════════════════════════════════════════════════════════

  /// بدء مراقبة الجلسة
  void startMonitoring() {
    if (_isMonitoring) {
      if (kDebugMode) {
        print('⚠️ Session monitoring already started');
      }
      return;
    }

    _isMonitoring = true;
    _isWarningShown = false;

    // تحديث آخر نشاط
    _storage.updateLastActivity();

    // بدء المؤقت
    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(checkInterval, (_) => _checkSession());

    if (kDebugMode) {
      print('✅ Session monitoring started');
    }
  }

  /// إيقاف مراقبة الجلسة
  void stopMonitoring() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _isMonitoring = false;
    _isWarningShown = false;

    if (kDebugMode) {
      print('🛑 Session monitoring stopped');
    }
  }

  /// فحص حالة الجلسة
  Future<void> _checkSession() async {
    try {
      final timeSinceActivity = await _storage.getTimeSinceLastActivity();

      if (timeSinceActivity == null) {
        if (kDebugMode) {
          print('⚠️ No last activity found');
        }
        return;
      }

      // التحقق من انتهاء الصلاحية
      if (timeSinceActivity >= sessionDuration) {
        await _handleSessionExpiry();
        return;
      }

      // التحقق من الحاجة للتحذير
      if (timeSinceActivity >= warningThreshold && !_isWarningShown) {
        _showSessionWarning();
      }

      if (kDebugMode) {
        final minutesRemaining =
            (sessionDuration - timeSinceActivity).inMinutes;
        print(
          '⏱️ Session check: ${minutesRemaining} minutes remaining',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking session: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Session Warning
  // ════════════════════════════════════════════════════════════

  /// عرض تحذير انتهاء الجلسة
  void _showSessionWarning() {
    _isWarningShown = true;

    final remainingTime = sessionDuration - warningThreshold;
    final minutes = remainingTime.inMinutes;

    Get.snackbar(
      'تحذير',
      'الجلسة ستنتهي خلال $minutes دقائق',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.access_time, color: Colors.white),
      duration: const Duration(seconds: 15),
      mainButton: TextButton(
        onPressed: () {
          Get.closeCurrentSnackbar();
          refreshSession();
        },
        child: const Text(
          'تمديد الجلسة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    onSessionWarning?.call();
  }

  // ════════════════════════════════════════════════════════════
  // Session Expiry
  // ════════════════════════════════════════════════════════════

  /// معالجة انتهاء الجلسة
  Future<void> _handleSessionExpiry() async {
    stopMonitoring();

    if (kDebugMode) {
      print('⏰ Session expired');
    }

    // عرض رسالة
    Get.snackbar(
      'انتهت الجلسة',
      'يرجى تسجيل الدخول مرة أخرى',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.9),
      colorText: Colors.white,
      icon: const Icon(Icons.lock, color: Colors.white),
      duration: const Duration(seconds: 5),
    );

    // مسح البيانات
    await _clearSessionData();

    // callback
    onSessionExpired?.call();

    // تأخير قبل التوجيه للـ login
    await Future.delayed(const Duration(seconds: 2));

    // توجيه لصفحة Login
    await handleSessionExpired();
  }

  /// مسح بيانات الجلسة
  Future<void> _clearSessionData() async {
    try {
      await _storage.deleteAllTokens();

      if (kDebugMode) {
        print('🗑️ Session data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing session data: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Session Refresh
  // ════════════════════════════════════════════════════════════

  /// تجديد الجلسة
  Future<void> refreshSession() async {
    try {
      showLoading();

      // محاولة الحصول على session info
      final completer = Completer<bool>();

      Api.getSessionInfo(
        onResponse: (response) async {
          // تحديث آخر نشاط
          await _storage.updateLastActivity();

          // إعادة تعيين التحذير
          _isWarningShown = false;

          hideLoading();

          Get.snackbar(
            'تم التجديد',
            'تم تمديد الجلسة بنجاح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            duration: const Duration(seconds: 3),
          );

          onSessionRefreshed?.call();

          completer.complete(true);
        },
        onError: (error, data) {
          hideLoading();

          Get.snackbar(
            'فشل التجديد',
            'لم نتمكن من تجديد الجلسة',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
          );

          // إذا فشل التجديد، انتهت الجلسة
          _handleSessionExpiry();

          completer.complete(false);
        },
      );

      await completer.future;
    } catch (e) {
      hideLoading();

      if (kDebugMode) {
        print('❌ Error refreshing session: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Activity Tracking
  // ════════════════════════════════════════════════════════════

  /// تسجيل نشاط المستخدم
  Future<void> recordActivity() async {
    if (!_isMonitoring) return;

    await _storage.updateLastActivity();

    // إعادة تعيين التحذير إذا كان ظاهراً
    if (_isWarningShown) {
      _isWarningShown = false;
      Get.closeCurrentSnackbar();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Session Validation
  // ════════════════════════════════════════════════════════════

  /// التحقق من صلاحية الجلسة الحالية
  Future<bool> isSessionValid() async {
    final hasSession = await _storage.hasActiveSession();
    if (!hasSession) return false;

    final isExpired = await _storage.isSessionExpired(
      sessionTimeout: sessionDuration,
    );

    return !isExpired;
  }

  /// فرض تسجيل الدخول إذا انتهت الجلسة
  Future<void> enforceValidSession() async {
    final isValid = await isSessionValid();

    if (!isValid) {
      await _handleSessionExpiry();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  /// الحصول على معلومات الجلسة
  Future<Map<String, dynamic>> getSessionInfo() async {
    final hasSession = await _storage.hasActiveSession();
    final isExpired = await _storage.isSessionExpired();
    final timeSinceActivity = await _storage.getTimeSinceLastActivity();
    final shouldWarn = await _storage.shouldShowSessionWarning();

    return {
      'hasSession': hasSession,
      'isExpired': isExpired,
      'isMonitoring': _isMonitoring,
      'timeSinceActivityMinutes': timeSinceActivity?.inMinutes ?? 0,
      'shouldShowWarning': shouldWarn,
      'isWarningShown': _isWarningShown,
    };
  }

  /// طباعة معلومات debug
  Future<void> printDebugInfo() async {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════════════════════');
    print('🔐 Session Manager Debug Info');
    print('═══════════════════════════════════════════════════════');

    final info = await getSessionInfo();
    info.forEach((key, value) {
      print('$key: $value');
    });

    print('═══════════════════════════════════════════════════════');
  }
}

// ════════════════════════════════════════════════════════════
// Session Activity Tracker Widget
// ════════════════════════════════════════════════════════════

/// Widget يتتبع نشاط المستخدم تلقائياً
class SessionActivityTracker extends StatefulWidget {
  final Widget child;

  const SessionActivityTracker({Key? key, required this.child})
      : super(key: key);

  @override
  State<SessionActivityTracker> createState() =>
      _SessionActivityTrackerState();
}

class _SessionActivityTrackerState extends State<SessionActivityTracker> {
  @override
  void initState() {
    super.initState();
    SessionManager.instance.startMonitoring();
  }

  @override
  void dispose() {
    // لا نوقف المراقبة هنا لأننا نريدها نشطة دائماً
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => SessionManager.instance.recordActivity(),
      onPanUpdate: (_) => SessionManager.instance.recordActivity(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
