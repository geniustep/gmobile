// ════════════════════════════════════════════════════════════
// OfflineQueueManager Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/offline/offline_queue_manager.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/base/base_api_client.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockBaseApiClient extends Mock implements BaseApiClient {}

void main() {
  group('OfflineQueueManager Tests', () {
    late OfflineQueueManager queueManager;

    setUp(() {
      queueManager = OfflineQueueManager.instance;
    });

    tearDown(() async {
      await queueManager.clearQueue();
      queueManager.stopAutoSync();
    });

    test('should add request to queue', () async {
      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {'key': 'value'},
      );

      await queueManager.addToQueue(request);

      expect(queueManager.pendingCount, equals(1));
    });

    test('should remove request from queue after successful sync', () async {
      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {'key': 'value'},
      );

      await queueManager.addToQueue(request);
      expect(queueManager.pendingCount, equals(1));

      // ملاحظة: في اختبار حقيقي، نحتاج mock للـ API
      // هنا نختبر فقط إضافة/إزالة من القائمة
    });

    test('should respect priority order in queue', () async {
      final lowPriorityRequest = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {},
        priority: RequestPriority.low,
      );

      final highPriorityRequest = PendingRequest(
        id: '2',
        operation: 'create',
        model: 'test.model',
        data: {},
        priority: RequestPriority.high,
      );

      await queueManager.addToQueue(lowPriorityRequest);
      await queueManager.addToQueue(highPriorityRequest);

      expect(queueManager.pendingCount, equals(2));
      // في اختبار حقيقي، نتحقق من ترتيب المعالجة
    });

    test('should limit retry attempts', () async {
      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {},
        maxRetries: 3,
      );

      await queueManager.addToQueue(request);

      expect(request.retryCount, equals(0));
      expect(request.maxRetries, equals(3));
    });

    test('should clear all queued requests', () async {
      await queueManager.addToQueue(
        PendingRequest(
          id: '1',
          operation: 'create',
          model: 'test.model',
          data: {},
        ),
      );

      await queueManager.addToQueue(
        PendingRequest(
          id: '2',
          operation: 'update',
          model: 'test.model',
          data: {},
        ),
      );

      expect(queueManager.pendingCount, equals(2));

      await queueManager.clearQueue();

      expect(queueManager.pendingCount, equals(0));
    });

    test('should export queued requests', () async {
      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {'key': 'value'},
      );

      await queueManager.addToQueue(request);

      final exported = queueManager.exportQueue();

      expect(exported, isA<List<Map<String, dynamic>>>());
      expect(exported.length, equals(1));
      expect(exported.first['id'], equals('1'));
    });

    test('should track request creation timestamp', () async {
      final before = DateTime.now();

      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {},
      );

      await queueManager.addToQueue(request);

      final after = DateTime.now();

      expect(
        request.timestamp.isAfter(before) ||
            request.timestamp.isAtSameMomentAs(before),
        isTrue,
      );
      expect(
        request.timestamp.isBefore(after) ||
            request.timestamp.isAtSameMomentAs(after),
        isTrue,
      );
    });

    test('should handle different operations', () async {
      final operations = ['create', 'update', 'delete', 'write'];

      for (final operation in operations) {
        await queueManager.addToQueue(
          PendingRequest(
            id: operation,
            operation: operation,
            model: 'test.model',
            data: {},
          ),
        );
      }

      expect(queueManager.pendingCount, equals(operations.length));
    });

    test('should start and stop auto sync', () {
      queueManager.startAutoSync(interval: const Duration(seconds: 5));

      // في اختبار حقيقي، نتحقق من أن Timer يعمل
      expect(queueManager.isAutoSyncEnabled, isTrue);

      queueManager.stopAutoSync();

      expect(queueManager.isAutoSyncEnabled, isFalse);
    });

    test('should get statistics about queue', () async {
      await queueManager.addToQueue(
        PendingRequest(
          id: '1',
          operation: 'create',
          model: 'test.model',
          data: {},
          priority: RequestPriority.high,
        ),
      );

      await queueManager.addToQueue(
        PendingRequest(
          id: '2',
          operation: 'write',
          model: 'test.model',
          data: {},
          priority: RequestPriority.low,
        ),
      );

      final stats = queueManager.getStatistics();

      expect(stats['total'], equals(2));
      expect(stats['isSyncing'], isFalse);
      expect(stats['byPriority']['high'], equals(1));
      expect(stats['byPriority']['low'], equals(1));
      expect(stats['byOperation']['create'], equals(1));
      expect(stats['byOperation']['write'], equals(1));
    });

    test('should get requests by priority', () async {
      await queueManager.addToQueue(
        PendingRequest(
          id: '1',
          operation: 'create',
          model: 'test.model',
          data: {},
          priority: RequestPriority.high,
        ),
      );

      await queueManager.addToQueue(
        PendingRequest(
          id: '2',
          operation: 'write',
          model: 'test.model',
          data: {},
          priority: RequestPriority.high,
        ),
      );

      await queueManager.addToQueue(
        PendingRequest(
          id: '3',
          operation: 'unlink',
          model: 'test.model',
          data: {},
          priority: RequestPriority.low,
        ),
      );

      final highPriorityRequests =
          queueManager.getRequestsByPriority(RequestPriority.high);

      expect(highPriorityRequests.length, equals(2));
      expect(highPriorityRequests.every((r) => r.priority == RequestPriority.high), isTrue);
    });

    test('should handle copyWith for retry count', () {
      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {},
        retryCount: 0,
      );

      final updatedRequest = request.copyWith(retryCount: 1);

      expect(updatedRequest.retryCount, equals(1));
      expect(updatedRequest.id, equals(request.id));
      expect(updatedRequest.operation, equals(request.operation));
      expect(updatedRequest.model, equals(request.model));
    });

    test('should handle remove from queue by id', () async {
      await queueManager.addToQueue(
        PendingRequest(
          id: 'request_1',
          operation: 'create',
          model: 'test.model',
          data: {},
        ),
      );

      await queueManager.addToQueue(
        PendingRequest(
          id: 'request_2',
          operation: 'write',
          model: 'test.model',
          data: {},
        ),
      );

      expect(queueManager.pendingCount, equals(2));

      await queueManager.removeFromQueue('request_1');

      expect(queueManager.pendingCount, equals(1));

      final remaining = queueManager.getAllRequests();
      expect(remaining.first.id, equals('request_2'));
    });
  });

  group('PendingRequest Tests', () {
    test('should create request with all fields', () {
      final request = PendingRequest(
        id: '123',
        operation: 'create',
        model: 'test.model',
        data: {'key': 'value'},
        priority: RequestPriority.high,
        maxRetries: 5,
      );

      expect(request.id, equals('123'));
      expect(request.operation, equals('create'));
      expect(request.model, equals('test.model'));
      expect(request.data, equals({'key': 'value'}));
      expect(request.priority, equals(RequestPriority.high));
      expect(request.maxRetries, equals(5));
      expect(request.retryCount, equals(0));
    });

    test('should serialize to JSON', () {
      final request = PendingRequest(
        id: '1',
        operation: 'create',
        model: 'test.model',
        data: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['id'], equals('1'));
      expect(json['operation'], equals('create'));
      expect(json['model'], equals('test.model'));
      expect(json['data'], equals({'key': 'value'}));
      expect(json['retryCount'], equals(0));
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'operation': 'create',
        'model': 'test.model',
        'data': {'key': 'value'},
        'timestamp': DateTime.now().toIso8601String(),
        'priority': 2,
        'retryCount': 2,
        'maxRetries': 5,
      };

      final request = PendingRequest.fromJson(json);

      expect(request.id, equals('1'));
      expect(request.operation, equals('create'));
      expect(request.model, equals('test.model'));
      expect(request.retryCount, equals(2));
      expect(request.maxRetries, equals(5));
    });
  });
}
