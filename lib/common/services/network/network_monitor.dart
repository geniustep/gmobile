// ════════════════════════════════════════════════════════════
// NetworkMonitor - مراقبة حالة الشبكة مع UI Feedback
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/services/network/network_info.dart';

class NetworkMonitor extends GetxController {
  final INetworkInfo _networkInfo;

  NetworkMonitor({INetworkInfo? networkInfo})
      : _networkInfo = networkInfo ?? NetworkInfo.instance;

  // ════════════════════════════════════════════════════════════
  // Singleton
  // ════════════════════════════════════════════════════════════

  static NetworkMonitor? _instance;

  static NetworkMonitor get instance {
    _instance ??= NetworkMonitor();
    return _instance!;
  }

  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  final Rx<ConnectionStatus> _status = ConnectionStatus.unknown.obs;
  StreamSubscription<bool>? _subscription;

  ConnectionStatus get status => _status.value;
  bool get isOnline => _status.value == ConnectionStatus.online;
  bool get isOffline => _status.value == ConnectionStatus.offline;

  // ════════════════════════════════════════════════════════════
  // Callbacks للأحداث
  // ════════════════════════════════════════════════════════════

  VoidCallback? onConnected;
  VoidCallback? onDisconnected;
  Function(List<dynamic>)? onReconnected; // لمزامنة الطلبات المعلقة

  // ════════════════════════════════════════════════════════════
  // Initialization
  // ════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
  }

  void _startMonitoring() async {
    // التحقق من الحالة الأولية
    final isConnected = await _networkInfo.isConnected;
    _status.value = isConnected
        ? ConnectionStatus.online
        : ConnectionStatus.offline;

    if (kDebugMode) {
      print('📡 Initial network status: ${_status.value}');
    }

    // الاستماع للتغييرات
    _subscription = _networkInfo.onConnectivityChanged.listen(
      (isConnected) {
        _handleConnectionChange(isConnected);
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Handle Connection Changes
  // ════════════════════════════════════════════════════════════

  void _handleConnectionChange(bool isConnected) {
    final oldStatus = _status.value;
    final newStatus = isConnected
        ? ConnectionStatus.online
        : ConnectionStatus.offline;

    if (oldStatus == newStatus) {
      return; // لا تغيير
    }

    _status.value = newStatus;

    if (kDebugMode) {
      print('📡 Network status changed: $oldStatus → $newStatus');
    }

    // التعامل مع التغيير
    if (newStatus == ConnectionStatus.online) {
      _handleOnline();
    } else {
      _handleOffline();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Online/Offline Handlers
  // ════════════════════════════════════════════════════════════

  void _handleOnline() {
    if (kDebugMode) {
      print('✅ Connected to internet');
    }

    // إخفاء البانر
    _hideOfflineBanner();

    // عرض snackbar
    Get.snackbar(
      'متصل',
      'تم استعادة الاتصال بالإنترنت',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      icon: const Icon(Icons.wifi, color: Colors.white),
      duration: const Duration(seconds: 2),
    );

    // استدعاء callback
    onConnected?.call();

    // مزامنة الطلبات المعلقة
    _syncPendingChanges();
  }

  void _handleOffline() {
    if (kDebugMode) {
      print('❌ Disconnected from internet');
    }

    // عرض البانر
    _showOfflineBanner();

    // استدعاء callback
    onDisconnected?.call();
  }

  // ════════════════════════════════════════════════════════════
  // Offline Banner
  // ════════════════════════════════════════════════════════════

  void _showOfflineBanner() {
    Get.showSnackbar(
      GetSnackBar(
        title: 'غير متصل',
        message: 'لا يوجد اتصال بالإنترنت',
        icon: const Icon(Icons.wifi_off, color: Colors.white),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(days: 1), // دائم حتى الاتصال
        isDismissible: false,
        snackPosition: SnackPosition.TOP,
      ),
    );
  }

  void _hideOfflineBanner() {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Sync Pending Changes
  // ════════════════════════════════════════════════════════════

  void _syncPendingChanges() async {
    if (kDebugMode) {
      print('🔄 Syncing pending changes...');
    }

    // هنا يمكن إضافة منطق لمزامنة الطلبات المعلقة
    // من الـ Offline Queue

    try {
      // جلب الطلبات المعلقة (ستضاف في المستقبل)
      final pendingOperations = <dynamic>[]; // TODO: من Offline Queue

      if (pendingOperations.isNotEmpty) {
        onReconnected?.call(pendingOperations);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing pending changes: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Manual Check
  // ════════════════════════════════════════════════════════════

  Future<bool> checkConnection() async {
    final isConnected = await _networkInfo.isConnected;

    _status.value = isConnected
        ? ConnectionStatus.online
        : ConnectionStatus.offline;

    if (kDebugMode) {
      print('📡 Manual check: ${_status.value}');
    }

    return isConnected;
  }

  // ════════════════════════════════════════════════════════════
  // Cleanup
  // ════════════════════════════════════════════════════════════

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}

// ════════════════════════════════════════════════════════════
// Connection Status
// ════════════════════════════════════════════════════════════

enum ConnectionStatus {
  online,
  offline,
  unknown,
}
