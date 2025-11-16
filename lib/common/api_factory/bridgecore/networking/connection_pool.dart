// ════════════════════════════════════════════════════════════
// ConnectionPool - Manage HTTP connections efficiently
// ════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ConnectionPool {
  ConnectionPool._();

  static final ConnectionPool instance = ConnectionPool._();

  static const int maxConnections = 5;
  static const Duration idleTimeout = Duration(minutes: 2);

  final List<Dio> _availableConnections = [];
  final List<Dio> _activeConnections = [];
  final Map<Dio, DateTime> _lastUsed = {};

  Future<Dio> acquire() async {
    // Clean up idle connections
    _cleanupIdleConnections();

    // Try to get from available pool
    if (_availableConnections.isNotEmpty) {
      final dio = _availableConnections.removeLast();
      _activeConnections.add(dio);

      if (kDebugMode) {
        print(
            '♻️ Reusing connection (${_activeConnections.length}/$maxConnections active)');
      }

      return dio;
    }

    // Create new connection if under limit
    if (_activeConnections.length + _availableConnections.length <
        maxConnections) {
      final dio = _createConnection();
      _activeConnections.add(dio);

      if (kDebugMode) {
        print(
            '🆕 Created new connection (${_activeConnections.length}/$maxConnections active)');
      }

      return dio;
    }

    // Wait for a connection to be released
    if (kDebugMode) {
      print('⏳ Pool full, waiting for connection...');
    }

    // For now, create anyway (we can improve this with actual waiting)
    final dio = _createConnection();
    _activeConnections.add(dio);
    return dio;
  }

  void release(Dio dio) {
    _activeConnections.remove(dio);
    _availableConnections.add(dio);
    _lastUsed[dio] = DateTime.now();

    if (kDebugMode) {
      print(
          '🔙 Released connection (${_activeConnections.length} active, ${_availableConnections.length} available)');
    }
  }

  Dio _createConnection() {
    final dio = Dio();

    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);

    return dio;
  }

  void _cleanupIdleConnections() {
    final now = DateTime.now();
    final toRemove = <Dio>[];

    for (final dio in _availableConnections) {
      final lastUsed = _lastUsed[dio];
      if (lastUsed != null && now.difference(lastUsed) > idleTimeout) {
        toRemove.add(dio);
      }
    }

    for (final dio in toRemove) {
      _availableConnections.remove(dio);
      _lastUsed.remove(dio);
      dio.close();

      if (kDebugMode) {
        print('🗑️ Closed idle connection');
      }
    }
  }

  Map<String, dynamic> getStats() {
    return {
      'maxConnections': maxConnections,
      'activeConnections': _activeConnections.length,
      'availableConnections': _availableConnections.length,
      'totalConnections':
          _activeConnections.length + _availableConnections.length,
    };
  }

  void printStats() {
    if (!kDebugMode) return;

    final stats = getStats();
    print('═══════════════════════════════════════');
    print('📊 Connection Pool Stats');
    print('═══════════════════════════════════════');
    print('Max Connections: ${stats['maxConnections']}');
    print('Active: ${stats['activeConnections']}');
    print('Available: ${stats['availableConnections']}');
    print('Total: ${stats['totalConnections']}');
    print('═══════════════════════════════════════');
  }

  void dispose() {
    for (final dio in [..._activeConnections, ..._availableConnections]) {
      dio.close();
    }

    _activeConnections.clear();
    _availableConnections.clear();
    _lastUsed.clear();
  }
}
