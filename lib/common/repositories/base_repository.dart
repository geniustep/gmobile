import 'package:gsloution_mobile/common/services/error/error_handler_service.dart';
import 'package:gsloution_mobile/common/offline/offline_queue_manager.dart'
    show OfflineQueueManager, PendingRequest, RequestPriority;
import 'package:gsloution_mobile/common/services/audit/audit_log_service.dart';

/// Base repository class
/// Provides common functionality for all repositories
abstract class BaseRepository<T> {
  final String entityName;

  BaseRepository(this.entityName);

  /// Get all records
  Future<List<T>> getAll({
    List<dynamic>? domain,
    bool showLoading = true,
  }) async {
    return await ErrorHandlerService.handleApiCall(
      apiCall: () => fetchAll(domain: domain, showLoading: showLoading),
      errorMessage: 'فشل تحميل $entityName',
    ) ?? [];
  }

  /// Get record by ID
  Future<T?> getById(int id) async {
    return await ErrorHandlerService.handleApiCall(
      apiCall: () => fetchById(id),
      errorMessage: 'فشل تحميل $entityName',
    );
  }

  /// Create new record
  Future<T?> create(Map<String, dynamic> data, {bool offline = false}) async {
    // Log audit
    await AuditLogService.log(
      action: AuditAction.create,
      entityType: entityName,
      metadata: data,
    );

    if (offline) {
      // Add to offline queue
      await OfflineQueueManager.instance.addToQueue(
        PendingRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          operation: 'create',
          model: entityName,
          data: data,
          priority: RequestPriority.medium,
        ),
      );
      return null;
    }

    return await ErrorHandlerService.handleApiCall(
      apiCall: () => performCreate(data),
      errorMessage: 'فشل إنشاء $entityName',
    );
  }

  /// Update record
  Future<T?> update(int id, Map<String, dynamic> data, {bool offline = false}) async {
    // Log audit
    await AuditLogService.log(
      action: AuditAction.update,
      entityType: entityName,
      entityId: id.toString(),
      metadata: data,
    );

    if (offline) {
      // Add to offline queue
      await OfflineQueueManager.instance.addToQueue(
        PendingRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          operation: 'write',
          model: entityName,
          data: {...data, 'id': id},
          priority: RequestPriority.medium,
        ),
      );
      return null;
    }

    return await ErrorHandlerService.handleApiCall(
      apiCall: () => performUpdate(id, data),
      errorMessage: 'فشل تحديث $entityName',
    );
  }

  /// Delete record
  Future<bool> delete(int id, {bool offline = false}) async {
    // Log audit
    await AuditLogService.log(
      action: AuditAction.delete,
      entityType: entityName,
      entityId: id.toString(),
    );

    if (offline) {
      // Add to offline queue
      await OfflineQueueManager.instance.addToQueue(
        PendingRequest(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          operation: 'unlink',
          model: entityName,
          data: {'id': id},
          priority: RequestPriority.medium,
        ),
      );
      return true;
    }

    return await ErrorHandlerService.handleApiCall(
      apiCall: () => performDelete(id),
      errorMessage: 'فشل حذف $entityName',
    ) ?? false;
  }

  /// Search records
  Future<List<T>> search(String query) async {
    return await ErrorHandlerService.handleApiCall(
      apiCall: () => performSearch(query),
      errorMessage: 'فشل البحث في $entityName',
    ) ?? [];
  }

  /// Filter records
  Future<List<T>> filter(Map<String, dynamic> filters) async {
    return await ErrorHandlerService.handleApiCall(
      apiCall: () => performFilter(filters),
      errorMessage: 'فشل التصفية في $entityName',
    ) ?? [];
  }

  // ========== Abstract methods to be implemented by subclasses ==========

  /// Fetch all records from API
  Future<List<T>> fetchAll({
    List<dynamic>? domain,
    bool showLoading = true,
  });

  /// Fetch record by ID from API
  Future<T> fetchById(int id);

  /// Perform create operation
  Future<T> performCreate(Map<String, dynamic> data);

  /// Perform update operation
  Future<T> performUpdate(int id, Map<String, dynamic> data);

  /// Perform delete operation
  Future<bool> performDelete(int id);

  /// Perform search operation
  Future<List<T>> performSearch(String query);

  /// Perform filter operation
  Future<List<T>> performFilter(Map<String, dynamic> filters);

  /// Get create endpoint
  String getCreateEndpoint();

  /// Get update endpoint
  String getUpdateEndpoint(int id);

  /// Get delete endpoint
  String getDeleteEndpoint(int id);
}
