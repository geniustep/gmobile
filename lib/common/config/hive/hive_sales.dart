// ════════════════════════════════════════════════════════════
// HiveSales - إدارة المبيعات في Hive
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/sale_order_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HiveSales {
  HiveSales._();

  static final RxList<OrderModel> sales = <OrderModel>[].obs;

  /// حفظ المبيعات في Hive
  static Future<void> setSales(RxList<OrderModel> salesList) async {
    sales.value = salesList;

    // حفظ في Hive
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      final entities = salesList
          .map((s) => SaleOrderEntity.fromModel(s))
          .toList();
      await HiveService.instance.saveSales(entities);

      if (kDebugMode) {
        print('✅ Saved ${salesList.length} sales to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving sales to Hive: $e');
      }
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.sales, jsonEncode(salesList.toList()));
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error saving sales to SharedPreferences: $fallbackError');
        }
      }
    }
  }

  /// جلب المبيعات من Hive
  static Future<RxList<OrderModel>> getSales() async {
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      // جلب من Hive
      final entities = await HiveService.instance.getSales();
      final salesList = entities.map((e) => e.toModel()).toList();
      sales.value = salesList;

      if (kDebugMode) {
        print('✅ Loaded ${salesList.length} sales from Hive');
      }

      return sales;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading sales from Hive: $e');
        print('🔄 Falling back to SharedPreferences...');
      }

      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        var salesString = prefs.getString(PrefKeys.sales);
        if (salesString == null || salesString.isEmpty) {
          sales.value = <OrderModel>[].obs;
          return sales;
        }
        List<dynamic> decoded = jsonDecode(salesString);
        sales.value = RxList(
          decoded.map((e) => OrderModel.fromJson(e)).toList(),
        );
        return sales;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error loading sales from SharedPreferences: $fallbackError');
        }
        sales.value = <OrderModel>[].obs;
        return sales;
      }
    }
  }

  /// حفظ المبيعات (alias لـ setSales)
  static Future<void> saveSales(RxList<OrderModel> salesList) async {
    await setSales(salesList);
  }

  /// مسح جميع المبيعات
  static Future<void> clearSales() async {
    try {
      await HiveService.instance.init();
      await HiveService.instance.clearSales();
      sales.clear();

      if (kDebugMode) {
        print('✅ Cleared all sales from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing sales: $e');
      }
    }
  }

  /// عدد المبيعات
  static int get salesCount {
    try {
      return HiveService.instance.salesCount;
    } catch (e) {
      return sales.length;
    }
  }
}
