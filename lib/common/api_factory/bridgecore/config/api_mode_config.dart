// ════════════════════════════════════════════════════════════
// ApiModeConfig - تكوين نظام التبديل بين Odoo المباشر و BridgeCore
// ════════════════════════════════════════════════════════════
//
// هذا الملف يسمح بالتبديل السلس بين النظامين:
// 1. Odoo Direct: الاتصال المباشر بـ Odoo (النظام القديم)
// 2. BridgeCore: الاتصال عبر BridgeCore middleware (النظام الجديد)
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ════════════════════════════════════════════════════════════
// Enums
// ════════════════════════════════════════════════════════════

/// أوضاع API المتاحة
enum ApiMode {
  /// الاتصال المباشر بـ Odoo (النظام القديم)
  odooDirect,

  /// الاتصال عبر BridgeCore middleware (النظام الجديد)
  bridgeCore,
}

extension ApiModeExtension on ApiMode {
  String get name {
    switch (this) {
      case ApiMode.odooDirect:
        return 'Odoo Direct';
      case ApiMode.bridgeCore:
        return 'BridgeCore';
    }
  }

  String get description {
    switch (this) {
      case ApiMode.odooDirect:
        return 'الاتصال المباشر بـ Odoo (النظام التقليدي)';
      case ApiMode.bridgeCore:
        return 'الاتصال عبر BridgeCore middleware (محسّن)';
    }
  }
}

// ════════════════════════════════════════════════════════════
// ApiModeConfig Class
// ════════════════════════════════════════════════════════════

class ApiModeConfig {
  ApiModeConfig._();

  static final ApiModeConfig instance = ApiModeConfig._();

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  /// الوضع الحالي (افتراضي: Odoo Direct للتوافق مع النظام القديم)
  ApiMode _currentMode = ApiMode.odooDirect;

  /// هل A/B Testing مفعّل؟
  bool _enableABTesting = false;

  /// نسبة المستخدمين الذين يستخدمون BridgeCore في A/B Testing (0.0 - 1.0)
  double _bridgeCoreUserPercentage = 0.10; // 10% افتراضياً

  /// مفتاح للتخزين
  static const String _prefKey = 'api_mode_config';
  static const String _abTestingKey = 'ab_testing_enabled';
  static const String _userPercentageKey = 'bridgecore_user_percentage';

  // ════════════════════════════════════════════════════════════
  // Getters
  // ════════════════════════════════════════════════════════════

  /// الوضع الحالي
  ApiMode get currentMode => _currentMode;

  /// هل نستخدم BridgeCore؟
  bool get useBridgeCore => _currentMode == ApiMode.bridgeCore;

  /// هل نستخدم Odoo المباشر؟
  bool get useOdooDirect => _currentMode == ApiMode.odooDirect;

  /// هل A/B Testing مفعّل؟
  bool get enableABTesting => _enableABTesting;

  /// نسبة مستخدمي BridgeCore
  double get bridgeCoreUserPercentage => _bridgeCoreUserPercentage;

  // ════════════════════════════════════════════════════════════
  // URLs Configuration
  // ════════════════════════════════════════════════════════════

  /// رابط Odoo المباشر (من config)
  String get odooUrl {
    // سيتم استخدام القيمة من Config الحالي
    // Config.odooDevURL أو Config.odooProdURL
    return '';
  }

  /// رابط BridgeCore API
  String get bridgeCoreUrl {
    // Production URL - BridgeCore Middleware Server
    return 'https://bridgecore.geniura.com';

    // يمكن التبديل للـ Development إذا لزم الأمر:
    // if (kDebugMode) {
    //   return 'http://localhost:8000'; // Development
    // } else {
    //   return 'https://bridgecore.geniura.com'; // Production
    // }
  }

  /// الـ URL الحالي المستخدم
  String get currentApiUrl {
    return useBridgeCore ? bridgeCoreUrl : odooUrl;
  }

  // ════════════════════════════════════════════════════════════
  // Mode Management
  // ════════════════════════════════════════════════════════════

  /// تبديل الوضع يدوياً
  Future<void> setMode(ApiMode mode) async {
    if (_currentMode == mode) return;

    final oldMode = _currentMode;
    _currentMode = mode;

    // حفظ في SharedPreferences
    await _saveToPrefs();

    if (kDebugMode) {
      print('🔄 API Mode changed: ${oldMode.name} → ${mode.name}');
    }
  }

  /// تفعيل/تعطيل A/B Testing
  Future<void> setABTesting(bool enabled) async {
    if (_enableABTesting == enabled) return;

    _enableABTesting = enabled;
    await _saveToPrefs();

    if (kDebugMode) {
      print('🧪 A/B Testing ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// تعيين نسبة مستخدمي BridgeCore
  Future<void> setBridgeCorePercentage(double percentage) async {
    if (percentage < 0.0 || percentage > 1.0) {
      throw ArgumentError('Percentage must be between 0.0 and 1.0');
    }

    if (_bridgeCoreUserPercentage == percentage) return;

    _bridgeCoreUserPercentage = percentage;
    await _saveToPrefs();

    if (kDebugMode) {
      print(
        '📊 BridgeCore user percentage set to: ${(percentage * 100).toStringAsFixed(0)}%',
      );
    }
  }

  /// تحديد الوضع بناءً على User ID (للـ A/B Testing)
  Future<void> setModeForUser(String userId) async {
    if (!_enableABTesting) {
      // إذا A/B Testing معطّل، استخدم الوضع الحالي
      return;
    }

    // استخدام hash للحصول على توزيع عادل
    final hash = userId.hashCode.abs();
    final percentage = (hash % 100) / 100.0;

    final shouldUseBridgeCore = percentage < _bridgeCoreUserPercentage;

    final newMode =
        shouldUseBridgeCore ? ApiMode.bridgeCore : ApiMode.odooDirect;

    if (_currentMode != newMode) {
      _currentMode = newMode;
      await _saveToPrefs();

      if (kDebugMode) {
        print('🎲 A/B Testing assigned user $userId to: ${newMode.name}');
        print('   Hash: $hash, Percentage: ${(percentage * 100).toStringAsFixed(2)}%');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Persistence
  // ════════════════════════════════════════════════════════════

  /// تحميل الإعدادات من SharedPreferences
  Future<void> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // تحميل الوضع
      final modeString = prefs.getString(_prefKey);
      if (modeString != null) {
        _currentMode = modeString == 'bridgeCore'
            ? ApiMode.bridgeCore
            : ApiMode.odooDirect;
      }

      // تحميل A/B Testing
      _enableABTesting = prefs.getBool(_abTestingKey) ?? false;

      // تحميل النسبة
      _bridgeCoreUserPercentage = prefs.getDouble(_userPercentageKey) ?? 0.10;

      if (kDebugMode) {
        print('✅ Loaded API Mode Config:');
        print('   Mode: ${_currentMode.name}');
        print('   A/B Testing: $_enableABTesting');
        print('   BridgeCore %: ${(_bridgeCoreUserPercentage * 100).toStringAsFixed(0)}%');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading API Mode Config: $e');
      }
    }
  }

  /// حفظ الإعدادات في SharedPreferences
  Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _prefKey,
        _currentMode == ApiMode.bridgeCore ? 'bridgeCore' : 'odooDirect',
      );

      await prefs.setBool(_abTestingKey, _enableABTesting);

      await prefs.setDouble(_userPercentageKey, _bridgeCoreUserPercentage);

      if (kDebugMode) {
        print('💾 Saved API Mode Config');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving API Mode Config: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  /// إعادة تعيين للإعدادات الافتراضية
  Future<void> resetToDefaults() async {
    _currentMode = ApiMode.odooDirect;
    _enableABTesting = false;
    _bridgeCoreUserPercentage = 0.10;

    await _saveToPrefs();

    if (kDebugMode) {
      print('🔄 Reset API Mode Config to defaults');
    }
  }

  /// الحصول على معلومات التكوين
  Map<String, dynamic> getInfo() {
    return {
      'currentMode': _currentMode.name,
      'useBridgeCore': useBridgeCore,
      'enableABTesting': _enableABTesting,
      'bridgeCoreUserPercentage': _bridgeCoreUserPercentage,
      'bridgeCoreUrl': bridgeCoreUrl,
    };
  }

  /// طباعة معلومات التكوين
  void printInfo() {
    if (kDebugMode) {
      print('📊 API Mode Config Info:');
      print('   Current Mode: ${_currentMode.name}');
      print('   Using BridgeCore: $useBridgeCore');
      print('   A/B Testing: $_enableABTesting');
      print('   BridgeCore %: ${(_bridgeCoreUserPercentage * 100).toStringAsFixed(0)}%');
      print('   BridgeCore URL: $bridgeCoreUrl');
    }
  }
}
