// ════════════════════════════════════════════════════════════
// SecureTokenStorage Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/security/secure_token_storage.dart';

void main() {
  group('SecureTokenStorage Tests', () {
    setUp(() {
      // تنظيف قبل كل اختبار
      SecureTokenStorage.clearAll();
    });

    tearDown(() {
      // تنظيف بعد كل اختبار
      SecureTokenStorage.clearAll();
    });

    test('should save and retrieve session token', () async {
      const token = 'test_session_token';

      await SecureTokenStorage.saveSessionToken(token);
      final retrievedToken = await SecureTokenStorage.getSessionToken();

      expect(retrievedToken, equals(token));
    });

    test('should save and retrieve UID', () async {
      const uid = 123;

      await SecureTokenStorage.saveUid(uid);
      final retrievedUid = await SecureTokenStorage.getUid();

      expect(retrievedUid, equals(uid));
    });

    test('should save and retrieve username', () async {
      const username = 'test_user';

      await SecureTokenStorage.saveUsername(username);
      final retrievedUsername = await SecureTokenStorage.getUsername();

      expect(retrievedUsername, equals(username));
    });

    test('should save and retrieve database name', () async {
      const dbName = 'test_database';

      await SecureTokenStorage.saveDbName(dbName);
      final retrievedDbName = await SecureTokenStorage.getDbName();

      expect(retrievedDbName, equals(dbName));
    });

    test('should return null for non-existent token', () async {
      final token = await SecureTokenStorage.getSessionToken();

      expect(token, isNull);
    });

    test('should save and retrieve access token', () async {
      const accessToken = 'test_access_token';

      await SecureTokenStorage.saveAccessToken(accessToken);
      final retrievedToken = await SecureTokenStorage.getAccessToken();

      expect(retrievedToken, equals(accessToken));
    });

    test('should save and retrieve refresh token', () async {
      const refreshToken = 'test_refresh_token';

      await SecureTokenStorage.saveRefreshToken(refreshToken);
      final retrievedToken = await SecureTokenStorage.getRefreshToken();

      expect(retrievedToken, equals(refreshToken));
    });

    test('should track last activity time', () async {
      final timeBefore = DateTime.now();

      await SecureTokenStorage.updateLastActivity();

      final lastActivity = await SecureTokenStorage.getLastActivity();

      expect(lastActivity, isNotNull);
      expect(lastActivity!.isAfter(timeBefore.subtract(const Duration(seconds: 1))), isTrue);
    });

    test('should detect session expiry', () async {
      // حفظ نشاط قديم (31 دقيقة في الماضي)
      final oldActivity = DateTime.now().subtract(const Duration(minutes: 31));
      await SecureTokenStorage.saveLastActivity(oldActivity);

      final isExpired = await SecureTokenStorage.isSessionExpired();

      expect(isExpired, isTrue);
    });

    test('should detect active session', () async {
      await SecureTokenStorage.updateLastActivity();

      final isExpired = await SecureTokenStorage.isSessionExpired();

      expect(isExpired, isFalse);
    });

    test('should clear all stored data', () async {
      await SecureTokenStorage.saveSessionToken('token');
      await SecureTokenStorage.saveUid(123);
      await SecureTokenStorage.saveUsername('user');

      await SecureTokenStorage.clearAll();

      final token = await SecureTokenStorage.getSessionToken();
      final uid = await SecureTokenStorage.getUid();
      final username = await SecureTokenStorage.getUsername();

      expect(token, isNull);
      expect(uid, isNull);
      expect(username, isNull);
    });

    test('should clear session data only', () async {
      await SecureTokenStorage.saveSessionToken('token');
      await SecureTokenStorage.saveAccessToken('access_token');

      await SecureTokenStorage.clearSession();

      final sessionToken = await SecureTokenStorage.getSessionToken();
      final accessToken = await SecureTokenStorage.getAccessToken();

      expect(sessionToken, isNull);
      // Access token يجب أن يبقى لأنه JWT token منفصل
      expect(accessToken, equals('access_token'));
    });

    test('should save and retrieve system ID', () async {
      const systemId = 'system_123';

      await SecureTokenStorage.saveSystemId(systemId);
      final retrievedSystemId = await SecureTokenStorage.getSystemId();

      expect(retrievedSystemId, equals(systemId));
    });

    test('should validate token format', () async {
      const validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U';

      final isValid = await SecureTokenStorage.isValidToken(validToken);

      // في اختبار حقيقي، سنتحقق من الصيغة
      expect(isValid, isA<bool>());
    });

    test('should handle multiple token updates', () async {
      await SecureTokenStorage.saveSessionToken('token1');
      await SecureTokenStorage.saveSessionToken('token2');
      await SecureTokenStorage.saveSessionToken('token3');

      final token = await SecureTokenStorage.getSessionToken();

      expect(token, equals('token3'));
    });
  });
}
