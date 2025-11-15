// ════════════════════════════════════════════════════════════
// CacheManager - إدارة Cache مع TTL
// ════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';

class CacheEntry<T> {
  final T data;
  final DateTime timestamp;
  final Duration ttl;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  bool get isExpired =>
      DateTime.now().difference(timestamp) > ttl;

  Duration get remainingTime =>
      ttl - DateTime.now().difference(timestamp);

  Map<String, dynamic> toJson() => {
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'ttlSeconds': ttl.inSeconds,
      };

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'] as T,
      timestamp: DateTime.parse(json['timestamp']),
      ttl: Duration(seconds: json['ttlSeconds']),
    );
  }
}

class CacheManager {
  CacheManager._();
  static final CacheManager instance = CacheManager._();

  static const Duration defaultTTL = Duration(hours: 24);
  static const String _cacheBoxName = 'cache';

  Future<void> set<T>({
    required String key,
    required T data,
    Duration? ttl,
  }) async {
    final cacheEntry = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl ?? defaultTTL,
    );

    try {
      await HiveService.instance.saveGenericData(
        _cacheBoxName,
        key,
        jsonEncode(cacheEntry.toJson()),
      );

      if (kDebugMode) {
        print('💾 Cache set: $key (TTL: ${cacheEntry.ttl.inMinutes} minutes)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error setting cache: $e');
      }
    }
  }

  Future<T?> get<T>({
    required String key,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final data = await HiveService.instance.getGenericData(_cacheBoxName, key);
      if (data == null) return null;

      final decoded = jsonDecode(data);
      final cacheEntry = CacheEntry<T>.fromJson(decoded);

      if (cacheEntry.isExpired) {
        await invalidate(key);
        if (kDebugMode) {
          print('⏰ Cache expired: $key');
        }
        return null;
      }

      if (kDebugMode) {
        print('✅ Cache hit: $key (${cacheEntry.remainingTime.inMinutes} minutes remaining)');
      }

      return fromJson != null
          ? fromJson(cacheEntry.data)
          : cacheEntry.data as T;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting cache: $e');
      }
      return null;
    }
  }

  Future<void> invalidate(String key) async {
    await HiveService.instance.saveGenericData(_cacheBoxName, key, null);
    if (kDebugMode) {
      print('🗑️ Cache invalidated: $key');
    }
  }

  Future<void> invalidateAll() async {
    await HiveService.instance.clearBox(_cacheBoxName);
    if (kDebugMode) {
      print('🧹 All cache cleared');
    }
  }

  Future<void> invalidatePattern(String pattern) async {
    // TODO: تطبيق invalidation بناءً على pattern
    if (kDebugMode) {
      print('🗑️ Cache invalidated by pattern: $pattern');
    }
  }
}
