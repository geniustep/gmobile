import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

/// Audit log service for tracking user actions
/// Maintains a history of all important operations
class AuditLogService {
  static const String _boxName = 'audit_logs';
  static const String _tag = '📝 AuditLog';
  static const int _maxLogs = 1000; // Maximum number of logs to keep

  static Box? _logBox;

  /// Initialize the audit log service
  static Future<void> initialize() async {
    try {
      _logBox = await Hive.openBox(_boxName);
      if (kDebugMode) {
        print('$_tag Initialized with ${_logBox?.length ?? 0} logs');
      }
      // Clean old logs if exceeding limit
      await _cleanOldLogs();
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error initializing: $e');
      }
    }
  }

  /// Log an action
  static Future<void> log({
    required AuditAction action,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? metadata,
    String? description,
  }) async {
    try {
      if (_logBox == null) await initialize();

      final logEntry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'userId': PrefUtils.getUserId() ?? 'unknown',
        'userName': PrefUtils.getUserName() ?? 'Unknown User',
        'action': action.name,
        'entityType': entityType,
        'entityId': entityId,
        'description': description ?? _getActionDescription(action, entityType, entityId),
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
        'deviceInfo': await _getDeviceInfo(),
      };

      await _logBox?.add(logEntry);

      if (kDebugMode) {
        print('$_tag Logged: ${action.name} on $entityType${entityId != null ? " #$entityId" : ""}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error logging action: $e');
      }
    }
  }

  /// Get all logs
  static Future<List<Map<String, dynamic>>> getAllLogs() async {
    try {
      if (_logBox == null) await initialize();

      final logs = _logBox?.values
          .cast<Map<String, dynamic>>()
          .toList()
          .reversed
          .toList() ?? [];

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting all logs: $e');
      }
      return [];
    }
  }

  /// Get logs for specific entity
  static Future<List<Map<String, dynamic>>> getLogsForEntity({
    required String entityType,
    String? entityId,
  }) async {
    try {
      if (_logBox == null) await initialize();

      final logs = _logBox?.values
          .cast<Map<String, dynamic>>()
          .where((log) {
            final matchesType = log['entityType'] == entityType;
            final matchesId = entityId == null || log['entityId'] == entityId;
            return matchesType && matchesId;
          })
          .toList()
          .reversed
          .toList() ?? [];

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting entity logs: $e');
      }
      return [];
    }
  }

  /// Get logs for specific user
  static Future<List<Map<String, dynamic>>> getLogsForUser(String userId) async {
    try {
      if (_logBox == null) await initialize();

      final logs = _logBox?.values
          .cast<Map<String, dynamic>>()
          .where((log) => log['userId'] == userId)
          .toList()
          .reversed
          .toList() ?? [];

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting user logs: $e');
      }
      return [];
    }
  }

  /// Get logs by action type
  static Future<List<Map<String, dynamic>>> getLogsByAction(AuditAction action) async {
    try {
      if (_logBox == null) await initialize();

      final logs = _logBox?.values
          .cast<Map<String, dynamic>>()
          .where((log) => log['action'] == action.name)
          .toList()
          .reversed
          .toList() ?? [];

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting action logs: $e');
      }
      return [];
    }
  }

  /// Get logs within date range
  static Future<List<Map<String, dynamic>>> getLogsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      if (_logBox == null) await initialize();

      final logs = _logBox?.values
          .cast<Map<String, dynamic>>()
          .where((log) {
            final timestamp = DateTime.parse(log['timestamp']);
            return timestamp.isAfter(startDate) && timestamp.isBefore(endDate);
          })
          .toList()
          .reversed
          .toList() ?? [];

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting date range logs: $e');
      }
      return [];
    }
  }

  /// Search logs by description
  static Future<List<Map<String, dynamic>>> searchLogs(String query) async {
    try {
      if (_logBox == null) await initialize();

      final lowercaseQuery = query.toLowerCase();

      final logs = _logBox?.values
          .cast<Map<String, dynamic>>()
          .where((log) {
            final description = (log['description'] ?? '').toString().toLowerCase();
            final entityType = (log['entityType'] ?? '').toString().toLowerCase();
            final userName = (log['userName'] ?? '').toString().toLowerCase();
            return description.contains(lowercaseQuery) ||
                   entityType.contains(lowercaseQuery) ||
                   userName.contains(lowercaseQuery);
          })
          .toList()
          .reversed
          .toList() ?? [];

      return logs;
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error searching logs: $e');
      }
      return [];
    }
  }

  /// Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      if (_logBox == null) await initialize();

      final logs = await getAllLogs();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final thisWeek = now.subtract(Duration(days: now.weekday - 1));
      final thisMonth = DateTime(now.year, now.month, 1);

      int todayCount = 0;
      int weekCount = 0;
      int monthCount = 0;
      Map<String, int> actionCounts = {};
      Map<String, int> entityCounts = {};

      for (var log in logs) {
        final timestamp = DateTime.parse(log['timestamp']);
        final action = log['action'] as String;
        final entityType = log['entityType'] as String;

        if (timestamp.isAfter(today)) todayCount++;
        if (timestamp.isAfter(thisWeek)) weekCount++;
        if (timestamp.isAfter(thisMonth)) monthCount++;

        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        entityCounts[entityType] = (entityCounts[entityType] ?? 0) + 1;
      }

      return {
        'total': logs.length,
        'today': todayCount,
        'thisWeek': weekCount,
        'thisMonth': monthCount,
        'byAction': actionCounts,
        'byEntity': entityCounts,
      };
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error getting statistics: $e');
      }
      return {};
    }
  }

  /// Export logs as JSON
  static Future<String> exportLogsAsJson({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      List<Map<String, dynamic>> logs;

      if (startDate != null && endDate != null) {
        logs = await getLogsByDateRange(startDate: startDate, endDate: endDate);
      } else {
        logs = await getAllLogs();
      }

      return jsonEncode(logs);
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error exporting logs: $e');
      }
      return '[]';
    }
  }

  /// Clear old logs (keep only recent _maxLogs entries)
  static Future<void> _cleanOldLogs() async {
    try {
      if (_logBox == null) return;

      if (_logBox!.length > _maxLogs) {
        final logsToDelete = _logBox!.length - _maxLogs;
        final keys = _logBox!.keys.take(logsToDelete).toList();

        for (var key in keys) {
          await _logBox!.delete(key);
        }

        if (kDebugMode) {
          print('$_tag Cleaned $logsToDelete old logs');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error cleaning old logs: $e');
      }
    }
  }

  /// Clear all logs
  static Future<void> clearAllLogs() async {
    try {
      if (_logBox == null) await initialize();
      await _logBox?.clear();

      if (kDebugMode) {
        print('$_tag Cleared all logs');
      }
    } catch (e) {
      if (kDebugMode) {
        print('$_tag Error clearing logs: $e');
      }
    }
  }

  /// Get action description
  static String _getActionDescription(AuditAction action, String entityType, String? entityId) {
    final id = entityId != null ? ' #$entityId' : '';
    switch (action) {
      case AuditAction.create:
        return 'إنشاء $entityType$id';
      case AuditAction.update:
        return 'تحديث $entityType$id';
      case AuditAction.delete:
        return 'حذف $entityType$id';
      case AuditAction.view:
        return 'عرض $entityType$id';
      case AuditAction.approve:
        return 'الموافقة على $entityType$id';
      case AuditAction.reject:
        return 'رفض $entityType$id';
      case AuditAction.confirm:
        return 'تأكيد $entityType$id';
      case AuditAction.cancel:
        return 'إلغاء $entityType$id';
      case AuditAction.export:
        return 'تصدير $entityType';
      case AuditAction.import:
        return 'استيراد $entityType';
      case AuditAction.login:
        return 'تسجيل الدخول';
      case AuditAction.logout:
        return 'تسجيل الخروج';
    }
  }

  /// Get device info
  static Future<Map<String, String>> _getDeviceInfo() async {
    // This would typically use device_info_plus package
    // For now, return basic info
    return {
      'platform': 'mobile',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Audit action types
enum AuditAction {
  create,
  update,
  delete,
  view,
  approve,
  reject,
  confirm,
  cancel,
  export,
  import,
  login,
  logout,
}

/// Extension for PrefUtils
extension PrefUtilsAudit on PrefUtils {
  static String? getUserName() {
    // This would typically be stored in SharedPreferences
    return 'Test User';
  }
}
