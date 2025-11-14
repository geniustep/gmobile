// ════════════════════════════════════════════════════════════
// HiveWarehouses - إدارة المستودعات في Hive
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_warehouse/stock_warehouse_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HiveWarehouses {
  HiveWarehouses._();

  static final RxList<StockWarehouseModel> warehouses = <StockWarehouseModel>[].obs;

  /// حفظ المستودعات في Hive
  static Future<void> setWarehouses(RxList<StockWarehouseModel> warehouseList) async {
    warehouses.value = warehouseList;
    
    // حفظ في Hive
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      final warehousesJson = warehouseList.map((w) => w.toJson()).toList();
      await HiveService.instance.saveWarehouses(warehousesJson);
      
      if (kDebugMode) {
        print('✅ Saved ${warehouseList.length} warehouses to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving warehouses to Hive: $e');
      }
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.warehouses, jsonEncode(warehouseList.toList()));
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error saving warehouses to SharedPreferences: $fallbackError');
        }
      }
    }
  }

  /// جلب المستودعات من Hive
  static Future<RxList<StockWarehouseModel>> getWarehouses() async {
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      // جلب من Hive
      final warehousesList = await HiveService.instance.getWarehouses();
      final warehouseList = warehousesList
          .map((e) => StockWarehouseModel.fromJson(e is Map ? e : e.toJson()))
          .toList();
      warehouses.value = warehouseList;
      
      if (kDebugMode) {
        print('✅ Loaded ${warehouseList.length} warehouses from Hive');
      }
      
      return warehouses;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading warehouses from Hive: $e');
        print('🔄 Falling back to SharedPreferences...');
      }
      
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        var warehousesString = prefs.getString(PrefKeys.warehouses);
        if (warehousesString == null || warehousesString.isEmpty) {
          warehouses.value = <StockWarehouseModel>[].obs;
          return warehouses;
        }
        List<dynamic> decoded = jsonDecode(warehousesString);
        warehouses.value = RxList(decoded.map((e) => StockWarehouseModel.fromJson(e)).toList());
        return warehouses;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error loading warehouses from SharedPreferences: $fallbackError');
        }
        warehouses.value = <StockWarehouseModel>[].obs;
        return warehouses;
      }
    }
  }

  /// مسح جميع المستودعات
  static Future<void> clearWarehouses() async {
    try {
      await HiveService.instance.init();
      await HiveService.instance.clearWarehouses();
      warehouses.clear();
      
      if (kDebugMode) {
        print('✅ Cleared all warehouses from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing warehouses: $e');
      }
    }
  }

  /// عدد المستودعات
  static int get warehousesCount {
    try {
      return HiveService.instance.warehousesCount;
    } catch (e) {
      return warehouses.length;
    }
  }
}

