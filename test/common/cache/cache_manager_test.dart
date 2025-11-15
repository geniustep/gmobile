// ════════════════════════════════════════════════════════════
// CacheManager Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/cache/cache_manager.dart';

void main() {
  group('CacheManager Tests', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager.instance;
    });

    tearDown(() async {
      await cacheManager.invalidateAll();
    });

    test('should save and retrieve data from cache', () async {
      const key = 'test_key';
      const data = 'test_data';

      await cacheManager.set(key: key, data: data);
      final result = await cacheManager.get<String>(key: key);

      expect(result, equals(data));
    });

    test('should return null for non-existent key', () async {
      final result = await cacheManager.get<String>(key: 'non_existent_key');

      expect(result, isNull);
    });

    test('should respect TTL and expire data', () async {
      const key = 'expiring_key';
      const data = 'expiring_data';

      await cacheManager.set(
        key: key,
        data: data,
        ttl: const Duration(milliseconds: 100),
      );

      // قبل الانتهاء
      final resultBefore = await cacheManager.get<String>(key: key);
      expect(resultBefore, equals(data));

      // انتظار انتهاء الصلاحية
      await Future.delayed(const Duration(milliseconds: 150));

      // بعد الانتهاء
      final resultAfter = await cacheManager.get<String>(key: key);
      expect(resultAfter, isNull);
    });

    test('should invalidate specific cache key', () async {
      const key = 'test_key';
      const data = 'test_data';

      await cacheManager.set(key: key, data: data);
      await cacheManager.invalidate(key);

      final result = await cacheManager.get<String>(key: key);
      expect(result, isNull);
    });

    test('should invalidate all cache', () async {
      await cacheManager.set(key: 'key1', data: 'data1');
      await cacheManager.set(key: 'key2', data: 'data2');

      await cacheManager.invalidateAll();

      final result1 = await cacheManager.get<String>(key: 'key1');
      final result2 = await cacheManager.get<String>(key: 'key2');

      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('should handle complex data types', () async {
      const key = 'complex_key';
      final data = {
        'id': 1,
        'name': 'Test',
        'items': [1, 2, 3],
      };

      await cacheManager.set(key: key, data: data);
      final result = await cacheManager.get<Map<String, dynamic>>(key: key);

      expect(result, isNotNull);
      expect(result?['id'], equals(1));
      expect(result?['name'], equals('Test'));
      expect(result?['items'], equals([1, 2, 3]));
    });

    test('should use default TTL when not specified', () async {
      const key = 'default_ttl_key';
      const data = 'test_data';

      await cacheManager.set(key: key, data: data);
      final result = await cacheManager.get<String>(key: key);

      expect(result, equals(data));
    });
  });
}
