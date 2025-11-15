// ════════════════════════════════════════════════════════════
// SecureTokenStorage - تخزين آمن للـ Tokens
// ════════════════════════════════════════════════════════════
//
// يستخدم FlutterSecureStorage لتخزين Tokens بشكل مشفر
// بدلاً من SharedPreferences غير الآمن
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  SecureTokenStorage._();

  static final SecureTokenStorage instance = SecureTokenStorage._();

  // ════════════════════════════════════════════════════════════
  // Storage Instance
  // ════════════════════════════════════════════════════════════

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ════════════════════════════════════════════════════════════
  // Keys
  // ════════════════════════════════════════════════════════════

  static const String _sessionTokenKey = 'session_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _databaseKey = 'database';
  static const String _lastActivityKey = 'last_activity';

  // ════════════════════════════════════════════════════════════
  // Token Management
  // ════════════════════════════════════════════════════════════

  /// حفظ Session Token
  Future<void> saveSessionToken(String token) async {
    try {
      await _storage.write(key: _sessionTokenKey, value: token);
      await updateLastActivity();

      if (kDebugMode) {
        print('✅ Session token saved securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving session token: $e');
      }
      rethrow;
    }
  }

  /// الحصول على Session Token
  Future<String?> getSessionToken() async {
    try {
      return await _storage.read(key: _sessionTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading session token: $e');
      }
      return null;
    }
  }

  /// حفظ Refresh Token
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: token);

      if (kDebugMode) {
        print('✅ Refresh token saved securely');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving refresh token: $e');
      }
      rethrow;
    }
  }

  /// الحصول على Refresh Token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading refresh token: $e');
      }
      return null;
    }
  }

  /// حذف Session Token
  Future<void> deleteSessionToken() async {
    try {
      await _storage.delete(key: _sessionTokenKey);

      if (kDebugMode) {
        print('🗑️ Session token deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting session token: $e');
      }
    }
  }

  /// حذف جميع Tokens
  Future<void> deleteAllTokens() async {
    try {
      await _storage.deleteAll();

      if (kDebugMode) {
        print('🗑️ All tokens deleted');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting all tokens: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // User Information
  // ════════════════════════════════════════════════════════════

  /// حفظ User ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// الحصول على User ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// حفظ Username
  Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  /// الحصول على Username
  Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// حفظ Database Name
  Future<void> saveDatabase(String database) async {
    await _storage.write(key: _databaseKey, value: database);
  }

  /// الحصول على Database Name
  Future<String?> getDatabase() async {
    return await _storage.read(key: _databaseKey);
  }

  // ════════════════════════════════════════════════════════════
  // Session Activity Tracking
  // ════════════════════════════════════════════════════════════

  /// تحديث آخر نشاط
  Future<void> updateLastActivity() async {
    final now = DateTime.now().toIso8601String();
    await _storage.write(key: _lastActivityKey, value: now);
  }

  /// الحصول على آخر نشاط
  Future<DateTime?> getLastActivity() async {
    try {
      final activityStr = await _storage.read(key: _lastActivityKey);
      if (activityStr == null) return null;

      return DateTime.parse(activityStr);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading last activity: $e');
      }
      return null;
    }
  }

  /// حساب الوقت منذ آخر نشاط
  Future<Duration?> getTimeSinceLastActivity() async {
    final lastActivity = await getLastActivity();
    if (lastActivity == null) return null;

    return DateTime.now().difference(lastActivity);
  }

  // ════════════════════════════════════════════════════════════
  // Validation
  // ════════════════════════════════════════════════════════════

  /// التحقق من وجود session نشط
  Future<bool> hasActiveSession() async {
    final token = await getSessionToken();
    return token != null && token.isNotEmpty;
  }

  /// التحقق من انتهاء صلاحية Session (30 دقيقة)
  Future<bool> isSessionExpired({
    Duration sessionTimeout = const Duration(minutes: 30),
  }) async {
    final timeSinceActivity = await getTimeSinceLastActivity();
    if (timeSinceActivity == null) return true;

    return timeSinceActivity > sessionTimeout;
  }

  /// التحقق من الحاجة لتحذير (25 دقيقة)
  Future<bool> shouldShowSessionWarning({
    Duration warningThreshold = const Duration(minutes: 25),
  }) async {
    final timeSinceActivity = await getTimeSinceLastActivity();
    if (timeSinceActivity == null) return false;

    return timeSinceActivity > warningThreshold;
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  /// الحصول على جميع المفاتيح المحفوظة
  Future<Map<String, String>> getAllSecureData() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error reading all secure data: $e');
      }
      return {};
    }
  }

  /// التحقق من وجود مفتاح معين
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  /// طباعة معلومات debug
  Future<void> printDebugInfo() async {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════════════════════');
    print('🔐 Secure Token Storage Debug Info');
    print('═══════════════════════════════════════════════════════');

    final hasSession = await hasActiveSession();
    final isExpired = await isSessionExpired();
    final timeSinceActivity = await getTimeSinceLastActivity();

    print('Has Active Session: $hasSession');
    print('Is Expired: $isExpired');
    print('Time Since Last Activity: ${timeSinceActivity?.inMinutes ?? 0} minutes');

    final allKeys = await getAllSecureData();
    print('Stored Keys: ${allKeys.keys.join(', ')}');

    print('═══════════════════════════════════════════════════════');
  }
}
