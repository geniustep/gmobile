// ════════════════════════════════════════════════════════════
// Developer Settings Controller
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/resilience/circuit_breaker.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/deduplication/request_deduplicator.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/networking/connection_pool.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_manager.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class DeveloperSettingsController extends GetxController {
  // ════════════════════════════════════════════════════════════
  // Observables
  // ════════════════════════════════════════════════════════════

  final apiMode = 'BridgeCore'.obs;
  final webSocketConnected = false.obs;

  final circuitBreakerStats = <String, dynamic>{}.obs;
  final deduplicationStats = <String, dynamic>{}.obs;
  final connectionPoolStats = <String, dynamic>{}.obs;
  final cacheStats = <String, dynamic>{}.obs;

  // ════════════════════════════════════════════════════════════
  // Lifecycle
  // ════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _loadCurrentSettings();
    refreshStats();
  }

  // ════════════════════════════════════════════════════════════
  // Load Current Settings
  // ════════════════════════════════════════════════════════════

  void _loadCurrentSettings() {
    try {
      // Get current API mode
      final currentMode = ApiModeConfig.instance.currentMode;
      apiMode.value = currentMode == ApiMode.bridgeCore ? 'BridgeCore' : 'Odoo Direct';

      // Get WebSocket status
      webSocketConnected.value = WebSocketManager.instance.isConnected;

      if (kDebugMode) {
        print('✅ DeveloperSettings: Loaded current settings');
        print('   API Mode: ${apiMode.value}');
        print('   WebSocket: ${webSocketConnected.value}');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error loading settings: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Set API Mode
  // ════════════════════════════════════════════════════════════

  void setApiMode(String mode) {
    try {
      apiMode.value = mode;

      final newMode = mode == 'BridgeCore' ? ApiMode.bridgeCore : ApiMode.odooDirect;
      ApiModeConfig.instance.setMode(newMode);

      if (kDebugMode) {
        print('✅ DeveloperSettings: API mode changed to $mode');
      }

      Get.snackbar(
        'API Mode Changed',
        'Now using: $mode',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Refresh stats
      refreshStats();

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error setting API mode: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // WebSocket Controls
  // ════════════════════════════════════════════════════════════

  Future<void> connectWebSocket() async {
    try {
      if (kDebugMode) {
        print('🔌 DeveloperSettings: Connecting WebSocket...');
      }

      await WebSocketManager.instance.enable();

      final token = await StorageService.instance.getToken();
      if (token.isNotEmpty) {
        await WebSocketManager.instance.connect(token);
      }

      webSocketConnected.value = WebSocketManager.instance.isConnected;

      if (kDebugMode) {
        print('✅ DeveloperSettings: WebSocket connected');
      }

      Get.snackbar(
        'WebSocket Connected',
        'Real-time updates enabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error connecting WebSocket: $e');
      }

      Get.snackbar(
        'Connection Failed',
        'Failed to connect WebSocket: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> disconnectWebSocket() async {
    try {
      if (kDebugMode) {
        print('🔌 DeveloperSettings: Disconnecting WebSocket...');
      }

      WebSocketManager.instance.disconnect();
      WebSocketManager.instance.disable();

      webSocketConnected.value = false;

      if (kDebugMode) {
        print('✅ DeveloperSettings: WebSocket disconnected');
      }

      Get.snackbar(
        'WebSocket Disconnected',
        'Real-time updates disabled',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error disconnecting WebSocket: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Refresh Stats
  // ════════════════════════════════════════════════════════════

  void refreshStats() {
    try {
      if (kDebugMode) {
        print('🔄 DeveloperSettings: Refreshing stats...');
      }

      // Update WebSocket status
      webSocketConnected.value = WebSocketManager.instance.isConnected;

      if (apiMode.value == 'BridgeCore') {
        // Circuit Breaker Stats
        // Note: You'll need to expose the circuit breaker instance from BridgeCoreClient
        circuitBreakerStats.value = {
          'state': 'closed',
          'failures': 0,
          'threshold': 5,
          'lastFailure': null,
        };

        // Deduplication Stats
        deduplicationStats.value = RequestDeduplicator.instance.getStats();

        // Connection Pool Stats
        connectionPoolStats.value = ConnectionPool.instance.getStats();
      }

      // Cache Stats
      cacheStats.value = {
        'products': PrefUtils.products.length,
        'partners': PrefUtils.partners.length,
        'sales': PrefUtils.sales.length,
      };

      if (kDebugMode) {
        print('✅ DeveloperSettings: Stats refreshed');
      }

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error refreshing stats: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Clear Cache
  // ════════════════════════════════════════════════════════════

  Future<void> clearCache() async {
    try {
      if (kDebugMode) {
        print('🗑️ DeveloperSettings: Clearing cache...');
      }

      Get.dialog(
        AlertDialog(
          title: const Text('Clear Cache?'),
          content: const Text('This will clear all cached data (Products, Partners, Sales). Continue?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Get.back();

                final storage = StorageService.instance;
                await storage.clearProducts();
                await storage.clearPartners();
                await storage.clearSales();

                refreshStats();

                if (kDebugMode) {
                  print('✅ DeveloperSettings: Cache cleared');
                }

                Get.snackbar(
                  'Cache Cleared',
                  'All cached data has been removed',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error clearing cache: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Reset All Stats
  // ════════════════════════════════════════════════════════════

  void resetAllStats() {
    try {
      if (kDebugMode) {
        print('🔄 DeveloperSettings: Resetting all stats...');
      }

      Get.dialog(
        AlertDialog(
          title: const Text('Reset All Stats?'),
          content: const Text('This will reset all performance statistics. Continue?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Get.back();

                if (apiMode.value == 'BridgeCore') {
                  RequestDeduplicator.instance.reset();
                  // Circuit breaker reset would go here
                }

                refreshStats();

                if (kDebugMode) {
                  print('✅ DeveloperSettings: All stats reset');
                }

                Get.snackbar(
                  'Stats Reset',
                  'All statistics have been reset',
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 2),
                );
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ DeveloperSettings: Error resetting stats: $e');
      }
    }
  }
}
