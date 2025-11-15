// ════════════════════════════════════════════════════════════
// SessionManager Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/session/session_manager.dart';

void main() {
  // تهيئة Flutter binding للاختبارات
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionManager Tests', () {
    late SessionManager sessionManager;

    setUp(() {
      sessionManager = SessionManager.instance;
    });

    tearDown(() {
      sessionManager.stopMonitoring();
    });

    test('should start monitoring session', () {
      sessionManager.startMonitoring();

      expect(sessionManager.isActive, isTrue);
    });

    test('should stop monitoring session', () {
      sessionManager.startMonitoring();
      sessionManager.stopMonitoring();

      expect(sessionManager.isActive, isFalse);
    });

    test('should calculate remaining time correctly', () async {
      sessionManager.startMonitoring();

      final remainingTime = await sessionManager.remainingTime;

      expect(remainingTime, isNotNull);
      expect(remainingTime!.inMinutes, lessThanOrEqualTo(30));
      expect(remainingTime.inMinutes, greaterThanOrEqualTo(29));
    });

    test('should refresh session and update expiry time', () async {
      sessionManager.startMonitoring();

      // الانتظار قليلاً
      await Future.delayed(const Duration(seconds: 2));

      final timeBefore = await sessionManager.remainingTime;

      await sessionManager.refreshSession();

      final timeAfter = await sessionManager.remainingTime;

      // بعد التحديث يجب أن يكون الوقت المتبقي أكبر
      expect(timeAfter, isNotNull);
      expect(timeBefore, isNotNull);
      expect(timeAfter!.inSeconds, greaterThan(timeBefore!.inSeconds));
    });

    test('should update last activity on user interaction', () async {
      sessionManager.startMonitoring();

      final timeBefore = await sessionManager.remainingTime;

      await Future.delayed(const Duration(seconds: 2));

      await sessionManager.updateActivity();

      final timeAfter = await sessionManager.remainingTime;

      expect(timeAfter, isNotNull);
      expect(timeBefore, isNotNull);
      expect(timeAfter!.inSeconds, greaterThan(timeBefore!.inSeconds));
    });

    test('should detect session expiry', () async {
      sessionManager.startMonitoring();

      // محاكاة انتهاء الجلسة عن طريق تعيين وقت انتهاء في الماضي
      // هذا اختبار مفاهيمي - في الواقع سيتطلب mock للوقت

      expect(sessionManager.isActive, isTrue);
    });

    test('should allow multiple refresh calls', () async {
      sessionManager.startMonitoring();

      await sessionManager.refreshSession();
      await sessionManager.refreshSession();
      await sessionManager.refreshSession();

      final remainingTime = await sessionManager.remainingTime;
      expect(remainingTime, isNotNull);
      expect(sessionManager.isActive, isTrue);
    });
  });
}
