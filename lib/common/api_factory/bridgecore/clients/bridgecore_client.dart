// ════════════════════════════════════════════════════════════
// BridgeCoreClient - الاتصال بـ Odoo عبر BridgeCore middleware
// ════════════════════════════════════════════════════════════
//
// هذا الـ Client يتصل بـ BridgeCore API الذي بدوره يتصل بـ Odoo
// مع تحسينات في:
// - الأداء (caching, connection pooling)
// - الأمان (تشفير, rate limiting)
// - الموثوقية (retry logic, circuit breaker)
//
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/base/base_api_client.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';

class BridgeCoreClient implements BaseApiClient {
  // ════════════════════════════════════════════════════════════
  // Private Variables
  // ════════════════════════════════════════════════════════════

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final String _baseUrl;

  String? _accessToken;
  String? _refreshToken;
  String? _systemId;
  bool _isAuthenticated = false;

  // ════════════════════════════════════════════════════════════
  // Constructor
  // ════════════════════════════════════════════════════════════

  BridgeCoreClient()
      : _dio = Dio(),
        _storage = const FlutterSecureStorage(),
        _baseUrl = ApiModeConfig.instance.bridgeCoreUrl {
    _setupInterceptors();
    _loadTokens();
  }

  // ════════════════════════════════════════════════════════════
  // Setup
  // ════════════════════════════════════════════════════════════

  void _setupInterceptors() {
    // Request Interceptor - إضافة token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }

          if (kDebugMode) {
            print('🚀 BridgeCore Request: ${options.method} ${options.path}');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // معالجة انتهاء صلاحية Token
          if (error.response?.statusCode == 401) {
            if (kDebugMode) {
              print('🔒 Token expired, refreshing...');
            }

            if (await _refreshAccessToken()) {
              // إعادة المحاولة مع token جديد
              final options = error.requestOptions;
              options.headers['Authorization'] = 'Bearer $_accessToken';

              try {
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }

          return handler.next(error);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('✅ BridgeCore Response: ${response.statusCode}');
          }
          return handler.next(response);
        },
      ),
    );

    // Timeout configuration
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  Future<void> _loadTokens() async {
    try {
      _accessToken = await _storage.read(key: 'bridgecore_access_token');
      _refreshToken = await _storage.read(key: 'bridgecore_refresh_token');
      _systemId = await _storage.read(key: 'bridgecore_system_id');

      _isAuthenticated = _accessToken != null;

      if (kDebugMode && _isAuthenticated) {
        print('✅ Loaded BridgeCore tokens from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error loading tokens: $e');
      }
    }
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      if (kDebugMode) {
        print('❌ No refresh token available');
      }
      return false;
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $_refreshToken'},
        ),
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        _accessToken = response.data['access_token'];
        await _storage.write(
          key: 'bridgecore_access_token',
          value: _accessToken,
        );

        if (kDebugMode) {
          print('✅ Access token refreshed successfully');
        }

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing token: $e');
      }
      return false;
    }
  }

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
    try {
      showLoading();

      final response = await _dio.post(
        '$_baseUrl/api/v1/auth/login',
        data: {
          'username': username,
          'password': password,
          'database': database,
        },
      );

      hideLoading();

      if (response.statusCode == 200) {
        final data = response.data;

        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _systemId = data['system_id'];
        _isAuthenticated = true;

        // حفظ في secure storage
        await _storage.write(key: 'bridgecore_access_token', value: _accessToken);
        await _storage.write(key: 'bridgecore_refresh_token', value: _refreshToken);
        await _storage.write(key: 'bridgecore_system_id', value: _systemId);

        if (kDebugMode) {
          print('✅ BridgeCore authentication successful');
          print('   System ID: $_systemId');
        }

        // تحويل الاستجابة لتكون متوافقة مع Odoo Direct
        final userResponse = {
          'uid': data['user']['id'],
          'username': data['user']['username'],
          'name': data['user']['name'],
          'company_id': data['user']['company_id'],
          'partner_id': data['user']['partner_id'],
        };

        onResponse(userResponse);
      } else {
        onError('Authentication failed', {});
      }
    } catch (e) {
      hideLoading();

      if (kDebugMode) {
        print('❌ BridgeCore authentication error: $e');
      }

      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Authentication failed';
        onError(errorMessage, e.response?.data ?? {});
      } else {
        onError(e.toString(), {});
      }
    }
  }

  @override
  Future<void> logout({
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    try {
      await _dio.post(
        '$_baseUrl/api/v1/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      // مسح tokens
      await _storage.delete(key: 'bridgecore_access_token');
      await _storage.delete(key: 'bridgecore_refresh_token');
      await _storage.delete(key: 'bridgecore_system_id');

      _accessToken = null;
      _refreshToken = null;
      _systemId = null;
      _isAuthenticated = false;

      if (kDebugMode) {
        print('✅ BridgeCore logout successful');
      }

      onResponse({});
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ BridgeCore logout error: $e');
      }

      // حتى لو فشل الـ logout على السيرفر، نمسح البيانات المحلية
      await _storage.deleteAll();
      _accessToken = null;
      _refreshToken = null;
      _systemId = null;
      _isAuthenticated = false;

      onResponse({});
    }
  }

  @override
  Future<void> getSessionInfo({
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/api/v1/auth/session',
        options: Options(
          headers: {'Authorization': 'Bearer $_accessToken'},
        ),
      );

      if (response.statusCode == 200) {
        onResponse(response.data);
      } else {
        onError('Failed to get session info', {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting session info: $e');
      }
      onError(e.toString(), {});
    }
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
    await _executeOperation(
      operation: 'search_read',
      data: {
        'model': model,
        'domain': domain,
        if (fields != null) 'fields': fields,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (order != null) 'order': order,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'read',
      data: {
        'model': model,
        'ids': ids,
        if (fields != null) 'fields': fields,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'create',
      data: {
        'model': model,
        'values': values,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'write',
      data: {
        'model': model,
        'ids': ids,
        'values': values,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'unlink',
      data: {
        'model': model,
        'ids': ids,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'web_search_read',
      data: {
        'model': model,
        'specification': specification,
        'domain': domain,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
        if (order != null) 'order': order,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'web_read',
      data: {
        'model': model,
        'ids': ids,
        'specification': specification,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'web_save',
      data: {
        'model': model,
        'ids': ids,
        'values': values,
        if (specification != null) 'specification': specification,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'call_kw',
      data: {
        'model': model,
        'method': method,
        'args': args,
        if (kwargs != null) 'kwargs': kwargs,
      },
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
    await _executeOperation(
      operation: 'search_count',
      data: {
        'model': model,
        'domain': domain,
        if (context != null) 'context': context,
      },
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
    await _executeOperation(
      operation: 'fields_get',
      data: {
        'model': model,
        if (attributes != null) 'attributes': attributes,
      },
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
    await _executeOperation(
      operation: 'onchange',
      data: {
        'model': model,
        'args': args,
        if (kwargs != null) 'kwargs': kwargs,
      },
      onResponse: onResponse,
      onError: onError,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════

  Future<void> _executeOperation({
    required String operation,
    required Map<String, dynamic> data,
    required OnResponse onResponse,
    required OnError onError,
    bool? showGlobalLoading,
  }) async {
    if (_systemId == null) {
      onError('Not authenticated', {});
      return;
    }

    try {
      if (showGlobalLoading == true) {
        showLoading();
      }

      final response = await _dio.post(
        '$_baseUrl/api/v1/systems/$_systemId/odoo/$operation',
        data: data,
      );

      if (showGlobalLoading == true) {
        hideLoading();
      }

      if (response.statusCode == 200) {
        final result = response.data['result'];
        onResponse(result);
      } else {
        onError('Operation failed', response.data ?? {});
      }
    } catch (e) {
      if (showGlobalLoading == true) {
        hideLoading();
      }

      if (kDebugMode) {
        print('❌ BridgeCore operation error: $e');
      }

      if (e is DioException) {
        final errorMessage = e.response?.data?['message'] ?? 'Operation failed';
        onError(errorMessage, e.response?.data ?? {});
      } else {
        onError(e.toString(), {});
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  @override
  String get systemName => 'BridgeCore';

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  Map<String, dynamic> getConnectionInfo() {
    return {
      'system': systemName,
      'baseUrl': _baseUrl,
      'isAuthenticated': _isAuthenticated,
      'systemId': _systemId,
      'hasAccessToken': _accessToken != null,
      'hasRefreshToken': _refreshToken != null,
    };
  }
}
