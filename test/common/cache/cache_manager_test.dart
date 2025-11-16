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

  group('CacheManager Error Cases', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager.instance;
    });

    tearDown(() async {
      await cacheManager.invalidateAll();
    });

    test('should handle null key gracefully', () async {
      // Should not throw, but may return null or handle gracefully
      expect(() => cacheManager.get<String>(key: ''), returnsNormally);
    });

    test('should handle null data', () async {
      const key = 'null_data_key';

      await cacheManager.set(key: key, data: null);
      final result = await cacheManager.get(key: key);

      // Depending on implementation, might be null
      expect(result, anyOf([isNull, equals(null)]));
    });

    test('should handle very large data', () async {
      const key = 'large_data_key';
      final largeData = List.generate(10000, (i) => 'Item $i');

      await cacheManager.set(key: key, data: largeData);
      final result = await cacheManager.get<List>(key: key);

      expect(result, isNotNull);
      expect(result?.length, equals(10000));
    });

    test('should handle special characters in keys', () async {
      const key = 'key_with_!@#\$%^&*()_+-=';
      const data = 'test';

      await cacheManager.set(key: key, data: data);
      final result = await cacheManager.get<String>(key: key);

      expect(result, equals(data));
    });

    test('should handle concurrent cache operations', () async {
      final futures = List.generate(
        10,
        (i) => cacheManager.set(key: 'key$i', data: 'data$i'),
      );

      await Future.wait(futures);

      // All should be saved
      for (var i = 0; i < 10; i++) {
        final result = await cacheManager.get<String>(key: 'key$i');
        expect(result, equals('data$i'));
      }
    });

    test('should handle invalidation of non-existent key', () async {
      // Should not throw
      expect(
        () => cacheManager.invalidate('non_existent_key'),
        returnsNormally,
      );
    });

    test('should handle multiple invalidateAll calls', () async {
      await cacheManager.set(key: 'key1', data: 'data1');

      await cacheManager.invalidateAll();
      await cacheManager.invalidateAll(); // Second call

      // Should not throw
      expect(() => cacheManager.invalidateAll(), returnsNormally);
    });
  });

  group('CacheManager Edge Cases', () {
    late CacheManager cacheManager;

    setUp(() {
      cacheManager = CacheManager.instance;
    });

    tearDown(() async {
      await cacheManager.invalidateAll();
    });

    test('should handle very short TTL', () async {
      const key = 'short_ttl_key';
      const data = 'test';

      await cacheManager.set(
        key: key,
        data: data,
        ttl: const Duration(milliseconds: 1),
      );

      await Future.delayed(const Duration(milliseconds: 10));

      final result = await cacheManager.get<String>(key: key);
      expect(result, isNull);
    });

    test('should handle zero TTL', () async {
      const key = 'zero_ttl_key';
      const data = 'test';

      await cacheManager.set(key: key, data: data, ttl: Duration.zero);

      final result = await cacheManager.get<String>(key: key);
      // Should be expired immediately
      expect(result, isNull);
    });

    test('should handle updating existing cache entry', () async {
      const key = 'update_key';

      await cacheManager.set(key: key, data: 'old_data');
      await cacheManager.set(key: key, data: 'new_data');

      final result = await cacheManager.get<String>(key: key);
      expect(result, equals('new_data'));
    });

    test('should handle different data types for same key', () async {
      const key = 'type_change_key';

      await cacheManager.set(key: key, data: 'string_data');
      final stringResult = await cacheManager.get<String>(key: key);
      expect(stringResult, equals('string_data'));

      await cacheManager.set(key: key, data: 123);
      final intResult = await cacheManager.get<int>(key: key);
      expect(intResult, equals(123));
    });
  });
}
