// ════════════════════════════════════════════════════════════
// AnalyticsService - تتبع الأحداث والتحليلات
// ════════════════════════════════════════════════════════════
//
// الميزات:
// - تتبع الأحداث (Events)
// - تتبع الشاشات (Screen Views)
// - تتبع الأخطاء (Errors)
// - User Properties
// - Custom Dimensions
// - دعم Firebase Analytics
// - دعم أنظمة تحليل متعددة
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsloution_mobile/common/logging/app_logger.dart';

// ════════════════════════════════════════════════════════════
// Analytics Event Model
// ════════════════════════════════════════════════════════════

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic>? parameters;
  final DateTime timestamp;

  AnalyticsEvent({required this.name, this.parameters, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters ?? {},
    'timestamp': timestamp.toIso8601String(),
  };
}

// ════════════════════════════════════════════════════════════
// Analytics Provider Interface
// ════════════════════════════════════════════════════════════

abstract class AnalyticsProvider {
  Future<void> logEvent(String name, Map<String, dynamic>? parameters);
  Future<void> setUserProperty(String name, String value);
  Future<void> setUserId(String? userId);
  Future<void> logScreenView(String screenName);
  Future<void> logError(String error, {StackTrace? stackTrace});
}

// ════════════════════════════════════════════════════════════
// Firebase Analytics Provider (placeholder for actual implementation)
// ════════════════════════════════════════════════════════════

class FirebaseAnalyticsProvider implements AnalyticsProvider {
  // TODO: Integrate actual Firebase Analytics
  // final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    if (kDebugMode) {
      print('📊 [Firebase] Event: $name');
      if (parameters != null) {
        print('   Parameters: $parameters');
      }
    }

    // TODO: Uncomment when Firebase Analytics is integrated
    // await _analytics.logEvent(
    //   name: name,
    //   parameters: parameters,
    // );
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (kDebugMode) {
      print('👤 [Firebase] User Property: $name = $value');
    }

    // TODO: Uncomment when Firebase Analytics is integrated
    // await _analytics.setUserProperty(name: name, value: value);
  }

  @override
  Future<void> setUserId(String? userId) async {
    if (kDebugMode) {
      print('👤 [Firebase] User ID: $userId');
    }

    // TODO: Uncomment when Firebase Analytics is integrated
    // await _analytics.setUserId(id: userId);
  }

  @override
  Future<void> logScreenView(String screenName) async {
    if (kDebugMode) {
      print('📱 [Firebase] Screen View: $screenName');
    }

    // TODO: Uncomment when Firebase Analytics is integrated
    // await _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> logError(String error, {StackTrace? stackTrace}) async {
    if (kDebugMode) {
      print('❌ [Firebase] Error: $error');
    }

    // Firebase Analytics doesn't have direct error logging
    // Use Crashlytics instead for errors
  }
}

// ════════════════════════════════════════════════════════════
// Local Analytics Provider (fallback)
// ════════════════════════════════════════════════════════════

class LocalAnalyticsProvider implements AnalyticsProvider {
  final List<AnalyticsEvent> _events = [];
  final Map<String, String> _userProperties = {};
  String? _userId;

  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    final event = AnalyticsEvent(name: name, parameters: parameters);
    _events.add(event);

    if (kDebugMode) {
      print('📊 [Local] Event: $name');
      if (parameters != null) {
        print('   Parameters: $parameters');
      }
    }

    // تسجيل في AppLogger
    await AppLogger.instance.log(
      'Analytics Event: $name',
      level: LogLevel.info,
      data: parameters,
    );

    // حذف الأحداث القديمة (الاحتفاظ بآخر 1000 فقط)
    if (_events.length > 1000) {
      _events.removeRange(0, _events.length - 1000);
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    _userProperties[name] = value;

    if (kDebugMode) {
      print('👤 [Local] User Property: $name = $value');
    }
  }

  @override
  Future<void> setUserId(String? userId) async {
    _userId = userId;

    if (kDebugMode) {
      print('👤 [Local] User ID: $userId');
    }
  }

  @override
  Future<void> logScreenView(String screenName) async {
    await logEvent('screen_view', {'screen_name': screenName});
  }

  @override
  Future<void> logError(String error, {StackTrace? stackTrace}) async {
    await logEvent('error', {
      'error_message': error,
      if (stackTrace != null) 'stack_trace': stackTrace.toString(),
    });
  }

  // ════════════════════════════════════════════════════════════
  // Export Methods
  // ════════════════════════════════════════════════════════════

  List<Map<String, dynamic>> exportEvents() {
    return _events.map((e) => e.toJson()).toList();
  }

  Map<String, String> getUserProperties() {
    return Map.from(_userProperties);
  }

  String? getUserId() => _userId;
}

// ════════════════════════════════════════════════════════════
// Analytics Service
// ════════════════════════════════════════════════════════════

class AnalyticsService {
  AnalyticsService._();

  static final AnalyticsService instance = AnalyticsService._();

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  final List<AnalyticsProvider> _providers = [];
  bool _isEnabled = true;

  // ════════════════════════════════════════════════════════════
  // Initialization
  // ════════════════════════════════════════════════════════════

  /// تهيئة Analytics
  Future<void> initialize({
    bool enableFirebase = false,
    bool enableLocal = true,
  }) async {
    if (kDebugMode) {
      print('📊 Initializing Analytics Service...');
    }

    // Firebase Analytics Provider
    if (enableFirebase) {
      try {
        _providers.add(FirebaseAnalyticsProvider());
        if (kDebugMode) {
          print('✅ Firebase Analytics enabled');
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Firebase Analytics initialization failed: $e');
        }
      }
    }

    // Local Analytics Provider (fallback)
    if (enableLocal) {
      _providers.add(LocalAnalyticsProvider());
      if (kDebugMode) {
        print('✅ Local Analytics enabled');
      }
    }

    if (kDebugMode) {
      print(
        '📊 Analytics Service initialized with ${_providers.length} provider(s)',
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Event Logging
  // ════════════════════════════════════════════════════════════

  /// تسجيل حدث
  Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    if (!_isEnabled) return;

    for (final provider in _providers) {
      try {
        await provider.logEvent(name, parameters);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Analytics provider error: $e');
        }
      }
    }
  }

  /// تسجيل عرض شاشة
  Future<void> logScreenView(String screenName) async {
    if (!_isEnabled) return;

    for (final provider in _providers) {
      try {
        await provider.logScreenView(screenName);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Analytics provider error: $e');
        }
      }
    }
  }

  /// تسجيل خطأ
  Future<void> logError(String error, {StackTrace? stackTrace}) async {
    if (!_isEnabled) return;

    for (final provider in _providers) {
      try {
        await provider.logError(error, stackTrace: stackTrace);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Analytics provider error: $e');
        }
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // User Properties
  // ════════════════════════════════════════════════════════════

  /// تعيين خاصية مستخدم
  Future<void> setUserProperty(String name, String value) async {
    if (!_isEnabled) return;

    for (final provider in _providers) {
      try {
        await provider.setUserProperty(name, value);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Analytics provider error: $e');
        }
      }
    }
  }

  /// تعيين معرف المستخدم
  Future<void> setUserId(String? userId) async {
    if (!_isEnabled) return;

    for (final provider in _providers) {
      try {
        await provider.setUserId(userId);
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Analytics provider error: $e');
        }
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Predefined Events (Common Analytics Events)
  // ════════════════════════════════════════════════════════════

  /// تسجيل تسجيل الدخول
  Future<void> logLogin({String? method}) async {
    await logEvent('login', parameters: {if (method != null) 'method': method});
  }

  /// تسجيل تسجيل الخروج
  Future<void> logLogout() async {
    await logEvent('logout');
  }

  /// تسجيل البحث
  Future<void> logSearch(String query) async {
    await logEvent('search', parameters: {'search_term': query});
  }

  /// تسجيل عرض منتج
  Future<void> logViewProduct(String productId, String productName) async {
    await logEvent(
      'view_item',
      parameters: {'item_id': productId, 'item_name': productName},
    );
  }

  /// تسجيل إضافة إلى السلة
  Future<void> logAddToCart(
    String productId,
    String productName,
    double price,
  ) async {
    await logEvent(
      'add_to_cart',
      parameters: {
        'item_id': productId,
        'item_name': productName,
        'price': price,
      },
    );
  }

  /// تسجيل إتمام عملية شراء
  Future<void> logPurchase({
    required String orderId,
    required double value,
    String? currency,
  }) async {
    await logEvent(
      'purchase',
      parameters: {
        'transaction_id': orderId,
        'value': value,
        if (currency != null) 'currency': currency,
      },
    );
  }

  /// تسجيل مشاركة
  Future<void> logShare({
    required String contentType,
    required String itemId,
  }) async {
    await logEvent(
      'share',
      parameters: {'content_type': contentType, 'item_id': itemId},
    );
  }

  /// تسجيل فتح التطبيق
  Future<void> logAppOpen() async {
    await logEvent('app_open');
  }

  // ════════════════════════════════════════════════════════════
  // API-Related Events
  // ════════════════════════════════════════════════════════════

  /// تسجيل API Call
  Future<void> logApiCall({
    required String endpoint,
    required String method,
    required int statusCode,
    required int duration,
  }) async {
    await logEvent(
      'api_call',
      parameters: {
        'endpoint': endpoint,
        'method': method,
        'status_code': statusCode,
        'duration_ms': duration,
      },
    );
  }

  /// تسجيل API Error
  Future<void> logApiError({
    required String endpoint,
    required String error,
  }) async {
    await logEvent(
      'api_error',
      parameters: {'endpoint': endpoint, 'error': error},
    );
  }

  // ════════════════════════════════════════════════════════════
  // Mode Switching (BridgeCore Integration)
  // ════════════════════════════════════════════════════════════

  /// تسجيل تبديل نظام API
  Future<void> logApiModeSwitch({
    required String fromMode,
    required String toMode,
  }) async {
    await logEvent(
      'api_mode_switch',
      parameters: {
        'from_mode': fromMode,
        'to_mode': toMode,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Management
  // ════════════════════════════════════════════════════════════

  /// تفعيل/تعطيل Analytics
  void setEnabled(bool enabled) {
    _isEnabled = enabled;

    if (kDebugMode) {
      print('📊 Analytics ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// الحصول على حالة التفعيل
  bool get isEnabled => _isEnabled;

  /// الحصول على عدد Providers المفعلة
  int get providerCount => _providers.length;
}

// ════════════════════════════════════════════════════════════
// Analytics Navigator Observer (لتتبع Navigation التلقائي)
// ════════════════════════════════════════════════════════════

class AnalyticsNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _logScreenView(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _logScreenView(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _logScreenView(newRoute);
    }
  }

  void _logScreenView(Route<dynamic> route) {
    final screenName = route.settings.name;
    if (screenName != null && screenName.isNotEmpty) {
      AnalyticsService.instance.logScreenView(screenName);
    }
  }
}
