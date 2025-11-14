// ════════════════════════════════════════════════════════════
// ApiRequestManager - منع الطلبات المكررة (Request Deduplication)
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

class ApiRequestManager {
  ApiRequestManager._();

  static final ApiRequestManager instance = ApiRequestManager._();

  // ════════════════════════════════════════════════════════════
  // Active Requests
  // ════════════════════════════════════════════════════════════

  final Map<String, Future<dynamic>> _activeRequests = {};
  final Map<String, DateTime> _requestTimestamps = {};

  // ════════════════════════════════════════════════════════════
  // Request with Deduplication
  // ════════════════════════════════════════════════════════════

  /// نفّذ request مع منع التكرار
  Future<T> request<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration? cacheFor, // cache النتيجة لمدة معينة
  }) async {
    // ════════════════════════════════════════════════════════════
    // 1. التحقق من Cache (إذا كان محدد)
    // ════════════════════════════════════════════════════════════
    if (cacheFor != null && _requestTimestamps.containsKey(key)) {
      final lastRequest = _requestTimestamps[key]!;
      final now = DateTime.now();

      if (now.difference(lastRequest) < cacheFor) {
        // ✅ النتيجة لا تزال صالحة
        if (_activeRequests.containsKey(key)) {
          if (kDebugMode) {
            print('💾 Using cached result for: $key');
          }
          return _activeRequests[key] as Future<T>;
        }
      }
    }

    // ════════════════════════════════════════════════════════════
    // 2. التحقق من وجود طلب نشط
    // ════════════════════════════════════════════════════════════
    if (_activeRequests.containsKey(key)) {
      if (kDebugMode) {
        print('🔄 Request already in progress, reusing: $key');
      }
      return _activeRequests[key] as Future<T>;
    }

    // ════════════════════════════════════════════════════════════
    // 3. إنشاء طلب جديد
    // ════════════════════════════════════════════════════════════
    if (kDebugMode) {
      print('🚀 New request: $key');
    }

    final future = fetcher();
    _activeRequests[key] = future;
    _requestTimestamps[key] = DateTime.now();

    try {
      final result = await future;

      if (kDebugMode) {
        print('✅ Request completed: $key');
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Request failed: $key - $e');
      }

      rethrow;
    } finally {
      // إزالة من الطلبات النشطة فقط، الاحتفاظ بـ timestamp للـ cache
      _activeRequests.remove(key);
    }
  }

  // ════════════════════════════════════════════════════════════
  // Cancel Request
  // ════════════════════════════════════════════════════════════

  /// إلغاء طلب معين
  void cancel(String key) {
    if (_activeRequests.containsKey(key)) {
      _activeRequests.remove(key);
      _requestTimestamps.remove(key);

      if (kDebugMode) {
        print('🚫 Cancelled request: $key');
      }
    }
  }

  /// إلغاء جميع الطلبات
  void cancelAll() {
    if (kDebugMode) {
      print('🚫 Cancelling all requests (${_activeRequests.length})');
    }

    _activeRequests.clear();
    _requestTimestamps.clear();
  }

  // ════════════════════════════════════════════════════════════
  // Clear Cache
  // ════════════════════════════════════════════════════════════

  /// مسح cache لطلب معين
  void clearCache(String key) {
    _requestTimestamps.remove(key);

    if (kDebugMode) {
      print('🧹 Cleared cache for: $key');
    }
  }

  /// مسح جميع الـ cache
  void clearAllCache() {
    _requestTimestamps.clear();

    if (kDebugMode) {
      print('🧹 Cleared all cache');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Status & Info
  // ════════════════════════════════════════════════════════════

  /// عدد الطلبات النشطة
  int get activeRequestsCount => _activeRequests.length;

  /// هل يوجد طلب نشط؟
  bool isActive(String key) => _activeRequests.containsKey(key);

  /// معلومات عن الطلبات
  Map<String, dynamic> getInfo() {
    return {
      'activeRequests': _activeRequests.keys.toList(),
      'cachedRequests': _requestTimestamps.keys.toList(),
      'activeCount': _activeRequests.length,
      'cachedCount': _requestTimestamps.length,
    };
  }
}

// ════════════════════════════════════════════════════════════
// Helper Functions
// ════════════════════════════════════════════════════════════

/// مساعد لإنشاء مفاتيح فريدة للطلبات
String createRequestKey(String model, {
  List? domain,
  List<String>? fields,
  int? limit,
  int? offset,
}) {
  final parts = <String>[model];

  if (domain != null && domain.isNotEmpty) {
    parts.add('domain:${domain.toString()}');
  }

  if (fields != null && fields.isNotEmpty) {
    parts.add('fields:${fields.join(',')}');
  }

  if (limit != null) {
    parts.add('limit:$limit');
  }

  if (offset != null) {
    parts.add('offset:$offset');
  }

  return parts.join('|');
}
