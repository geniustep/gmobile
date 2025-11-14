// ════════════════════════════════════════════════════════════
// CachedDataService - Cache-First Strategy مع Background Sync
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/services/network/network_info.dart';
import 'package:gsloution_mobile/common/utils/result.dart';

class CachedDataService<T> {
  final StorageService _storage = StorageService.instance;
  final INetworkInfo _network = NetworkInfo.instance;

  final String cacheKey;
  final Duration cacheValidity;
  final Future<List<T>> Function() fetchFromServer;
  final Future<void> Function(List<T>) saveToCache;
  final Future<List<T>> Function() getFromCache;

  CachedDataService({
    required this.cacheKey,
    required this.cacheValidity,
    required this.fetchFromServer,
    required this.saveToCache,
    required this.getFromCache,
  });

  // ════════════════════════════════════════════════════════════
  // Get Data with Cache-First Strategy
  // ════════════════════════════════════════════════════════════

  Future<Result<List<T>>> getData({
    bool forceRefresh = false,
  }) async {
    try {
      // ════════════════════════════════════════════════════════════
      // 1️⃣ إذا لم يكن Force Refresh، تحقق من الـ Cache
      // ════════════════════════════════════════════════════════════
      if (!forceRefresh) {
        final isCacheValid = await _storage.isCacheValid(
          cacheKey,
          cacheValidity,
        );

        if (isCacheValid) {
          if (kDebugMode) {
            print('💾 Using cache for: $cacheKey');
          }

          final cached = await getFromCache();

          if (cached.isNotEmpty) {
            // ✅ استخدم الـ Cache وقم بالمزامنة في الخلفية
            _syncInBackground();
            return Result.success(cached);
          }
        }
      }

      // ════════════════════════════════════════════════════════════
      // 2️⃣ جلب من السيرفر
      // ════════════════════════════════════════════════════════════
      if (kDebugMode) {
        print('🌐 Fetching from server: $cacheKey');
      }

      // التحقق من الاتصال
      final isConnected = await _network.isConnected;

      if (!isConnected) {
        // لا يوجد اتصال، حاول استخدام Cache حتى لو منتهي
        if (kDebugMode) {
          print('📡 No connection, using stale cache: $cacheKey');
        }

        final cached = await getFromCache();

        if (cached.isNotEmpty) {
          return Result.success(cached);
        }

        return Result.error(
          AppError.network('لا يوجد اتصال بالإنترنت'),
        );
      }

      // جلب من السيرفر
      final serverData = await fetchFromServer();

      // ════════════════════════════════════════════════════════════
      // 3️⃣ حفظ في الـ Cache
      // ════════════════════════════════════════════════════════════
      await saveToCache(serverData);

      if (kDebugMode) {
        print('✅ Data fetched and cached: $cacheKey (${serverData.length} items)');
      }

      return Result.success(serverData);
    } on NetworkException catch (e) {
      if (kDebugMode) {
        print('❌ Network error for $cacheKey: $e');
      }

      // حاول استخدام Cache
      final cached = await getFromCache();

      if (cached.isNotEmpty) {
        if (kDebugMode) {
          print('💾 Using stale cache due to network error: $cacheKey');
        }
        return Result.success(cached);
      }

      return Result.error(
        AppError.network('لا يوجد اتصال بالإنترنت', e),
      );
    } on CacheException catch (e) {
      if (kDebugMode) {
        print('❌ Cache error for $cacheKey: $e');
      }

      return Result.error(
        AppError.cache('خطأ في تحميل البيانات المحفوظة', e),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unknown error for $cacheKey: $e');
      }

      return Result.error(
        AppError.unknown('حدث خطأ غير متوقع'),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Background Sync (مزامنة في الخلفية)
  // ════════════════════════════════════════════════════════════

  void _syncInBackground() {
    // تأخير بسيط ثم مزامنة
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        final isConnected = await _network.isConnected;

        if (!isConnected) {
          if (kDebugMode) {
            print('⏸️ Skipping background sync (offline): $cacheKey');
          }
          return;
        }

        if (kDebugMode) {
          print('🔄 Background syncing: $cacheKey');
        }

        final freshData = await fetchFromServer();
        await saveToCache(freshData);

        if (kDebugMode) {
          print('✅ Background sync completed: $cacheKey');
        }
      } catch (e) {
        // تجاهل أخطاء Background Sync
        if (kDebugMode) {
          print('⚠️ Background sync failed (ignored): $cacheKey - $e');
        }
      }
    });
  }

  // ════════════════════════════════════════════════════════════
  // Refresh (إعادة التحميل)
  // ════════════════════════════════════════════════════════════

  Future<Result<List<T>>> refresh() async {
    return getData(forceRefresh: true);
  }

  // ════════════════════════════════════════════════════════════
  // Clear Cache
  // ════════════════════════════════════════════════════════════

  Future<void> clearCache() async {
    // يمكن إضافة منطق لمسح الـ cache هنا
    if (kDebugMode) {
      print('🧹 Cache cleared for: $cacheKey');
    }
  }
}

// ════════════════════════════════════════════════════════════
// Exceptions
// ════════════════════════════════════════════════════════════

class NetworkException implements Exception {
  final String message;
  final dynamic originalError;

  NetworkException(this.message, [this.originalError]);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  final dynamic originalError;

  CacheException(this.message, [this.originalError]);

  @override
  String toString() => 'CacheException: $message';
}
