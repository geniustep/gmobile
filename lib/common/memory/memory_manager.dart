// ════════════════════════════════════════════════════════════
// MemoryManager - منع تسريب الذاكرة
// ════════════════════════════════════════════════════════════
//
// - مساعد لـ dispose Controllers بشكل صحيح
// - مراقبة استهلاك الذاكرة
// - تنظيف تلقائي للموارد
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

// ════════════════════════════════════════════════════════════
// Auto Dispose Controller Mixin
// ════════════════════════════════════════════════════════════

/// Mixin لتنظيف تلقائي للـ Controllers
mixin AutoDisposeMixin on GetxController {
  final List<RxInterface> _observables = [];
  final List<Worker> _workers = [];

  /// تسجيل observable للتنظيف التلقائي
  T registerObservable<T extends RxInterface>(T observable) {
    _observables.add(observable);
    return observable;
  }

  /// تسجيل worker للتنظيف التلقائي
  T registerWorker<T extends Worker>(T worker) {
    _workers.add(worker);
    return worker;
  }

  @override
  void onClose() {
    // تنظيف workers
    for (final worker in _workers) {
      worker.dispose();
    }
    _workers.clear();

    // تنظيف observables
    for (final observable in _observables) {
      if (observable is RxList) {
        observable.clear();
      } else if (observable is RxMap) {
        observable.clear();
      } else if (observable is RxSet) {
        observable.clear();
      }
    }
    _observables.clear();

    if (kDebugMode) {
      print('🧹 ${runtimeType} disposed (workers: ${_workers.length}, observables: ${_observables.length})');
    }

    super.onClose();
  }
}

// ════════════════════════════════════════════════════════════
// Memory Manager
// ════════════════════════════════════════════════════════════

class MemoryManager {
  MemoryManager._();

  static final MemoryManager instance = MemoryManager._();

  // ════════════════════════════════════════════════════════════
  // Controller Tracking
  // ════════════════════════════════════════════════════════════

  final Map<String, DateTime> _controllerCreationTime = {};
  final Map<String, int> _controllerUsageCount = {};

  /// تسجيل إنشاء controller
  void registerController(String controllerId) {
    _controllerCreationTime[controllerId] = DateTime.now();
    _controllerUsageCount[controllerId] =
        (_controllerUsageCount[controllerId] ?? 0) + 1;

    if (kDebugMode) {
      print('✨ Controller registered: $controllerId');
    }
  }

  /// تسجيل حذف controller
  void unregisterController(String controllerId) {
    _controllerCreationTime.remove(controllerId);

    if (kDebugMode) {
      print('🗑️ Controller unregistered: $controllerId');
    }
  }

  /// الحصول على controllers النشطة
  List<String> getActiveControllers() {
    return _controllerCreationTime.keys.toList();
  }

  /// الحصول على عمر controller
  Duration? getControllerAge(String controllerId) {
    final creationTime = _controllerCreationTime[controllerId];
    if (creationTime == null) return null;

    return DateTime.now().difference(creationTime);
  }

  // ════════════════════════════════════════════════════════════
  // Memory Warnings
  // ════════════════════════════════════════════════════════════

  /// البحث عن controllers قديمة قد تكون leaked
  List<String> findPotentialLeaks({
    Duration threshold = const Duration(minutes: 30),
  }) {
    final leaks = <String>[];

    _controllerCreationTime.forEach((id, creationTime) {
      final age = DateTime.now().difference(creationTime);
      if (age > threshold) {
        leaks.add(id);
      }
    });

    return leaks;
  }

  /// طباعة تحذيرات Memory
  void printMemoryWarnings() {
    if (!kDebugMode) return;

    final leaks = findPotentialLeaks();

    if (leaks.isNotEmpty) {
      print('═══════════════════════════════════════════════════════');
      print('⚠️ Potential Memory Leaks Detected');
      print('═══════════════════════════════════════════════════════');

      for (final leak in leaks) {
        final age = getControllerAge(leak);
        final usage = _controllerUsageCount[leak] ?? 0;

        print('Controller: $leak');
        print('  Age: ${age?.inMinutes ?? 0} minutes');
        print('  Usage Count: $usage');
      }

      print('═══════════════════════════════════════════════════════');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Cleanup
  // ════════════════════════════════════════════════════════════

  /// تنظيف قسري لجميع Controllers
  void forceCleanup() {
    if (kDebugMode) {
      print('🧹 Force cleanup initiated');
    }

    // حذف جميع GetX controllers
    Get.deleteAll(force: true);

    // مسح tracking data
    _controllerCreationTime.clear();

    if (kDebugMode) {
      print('✅ Force cleanup completed');
    }
  }

  /// تنظيف controllers قديمة
  void cleanupOldControllers({
    Duration threshold = const Duration(minutes: 30),
  }) {
    final toRemove = findPotentialLeaks(threshold: threshold);

    if (kDebugMode && toRemove.isNotEmpty) {
      print('🧹 Cleaning up ${toRemove.length} old controllers');
    }

    for (final id in toRemove) {
      try {
        Get.delete(tag: id);
        unregisterController(id);
      } catch (e) {
        if (kDebugMode) {
          print('❌ Error cleaning up $id: $e');
        }
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Statistics
  // ════════════════════════════════════════════════════════════

  Map<String, dynamic> getStatistics() {
    return {
      'activeControllers': _controllerCreationTime.length,
      'controllers': _controllerCreationTime.keys.toList(),
      'usageCounts': Map.from(_controllerUsageCount),
      'potentialLeaks': findPotentialLeaks().length,
    };
  }

  void printStatistics() {
    if (!kDebugMode) return;

    print('═══════════════════════════════════════════════════════');
    print('📊 Memory Manager Statistics');
    print('═══════════════════════════════════════════════════════');

    final stats = getStatistics();

    print('Active Controllers: ${stats['activeControllers']}');
    print('Potential Leaks: ${stats['potentialLeaks']}');
    print('');

    print('Controllers:');
    for (final controller in stats['controllers']) {
      final age = getControllerAge(controller);
      final usage = _controllerUsageCount[controller] ?? 0;

      print('  - $controller');
      print('    Age: ${age?.inMinutes ?? 0} minutes');
      print('    Usage: $usage times');
    }

    print('═══════════════════════════════════════════════════════');
  }
}

// ════════════════════════════════════════════════════════════
// Base Controller with Auto Dispose
// ════════════════════════════════════════════════════════════

/// Base controller مع تنظيف تلقائي
abstract class BaseController extends GetxController with AutoDisposeMixin {
  final String controllerId;

  BaseController({String? id})
      : controllerId = id ?? DateTime.now().millisecondsSinceEpoch.toString() {
    MemoryManager.instance.registerController(controllerId);
  }

  @override
  void onClose() {
    MemoryManager.instance.unregisterController(controllerId);
    super.onClose();
  }
}

// ════════════════════════════════════════════════════════════
// Helper Extensions
// ════════════════════════════════════════════════════════════

extension RxListExtension<T> on RxList<T> {
  /// تنظيف آمن
  void safeClear() {
    try {
      clear();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error clearing RxList: $e');
      }
    }
  }

  /// إضافة آمنة
  void safeAdd(T item) {
    try {
      add(item);
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error adding to RxList: $e');
      }
    }
  }
}

extension RxMapExtension<K, V> on RxMap<K, V> {
  /// تنظيف آمن
  void safeClear() {
    try {
      clear();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error clearing RxMap: $e');
      }
    }
  }
}
