import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';

/// Interceptor for handling authentication and token refresh
class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<RequestOptions> _pendingRequests = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token to headers if available
    _addTokenToRequest(options);
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Session expired
    if (err.response?.statusCode == 401) {
      final options = err.requestOptions;

      // Don't retry authentication endpoint
      if (options.path.contains('authenticate') ||
          options.path.contains('destroy')) {
        return handler.next(err);
      }

      // If already refreshing, queue this request
      if (_isRefreshing) {
        _pendingRequests.add(options);
        return handler.next(err);
      }

      _isRefreshing = true;

      try {
        // Try to refresh session by getting session info
        final refreshed = await _refreshSession();

        if (refreshed) {
          // Retry the original request
          _addTokenToRequest(options);
          final response = await DioFactory.dio!.fetch(options);
          _processPendingRequests();
          return handler.resolve(response);
        } else {
          // Refresh failed, show session dialog
          if (kDebugMode) {
            print('Session refresh failed, showing dialog...');
          }
          showSessionDialog();
          _processPendingRequests();
          return handler.next(err);
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error refreshing session: $e');
        }
        showSessionDialog();
        _processPendingRequests();
        return handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    }

    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle successful responses
    return handler.next(response);
  }

  /// Add token to request headers
  void _addTokenToRequest(RequestOptions options) async {
    try {
      final token = await PrefUtils.getToken();
      if (token.isNotEmpty) {
        options.headers['Cookie'] = token;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding token to request: $e');
      }
    }
  }

  /// Refresh session by getting session info
  Future<bool> _refreshSession() async {
    try {
      final completer = Completer<bool>();

      Api.getSessionInfo(
        onResponse: (response) {
          if (kDebugMode) {
            print('Session refreshed successfully');
          }
          completer.complete(true);
        },
        onError: (error, data) {
          if (kDebugMode) {
            print('Session refresh failed: $error');
          }
          completer.complete(false);
        },
      );

      // Wait for response with timeout
      return await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          if (kDebugMode) {
            print('Session refresh timeout');
          }
          return false;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in refresh session: $e');
      }
      return false;
    }
  }

  /// Process pending requests after refresh
  void _processPendingRequests() {
    final requests = List<RequestOptions>.from(_pendingRequests);
    _pendingRequests.clear();

    for (final options in requests) {
      _addTokenToRequest(options);
      DioFactory.dio!.fetch(options).catchError((e) {
        if (kDebugMode) {
          print('Error retrying pending request: $e');
        }
        return Future<Response>.error(e);
      });
    }
  }
}
