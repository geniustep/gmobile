// ════════════════════════════════════════════════════════════
// WebSocketManager - Singleton manager for WebSocket connections
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'dart:async';
import 'websocket_client.dart';
import 'websocket_event.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';

class WebSocketManager {
  WebSocketManager._();

  static final WebSocketManager instance = WebSocketManager._();

  WebSocketClient? _client;
  bool _isEnabled = false;

  bool get isConnected => _client?.isConnected ?? false;
  bool get isEnabled => _isEnabled;

  Future<void> enable() async {
    if (_isEnabled) return;

    _isEnabled = true;

    // Connect if user is authenticated
    final token = await StorageService.instance.getToken();
    if (token != null) {
      await connect(token);
    }

    if (kDebugMode) print('✅ WebSocket enabled');
  }

  void disable() {
    _isEnabled = false;
    _client?.disconnect();
    _client = null;

    if (kDebugMode) print('🛑 WebSocket disabled');
  }

  Future<void> connect(String token) async {
    if (!_isEnabled) return;

    _client = WebSocketClient();

    final baseUrl = ApiModeConfig.instance.bridgeCoreUrl;

    try {
      await _client!.connect(baseUrl, token);

      // Setup callbacks
      _client!.onUpdate = _handleUpdate;
      _client!.onCreate = _handleCreate;
      _client!.onDelete = _handleDelete;
    } catch (e) {
      if (kDebugMode) print('❌ WebSocket connection failed: $e');
    }
  }

  void disconnect() {
    _client?.disconnect();
    _client = null;
  }

  void subscribe(String model, List<int> ids) {
    _client?.subscribe(model, ids);
  }

  void unsubscribe(String model, List<int> ids) {
    _client?.unsubscribe(model, ids);
  }

  void _handleUpdate(String model, int id, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('📬 Real-time UPDATE: $model #$id');
    }

    // Emit event for repositories to handle
    _emitEvent('update', model, id, data);
  }

  void _handleCreate(String model, int id, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('📬 Real-time CREATE: $model #$id');
    }

    _emitEvent('create', model, id, data);
  }

  void _handleDelete(String model, int id) {
    if (kDebugMode) {
      print('📬 Real-time DELETE: $model #$id');
    }

    _emitEvent('delete', model, id, {});
  }

  // Event bus for real-time updates
  final _eventController = StreamController<WebSocketEvent>.broadcast();
  Stream<WebSocketEvent> get events => _eventController.stream;

  void _emitEvent(
      String operation, String model, int id, Map<String, dynamic> data) {
    _eventController.add(WebSocketEvent(
      operation: operation,
      model: model,
      id: id,
      data: data,
    ));
  }

  void dispose() {
    _eventController.close();
    _client?.dispose();
  }
}
