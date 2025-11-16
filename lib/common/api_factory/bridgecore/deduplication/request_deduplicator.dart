// ════════════════════════════════════════════════════════════
// RequestDeduplicator - Prevent duplicate requests
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class RequestDeduplicator {
  RequestDeduplicator._();

  static final RequestDeduplicator instance = RequestDeduplicator._();

  // Pending requests: key -> Completer
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  // Request count for stats
  int _totalRequests = 0;
  int _deduplicatedRequests = 0;

  String generateKey(String endpoint, Map<String, dynamic>? data) {
    final combined = '$endpoint:${jsonEncode(data ?? {})}';
    final bytes = utf8.encode(combined);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<T> deduplicate<T>({
    required String endpoint,
    Map<String, dynamic>? data,
    required Future<T> Function() request,
  }) async {
    _totalRequests++;

    final key = generateKey(endpoint, data);

    // Check if request is already pending
    if (_pendingRequests.containsKey(key)) {
      _deduplicatedRequests++;

      if (kDebugMode) {
        print('🔄 Deduplicating request: $endpoint');
        print('   Already pending, waiting for result...');
      }

      // Wait for existing request to complete
      return await _pendingRequests[key]!.future as T;
    }

    // Create new completer for this request
    final completer = Completer<T>();
    _pendingRequests[key] = completer;

    try {
      // Execute request
      final result = await request();

      // Complete with result
      completer.complete(result);

      return result;
    } catch (error) {
      // Complete with error
      completer.completeError(error);
      rethrow;
    } finally {
      // Remove from pending after a small delay
      // to catch any requests that arrive just after completion
      Future.delayed(const Duration(milliseconds: 100), () {
        _pendingRequests.remove(key);
      });
    }
  }

  Map<String, dynamic> getStats() {
    final deduplicationRate = _totalRequests > 0
        ? (_deduplicatedRequests / _totalRequests * 100)
        : 0.0;

    return {
      'totalRequests': _totalRequests,
      'deduplicatedRequests': _deduplicatedRequests,
      'deduplicationRate': '${deduplicationRate.toStringAsFixed(2)}%',
      'pendingRequests': _pendingRequests.length,
    };
  }

  void printStats() {
    if (!kDebugMode) return;

    final stats = getStats();
    print('═══════════════════════════════════════');
    print('📊 Request Deduplication Stats');
    print('═══════════════════════════════════════');
    print('Total Requests: ${stats['totalRequests']}');
    print('Deduplicated: ${stats['deduplicatedRequests']}');
    print('Rate: ${stats['deduplicationRate']}');
    print('Currently Pending: ${stats['pendingRequests']}');
    print('═══════════════════════════════════════');
  }

  void reset() {
    _totalRequests = 0;
    _deduplicatedRequests = 0;
    _pendingRequests.clear();
  }
}
