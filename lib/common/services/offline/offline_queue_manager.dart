import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Manages offline operations queue
/// Stores operations when offline and syncs when connection is restored
class OfflineQueueManager {
  static const String _boxName = 'offline_queue';
  static const String _tag = '📦 OfflineQueue';

  static Box? _queueBox;

  /// Initialize the queue manager
  static Future<void> initialize() async {
    try {
      _queueBox = await Hive.openBox(_boxName);
      if (kDebugMode) {
        print('$_tag Initialized with ${_queueBox?.length ?? 0} pending operations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error initializing: $e');
      }
    }
  }

  /// Add operation to queue
  static Future<void> addOperation({
    required String type,
    required Map<String, dynamic> data,
    required String endpoint,
    String method = 'POST',
  }) async {
    try {
      if (_queueBox == null) await initialize();

      final operation = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'type': type,
        'endpoint': endpoint,
        'method': method,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'status': 'pending',
        'retryCount': 0,
      };

      await _queueBox?.add(operation);

      if (kDebugMode) {
        print('$_tag Added operation: $type');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error adding operation: $e');
      }
    }
  }

  /// Get all pending operations
  static Future<List<Map<String, dynamic>>> getPendingOperations() async {
    try {
      if (_queueBox == null) await initialize();

      final operations = _queueBox?.values
          .where((op) => op['status'] == 'pending')
          .cast<Map<String, dynamic>>()
          .toList() ?? [];

      return operations;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting pending operations: $e');
      }
      return [];
    }
  }

  /// Mark operation as completed
  static Future<void> markAsCompleted(String operationId) async {
    try {
      if (_queueBox == null) await initialize();

      final key = _queueBox?.keys.firstWhere(
        (key) => _queueBox?.get(key)['id'] == operationId,
        orElse: () => null,
      );

      if (key != null) {
        final operation = _queueBox?.get(key) as Map<String, dynamic>;
        operation['status'] = 'completed';
        operation['completedAt'] = DateTime.now().toIso8601String();
        await _queueBox?.put(key, operation);

        if (kDebugMode) {
          print('$_tag Marked operation $operationId as completed');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error marking operation as completed: $e');
      }
    }
  }

  /// Mark operation as failed
  static Future<void> markAsFailed(String operationId, String error) async {
    try {
      if (_queueBox == null) await initialize();

      final key = _queueBox?.keys.firstWhere(
        (key) => _queueBox?.get(key)['id'] == operationId,
        orElse: () => null,
      );

      if (key != null) {
        final operation = _queueBox?.get(key) as Map<String, dynamic>;
        operation['status'] = 'failed';
        operation['error'] = error;
        operation['failedAt'] = DateTime.now().toIso8601String();
        operation['retryCount'] = (operation['retryCount'] ?? 0) + 1;
        await _queueBox?.put(key, operation);

        if (kDebugMode) {
          print('$_tag Marked operation $operationId as failed: $error');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error marking operation as failed: $e');
      }
    }
  }

  /// Retry failed operation
  static Future<void> retryOperation(String operationId) async {
    try {
      if (_queueBox == null) await initialize();

      final key = _queueBox?.keys.firstWhere(
        (key) => _queueBox?.get(key)['id'] == operationId,
        orElse: () => null,
      );

      if (key != null) {
        final operation = _queueBox?.get(key) as Map<String, dynamic>;
        operation['status'] = 'pending';
        operation['retryCount'] = (operation['retryCount'] ?? 0) + 1;
        await _queueBox?.put(key, operation);

        if (kDebugMode) {
          print('$_tag Retrying operation $operationId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error retrying operation: $e');
      }
    }
  }

  /// Clear completed operations
  static Future<void> clearCompleted() async {
    try {
      if (_queueBox == null) await initialize();

      final keysToDelete = <dynamic>[];

      _queueBox?.keys.forEach((key) {
        final operation = _queueBox?.get(key) as Map<String, dynamic>;
        if (operation['status'] == 'completed') {
          keysToDelete.add(key);
        }
      });

      for (var key in keysToDelete) {
        await _queueBox?.delete(key);
      }

      if (kDebugMode) {
        print('$_tag Cleared ${keysToDelete.length} completed operations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error clearing completed operations: $e');
      }
    }
  }

  /// Get queue statistics
  static Future<Map<String, int>> getStatistics() async {
    try {
      if (_queueBox == null) await initialize();

      int pending = 0;
      int completed = 0;
      int failed = 0;

      _queueBox?.values.forEach((operation) {
        final op = operation as Map<String, dynamic>;
        switch (op['status']) {
          case 'pending':
            pending++;
            break;
          case 'completed':
            completed++;
            break;
          case 'failed':
            failed++;
            break;
        }
      });

      return {
        'pending': pending,
        'completed': completed,
        'failed': failed,
        'total': _queueBox?.length ?? 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting statistics: $e');
      }
      return {'pending': 0, 'completed': 0, 'failed': 0, 'total': 0};
    }
  }

  /// Clear all operations (use with caution)
  static Future<void> clearAll() async {
    try {
      if (_queueBox == null) await initialize();
      await _queueBox?.clear();

      if (kDebugMode) {
        print('$_tag Cleared all operations');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error clearing all operations: $e');
      }
    }
  }
}
