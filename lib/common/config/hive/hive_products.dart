// ════════════════════════════════════════════════════════════
// HiveProducts - إدارة المنتجات في Hive
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/product_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HiveProducts {
  HiveProducts._();

  static final RxList<ProductModel> products = <ProductModel>[].obs;

  /// حفظ المنتجات في Hive
  static Future<void> setProducts(RxList<ProductModel> productList) async {
    products.value = productList;

    // حفظ في Hive
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      final entities = productList
          .map((p) => ProductEntity.fromModel(p))
          .toList();
      await HiveService.instance.saveProducts(entities);

      if (kDebugMode) {
        print('✅ Saved ${productList.length} products to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving products to Hive: $e');
      }
      // Fallback إلى SharedPreferences في حالة الخطأ
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          PrefKeys.products,
          jsonEncode(productList.toList()),
        );
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error saving products to SharedPreferences: $fallbackError');
        }
      }
    }
  }

  /// جلب المنتجات من Hive
  static Future<RxList<ProductModel>> getProducts() async {
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      // جلب من Hive
      final entities = await HiveService.instance.getProducts();
      final productList = entities.map((e) => e.toModel()).toList();
      products.value = productList;

      if (kDebugMode) {
        print('✅ Loaded ${productList.length} products from Hive');
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading products from Hive: $e');
        print('🔄 Falling back to SharedPreferences...');
      }

      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        var productsString = prefs.getString(PrefKeys.products);
        if (productsString == null || productsString.isEmpty) {
          products.value = <ProductModel>[].obs;
          return products;
        }
        List<dynamic> decoded = jsonDecode(productsString);
        products.value = RxList(
          decoded.map((e) => ProductModel.fromJson(e)).toList(),
        );
        return products;
      } catch (fallbackError) {
        if (kDebugMode) {
          print(
            '❌ Error loading products from SharedPreferences: $fallbackError',
          );
        }
        products.value = <ProductModel>[].obs;
        return products;
      }
    }
  }

  /// مسح جميع المنتجات
  static Future<void> clearProducts() async {
    try {
      await HiveService.instance.init();
      await HiveService.instance.clearProducts();
      products.clear();

      if (kDebugMode) {
        print('✅ Cleared all products from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing products: $e');
      }
    }
  }

  /// عدد المنتجات
  static int get productsCount {
    try {
      return HiveService.instance.productsCount;
    } catch (e) {
      return products.length;
    }
  }
}
