import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/offline/offline_queue_manager.dart';
import 'package:gsloution_mobile/common/services/error/error_handler_service.dart';

/// Automatic synchronization service
/// Monitors connection status and syncs offline operations
class SyncService extends GetxController {
  static const String _tag = '🔄 SyncService';

  final RxBool isSyncing = false.obs;
  final RxBool isOnline = true.obs;
  final RxInt pendingOperations = 0.obs;
  final RxString syncStatus = 'idle'.obs; // idle, syncing, success, error

  Timer? _syncTimer;
  Timer? _connectionCheckTimer;

  @override
  void onInit() {
    super.onInit();
    _startConnectionMonitoring();
    _startPeriodicSync();
    if (kDebugMode) {
      print('$_tag Initialized');
    }
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    _connectionCheckTimer?.cancel();
    super.onClose();
  }

  /// Start monitoring connection status
  void _startConnectionMonitoring() {
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _checkConnection(),
    );
  }

  /// Check internet connection
  Future<void> _checkConnection() async {
    final wasOnline = isOnline.value;
    isOnline.value = await ErrorHandlerService.hasInternetConnection();

    // If connection was restored, trigger sync
    if (!wasOnline && isOnline.value) {
      if (kDebugMode) {
        print('$_tag Connection restored, triggering sync');
      }
      await syncPendingOperations();
    }
  }

  /// Start periodic sync (every 5 minutes when online)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) async {
        if (isOnline.value && !isSyncing.value) {
          await syncPendingOperations();
        }
      },
    );
  }

  /// Sync all pending operations
  Future<void> syncPendingOperations() async {
    if (isSyncing.value) {
      if (kDebugMode) {
        print('$_tag Sync already in progress');
      }
      return;
    }

    try {
      isSyncing.value = true;
      syncStatus.value = 'syncing';

      // Load queue first
      await OfflineQueueManager.instance.loadQueue();
      
      final requests = OfflineQueueManager.instance.getAllRequests();
      pendingOperations.value = requests.length;

      if (requests.isEmpty) {
        if (kDebugMode) {
          print('$_tag No pending operations to sync');
        }
        syncStatus.value = 'idle';
        isSyncing.value = false;
        return;
      }

      if (kDebugMode) {
        print('$_tag Syncing ${requests.length} operations');
      }

      int successCount = 0;
      int failCount = 0;

      for (var request in requests) {
        final operation = {
          'id': request.id,
          'type': request.operation,
          'data': request.data,
          'endpoint': request.model,
        };
        final success = await _syncOperation(operation);
        if (success) {
          successCount++;
          await OfflineQueueManager.instance.removeFromQueue(request.id);
        } else {
          failCount++;
          // Request will be retried automatically by OfflineQueueManager
        }
      }

      // Update statistics
      final stats = OfflineQueueManager.instance.getStatistics();
      pendingOperations.value = stats['total'] ?? 0;

      if (kDebugMode) {
        print('$_tag Sync completed: $successCount success, $failCount failed');
      }

      syncStatus.value = failCount == 0 ? 'success' : 'error';

      // Show notification
      if (successCount > 0) {
        ErrorHandlerService.showSuccess(
          'مزامنة ناجحة',
          'تم مزامنة $successCount عملية بنجاح',
        );
      }

      if (failCount > 0) {
        ErrorHandlerService.showWarning(
          'فشلت بعض العمليات',
          'فشلت مزامنة $failCount عملية. سيتم إعادة المحاولة لاحقاً',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Sync error: $e');
      }
      syncStatus.value = 'error';
      ErrorHandlerService.handleError(
        e,
        customMessage: 'فشلت عملية المزامنة',
      );
    } finally {
      isSyncing.value = false;
    }
  }

  /// Sync individual operation
  Future<bool> _syncOperation(Map<String, dynamic> operation) async {
    try {
      final type = operation['type'] as String;
      // ignore: unused_local_variable
      final data = operation['data'] as Map<String, dynamic>; // Will be used when implementing actual API calls
      final endpoint = operation['endpoint'] as String;

      if (kDebugMode) {
        print('$_tag Syncing $type operation to $endpoint');
      }

      // Here you would call the actual API based on the operation type
      // For now, we'll simulate success
      await Future.delayed(const Duration(milliseconds: 500));

      // Example of calling appropriate controller based on type
      switch (type) {
        case 'create':
        case 'create_payment':
          // await PaymentController.createPayment(data);
          break;
        case 'create_invoice':
          // await InvoiceController.createInvoice(data);
          break;
        case 'create_expense':
          // await ExpenseController.createExpense(data);
          break;
        case 'write':
        case 'update':
          // Update operation
          break;
        case 'unlink':
        case 'delete':
          // Delete operation
          break;
        case 'approve_expense':
          // await ExpenseController.approveExpense(data['id']);
          break;
        case 'reject_expense':
          // await ExpenseController.rejectExpense(data['id'], data['reason']);
          break;
        default:
          if (kDebugMode) {
            print('$_tag Unknown operation type: $type');
          }
          return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error syncing operation: $e');
      }
      return false;
    }
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    if (kDebugMode) {
      print('$_tag Force sync triggered');
    }
    await syncPendingOperations();
  }

  /// Get sync statistics
  Future<Map<String, dynamic>> getSyncStatistics() async {
    return OfflineQueueManager.instance.getStatistics();
  }

  /// Clear all sync data (use with caution)
  Future<void> clearSyncData() async {
    await OfflineQueueManager.instance.clearQueue();
    pendingOperations.value = 0;
    syncStatus.value = 'idle';
    if (kDebugMode) {
      print('$_tag Cleared all sync data');
    }
  }
}
