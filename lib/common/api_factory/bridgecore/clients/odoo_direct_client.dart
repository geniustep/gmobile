// ════════════════════════════════════════════════════════════
// OdooDirectClient - Adapter للنظام القديم (الاتصال المباشر بـ Odoo)
// ════════════════════════════════════════════════════════════
//
// هذا الـ Client يستخدم Api class الموجود حالياً
// ويطبق واجهة BaseApiClient لتوحيد الطرق مع BridgeCoreClient
//
// ════════════════════════════════════════════════════════════

import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/base/base_api_client.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';

class OdooDirectClient implements BaseApiClient {
  // ════════════════════════════════════════════════════════════
  // Constructor
  // ════════════════════════════════════════════════════════════

  OdooDirectClient();

  // ════════════════════════════════════════════════════════════
  // Authentication
  // ════════════════════════════════════════════════════════════

  @override
  Future<void> authenticate({
    required String username,
    required String password,
    required String database,
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    Api.authenticate(
      username: username,
      password: password,
      database: database,
      onResponse: (userModel) {
        // تحويل UserModel إلى Map للتوافق مع الواجهة
        onResponse(userModel.toJson());
      },
      onError: onError,
    );
  }

  @override
  Future<void> logout({
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    Api.destroy(
      onResponse: onResponse,
      onError: onError,
    );
  }

  @override
  Future<void> getSessionInfo({
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    Api.getSessionInfo(
      onResponse: onResponse,
      onError: onError,
    );
  }

  // ════════════════════════════════════════════════════════════
  // CRUD Operations
  // ════════════════════════════════════════════════════════════

  @override
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
  }) async {
    await Api.searchRead(
      model: model,
      fields: fields,
      domain: domain,
      limit: limit,
      offset: offset,
      order: order,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> read({
    required String model,
    required List<int> ids,
    List<String>? fields,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.read(
      model: model,
      ids: ids,
      fields: fields,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> create({
    required String model,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.create(
      model: model,
      values: values,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> write({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.write(
      model: model,
      ids: ids,
      values: values,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> unlink({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.unlink(
      model: model,
      ids: ids,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Web Methods
  // ════════════════════════════════════════════════════════════

  @override
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
  }) async {
    await Api.webSearchRead(
      model: model,
      specification: specification,
      domain: domain,
      limit: limit,
      offset: offset,
      order: order,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> webRead({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> specification,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.webRead(
      model: model,
      ids: ids,
      specification: specification,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> webSave({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? specification,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.webSave(
      model: model,
      ids: ids,
      values: values,
      specification: specification,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Advanced Operations
  // ════════════════════════════════════════════════════════════

  @override
  Future<void> callKW({
    required String model,
    required String method,
    required List args,
    Map<String, dynamic>? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.callKW(
      model: model,
      method: method,
      args: args,
      kwargs: kwargs,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> searchCount({
    required String model,
    required List domain,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.searchCount(
      model: model,
      domain: domain,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> fieldsGet({
    required String model,
    List<String>? attributes,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.fieldsGetWithInfo(
      model: model,
      attributes: attributes,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  @override
  Future<void> onChange({
    required String model,
    required dynamic args,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Api.onChange(
      model: model,
      args: args,
      kwargs: kwargs,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  @override
  String get systemName => 'Odoo Direct';

  @override
  bool get isAuthenticated {
    // يمكن التحقق من وجود session في PrefUtils أو ApiConfig
    return true; // TODO: تحسين هذا
  }

  @override
  Map<String, dynamic> getConnectionInfo() {
    return {
      'system': systemName,
      'isAuthenticated': isAuthenticated,
      'note': 'Uses existing Api class',
    };
  }
}
