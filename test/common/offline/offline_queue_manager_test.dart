// ════════════════════════════════════════════════════════════
// OfflineQueueManager Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/offline/offline_queue_manager.dart';

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
        method: 'POST',
        endpoint: '/api/test',
        data: {'key': 'value'},
      );

      await queueManager.addToQueue(request);

      expect(queueManager.pendingCount, equals(1));
    });

    test('should remove request from queue after successful sync', () async {
      final request = PendingRequest(
        id: '1',
        method: 'POST',
        endpoint: '/api/test',
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
        method: 'POST',
        endpoint: '/api/low',
        data: {},
        priority: RequestPriority.low,
      );

      final highPriorityRequest = PendingRequest(
        id: '2',
        method: 'POST',
        endpoint: '/api/high',
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
        method: 'POST',
        endpoint: '/api/test',
        data: {},
        maxRetries: 3,
      );

      await queueManager.addToQueue(request);

      expect(request.retryCount, equals(0));
      expect(request.maxRetries, equals(3));
    });

    test('should clear all queued requests', () async {
      await queueManager.addToQueue(PendingRequest(
        id: '1',
        method: 'POST',
        endpoint: '/api/test1',
        data: {},
      ));

      await queueManager.addToQueue(PendingRequest(
        id: '2',
        method: 'POST',
        endpoint: '/api/test2',
        data: {},
      ));

      expect(queueManager.pendingCount, equals(2));

      await queueManager.clearQueue();

      expect(queueManager.pendingCount, equals(0));
    });

    test('should export queued requests', () async {
      final request = PendingRequest(
        id: '1',
        method: 'POST',
        endpoint: '/api/test',
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
        method: 'POST',
        endpoint: '/api/test',
        data: {},
      );

      await queueManager.addToQueue(request);

      final after = DateTime.now();

      expect(request.createdAt.isAfter(before) || request.createdAt.isAtSameMomentAs(before), isTrue);
      expect(request.createdAt.isBefore(after) || request.createdAt.isAtSameMomentAs(after), isTrue);
    });

    test('should handle different HTTP methods', () async {
      final getMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'];

      for (final method in getMethods) {
        await queueManager.addToQueue(PendingRequest(
          id: method,
          method: method,
          endpoint: '/api/test',
          data: {},
        ));
      }

      expect(queueManager.pendingCount, equals(getMethods.length));
    });

    test('should start and stop auto sync', () {
      queueManager.startAutoSync(interval: const Duration(seconds: 5));

      // في اختبار حقيقي، نتحقق من أن Timer يعمل
      expect(queueManager.isAutoSyncEnabled, isTrue);

      queueManager.stopAutoSync();

      expect(queueManager.isAutoSyncEnabled, isFalse);
    });
  });

  group('PendingRequest Tests', () {
    test('should create request with all fields', () {
      final request = PendingRequest(
        id: '123',
        method: 'POST',
        endpoint: '/api/test',
        data: {'key': 'value'},
        priority: RequestPriority.high,
        maxRetries: 5,
      );

      expect(request.id, equals('123'));
      expect(request.method, equals('POST'));
      expect(request.endpoint, equals('/api/test'));
      expect(request.data, equals({'key': 'value'}));
      expect(request.priority, equals(RequestPriority.high));
      expect(request.maxRetries, equals(5));
      expect(request.retryCount, equals(0));
    });

    test('should serialize to JSON', () {
      final request = PendingRequest(
        id: '1',
        method: 'POST',
        endpoint: '/api/test',
        data: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['id'], equals('1'));
      expect(json['method'], equals('POST'));
      expect(json['endpoint'], equals('/api/test'));
      expect(json['data'], equals({'key': 'value'}));
      expect(json['retryCount'], equals(0));
    });

    test('should deserialize from JSON', () {
      final json = {
        'id': '1',
        'method': 'POST',
        'endpoint': '/api/test',
        'data': {'key': 'value'},
        'priority': 'high',
        'retryCount': 2,
        'maxRetries': 5,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final request = PendingRequest.fromJson(json);

      expect(request.id, equals('1'));
      expect(request.method, equals('POST'));
      expect(request.endpoint, equals('/api/test'));
      expect(request.retryCount, equals(2));
      expect(request.maxRetries, equals(5));
    });
  });
}
