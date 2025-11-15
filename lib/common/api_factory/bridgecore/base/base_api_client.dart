// ════════════════════════════════════════════════════════════
// BaseApiClient - الواجهة الموحدة للتواصل مع Odoo
// ════════════════════════════════════════════════════════════
//
// هذه الواجهة تحدد العمليات الأساسية التي يجب أن يدعمها أي Client
// سواء كان Odoo Direct أو BridgeCore
//
// ════════════════════════════════════════════════════════════

import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';

// ════════════════════════════════════════════════════════════
// Base API Client Interface
// ════════════════════════════════════════════════════════════

abstract class BaseApiClient {
  // ════════════════════════════════════════════════════════════
  // Authentication
  // ════════════════════════════════════════════════════════════

  /// تسجيل الدخول
  Future<void> authenticate({
    required String username,
    required String password,
    required String database,
    required OnResponse onResponse,
    required OnError onError,
  });

  /// تسجيل الخروج
  Future<void> logout({
    required OnResponse onResponse,
    required OnError onError,
  });

  /// الحصول على معلومات الجلسة
  Future<void> getSessionInfo({
    required OnResponse onResponse,
    required OnError onError,
  });

  // ════════════════════════════════════════════════════════════
  // CRUD Operations
  // ════════════════════════════════════════════════════════════

  /// البحث والقراءة
  Future<void> searchRead({
    required String model,
    List<String>? fields,
    required List domain,
    dynamic limit,
    dynamic offset,
    String? order,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// القراءة بـ IDs
  Future<void> read({
    required String model,
    required List<int> ids,
    List<String>? fields,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// الإنشاء
  Future<void> create({
    required String model,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// التحديث
  Future<void> write({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// الحذف
  Future<void> unlink({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  // ════════════════════════════════════════════════════════════
  // Web Methods (Odoo 14+)
  // ════════════════════════════════════════════════════════════

  /// web_search_read - البحث المتقدم
  Future<void> webSearchRead({
    required String model,
    required Map<String, dynamic> specification,
    required List domain,
    dynamic limit,
    dynamic offset,
    String? order,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// web_read - القراءة المتقدمة
  Future<void> webRead({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> specification,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// web_save - الحفظ المتقدم
  Future<void> webSave({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? specification,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  // ════════════════════════════════════════════════════════════
  // Advanced Operations
  // ════════════════════════════════════════════════════════════

  /// استدعاء دالة مخصصة
  Future<void> callKW({
    required String model,
    required String method,
    required List args,
    Map<String, dynamic>? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// عد السجلات
  Future<void> searchCount({
    required String model,
    required List domain,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// الحصول على معلومات الحقول
  Future<void> fieldsGet({
    required String model,
    List<String>? attributes,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  /// onChange
  Future<void> onChange({
    required String model,
    required dynamic args,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  });

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  /// الحصول على اسم النظام
  String get systemName;

  /// هل متصل؟
  bool get isAuthenticated;

  /// الحصول على معلومات الاتصال
  Map<String, dynamic> getConnectionInfo();
}
