// ════════════════════════════════════════════════════════════
// OfflineQueueManager - إدارة الطلبات في وضع Offline
// ════════════════════════════════════════════════════════════
//
// - حفظ الطلبات الفاشلة بسبب انقطاع الشبكة
// - إعادة المحاولة تلقائياً عند عودة الاتصال
// - ترتيب الطلبات حسب الأولوية
//
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:gsloution_mobile/common/services/network/network_info.dart';

// ════════════════════════════════════════════════════════════
// Pending Request Model
// ════════════════════════════════════════════════════════════

enum RequestPriority { low, medium, high, critical }

class PendingRequest {
  final String id;
  final String operation;
  final String model;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final RequestPriority priority;
  final int retryCount;
  final int maxRetries;

  PendingRequest({
    required this.id,
    required this.operation,
    required this.model,
    required this.data,
    DateTime? timestamp,
    this.priority = RequestPriority.medium,
    this.retryCount = 0,
    this.maxRetries = 3,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'operation': operation,
        'model': model,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'priority': priority.index,
        'retryCount': retryCount,
        'maxRetries': maxRetries,
      };

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'],
      operation: json['operation'],
      model: json['model'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      priority: RequestPriority.values[json['priority'] ?? 1],
      retryCount: json['retryCount'] ?? 0,
      maxRetries: json['maxRetries'] ?? 3,
    );
  }

  PendingRequest copyWith({int? retryCount}) {
    return PendingRequest(
      id: id,
      operation: operation,
      model: model,
      data: data,
      timestamp: timestamp,
      priority: priority,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries,
    );
  }
}

// ════════════════════════════════════════════════════════════
// Offline Queue Manager
// ════════════════════════════════════════════════════════════

class OfflineQueueManager {
  OfflineQueueManager._();

  static final OfflineQueueManager instance = OfflineQueueManager._();

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  final List<PendingRequest> _queue = [];
  bool _isSyncing = false;

  static const String _queueKey = 'offline_queue';
  static const String _queueBoxName = 'offline';

  // ════════════════════════════════════════════════════════════
  // Callbacks
  // ════════════════════════════════════════════════════════════

  Function(PendingRequest)? onRequestAdded;
  Function(PendingRequest)? onRequestCompleted;
  Function(PendingRequest, dynamic error)? onRequestFailed;
  Function(int completed, int total)? onSyncProgress;

  // ════════════════════════════════════════════════════════════
  // Queue Management
  // ════════════════════════════════════════════════════════════

  /// إضافة طلب للـ queue
  Future<void> addToQueue(PendingRequest request) async {
    _queue.add(request);

    // ترتيب حسب الأولوية
    _sortQueue();

    // حفظ
    await _saveQueue();

    if (kDebugMode) {
      print('📥 Request added to offline queue: ${request.id}');
      print('   Operation: ${request.operation}');
      print('   Model: ${request.model}');
      print('   Priority: ${request.priority.name}');
    }

    onRequestAdded?.call(request);
  }

  /// حذف طلب من الـ queue
  Future<void> removeFromQueue(String requestId) async {
    _queue.removeWhere((r) => r.id == requestId);
    await _saveQueue();

    if (kDebugMode) {
      print('🗑️ Request removed from queue: $requestId');
    }
  }

  /// مسح الـ queue بالكامل
  Future<void> clearQueue() async {
    _queue.clear();
    await _saveQueue();

    if (kDebugMode) {
      print('🧹 Offline queue cleared');
    }
  }

  /// ترتيب الـ queue حسب الأولوية والوقت
  void _sortQueue() {
    _queue.sort((a, b) {
      // الأولوية أولاً
      final priorityCompare = b.priority.index.compareTo(a.priority.index);
      if (priorityCompare != 0) return priorityCompare;

      // ثم الوقت (الأقدم أولاً)
      return a.timestamp.compareTo(b.timestamp);
    });
  }

  // ════════════════════════════════════════════════════════════
  // Persistence
  // ════════════════════════════════════════════════════════════

  /// حفظ الـ queue
  Future<void> _saveQueue() async {
    try {
      final queueData = _queue.map((r) => r.toJson()).toList();
      await HiveService.instance.saveGenericData(
        _queueBoxName,
        _queueKey,
        jsonEncode(queueData),
      );

      if (kDebugMode) {
        print('💾 Queue saved: ${_queue.length} requests');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving queue: $e');
      }
    }
  }

  /// تحميل الـ queue
  Future<void> loadQueue() async {
    try {
      final queueData = await HiveService.instance.getGenericData(
        _queueBoxName,
        _queueKey,
      );

      if (queueData != null) {
        final List<dynamic> parsed = jsonDecode(queueData);
        _queue.clear();
        _queue.addAll(parsed.map((item) => PendingRequest.fromJson(item)));

        _sortQueue();

        if (kDebugMode) {
          print('📂 Queue loaded: ${_queue.length} requests');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading queue: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Sync Operations
  // ════════════════════════════════════════════════════════════

  /// مزامنة الـ queue (إعادة محاولة جميع الطلبات)
  Future<void> syncQueue() async {
    if (_isSyncing) {
      if (kDebugMode) {
        print('⚠️ Sync already in progress');
      }
      return;
    }

    // التحقق من الاتصال
    final isConnected = await NetworkInfo.instance.isConnected;
    if (!isConnected) {
      if (kDebugMode) {
        print('⚠️ No internet connection, sync cancelled');
      }
      return;
    }

    _isSyncing = true;

    if (kDebugMode) {
      print('🔄 Starting queue sync: ${_queue.length} requests');
    }

    int completed = 0;
    final total = _queue.length;
    final failed = <PendingRequest>[];

    for (final request in List.from(_queue)) {
      try {
        // محاولة تنفيذ الطلب
        await _executeRequest(request);

        // نجح - حذف من الـ queue
        await removeFromQueue(request.id);

        completed++;
        onRequestCompleted?.call(request);

        if (kDebugMode) {
          print('✅ Request completed: ${request.id}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ Request failed: ${request.id} - $e');
        }

        // فشل - زيادة retry count
        final updatedRequest = request.copyWith(
          retryCount: request.retryCount + 1,
        );

        // إذا وصل لأقصى محاولات، حذف من القائمة
        if (updatedRequest.retryCount >= updatedRequest.maxRetries) {
          await removeFromQueue(request.id);
          failed.add(request);

          onRequestFailed?.call(request, e);
        } else {
          // تحديث في القائمة
          final index = _queue.indexWhere((r) => r.id == request.id);
          if (index != -1) {
            _queue[index] = updatedRequest;
            await _saveQueue();
          }
        }
      }

      onSyncProgress?.call(completed, total);
    }

    _isSyncing = false;

    if (kDebugMode) {
      print('🏁 Sync completed: $completed/$total successful');
      if (failed.isNotEmpty) {
        print('   Failed (max retries): ${failed.length}');
      }
    }
  }

  /// تنفيذ طلب واحد
  Future<void> _executeRequest(PendingRequest request) async {
    // TODO: تطبيق تنفيذ الطلب بناءً على operation
    // يمكن استخدام ApiClientFactory هنا

    // مثال:
    // final client = ApiClientFactory.instance;
    // await client.create(
    //   model: request.model,
    //   values: request.data,
    //   onResponse: (response) {},
    //   onError: (error, data) => throw Exception(error),
    // );

    // للآن نرمي exception للاختبار
    throw UnimplementedError('Request execution not implemented yet');
  }

  // ════════════════════════════════════════════════════════════
  // Auto Sync
  // ════════════════════════════════════════════════════════════

  Timer? _autoSyncTimer;

  /// بدء المزامنة التلقائية
  void startAutoSync({Duration interval = const Duration(minutes: 5)}) {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = Timer.periodic(interval, (_) async {
      if (_queue.isNotEmpty) {
        await syncQueue();
      }
    });

    if (kDebugMode) {
      print('✅ Auto sync started (every ${interval.inMinutes} minutes)');
    }
  }

  /// إيقاف المزامنة التلقائية
  void stopAutoSync() {
    _autoSyncTimer?.cancel();
    _autoSyncTimer = null;

    if (kDebugMode) {
      print('🛑 Auto sync stopped');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Queue Information
  // ════════════════════════════════════════════════════════════

  /// عدد الطلبات في الـ queue
  int get queueSize => _queue.length;

  /// عدد الطلبات المعلقة (alias for queueSize)
  int get pendingCount => _queue.length;

  /// هل الـ queue فارغة
  bool get isEmpty => _queue.isEmpty;

  /// هل جاري المزامنة
  bool get isSyncing => _isSyncing;

  /// هل المزامنة التلقائية مفعلة
  bool get isAutoSyncEnabled => _autoSyncTimer != null;

  /// الحصول على جميع الطلبات
  List<PendingRequest> getAllRequests() => List.unmodifiable(_queue);

  /// الحصول على طلبات بأولوية معينة
  List<PendingRequest> getRequestsByPriority(RequestPriority priority) {
    return _queue.where((r) => r.priority == priority).toList();
  }

  /// تصدير الـ queue كـ JSON
  List<Map<String, dynamic>> exportQueue() {
    return _queue.map((r) => r.toJson()).toList();
  }

  /// إحصائيات الـ queue
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{
      'total': _queue.length,
      'isSyncing': _isSyncing,
      'byPriority': {},
      'byOperation': {},
      'oldest': null,
      'newest': null,
    };

    // حسب الأولوية
    for (final priority in RequestPriority.values) {
      stats['byPriority'][priority.name] =
          _queue.where((r) => r.priority == priority).length;
    }

    // حسب العملية
    final operations = _queue.map((r) => r.operation).toSet();
    for (final op in operations) {
      stats['byOperation'][op] = _queue.where((r) => r.operation == op).length;
    }

    // أقدم وأحدث
    if (_queue.isNotEmpty) {
      stats['oldest'] = _queue
          .reduce((a, b) => a.timestamp.isBefore(b.timestamp) ? a : b)
          .timestamp
          .toIso8601String();

      stats['newest'] = _queue
          .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
          .timestamp
          .toIso8601String();
    }

    return stats;
  }

  /// طباعة معلومات الـ queue
  void printQueueInfo() {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════════════════════');
    print('📋 Offline Queue Info');
    print('═══════════════════════════════════════════════════════');

    final stats = getStatistics();

    print('Total Requests: ${stats['total']}');
    print('Is Syncing: ${stats['isSyncing']}');
    print('');

    print('By Priority:');
    (stats['byPriority'] as Map).forEach((key, value) {
      print('  $key: $value');
    });
    print('');

    print('By Operation:');
    (stats['byOperation'] as Map).forEach((key, value) {
      print('  $key: $value');
    });

    if (stats['oldest'] != null) {
      print('');
      print('Oldest Request: ${stats['oldest']}');
      print('Newest Request: ${stats['newest']}');
    }

    print('═══════════════════════════════════════════════════════');
  }
}
