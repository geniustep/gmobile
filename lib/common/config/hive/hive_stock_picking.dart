// ════════════════════════════════════════════════════════════
// HiveStockPicking - إدارة المخزون في Hive
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HiveStockPicking {
  HiveStockPicking._();

  static final RxList<StockPickingModel> stockPicking = <StockPickingModel>[].obs;

  /// حفظ إدارة المخزون في Hive
  static Future<void> setStockPicking(RxList<StockPickingModel> stockPickingList) async {
    stockPicking.value = stockPickingList;
    
    // حفظ في Hive
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      final stockPickingJson = stockPickingList.map((s) => s.toJson()).toList();
      await HiveService.instance.saveStockPicking(stockPickingJson);
      
      if (kDebugMode) {
        print('✅ Saved ${stockPickingList.length} stock pickings to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving stock picking to Hive: $e');
      }
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.stockPicking, jsonEncode(stockPickingList.toList()));
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error saving stock picking to SharedPreferences: $fallbackError');
        }
      }
    }
  }

  /// جلب إدارة المخزون من Hive
  static Future<RxList<StockPickingModel>> getStockPicking() async {
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      // جلب من Hive
      final stockPickingList = await HiveService.instance.getStockPicking();
      final stockList = stockPickingList
          .map((e) => StockPickingModel.fromJson(e is Map ? e : e.toJson()))
          .toList();
      stockPicking.value = stockList;
      
      if (kDebugMode) {
        print('✅ Loaded ${stockList.length} stock pickings from Hive');
      }
      
      return stockPicking;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading stock picking from Hive: $e');
        print('🔄 Falling back to SharedPreferences...');
      }
      
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        var stock = prefs.getString(PrefKeys.stockPicking);
        if (stock == null || stock.isEmpty) {
          stockPicking.value = <StockPickingModel>[].obs;
          return stockPicking;
        }
        List<dynamic> decoded = jsonDecode(stock);
        stockPicking.value = RxList(decoded.map((e) => StockPickingModel.fromJson(e)).toList());
        return stockPicking;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error loading stock picking from SharedPreferences: $fallbackError');
        }
        stockPicking.value = <StockPickingModel>[].obs;
        return stockPicking;
      }
    }
  }

  /// حفظ إدارة المخزون (alias لـ setStockPicking)
  static Future<void> saveStockPicking(RxList<StockPickingModel> stockPickingList) async {
    await setStockPicking(stockPickingList);
  }

  /// مسح جميع إدارة المخزون
  static Future<void> clearStockPicking() async {
    try {
      await HiveService.instance.init();
      await HiveService.instance.clearStockPicking();
      stockPicking.clear();
      
      if (kDebugMode) {
        print('✅ Cleared all stock picking from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing stock picking: $e');
      }
    }
  }

  /// عدد إدارة المخزون
  static int get stockPickingCount {
    try {
      return HiveService.instance.stockPickingCount;
    } catch (e) {
      return stockPicking.length;
    }
  }
}

