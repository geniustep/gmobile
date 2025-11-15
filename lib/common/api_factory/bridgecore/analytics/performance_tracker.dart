// ════════════════════════════════════════════════════════════
// PerformanceTracker - تتبع وقياس أداء API Calls
// ════════════════════════════════════════════════════════════
//
// يتتبع:
// - زمن الاستجابة (Response Time)
// - معدل النجاح/الفشل (Success/Failure Rate)
// - عدد الطلبات (Request Count)
// - استهلاك الموارد
//
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';

// ════════════════════════════════════════════════════════════
// Performance Measurement Model
// ════════════════════════════════════════════════════════════

class PerformanceMeasurement {
  final String operation;
  final String apiMode;
  final Duration duration;
  final bool success;
  final DateTime timestamp;
  final String? errorMessage;

  PerformanceMeasurement({
    required this.operation,
    required this.apiMode,
    required this.duration,
    required this.success,
    required this.timestamp,
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation': operation,
      'apiMode': apiMode,
      'durationMs': duration.inMilliseconds,
      'success': success,
      'timestamp': timestamp.toIso8601String(),
      if (errorMessage != null) 'error': errorMessage,
    };
  }
}

// ════════════════════════════════════════════════════════════
// Performance Tracker
// ════════════════════════════════════════════════════════════

class PerformanceTracker {
  PerformanceTracker._();

  static final PerformanceTracker instance = PerformanceTracker._();

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  /// جميع القياسات
  final Map<String, List<PerformanceMeasurement>> _measurements = {};

  /// القياسات حسب API Mode
  final Map<String, List<PerformanceMeasurement>> _measurementsByMode = {
    'odooDirect': [],
    'bridgeCore': [],
  };

  /// الحد الأقصى للقياسات المحفوظة لكل operation
  final int _maxMeasurementsPerOperation = 100;

  /// هل التتبع مفعّل؟
  bool _isEnabled = true;

  // ════════════════════════════════════════════════════════════
  // Tracking
  // ════════════════════════════════════════════════════════════

  /// تتبع عملية API
  static Future<T> track<T>({
    required String operation,
    required Future<T> Function() function,
  }) async {
    if (!instance._isEnabled) {
      return await function();
    }

    final apiMode = ApiModeConfig.instance.currentMode.name;
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now();

    try {
      final result = await function();
      stopwatch.stop();

      // تسجيل قياس ناجح
      instance._recordMeasurement(
        PerformanceMeasurement(
          operation: operation,
          apiMode: apiMode,
          duration: stopwatch.elapsed,
          success: true,
          timestamp: timestamp,
        ),
      );

      return result;
    } catch (e) {
      stopwatch.stop();

      // تسجيل قياس فاشل
      instance._recordMeasurement(
        PerformanceMeasurement(
          operation: operation,
          apiMode: apiMode,
          duration: stopwatch.elapsed,
          success: false,
          timestamp: timestamp,
          errorMessage: e.toString(),
        ),
      );

      rethrow;
    }
  }

  /// تسجيل قياس جديد
  void _recordMeasurement(PerformanceMeasurement measurement) {
    // تسجيل حسب العملية
    if (!_measurements.containsKey(measurement.operation)) {
      _measurements[measurement.operation] = [];
    }

    _measurements[measurement.operation]!.add(measurement);

    // حفظ آخر N قياس فقط
    if (_measurements[measurement.operation]!.length >
        _maxMeasurementsPerOperation) {
      _measurements[measurement.operation]!.removeAt(0);
    }

    // تسجيل حسب API Mode
    _measurementsByMode[measurement.apiMode]?.add(measurement);

    if (kDebugMode) {
      final status = measurement.success ? '✅' : '❌';
      print(
        '$status ${measurement.operation} (${measurement.apiMode}): ${measurement.duration.inMilliseconds}ms',
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Statistics
  // ════════════════════════════════════════════════════════════

  /// الحصول على إحصائيات عملية محددة
  Map<String, dynamic> getOperationStats(String operation) {
    final measurements = _measurements[operation] ?? [];

    if (measurements.isEmpty) {
      return {
        'operation': operation,
        'count': 0,
        'avgMs': 0,
        'minMs': 0,
        'maxMs': 0,
        'successRate': 0.0,
      };
    }

    final durations = measurements.map((m) => m.duration.inMilliseconds);
    final successful = measurements.where((m) => m.success).length;

    return {
      'operation': operation,
      'count': measurements.length,
      'avgMs': durations.reduce((a, b) => a + b) ~/ measurements.length,
      'minMs': durations.reduce((a, b) => a < b ? a : b),
      'maxMs': durations.reduce((a, b) => a > b ? a : b),
      'successRate': successful / measurements.length,
      'successful': successful,
      'failed': measurements.length - successful,
    };
  }

  /// الحصول على إحصائيات لجميع العمليات
  Map<String, dynamic> getAllStats() {
    final stats = <String, dynamic>{};

    _measurements.forEach((operation, measurements) {
      stats[operation] = getOperationStats(operation);
    });

    return stats;
  }

  /// مقارنة الأداء بين النظامين
  Map<String, dynamic> comparePerformance() {
    final odooMeasurements = _measurementsByMode['odooDirect'] ?? [];
    final bridgeMeasurements = _measurementsByMode['bridgeCore'] ?? [];

    if (odooMeasurements.isEmpty || bridgeMeasurements.isEmpty) {
      return {
        'comparison': 'insufficient_data',
        'odooCount': odooMeasurements.length,
        'bridgeCoreCount': bridgeMeasurements.length,
      };
    }

    final odooAvg = odooMeasurements.isEmpty
        ? 0
        : odooMeasurements
                .map((m) => m.duration.inMilliseconds)
                .reduce((a, b) => a + b) ~/
            odooMeasurements.length;

    final bridgeAvg = bridgeMeasurements.isEmpty
        ? 0
        : bridgeMeasurements
                .map((m) => m.duration.inMilliseconds)
                .reduce((a, b) => a + b) ~/
            bridgeMeasurements.length;

    final odooSuccess = odooMeasurements.where((m) => m.success).length;
    final bridgeSuccess = bridgeMeasurements.where((m) => m.success).length;

    final improvement =
        odooAvg > 0 ? ((odooAvg - bridgeAvg) / odooAvg * 100) : 0.0;

    return {
      'odooDirect': {
        'count': odooMeasurements.length,
        'avgMs': odooAvg,
        'successRate': odooSuccess / odooMeasurements.length,
      },
      'bridgeCore': {
        'count': bridgeMeasurements.length,
        'avgMs': bridgeAvg,
        'successRate': bridgeSuccess / bridgeMeasurements.length,
      },
      'improvement': {
        'speedImprovement': improvement.toStringAsFixed(1) + '%',
        'faster': improvement > 0 ? 'bridgeCore' : 'odooDirect',
      },
    };
  }

  /// الحصول على تقرير كامل
  Map<String, dynamic> getReport() {
    return {
      'enabled': _isEnabled,
      'totalMeasurements': _measurements.values
          .map((list) => list.length)
          .fold(0, (a, b) => a + b),
      'operations': getAllStats(),
      'comparison': comparePerformance(),
      'byMode': {
        'odooDirect': _measurementsByMode['odooDirect']!.length,
        'bridgeCore': _measurementsByMode['bridgeCore']!.length,
      },
    };
  }

  // ════════════════════════════════════════════════════════════
  // Management
  // ════════════════════════════════════════════════════════════

  /// تفعيل/تعطيل التتبع
  void setEnabled(bool enabled) {
    _isEnabled = enabled;

    if (kDebugMode) {
      print('📊 Performance tracking ${enabled ? 'enabled' : 'disabled'}');
    }
  }

  /// مسح جميع القياسات
  void clearAll() {
    _measurements.clear();
    _measurementsByMode['odooDirect']!.clear();
    _measurementsByMode['bridgeCore']!.clear();

    if (kDebugMode) {
      print('🧹 Cleared all performance measurements');
    }
  }

  /// مسح قياسات عملية محددة
  void clearOperation(String operation) {
    _measurements.remove(operation);

    if (kDebugMode) {
      print('🧹 Cleared measurements for: $operation');
    }
  }

  /// مسح قياسات API mode محدد
  void clearMode(String mode) {
    if (_measurementsByMode.containsKey(mode)) {
      _measurementsByMode[mode]!.clear();

      if (kDebugMode) {
        print('🧹 Cleared measurements for mode: $mode');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Export
  // ════════════════════════════════════════════════════════════

  /// تصدير القياسات كـ JSON
  Map<String, dynamic> exportToJson() {
    final data = <String, dynamic>{};

    _measurements.forEach((operation, measurements) {
      data[operation] = measurements.map((m) => m.toJson()).toList();
    });

    return data;
  }

  /// طباعة تقرير مفصل
  void printReport() {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════════════════════');
    print('📊 Performance Tracker Report');
    print('═══════════════════════════════════════════════════════');

    final report = getReport();

    print('Total Measurements: ${report['totalMeasurements']}');
    print('Enabled: ${report['enabled']}');
    print('');

    print('By Mode:');
    print('  Odoo Direct: ${report['byMode']['odooDirect']}');
    print('  BridgeCore: ${report['byMode']['bridgeCore']}');
    print('');

    if (report['operations'] is Map) {
      print('Operations:');
      (report['operations'] as Map).forEach((operation, stats) {
        print('  $operation:');
        print('    Count: ${stats['count']}');
        print('    Avg: ${stats['avgMs']}ms');
        print('    Min: ${stats['minMs']}ms');
        print('    Max: ${stats['maxMs']}ms');
        print('    Success Rate: ${(stats['successRate'] * 100).toStringAsFixed(1)}%');
      });
    }

    print('');

    final comparison = report['comparison'];
    if (comparison is Map && comparison['comparison'] != 'insufficient_data') {
      print('Comparison:');
      print('  Odoo Direct:');
      print('    Avg: ${comparison['odooDirect']['avgMs']}ms');
      print('    Success: ${(comparison['odooDirect']['successRate'] * 100).toStringAsFixed(1)}%');
      print('  BridgeCore:');
      print('    Avg: ${comparison['bridgeCore']['avgMs']}ms');
      print('    Success: ${(comparison['bridgeCore']['successRate'] * 100).toStringAsFixed(1)}%');
      print('  Improvement: ${comparison['improvement']['speedImprovement']}');
      print('  Faster: ${comparison['improvement']['faster']}');
    }

    print('═══════════════════════════════════════════════════════');
  }
}
