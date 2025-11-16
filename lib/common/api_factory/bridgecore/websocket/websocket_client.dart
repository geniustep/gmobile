// ════════════════════════════════════════════════════════════
// WebSocketClient - Real-time communication with BridgeCore
// ════════════════════════════════════════════════════════════

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';

class WebSocketClient {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  String? _token;
  bool _isConnected = false;

  // Subscriptions: model -> Set of IDs
  final Map<String, Set<int>> _subscriptions = {};

  // Callbacks
  Function(String model, int id, Map<String, dynamic> data)? onUpdate;
  Function(String model, int id, Map<String, dynamic> data)? onCreate;
  Function(String model, int id)? onDelete;

  Stream<Map<String, dynamic>> get messages => _messageController!.stream;
  bool get isConnected => _isConnected;

  Future<void> connect(String baseUrl, String token) async {
    if (_isConnected) {
      if (kDebugMode) print('⚠️ WebSocket already connected');
      return;
    }

    _token = token;
    _messageController = StreamController<Map<String, dynamic>>.broadcast();

    try {
      final wsUrl = baseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      final uri = Uri.parse('$wsUrl/ws?token=$token');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      if (kDebugMode) print('✅ WebSocket connected to $wsUrl');

      // Listen to messages
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) {
          if (kDebugMode) print('❌ WebSocket error: $error');
          _isConnected = false;
        },
        onDone: () {
          if (kDebugMode) print('🔌 WebSocket disconnected');
          _isConnected = false;
        },
      );

      // Start ping/pong heartbeat
      _startHeartbeat();
    } catch (e) {
      if (kDebugMode) print('❌ WebSocket connection failed: $e');
      _isConnected = false;
      rethrow;
    }
  }

  void disconnect() {
    _channel?.sink.close();
    _messageController?.close();
    _isConnected = false;
    _subscriptions.clear();

    if (kDebugMode) print('🔌 WebSocket disconnected');
  }

  void subscribe(String model, List<int> ids) {
    if (!_isConnected) {
      if (kDebugMode) print('⚠️ Not connected, cannot subscribe');
      return;
    }

    // Add to local subscriptions
    if (!_subscriptions.containsKey(model)) {
      _subscriptions[model] = {};
    }
    _subscriptions[model]!.addAll(ids);

    // Send to server
    _send({
      'action': 'subscribe',
      'model': model,
      'ids': ids,
    });

    if (kDebugMode) print('📬 Subscribed to $model: $ids');
  }

  void unsubscribe(String model, List<int> ids) {
    if (!_isConnected) return;

    // Remove from local subscriptions
    if (_subscriptions.containsKey(model)) {
      _subscriptions[model]!.removeAll(ids);
      if (_subscriptions[model]!.isEmpty) {
        _subscriptions.remove(model);
      }
    }

    // Send to server
    _send({
      'action': 'unsubscribe',
      'model': model,
      'ids': ids,
    });

    if (kDebugMode) print('📭 Unsubscribed from $model: $ids');
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String);
      _messageController?.add(data);

      final type = data['type'];

      if (type == 'update') {
        final operation = data['operation'];
        final model = data['model'];
        final id = data['id'] as int;
        final recordData = data['data'] as Map<String, dynamic>;

        if (operation == 'update') {
          onUpdate?.call(model, id, recordData);
        } else if (operation == 'create') {
          onCreate?.call(model, id, recordData);
        } else if (operation == 'delete') {
          onDelete?.call(model, id);
        }
      } else if (type == 'pong') {
        if (kDebugMode) print('💓 Pong received');
      } else if (type == 'ack') {
        if (kDebugMode) print('✅ Acknowledged: ${data['action']}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error handling message: $e');
    }
  }

  Timer? _heartbeatTimer;

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_isConnected) {
          _send({'action': 'ping'});
        }
      },
    );
  }

  void dispose() {
    _heartbeatTimer?.cancel();
    disconnect();
  }
}
