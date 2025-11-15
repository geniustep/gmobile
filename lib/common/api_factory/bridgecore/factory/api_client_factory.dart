// ════════════════════════════════════════════════════════════
// ApiClientFactory - إنشاء الـ Client المناسب بناءً على التكوين
// ════════════════════════════════════════════════════════════
//
// هذا الـ Factory يُنشئ BaseApiClient بناءً على ApiModeConfig
// - إذا كان الوضع bridgeCore ← ينشئ BridgeCoreClient
// - إذا كان الوضع odooDirect ← ينشئ OdooDirectClient
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/base/base_api_client.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/clients/bridgecore_client.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/clients/odoo_direct_client.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';

class ApiClientFactory {
  ApiClientFactory._();

  // ════════════════════════════════════════════════════════════
  // Singleton Instance
  // ════════════════════════════════════════════════════════════

  static BaseApiClient? _instance;

  /// الحصول على الـ Client الحالي (أو إنشاؤه إن لم يكن موجوداً)
  static BaseApiClient get instance {
    _instance ??= create();
    return _instance!;
  }

  // ════════════════════════════════════════════════════════════
  // Factory Method
  // ════════════════════════════════════════════════════════════

  /// إنشاء BaseApiClient بناءً على التكوين الحالي
  static BaseApiClient create() {
    final config = ApiModeConfig.instance;
    final client = _createClient(config.currentMode);

    if (kDebugMode) {
      print('🏭 ApiClientFactory: Created ${client.systemName} client');
    }

    return client;
  }

  /// إنشاء client بناءً على وضع محدد
  static BaseApiClient _createClient(ApiMode mode) {
    switch (mode) {
      case ApiMode.bridgeCore:
        return BridgeCoreClient();
      case ApiMode.odooDirect:
        return OdooDirectClient();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Mode Switching
  // ════════════════════════════════════════════════════════════

  /// تبديل الوضع وإعادة إنشاء الـ Client
  static Future<void> switchMode(ApiMode mode) async {
    final config = ApiModeConfig.instance;

    if (config.currentMode == mode) {
      if (kDebugMode) {
        print('⚠️ Already using ${mode.name}');
      }
      return;
    }

    // تحديث التكوين
    await config.setMode(mode);

    // إعادة إنشاء الـ Client
    _instance = create();

    if (kDebugMode) {
      print('🔄 Switched to ${mode.name}');
    }
  }

  /// إعادة إنشاء الـ Client الحالي
  static void recreate() {
    _instance = create();

    if (kDebugMode) {
      print('🔄 Recreated ${_instance!.systemName} client');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Utilities
  // ════════════════════════════════════════════════════════════

  /// الحصول على الـ Client الحالي (دون إنشاء)
  static BaseApiClient? get currentClient => _instance;

  /// هل يوجد client نشط؟
  static bool get hasClient => _instance != null;

  /// الوضع الحالي
  static ApiMode get currentMode => ApiModeConfig.instance.currentMode;

  /// اسم النظام الحالي
  static String get currentSystemName {
    if (_instance == null) return 'None';
    return _instance!.systemName;
  }

  /// معلومات الـ Client الحالي
  static Map<String, dynamic> getInfo() {
    return {
      'hasClient': hasClient,
      'currentMode': currentMode.name,
      'currentSystemName': currentSystemName,
      'clientInfo': _instance?.getConnectionInfo(),
    };
  }

  /// طباعة معلومات Factory
  static void printInfo() {
    if (kDebugMode) {
      print('🏭 ApiClientFactory Info:');
      print('   Has Client: $hasClient');
      print('   Current Mode: ${currentMode.name}');
      print('   System Name: $currentSystemName');
      if (_instance != null) {
        final info = _instance!.getConnectionInfo();
        info.forEach((key, value) {
          print('   $key: $value');
        });
      }
    }
  }
}
