import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor for retrying failed requests
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryableStatusCodes;
  final Dio dio;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.retryableStatusCodes = const [408, 500, 502, 503, 504],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final retryCount = options.extra['retryCount'] ?? 0;

    // Check if we should retry
    if (_shouldRetry(err, retryCount)) {
      options.extra['retryCount'] = retryCount + 1;

      if (kDebugMode) {
        print(
          'Retrying request (${retryCount + 1}/$maxRetries): ${options.path}',
        );
      }

      // Wait before retrying
      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        // Retry the request
        final response = await dio.fetch(options);
        return handler.resolve(response);
      } catch (e) {
        // If retry failed, continue with error
        if (retryCount + 1 >= maxRetries) {
          return handler.next(err);
        }
        // Recursive retry
        return onError(err.copyWith(requestOptions: options), handler);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err, int retryCount) {
    // Don't retry if max retries reached
    if (retryCount >= maxRetries) return false;

    // Retry on network errors
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific status codes
    if (err.response != null) {
      return retryableStatusCodes.contains(err.response!.statusCode);
    }

    return false;
  }
}
