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
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _databaseKey = 'database';
  static const String _systemIdKey = 'system_id';
  static const String _lastActivityKey = 'last_activity';

  // ════════════════════════════════════════════════════════════
  // Token Management
  // ════════════════════════════════════════════════════════════

  /// حفظ Session Token
  static Future<void> saveSessionToken(String token) async {
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
  static Future<String?> getSessionToken() async {
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
  static Future<void> saveRefreshToken(String token) async {
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
  static Future<String?> getRefreshToken() async {
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
  static Future<void> deleteSessionToken() async {
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
  static Future<void> deleteAllTokens() async {
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

  /// مسح جميع البيانات (alias for deleteAllTokens)
  static Future<void> clearAll() async {
    await deleteAllTokens();
  }

  /// مسح بيانات Session فقط
  static Future<void> clearSession() async {
    await deleteSessionToken();
  }

  // ════════════════════════════════════════════════════════════
  // User Information
  // ════════════════════════════════════════════════════════════

  /// حفظ User ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// الحصول على User ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// حفظ Username
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  /// الحصول على Username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  /// حفظ Database Name
  static Future<void> saveDatabase(String database) async {
    await _storage.write(key: _databaseKey, value: database);
  }

  /// الحصول على Database Name
  static Future<String?> getDatabase() async {
    return await _storage.read(key: _databaseKey);
  }

  /// حفظ Access Token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// الحصول على Access Token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// حفظ System ID
  static Future<void> saveSystemId(String systemId) async {
    await _storage.write(key: _systemIdKey, value: systemId);
  }

  /// الحصول على System ID
  static Future<String?> getSystemId() async {
    return await _storage.read(key: _systemIdKey);
  }

  /// حفظ Last Activity (مع DateTime)
  static Future<void> saveLastActivity(DateTime dateTime) async {
    await _storage.write(key: _lastActivityKey, value: dateTime.toIso8601String());
  }

  /// التحقق من صحة Token
  static Future<bool> isValidToken(String token) async {
    // التحقق من أن Token ليس فارغاً
    if (token.isEmpty) return false;
    
    // يمكن إضافة المزيد من التحقق هنا (مثل JWT format)
    return true;
  }

  // ════════════════════════════════════════════════════════════
  // Session Activity Tracking
  // ════════════════════════════════════════════════════════════

  /// تحديث آخر نشاط
  static Future<void> updateLastActivity() async {
    final now = DateTime.now().toIso8601String();
    await _storage.write(key: _lastActivityKey, value: now);
  }

  /// الحصول على آخر نشاط
  static Future<DateTime?> getLastActivity() async {
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
  static Future<Duration?> getTimeSinceLastActivity() async {
    final lastActivity = await getLastActivity();
    if (lastActivity == null) return null;

    return DateTime.now().difference(lastActivity);
  }

  // ════════════════════════════════════════════════════════════
  // Validation
  // ════════════════════════════════════════════════════════════

  /// التحقق من وجود session نشط
  static Future<bool> hasActiveSession() async {
    final token = await getSessionToken();
    return token != null && token.isNotEmpty;
  }

  /// التحقق من انتهاء صلاحية Session (30 دقيقة)
  static Future<bool> isSessionExpired({
    Duration sessionTimeout = const Duration(minutes: 30),
  }) async {
    final timeSinceActivity = await getTimeSinceLastActivity();
    if (timeSinceActivity == null) return true;

    return timeSinceActivity > sessionTimeout;
  }

  /// التحقق من الحاجة لتحذير (25 دقيقة)
  static Future<bool> shouldShowSessionWarning({
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
  static Future<Map<String, String>> getAllSecureData() async {
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
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      return false;
    }
  }

  /// طباعة معلومات debug
  static Future<void> printDebugInfo() async {
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

  // ════════════════════════════════════════════════════════════
  // Static Helper Methods (for tests compatibility)
  // ════════════════════════════════════════════════════════════

  static Future<void> saveUid(int uid) async {
    await saveUserId(uid.toString());
  }

  static Future<int?> getUid() async {
    final userId = await getUserId();
    if (userId == null) return null;
    return int.tryParse(userId);
  }

  static Future<void> saveDbName(String dbName) async {
    await saveDatabase(dbName);
  }

  static Future<String?> getDbName() async {
    return await getDatabase();
  }
}
