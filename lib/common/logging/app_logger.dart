// ════════════════════════════════════════════════════════════
// AppLogger - نظام تسجيل متقدم
// ════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';

enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final Map<String, dynamic>? data;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.data,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'level': level.name,
        'message': message,
        if (data != null) 'data': data,
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      };

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere((e) => e.name == json['level']),
      message: json['message'],
      data: json['data'],
    );
  }
}

class AppLogger {
  AppLogger._();
  static final AppLogger instance = AppLogger._();

  final List<LogEntry> _logs = [];
  final int _maxLogs = 1000;
  static const String _logsKey = 'app_logs';
  static const String _logsBoxName = 'logs';

  Future<void> log(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? data,
    StackTrace? stackTrace,
  }) async {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      data: data,
      stackTrace: stackTrace,
    );

    _logs.add(entry);

    // الاحتفاظ بآخر N log فقط
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    if (kDebugMode) {
      _printLog(entry);
    }

    // حفظ logs مهمة فقط
    if (level.index >= LogLevel.warning.index) {
      await _saveLogs();
    }

    // إرسال logs حرجة
    if (kReleaseMode && level == LogLevel.critical) {
      _sendToRemote(entry);
    }
  }

  void _printLog(LogEntry entry) {
    final icon = _getLogIcon(entry.level);
    final timestamp = entry.timestamp.toIso8601String();

    print('[$timestamp] $icon [${entry.level.name.toUpperCase()}] ${entry.message}');
    if (entry.data != null) {
      print('Data: ${jsonEncode(entry.data)}');
    }
    if (entry.stackTrace != null) {
      print('Stack: ${entry.stackTrace}');
    }
  }

  String _getLogIcon(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛';
      case LogLevel.info:
        return 'ℹ️';
      case LogLevel.warning:
        return '⚠️';
      case LogLevel.error:
        return '❌';
      case LogLevel.critical:
        return '🔥';
    }
  }

  Future<void> _saveLogs() async {
    try {
      final logsData = _logs.map((log) => log.toJson()).toList();
      await HiveService.instance.saveGenericData(
        _logsBoxName,
        _logsKey,
        jsonEncode(logsData),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving logs: $e');
      }
    }
  }

  Future<void> loadLogs() async {
    try {
      final logsData = await HiveService.instance.getGenericData(
        _logsBoxName,
        _logsKey,
      );

      if (logsData != null) {
        final List<dynamic> parsed = jsonDecode(logsData);
        _logs.clear();
        _logs.addAll(parsed.map((item) => LogEntry.fromJson(item)));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading logs: $e');
      }
    }
  }

  void _sendToRemote(LogEntry entry) {
    // TODO: إرسال للـ remote logging service
    // FirebaseAnalytics, Sentry, etc.
  }

  List<LogEntry> getLogs({LogLevel? level}) {
    if (level == null) return List.unmodifiable(_logs);
    return _logs.where((log) => log.level == level).toList();
  }

  void clearLogs() {
    _logs.clear();
    _saveLogs();
  }

  // Helper methods
  void debug(String message, {Map<String, dynamic>? data}) =>
      log(message, level: LogLevel.debug, data: data);

  void info(String message, {Map<String, dynamic>? data}) =>
      log(message, level: LogLevel.info, data: data);

  void warning(String message, {Map<String, dynamic>? data}) =>
      log(message, level: LogLevel.warning, data: data);

  void error(String message, {Map<String, dynamic>? data, StackTrace? stack}) =>
      log(message, level: LogLevel.error, data: data, stackTrace: stack);

  void critical(String message,
          {Map<String, dynamic>? data, StackTrace? stack}) =>
      log(message, level: LogLevel.critical, data: data, stackTrace: stack);
}
