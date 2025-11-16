// ════════════════════════════════════════════════════════════
// OptimisticRepository - Optimistic UI updates
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';

abstract class OptimisticRepository<T> {
  // Local data snapshot for rollback
  List<T>? _snapshot;

  Future<void> optimisticUpdate({
    required Future<void> Function() serverUpdate,
    required void Function() localUpdate,
    required void Function() rollback,
    void Function()? onSuccess,
    void Function(dynamic error)? onError,
  }) async {
    try {
      // 1. Apply local update immediately (Optimistic)
      localUpdate();

      if (kDebugMode) {
        print('⚡ Optimistic update applied locally');
      }

      // 2. Send to server
      await serverUpdate();

      if (kDebugMode) {
        print('✅ Server update confirmed');
      }

      onSuccess?.call();
    } catch (error) {
      // 3. Rollback on failure
      if (kDebugMode) {
        print('❌ Server update failed, rolling back...');
      }

      rollback();
      onError?.call(error);

      rethrow;
    }
  }

  void createSnapshot(List<T> data) {
    _snapshot = List<T>.from(data);
  }

  List<T>? getSnapshot() {
    return _snapshot;
  }

  void clearSnapshot() {
    _snapshot = null;
  }
}
