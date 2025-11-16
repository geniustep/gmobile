// ════════════════════════════════════════════════════════════
// CircuitBreaker - Prevent cascading failures
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

enum CircuitState { closed, open, halfOpen }

class CircuitBreakerException implements Exception {
  final String message;
  CircuitBreakerException(this.message);

  @override
  String toString() => 'CircuitBreakerException: $message';
}

class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration resetTimeout;

  CircuitState _state = CircuitState.closed;
  int _failureCount = 0;
  DateTime? _lastFailureTime;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.resetTimeout = const Duration(seconds: 60),
  });

  CircuitState get state => _state;
  int get failures => _failureCount;

  Future<T> execute<T>(Future<T> Function() operation) async {
    // Check if circuit is open
    if (_state == CircuitState.open) {
      if (_shouldAttemptReset()) {
        if (kDebugMode) {
          print('🔄 [$name] Circuit: OPEN -> HALF_OPEN (attempting reset)');
        }
        _state = CircuitState.halfOpen;
      } else {
        if (kDebugMode) {
          print('🚫 [$name] Circuit OPEN - Request blocked');
        }
        throw CircuitBreakerException('Circuit breaker is OPEN');
      }
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    if (_state == CircuitState.halfOpen) {
      if (kDebugMode) {
        print('✅ [$name] Circuit: HALF_OPEN -> CLOSED (success)');
      }
      _state = CircuitState.closed;
    }

    _failureCount = 0;
    _lastFailureTime = null;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (kDebugMode) {
      print('❌ [$name] Circuit failure: $_failureCount/$failureThreshold');
    }

    if (_failureCount >= failureThreshold) {
      _state = CircuitState.open;

      if (kDebugMode) {
        print('🔴 [$name] Circuit: CLOSED -> OPEN (threshold reached)');
      }
    }
  }

  bool _shouldAttemptReset() {
    if (_lastFailureTime == null) return false;

    final elapsed = DateTime.now().difference(_lastFailureTime!);
    return elapsed >= resetTimeout;
  }

  void reset() {
    _state = CircuitState.closed;
    _failureCount = 0;
    _lastFailureTime = null;

    if (kDebugMode) {
      print('🔄 [$name] Circuit manually reset');
    }
  }

  Map<String, dynamic> getStats() {
    return {
      'name': name,
      'state': _state.toString().split('.').last,
      'failures': _failureCount,
      'threshold': failureThreshold,
      'lastFailure': _lastFailureTime?.toIso8601String(),
    };
  }

  void printStats() {
    if (!kDebugMode) return;

    final stats = getStats();
    print('═══════════════════════════════════════');
    print('📊 Circuit Breaker Stats: $name');
    print('═══════════════════════════════════════');
    print('State: ${stats['state']}');
    print('Failures: ${stats['failures']}/${stats['threshold']}');
    if (stats['lastFailure'] != null) {
      print('Last Failure: ${stats['lastFailure']}');
    }
    print('═══════════════════════════════════════');
  }
}
