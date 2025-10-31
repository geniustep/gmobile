// ════════════════════════════════════════════════════════════
// api.dart - الصفحة الكاملة المحسّنة والمحدثة
// ════════════════════════════════════════════════════════════

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/api_end_points.dart';
import 'package:gsloution_mobile/common/api_factory/message/error_handler.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/api_factory/models/version_info_response.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/field_presets/fallback_level.dart';
import 'package:gsloution_mobile/common/config/field_presets/field_filter.dart';
import 'package:gsloution_mobile/common/config/field_presets/presets_manager.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/common/widgets/log.dart';
import 'package:gsloution_mobile/src/authentication/models/user_model.dart';

import 'package:uuid/uuid.dart';

// ════════════════════════════════════════════════════════════
// Enums
// ════════════════════════════════════════════════════════════

enum ApiEnvironment { UAT, Dev, Prod }

extension APIEnvi on ApiEnvironment {
  String get endpoint {
    switch (this) {
      case ApiEnvironment.UAT:
        return Config.odooUATURL;
      case ApiEnvironment.Dev:
        return Config.odooDevURL;
      case ApiEnvironment.Prod:
        return Config.odooProdURL;
    }
  }
}

enum HttpMethod { delete, get, patch, post, put }

extension HttpMethods on HttpMethod {
  String get value {
    switch (this) {
      case HttpMethod.delete:
        return 'DELETE';
      case HttpMethod.get:
        return 'GET';
      case HttpMethod.patch:
        return 'PATCH';
      case HttpMethod.post:
        return 'POST';
      case HttpMethod.put:
        return 'PUT';
    }
  }
}

// ════════════════════════════════════════════════════════════
// Api Class
// ════════════════════════════════════════════════════════════

class Api {
  Api._();

  // ════════════════════════════════════════════════════════════
  // Private Variables
  // ════════════════════════════════════════════════════════════

  static final Map<String, FieldFallbackStrategy> _activeStrategies = {};

  // ════════════════════════════════════════════════════════════
  // Loading Handler
  // ════════════════════════════════════════════════════════════

  static void _handleLoading(bool? showGlobalLoading, bool isStart) {
    if (showGlobalLoading == true) {
      if (isStart) {
        showLoading();
      } else {
        hideLoading();
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Error Handling
  // ════════════════════════════════════════════════════════════

  static final catchError = _catchError;

  static void _catchError(e, stackTrace, OnError onError) async {
    if (!kReleaseMode) {
      print(e);
    }

    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        onError('Server unreachable', {});
      } else if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        if (response != null) {
          var data = response.data;

          // HTML response check
          if (data is String && data.contains('<!doctype html>')) {
            await handleSessionExpired();
            onError(
              'Session expired or URL not found. Please login again.',
              {},
            );
            return;
          }

          // JSON response
          if (data != null && data is Map<String, dynamic>) {
            // Session expired check
            if (data.containsKey("error") && data["error"]["code"] == 100) {
              await handleSessionExpired();
              return;
            }

            onError('Failed to get response: ${e.message}', data);
            return;
          }
        }
        onError('Failed to get response: ${e.message}', {});
      } else {
        onError('Request cancelled: ${e.message}', {});
      }
    } else {
      onError(e?.toString() ?? 'Unknown error occurred', {});
    }
  }

  // ════════════════════════════════════════════════════════════
  // General Request
  // ════════════════════════════════════════════════════════════

  static Future<void> request({
    required HttpMethod method,
    required String path,
    required Map params,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    Future.delayed(const Duration(microseconds: 1), () {
      if (path != ApiEndPoints.getVersionInfo &&
          path != ApiEndPoints.getDb &&
          path != ApiEndPoints.getDb9 &&
          path != ApiEndPoints.getDb10) {
        _handleLoading(showGlobalLoading, true);
      }
    });

    try {
      Response? response;
      switch (method) {
        case HttpMethod.post:
          response = await DioFactory.dio!.post(path, data: params);
          break;
        case HttpMethod.delete:
          response = await DioFactory.dio!.delete(path, data: params);
          break;
        case HttpMethod.get:
          response = await DioFactory.dio!.get(path);
          break;
        case HttpMethod.patch:
          response = await DioFactory.dio!.patch(path, data: params);
          break;
        case HttpMethod.put:
          response = await DioFactory.dio!.put(path, data: params);
          break;
      }

      _handleLoading(showGlobalLoading, false);

      if (response.data["success"] == 0) {
        final error = ErrorHandler.handleErrorCode(
          'SERVER_ERROR',
          customMessage: response.data["error"][0],
        );
        ErrorHandler.showError(error);
        onError(error.message, {});
      } else {
        if (response.data.containsKey("error") &&
            response.data["error"] is Map<String, dynamic> &&
            response.data["error"]["code"] == 100) {
          final error = ErrorHandler.handleErrorCode('SESSION_EXPIRED');
          ErrorHandler.showError(error);
          await handleSessionExpired();
        } else if (response.data.containsKey("result")) {
          onResponse(response.data["result"]);
        } else {
          final error = ErrorHandler.handleErrorCode('BAD_RESPONSE');
          ErrorHandler.showError(error);
          onError(error.message, response.data);
        }
      }

      if (path == ApiEndPoints.authenticate) {
        _updateCookies(response.headers);
      }
    } on DioException catch (e) {
      _handleLoading(showGlobalLoading, false);

      AppError error;

      if (e.type == DioExceptionType.connectionError) {
        if (e.error is SocketException) {
          final socketException = e.error as SocketException;
          if (socketException.osError?.errorCode == 7 ||
              e.message?.contains('Failed host lookup') == true) {
            error = ErrorHandler.handleErrorCode('NO_INTERNET');
          } else {
            error = ErrorHandler.handleErrorCode('CONNECTION_FAILED');
          }
        } else {
          error = ErrorHandler.handleErrorCode('CONNECTION_FAILED');
        }
      } else if (e.type == DioExceptionType.connectionTimeout) {
        error = ErrorHandler.handleErrorCode('CONNECTION_TIMEOUT');
      } else if (e.type == DioExceptionType.sendTimeout) {
        error = ErrorHandler.handleErrorCode('SEND_TIMEOUT');
      } else if (e.type == DioExceptionType.receiveTimeout) {
        error = ErrorHandler.handleErrorCode('RECEIVE_TIMEOUT');
      } else if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        if (response != null) {
          var data = response.data;

          if (data is String && data.contains('<!doctype html>')) {
            error = ErrorHandler.handleErrorCode('SESSION_EXPIRED');
            ErrorHandler.showError(error);
            await handleSessionExpired();
            onError(error.message, {});
            return;
          }

          if (data != null && data is Map<String, dynamic>) {
            if (data.containsKey("error")) {
              error = ErrorHandler.handleOdooError(data["error"]);
              if (data["error"]["code"] == 100) {
                ErrorHandler.showError(error);
                await handleSessionExpired();
                onError(error.message, {});
                return;
              }
            } else {
              error = ErrorHandler.handleErrorCode('BAD_RESPONSE');
            }
          } else {
            error = ErrorHandler.handleErrorCode('BAD_RESPONSE');
          }
        } else {
          error = ErrorHandler.handleErrorCode('BAD_RESPONSE');
        }
      } else if (e.type == DioExceptionType.cancel) {
        error = ErrorHandler.handleErrorCode('REQUEST_CANCELLED');
      } else if (e.type == DioExceptionType.unknown) {
        if (e.error is SocketException) {
          error = ErrorHandler.handleErrorCode('NO_INTERNET');
        } else {
          error = ErrorHandler.handleErrorCode('UNKNOWN_ERROR');
        }
      } else {
        error = ErrorHandler.handleErrorCode('UNKNOWN_ERROR');
      }

      ErrorHandler.showError(error);
      ErrorHandler.logError(error);
      onError(error.message, {});
    } catch (e) {
      _handleLoading(showGlobalLoading, false);
      log('Unexpected error: $e');

      final error = ErrorHandler.handleErrorCode('UNKNOWN_ERROR');
      ErrorHandler.showError(error);
      ErrorHandler.logError(error);
      onError(error.message, {});
    }
  }

  static void _updateCookies(Headers headers) async {
    Log("Updating cookies...");
    final cookies = headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      final combinedCookies = cookies.join('; ');
      DioFactory.initialiseHeaders(combinedCookies);
      await PrefUtils.setToken(combinedCookies);
      Log("Cookies updated successfully: $combinedCookies");
    } else {
      Log("No cookies found in the response headers.");
    }
  }

  // ════════════════════════════════════════════════════════════
  // Session Management
  // ════════════════════════════════════════════════════════════

  static getSessionInfo({
    required OnResponse onResponse,
    required OnError onError,
  }) {
    request(
      method: HttpMethod.post,
      path: ApiEndPoints.getSessionInfo,
      params: createPayload({}),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  static destroy({required OnResponse onResponse, required OnError onError}) {
    request(
      method: HttpMethod.post,
      path: ApiEndPoints.destroy,
      params: createPayload({}),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Authentication
  // ════════════════════════════════════════════════════════════

  static authenticate({
    required String username,
    required String password,
    required String database,
    required OnResponse<UserModel> onResponse,
    required OnError onError,
  }) {
    var params = {
      "db": database,
      "login": username,
      "password": password,
      "context": {},
    };

    request(
      method: HttpMethod.post,
      path: ApiEndPoints.authenticate,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(UserModel.fromJson(response));
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Call KW - الدالة الأساسية
  // ════════════════════════════════════════════════════════════

  static callKW({
    required String model,
    required String method,
    required List args,
    Map<String, dynamic>? context,
    Map? kwargs, // ✅ Optional - لا يحتاج required
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    var params = {
      "model": model,
      "method": method,
      "args": args,
      "kwargs": kwargs ?? {}, // ✅ استخدام {} كقيمة افتراضية
    };

    request(
      method: HttpMethod.post,
      path: ApiEndPoints.callKw,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Fields Get - اكتشاف الحقول من السيرفر
  // ════════════════════════════════════════════════════════════

  static fieldsGet({
    required String model,
    List<String>? attributes,
    required OnResponse<List<String>> onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "fields_get",
      args: [],
      kwargs: {if (attributes != null) "attributes": attributes},
      onResponse: (response) {
        if (response is Map<String, dynamic>) {
          final fieldNames = response.keys.toList();
          print('📋 Discovered ${fieldNames.length} fields for $model');
          onResponse(fieldNames);
        } else {
          onError('Unexpected response format', {});
        }
      },
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  static fieldsGetWithInfo({
    required String model,
    List<String>? attributes,
    required OnResponse<Map<String, dynamic>> onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "fields_get",
      args: [],
      kwargs: {
        "attributes":
            attributes ?? ['string', 'type', 'help', 'required', 'readonly'],
      },
      onResponse: (response) {
        if (response is Map<String, dynamic>) {
          print('📋 Discovered ${response.length} fields with info for $model');
          onResponse(response);
        } else {
          onError('Unexpected response format', {});
        }
      },
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Search Read - مع Fallback Strategy الذكي
  // ════════════════════════════════════════════════════════════

  static Future<void> searchRead({
    required String model,
    List<String>? fields,
    FieldPreset? preset,
    required List domain,
    dynamic limit,
    dynamic offset,
    String? order,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
    bool useSmartFallback = true, // ✅ تفعيل/تعطيل Smart Fallback
  }) async {
    // تحديد الحقول الأولية
    List<String>? initialFields = fields;

    if (preset != null && fields == null) {
      initialFields = FieldPresetsManager.getFields(model, preset);
    }

    if (initialFields != null && initialFields.isNotEmpty) {
      initialFields = FieldFilter.instance.apply(initialFields);
    }

    // إذا Smart Fallback معطل، استخدم الطريقة التقليدية
    if (!useSmartFallback || initialFields == null) {
      await _directSearchRead(
        model: model,
        fields: initialFields,
        domain: domain,
        limit: limit,
        offset: offset,
        order: order,
        context: context,
        onResponse: onResponse,
        onError: onError,
        showGlobalLoading: showGlobalLoading,
      );
      return;
    }

    // ✅ استخدام Smart Fallback Strategy
    print('📋 searchRead with Smart Fallback: $model');
    print('   Initial fields: ${initialFields.length}');

    // إنشاء Strategy
    final strategyKey =
        '$model-searchRead-${DateTime.now().millisecondsSinceEpoch}';

    final strategy = FieldFallbackStrategy(
      model: model,
      onFieldsGet: (model) async {
        final completer = Completer<Map<String, dynamic>>();

        fieldsGetWithInfo(
          model: model,
          onResponse: (fieldsInfo) => completer.complete(fieldsInfo),
          onError: (error, data) => completer.completeError(error),
          showGlobalLoading: false,
        );

        return await completer.future;
      },
    );

    strategy.initialize(initialFields);
    _activeStrategies[strategyKey] = strategy;

    await _attemptSearchRead(
      strategyKey: strategyKey,
      strategy: strategy,
      model: model,
      domain: domain,
      limit: limit,
      offset: offset,
      order: order,
      context: context,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );

    // تنظيف
    _activeStrategies.remove(strategyKey);
  }

  // ────────────────────────────────────────────────────────
  // محاولة Search Read مع معالجة الأخطاء
  // ────────────────────────────────────────────────────────

  static Future<void> _attemptSearchRead({
    required String strategyKey,
    required FieldFallbackStrategy strategy,
    required String model,
    required List domain,
    dynamic limit,
    dynamic offset,
    String? order,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    required bool? showGlobalLoading,
  }) async {
    final currentFields = strategy.getCurrentFields();

    await _directSearchRead(
      model: model,
      fields: currentFields,
      domain: domain,
      limit: limit,
      offset: offset,
      order: order,
      context: context,
      onResponse: (response) {
        // Success!
        final status = strategy.getStatus();
        print('✅ searchRead success: $model');
        print('   Level: ${status['current_level']}');
        print('   Fields: ${status['current_fields_count']}');

        if (status['retry_count'] > 0) {
          print('   Retries: ${status['retry_count']}');
          print('   Invalid fields: ${status['cached_invalid_fields']}');
        }

        onResponse(response);
      },
      onError: (error, data) async {
        final errorStr = error.toString();

        // تحقق: هل الخطأ Invalid field؟
        if (errorStr.contains('Invalid field')) {
          try {
            // معالجة الخطأ
            final newFields = await strategy.handleInvalidField(errorStr);

            if (newFields != null && newFields.isNotEmpty) {
              // إعادة المحاولة
              print('🔄 Retrying searchRead...');

              await _attemptSearchRead(
                strategyKey: strategyKey,
                strategy: strategy,
                model: model,
                domain: domain,
                limit: limit,
                offset: offset,
                order: order,
                context: context,
                onResponse: onResponse,
                onError: onError,
                showGlobalLoading: false, // تم عرض loading مسبقاً
              );
              return;
            }
          } catch (strategyError) {
            print('❌ Strategy exhausted: $strategyError');
            onError(strategyError.toString(), {});
            return;
          }
        }

        // خطأ آخر
        onError(error, data);
      },
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ────────────────────────────────────────────────────────
  // Search Read المباشر (بدون Strategy)
  // ────────────────────────────────────────────────────────

  static Future<void> _directSearchRead({
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
    var params = {
      "model": model,
      "method": "search_read",
      "args": [],
      "kwargs": {
        "domain": domain,
        if (fields != null) "fields": fields,
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        if (order != null) "order": order,
        "context": context ?? {},
      },
    };

    request(
      method: HttpMethod.post,
      path: ApiEndPoints.callKw,
      params: createPayload(params),
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Web Search Read - مع دعم Presets
  // ════════════════════════════════════════════════════════════

  static Future<void> webSearchRead({
    required String model,
    Map<String, dynamic>? specification,
    FieldPreset? preset,
    required List domain,
    dynamic limit,
    dynamic offset,
    String? order,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    // بناء specification
    Map<String, dynamic> finalSpec = specification ?? {};

    if (preset != null && specification == null) {
      final fields = FieldPresetsManager.getFields(model, preset);

      if (fields != null && fields.isNotEmpty) {
        final filteredFields = FieldFilter.instance.apply(fields);

        finalSpec = {for (var field in filteredFields) field: {}};

        print('📋 webSearchRead: $model');
        print('   Preset: ${preset.toString().split('.').last}');
        print('   Specification fields: ${finalSpec.length}');
      }
    }

    var params = {
      "model": model,
      "method": "web_search_read",
      "args": [],
      "kwargs": {
        "domain": domain,
        "specification": finalSpec,
        if (limit != null) "limit": limit,
        if (offset != null) "offset": offset,
        if (order != null) "order": order,
        "context": context ?? {},
      },
    };

    request(
      method: HttpMethod.post,
      path: ApiEndPoints.callKw,
      params: createPayload(params),
      onResponse: (response) {
        // web_search_read returns {records: [], length: x}
        if (response is Map && response.containsKey('records')) {
          onResponse(response['records']);
        } else {
          onResponse(response);
        }
      },
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Search Count
  // ════════════════════════════════════════════════════════════

  static searchCount({
    required String model,
    required List domain,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "search_count",
      args: [],
      kwargs: {"domain": domain, if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Read
  // ════════════════════════════════════════════════════════════

  static read({
    required String model,
    required List<int> ids,
    List<String>? fields,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "read",
      args: [ids],
      kwargs: {
        if (fields != null) "fields": fields,
        if (context != null) "context": context,
      },
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Create
  // ════════════════════════════════════════════════════════════

  static create({
    required String model,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "create",
      args: [values],
      kwargs: {if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Write
  // ════════════════════════════════════════════════════════════

  static write({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "write",
      args: [ids, values],
      kwargs: {if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Unlink
  // ════════════════════════════════════════════════════════════

  static unlink({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "unlink",
      args: [ids],
      kwargs: {if (context != null) "context": context},
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Execute
  // ════════════════════════════════════════════════════════════

  static execute({
    required String model,
    required List<int> ids,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "execute",
      args: [ids],
      kwargs: kwargs,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Web Save
  // ════════════════════════════════════════════════════════════

  static webSave({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> values,
    Map<String, dynamic>? specification,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) {
    callKW(
      model: model,
      method: "web_save",
      args: [ids, values],
      kwargs: {
        if (specification != null) "specification": specification,
        if (context != null) "context": context,
      },
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Web Read
  // ════════════════════════════════════════════════════════════

  static webRead({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> specification,
    Map<String, dynamic>? context,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) {
    callKW(
      model: model,
      method: "web_read",
      args: [ids],
      kwargs: {
        "specification": specification,
        if (context != null) "context": context,
      },
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // OnChange
  // ════════════════════════════════════════════════════════════

  static onChange({
    required String model,
    required dynamic args,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    callKW(
      model: model,
      method: "onchange",
      args: args,
      kwargs: kwargs,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Call Controller
  // ════════════════════════════════════════════════════════════

  static callController({
    required String path,
    required Map params,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    request(
      method: HttpMethod.post,
      path: path,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Get Version Info
  // ════════════════════════════════════════════════════════════

  static getVersionInfo({
    required OnResponse<VersionInfoResponse> onResponse,
    required OnError onError,
  }) {
    request(
      method: HttpMethod.post,
      path: ApiEndPoints.getVersionInfo,
      params: createPayload({}),
      onResponse: (response) {
        onResponse(VersionInfoResponse.fromJson(response));
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Get Databases
  // ════════════════════════════════════════════════════════════

  static getDatabases({
    required int serverVersionNumber,
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    var params = {};
    var endPoint = "";

    if (serverVersionNumber == 9) {
      params["method"] = "list";
      params["service"] = "db";
      params["args"] = [];
      endPoint = ApiEndPoints.getDb9;
    } else if (serverVersionNumber >= 10) {
      endPoint = ApiEndPoints.getDb10;
      params["context"] = {};
    } else {
      endPoint = ApiEndPoints.getDb;
      params["context"] = {};
    }

    request(
      method: HttpMethod.post,
      path: endPoint,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Has Right
  // ════════════════════════════════════════════════════════════

  static hasRight({
    required String model,
    required List right,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) {
    callKW(
      model: model,
      method: "has_group",
      args: right,
      kwargs: kwargs,
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════

  static Map createPayload(Map params) {
    return {
      "id": const Uuid().v1(),
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    };
  }

  static Map getContext(dynamic addition) {
    Map map = {
      "lang": "en_US",
      "tz": "Europe/Brussels",
      "uid": const Uuid().v1(),
    };
    if (addition != null && addition.isNotEmpty) {
      addition.forEach((key, value) {
        map[key] = value;
      });
    }
    return map;
  }

  // ════════════════════════════════════════════════════════════
  // Print PDF Report
  // ════════════════════════════════════════════════════════════

  static printPdfReport({
    required String model,
    required String method,
    required List args,
    dynamic context,
    Map? kwargs,
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    var params;
    if (context != null) {
      kwargs = kwargs ?? {};
      kwargs["context"] = getContext(context);
      params = {
        "model": model,
        "method": method,
        "args": args,
        "kwargs": kwargs,
      };
    } else {
      params = {
        "model": model,
        "method": method,
        "args": args,
        "kwargs": kwargs ?? {},
        "context": getContext(context),
      };
    }

    request(
      method: HttpMethod.post,
      path: ApiEndPoints.report,
      params: createPayload(params),
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        onError(error, {});
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Download PDF Report
  // ════════════════════════════════════════════════════════════

  static Future<void> downloadPdfReport({
    required String reportName,
    required List<int> ids,
    required String model,
  }) async {
    final url = Config.odooDevURL + 'jsonrpc';
    final body = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': {
        'service': 'report',
        'method': 'render_report',
        'args': [reportName, model, ids, 'pdf'],
      },
      'id': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      var response = await DioFactory.dio!.post(url, data: body);
      if (response.statusCode == 200 && response.data['result'] != null) {
        final pdfData = base64Decode(response.data['result']['result']);
        // حفظ pdfData كملف PDF
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
    }
  }

  // ════════════════════════════════════════════════════════════
  // Add Module
  // ════════════════════════════════════════════════════════════

  static addModule({
    required String model,
    required dynamic maps,
    required OnResponse onResponse,
  }) async {
    Api.create(
      model: model,
      values: maps!,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Utilities - الحصول على Strategy Statistics
  // ════════════════════════════════════════════════════════════

  static Map<String, dynamic> getActiveStrategiesStats() {
    return {
      'active_count': _activeStrategies.length,
      'strategies': _activeStrategies.map(
        (key, strategy) => MapEntry(key, strategy.getStatus()),
      ),
    };
  }

  static void clearActiveStrategies() {
    _activeStrategies.clear();
    print('🧹 Cleared active strategies');
  }

  // ════════════════════════════════════════════════════════════
  // Global Invalid Fields Cache Management
  // ════════════════════════════════════════════════════════════

  static Map<String, List<String>> getGlobalInvalidFieldsCache() {
    return FieldFallbackStrategy.getGlobalInvalidFieldsCache();
  }

  static void clearGlobalInvalidFieldsCache() {
    FieldFallbackStrategy.clearGlobalCache();
  }
}
