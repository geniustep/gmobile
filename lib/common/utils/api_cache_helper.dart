import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class for API response caching
class ApiCacheHelper {
  static const String _cachePrefix = 'api_cache_';
  static const Duration defaultCacheDuration = Duration(minutes: 5);
  
  /// Get cached response
  static Future<Map<String, dynamic>?> getCachedResponse(
    String key, {
    Duration? maxAge,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData == null) return null;
      
      final decoded = jsonDecode(cachedData) as Map<String, dynamic>;
      final timestamp = DateTime.parse(decoded['timestamp'] as String);
      final age = DateTime.now().difference(timestamp);
      
      final maxAgeToUse = maxAge ?? defaultCacheDuration;
      if (age > maxAgeToUse) {
        // Cache expired
        await prefs.remove(cacheKey);
        return null;
      }
      
      return decoded['data'] as Map<String, dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Error reading cache: $e');
      }
      return null;
    }
  }
  
  /// Save response to cache
  static Future<void> saveResponse(
    String key,
    Map<String, dynamic> data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving cache: $e');
      }
    }
  }
  
  /// Clear specific cache
  static Future<void> clearCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      await prefs.remove(cacheKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }
  
  /// Clear all API cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => key.startsWith(_cachePrefix));
      
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all cache: $e');
      }
    }
  }
  
  /// Generate cache key from URL and parameters
  static String generateCacheKey(String url, Map<String, dynamic>? params) {
    final paramsString = params != null && params.isNotEmpty
        ? jsonEncode(params).replaceAll(RegExp(r'[^\w]'), '_')
        : '';
    return '${url}_$paramsString';
  }
}

