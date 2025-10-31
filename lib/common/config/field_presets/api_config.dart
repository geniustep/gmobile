// lib/config/api/api_config.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

enum ApiMethod { searchRead, webSearchRead }

class ApiConfig {
  ApiMethod method;
  bool autoFallback;
  int timeout;
  bool cacheFieldsDiscovery;
  int maxRetries;
  Duration retryDelay;

  ApiConfig({
    this.method = ApiMethod.searchRead,
    this.autoFallback = true,
    this.timeout = 30,
    this.cacheFieldsDiscovery = true,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
  });

  static ApiConfig? _instance;

  static ApiConfig get instance {
    _instance ??= ApiConfig();
    return _instance!;
  }

  static void setInstance(ApiConfig config) {
    _instance = config;
  }

  bool get isSearchRead => method == ApiMethod.searchRead;
  bool get isWebSearchRead => method == ApiMethod.webSearchRead;

  String get methodName {
    switch (method) {
      case ApiMethod.searchRead:
        return 'search_read';
      case ApiMethod.webSearchRead:
        return 'web_search_read';
    }
  }

  void setMethod(ApiMethod newMethod) {
    method = newMethod;
  }

  void toggleMethod() {
    method = method == ApiMethod.searchRead
        ? ApiMethod.webSearchRead
        : ApiMethod.searchRead;
  }

  void setTimeout(int seconds) {
    if (seconds > 0 && seconds <= 300) {
      timeout = seconds;
    }
  }

  void setMaxRetries(int retries) {
    if (retries >= 0 && retries <= 10) {
      maxRetries = retries;
    }
  }

  void setRetryDelay(Duration delay) {
    retryDelay = delay;
  }

  ApiConfig copyWith({
    ApiMethod? method,
    bool? autoFallback,
    dynamic timeout,
    bool? cacheFieldsDiscovery,
    dynamic maxRetries,
    Duration? retryDelay,
  }) {
    return ApiConfig(
      method: method ?? this.method,
      autoFallback: autoFallback ?? this.autoFallback,
      timeout: timeout ?? this.timeout,
      cacheFieldsDiscovery: cacheFieldsDiscovery ?? this.cacheFieldsDiscovery,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method.toString().split('.').last,
      'autoFallback': autoFallback,
      'timeout': timeout,
      'cacheFieldsDiscovery': cacheFieldsDiscovery,
      'maxRetries': maxRetries,
      'retryDelaySeconds': retryDelay.inSeconds,
    };
  }

  factory ApiConfig.fromJson(Map<String, dynamic> json) {
    return ApiConfig(
      method: json['method'] == 'webSearchRead'
          ? ApiMethod.webSearchRead
          : ApiMethod.searchRead,
      autoFallback: json['autoFallback'] ?? true,
      timeout: json['timeout'] ?? 30,
      cacheFieldsDiscovery: json['cacheFieldsDiscovery'] ?? true,
      maxRetries: json['maxRetries'] ?? 3,
      retryDelay: Duration(seconds: json['retryDelaySeconds'] ?? 2),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_config', jsonEncode(toJson()));
  }

  static Future<ApiConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('api_config');

    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return ApiConfig.fromJson(json);
      } catch (e) {
        return ApiConfig();
      }
    }

    return ApiConfig();
  }

  void reset() {
    method = ApiMethod.searchRead;
    autoFallback = true;
    timeout = 30;
    cacheFieldsDiscovery = true;
    maxRetries = 3;
    retryDelay = Duration(seconds: 2);
  }

  bool validate() {
    return timeout > 0 && timeout <= 300 && maxRetries >= 0 && maxRetries <= 10;
  }

  Map<String, String> getDebugInfo() {
    return {
      'Method': methodName,
      'Timeout': '${timeout}s',
      'Auto Fallback': autoFallback ? 'Enabled' : 'Disabled',
      'Cache Discovery': cacheFieldsDiscovery ? 'Enabled' : 'Disabled',
      'Max Retries': maxRetries.toString(),
      'Retry Delay': '${retryDelay.inSeconds}s',
    };
  }

  @override
  String toString() {
    return 'ApiConfig(method: $method, autoFallback: $autoFallback, '
        'timeout: $timeout, cacheFieldsDiscovery: $cacheFieldsDiscovery, '
        'maxRetries: $maxRetries, retryDelay: $retryDelay)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ApiConfig &&
        other.method == method &&
        other.autoFallback == autoFallback &&
        other.timeout == timeout &&
        other.cacheFieldsDiscovery == cacheFieldsDiscovery &&
        other.maxRetries == maxRetries &&
        other.retryDelay == retryDelay;
  }

  @override
  int get hashCode {
    return method.hashCode ^
        autoFallback.hashCode ^
        timeout.hashCode ^
        cacheFieldsDiscovery.hashCode ^
        maxRetries.hashCode ^
        retryDelay.hashCode;
  }
}
