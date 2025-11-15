// ════════════════════════════════════════════════════════════
// App Integration Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/cache/cache_manager.dart';
import 'package:gsloution_mobile/common/session/session_manager.dart';
import 'package:gsloution_mobile/common/offline/offline_queue_manager.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';

void main() {
  // تهيئة Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('App System Integration Tests', () {
    test('Storage and Cache should work together', () async {
      // Use StorageService to save data
      const token = 'integration_test_token';
      await StorageService.instance.saveToken(token);

      // Use CacheManager to cache data
      await CacheManager.instance.set(
        key: 'test_cache',
        data: {'token': token},
      );

      // Retrieve from both
      final storedToken = await StorageService.instance.getToken();
      final cachedData = await CacheManager.instance.get(key: 'test_cache');

      expect(storedToken, equals(token));
      expect(cachedData, isNotNull);
      expect(cachedData['token'], equals(token));

      // Cleanup
      await StorageService.instance.clearToken();
      await CacheManager.instance.invalidateAll();
    });

    test('Session and Storage should integrate properly', () async {
      final sessionManager = SessionManager.instance;

      // Simular iniciar sesión
      await StorageService.instance.setIsLoggedIn(true);
      await StorageService.instance.saveToken('session_token');

      // Verificar que la sesión está activa
      sessionManager.startMonitoring();
      expect(sessionManager.isActive, isTrue);

      // Limpiar
      sessionManager.stopMonitoring();
      await StorageService.instance.setIsLoggedIn(false);
      await StorageService.instance.clearToken();
    });

    test('Offline Queue and Storage should persist requests', () async {
      final queueManager = OfflineQueueManager.instance;

      // Add request to queue
      final request = PendingRequest(
        id: 'integration_test_1',
        operation: 'create',
        model: 'test.model',
        data: {'key': 'value'},
      );

      await queueManager.addToQueue(request);
      expect(queueManager.pendingCount, greaterThan(0));

      // Clear
      await queueManager.clearQueue();
    });

    test('ApiModeConfig should persist settings', () async {
      final config = ApiModeConfig.instance;

      // Get current mode
      final currentMode = config.currentMode;

      // Verify it's one of the valid modes
      expect(currentMode, anyOf([ApiMode.odooDirect, ApiMode.bridgeCore]));

      // Verify booleans are consistent
      if (currentMode == ApiMode.odooDirect) {
        expect(config.useOdooDirect, isTrue);
        expect(config.useBridgeCore, isFalse);
      } else {
        expect(config.useOdooDirect, isFalse);
        expect(config.useBridgeCore, isTrue);
      }
    });
  });

  group('Data Flow Integration Tests', () {
    test('Complete data flow: Storage -> Cache -> Retrieval', () async {
      // Step 1: Save to storage
      const testData = 'flow_test_data';
      await StorageService.instance.saveToken(testData);

      // Step 2: Cache it
      final token = await StorageService.instance.getToken();
      await CacheManager.instance.set(
        key: 'cached_token',
        data: token,
        ttl: const Duration(seconds: 30),
      );

      // Step 3: Retrieve from cache
      final cachedToken = await CacheManager.instance.get<String>(
        key: 'cached_token',
      );

      // Step 4: Verify data integrity
      expect(cachedToken, equals(testData));
      expect(token, equals(testData));

      // Cleanup
      await StorageService.instance.clearToken();
      await CacheManager.instance.invalidateAll();
    });

    test('Multiple systems should not conflict', () async {
      // Initialize multiple systems simultaneously
      final futures = [
        StorageService.instance.saveToken('token_1'),
        CacheManager.instance.set(key: 'key_1', data: 'data_1'),
        OfflineQueueManager.instance.addToQueue(
          PendingRequest(
            id: 'req_1',
            operation: 'create',
            model: 'test',
            data: {},
          ),
        ),
      ];

      await Future.wait(futures);

      // Verify each system works correctly
      expect(await StorageService.instance.getToken(), equals('token_1'));
      expect(
        await CacheManager.instance.get<String>(key: 'key_1'),
        equals('data_1'),
      );
      expect(OfflineQueueManager.instance.pendingCount, greaterThan(0));

      // Cleanup
      await StorageService.instance.clearToken();
      await CacheManager.instance.invalidateAll();
      await OfflineQueueManager.instance.clearQueue();
    });
  });

  group('Error Recovery Integration Tests', () {
    test('System should recover from storage errors', () async {
      // Save data
      await StorageService.instance.saveToken('recovery_token');

      // Simulate error by clearing
      await StorageService.instance.clearToken();

      // Recover by saving again
      await StorageService.instance.saveToken('new_token');

      final token = await StorageService.instance.getToken();
      expect(token, equals('new_token'));

      // Cleanup
      await StorageService.instance.clearToken();
    });

    test('Cache should handle expired data gracefully', () async {
      // Set cache with very short TTL
      await CacheManager.instance.set(
        key: 'expiring_key',
        data: 'expiring_data',
        ttl: const Duration(milliseconds: 10),
      );

      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 50));

      // Try to retrieve (should be null)
      final data = await CacheManager.instance.get(key: 'expiring_key');
      expect(data, isNull);

      // Set again
      await CacheManager.instance.set(
        key: 'expiring_key',
        data: 'new_data',
      );

      final newData = await CacheManager.instance.get<String>(
        key: 'expiring_key',
      );
      expect(newData, equals('new_data'));

      // Cleanup
      await CacheManager.instance.invalidateAll();
    });
  });

  group('Performance Integration Tests', () {
    test('System should handle concurrent operations efficiently', () async {
      final stopwatch = Stopwatch()..start();

      // Perform 50 concurrent operations
      final futures = <Future>[];

      for (var i = 0; i < 50; i++) {
        futures.add(
          CacheManager.instance.set(key: 'perf_key_$i', data: 'data_$i'),
        );
      }

      await Future.wait(futures);

      stopwatch.stop();

      // Should complete in reasonable time (< 5 seconds)
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      // Verify all were saved
      for (var i = 0; i < 50; i++) {
        final data = await CacheManager.instance.get<String>(
          key: 'perf_key_$i',
        );
        expect(data, equals('data_$i'));
      }

      // Cleanup
      await CacheManager.instance.invalidateAll();
    });

    test('Large data should be handled efficiently', () async {
      final largeList = List.generate(5000, (i) => 'Item $i');

      final stopwatch = Stopwatch()..start();

      await CacheManager.instance.set(
        key: 'large_data',
        data: largeList,
      );

      final retrieved = await CacheManager.instance.get<List>(
        key: 'large_data',
      );

      stopwatch.stop();

      expect(retrieved, isNotNull);
      expect(retrieved?.length, equals(5000));
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));

      // Cleanup
      await CacheManager.instance.invalidateAll();
    });
  });
}
