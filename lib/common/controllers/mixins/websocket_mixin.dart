// ════════════════════════════════════════════════════════════
// WebSocket Mixin - Real-time updates for controllers
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_manager.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_event.dart';

/// Mixin to add WebSocket real-time updates to controllers
///
/// Usage:
/// ```dart
/// class ProductsController extends GetxController with WebSocketMixin {
///   @override
///   void onInit() {
///     super.onInit();
///     subscribeToModel('product.product');
///   }
/// }
/// ```
mixin WebSocketMixin on GetxController {
  StreamSubscription<WebSocketEvent>? _webSocketSubscription;
  final Set<String> _subscribedModels = {};

  /// Subscribe to real-time updates for a specific model
  void subscribeToModel(String model, {List<int>? ids}) {
    try {
      if (!WebSocketManager.instance.isEnabled) {
        if (kDebugMode) {
          print('⚠️ [WebSocketMixin] WebSocket not enabled for $model');
        }
        return;
      }

      if (_subscribedModels.contains(model)) {
        if (kDebugMode) {
          print('⚠️ [WebSocketMixin] Already subscribed to $model');
        }
        return;
      }

      if (kDebugMode) {
        print('🔌 [WebSocketMixin] Subscribing to $model${ids != null ? " (${ids.length} IDs)" : ""}');
      }

      // Subscribe to WebSocket events
      _webSocketSubscription ??= WebSocketManager.instance.events.listen(
        _handleWebSocketEvent,
        onError: (error) {
          if (kDebugMode) {
            print('❌ [WebSocketMixin] WebSocket error: $error');
          }
        },
      );

      // Subscribe to specific model
      if (ids != null && ids.isNotEmpty) {
        WebSocketManager.instance.subscribe(model, ids);
      }

      _subscribedModels.add(model);

      if (kDebugMode) {
        print('✅ [WebSocketMixin] Subscribed to $model');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ [WebSocketMixin] Error subscribing to $model: $e');
      }
    }
  }

  /// Unsubscribe from a specific model
  void unsubscribeFromModel(String model, {List<int>? ids}) {
    try {
      if (!_subscribedModels.contains(model)) {
        return;
      }

      if (ids != null && ids.isNotEmpty) {
        WebSocketManager.instance.unsubscribe(model, ids);
      }

      _subscribedModels.remove(model);

      if (kDebugMode) {
        print('🔌 [WebSocketMixin] Unsubscribed from $model');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ [WebSocketMixin] Error unsubscribing from $model: $e');
      }
    }
  }

  /// Handle incoming WebSocket events
  void _handleWebSocketEvent(WebSocketEvent event) {
    try {
      if (!_subscribedModels.contains(event.model)) {
        return; // Not interested in this model
      }

      if (kDebugMode) {
        print('📬 [WebSocketMixin] ${event.operation.toUpperCase()}: ${event.model} #${event.id}');
      }

      // Dispatch to specific handler based on operation
      switch (event.operation) {
        case 'create':
          onRecordCreated(event.model, event.id, event.data);
          break;
        case 'update':
          onRecordUpdated(event.model, event.id, event.data);
          break;
        case 'delete':
          onRecordDeleted(event.model, event.id);
          break;
        default:
          if (kDebugMode) {
            print('⚠️ [WebSocketMixin] Unknown operation: ${event.operation}');
          }
      }

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ [WebSocketMixin] Error handling WebSocket event: $e');
        print('Stack: $stackTrace');
      }
    }
  }

  /// Override this method to handle record creation
  void onRecordCreated(String model, int id, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('➕ [WebSocketMixin] Record created: $model #$id');
      print('   Data: $data');
    }
    // Override in subclass to implement custom logic
  }

  /// Override this method to handle record updates
  void onRecordUpdated(String model, int id, Map<String, dynamic> data) {
    if (kDebugMode) {
      print('✏️ [WebSocketMixin] Record updated: $model #$id');
      print('   Data: $data');
    }
    // Override in subclass to implement custom logic
  }

  /// Override this method to handle record deletion
  void onRecordDeleted(String model, int id) {
    if (kDebugMode) {
      print('🗑️ [WebSocketMixin] Record deleted: $model #$id');
    }
    // Override in subclass to implement custom logic
  }

  /// Clean up WebSocket subscription
  @override
  void onClose() {
    if (kDebugMode) {
      print('🔌 [WebSocketMixin] Cleaning up WebSocket subscriptions');
    }

    // Unsubscribe from all models
    for (final model in _subscribedModels.toList()) {
      unsubscribeFromModel(model);
    }

    // Cancel subscription
    _webSocketSubscription?.cancel();
    _webSocketSubscription = null;

    super.onClose();
  }

  /// Get list of subscribed models
  List<String> get subscribedModels => _subscribedModels.toList();

  /// Check if subscribed to a specific model
  bool isSubscribedTo(String model) => _subscribedModels.contains(model);
}
