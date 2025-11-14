// ════════════════════════════════════════════════════════════
// NetworkInfo - التحقق من حالة الاتصال بالإنترنت
// ════════════════════════════════════════════════════════════

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

abstract class INetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}

class NetworkInfo implements INetworkInfo {
  final Connectivity _connectivity;

  NetworkInfo(this._connectivity);

  // ════════════════════════════════════════════════════════════
  // Singleton
  // ════════════════════════════════════════════════════════════

  static NetworkInfo? _instance;

  static NetworkInfo get instance {
    _instance ??= NetworkInfo(Connectivity());
    return _instance!;
  }

  // ════════════════════════════════════════════════════════════
  // Check Connection
  // ════════════════════════════════════════════════════════════

  @override
  Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      final connected = _isConnected(result);

      if (kDebugMode) {
        print('📡 Network status: ${connected ? "Connected" : "Disconnected"}');
      }

      return connected;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error checking connectivity: $e');
      }
      return false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Listen to Connection Changes
  // ════════════════════════════════════════════════════════════

  @override
  Stream<bool> get onConnectivityChanged {
    return _connectivity.onConnectivityChanged.map((result) {
      final connected = _isConnected(result);

      if (kDebugMode) {
        print(
          '📡 Connectivity changed: ${connected ? "Connected ✅" : "Disconnected ❌"}',
        );
      }

      return connected;
    });
  }

  // ════════════════════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════════════════════

  bool _isConnected(List<ConnectivityResult> results) {
    // إذا كان أي من النتائج متصل
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// التحقق من نوع الاتصال
  Future<ConnectionType> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();

      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectionType.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        return ConnectionType.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectionType.ethernet;
      } else {
        return ConnectionType.none;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting connection type: $e');
      }
      return ConnectionType.none;
    }
  }
}

// ════════════════════════════════════════════════════════════
// Connection Type
// ════════════════════════════════════════════════════════════

enum ConnectionType {
  wifi,
  mobile,
  ethernet,
  none,
}
