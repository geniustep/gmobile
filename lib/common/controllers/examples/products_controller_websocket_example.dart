// ════════════════════════════════════════════════════════════
// ProductsController with WebSocket - Example
// ════════════════════════════════════════════════════════════
// This is an example showing how to integrate WebSocket into ProductsController
// Copy relevant parts to your actual controller

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/controllers/mixins/websocket_mixin.dart';

class ProductsControllerWithWebSocket extends GetxController
    with WebSocketMixin {
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Load products from cache
    _loadProducts();

    // Subscribe to real-time product updates
    subscribeToModel('product.product');

    if (kDebugMode) {
      print('✅ ProductsController initialized with WebSocket');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Load Products
  // ════════════════════════════════════════════════════════════

  void _loadProducts() {
    try {
      if (PrefUtils.products.isEmpty) {
        if (kDebugMode) {
          print('⚠️ No products available in cache');
        }
        return;
      }

      products.assignAll(List<ProductModel>.from(PrefUtils.products));
      filteredProducts.assignAll(products);

      if (kDebugMode) {
        print('✅ Loaded ${products.length} products from cache');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading products: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // WebSocket Event Handlers
  // ════════════════════════════════════════════════════════════

  @override
  void onRecordCreated(String model, int id, Map<String, dynamic> data) {
    if (model != 'product.product') return;

    try {
      if (kDebugMode) {
        print('➕ New product created: #$id');
        print('   Name: ${data['name']}');
      }

      // Create ProductModel from data
      final newProduct = ProductModel.fromJson({'id': id, ...data});

      // Add to list
      products.insert(0, newProduct);
      _applyFilters();

      // Save to cache
      PrefUtils.setProducts(products);

      // Show notification
      Get.snackbar(
        '✅ منتج جديد',
        'تم إضافة: ${newProduct.name}',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling product creation: $e');
      }
    }
  }

  @override
  void onRecordUpdated(String model, int id, Map<String, dynamic> data) {
    if (model != 'product.product') return;

    try {
      if (kDebugMode) {
        print('✏️ Product updated: #$id');
        print('   Changes: ${data.keys.join(", ")}');
      }

      // Find product index
      final index = products.indexWhere((p) => p.id == id);
      if (index == -1) {
        if (kDebugMode) {
          print('⚠️ Product #$id not found in local list');
        }
        return;
      }

      // Update product data
      final updatedProduct = products[index].copyWith(
        name: data['name'] ?? products[index].name,
        defaultCode: data['default_code'] ?? products[index].default_code,
        listPrice: data['list_price'] ?? products[index].list_price,
        standardPrice: data['standard_price'] ?? products[index].standard_price,
        // Add more fields as needed
      );

      products[index] = updatedProduct;
      _applyFilters();

      // Save to cache
      PrefUtils.setProducts(products);

      // Show notification
      Get.snackbar(
        '✏️ تم التحديث',
        'تم تحديث: ${updatedProduct.name}',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling product update: $e');
      }
    }
  }

  @override
  void onRecordDeleted(String model, int id) {
    if (model != 'product.product') return;

    try {
      if (kDebugMode) {
        print('🗑️ Product deleted: #$id');
      }

      // Find and remove product
      final index = products.indexWhere((p) => p.id == id);
      if (index == -1) {
        if (kDebugMode) {
          print('⚠️ Product #$id not found in local list');
        }
        return;
      }

      final deletedProduct = products[index];
      products.removeAt(index);
      _applyFilters();

      // Save to cache
      PrefUtils.setProducts(products);

      // Show notification
      Get.snackbar(
        '🗑️ تم الحذف',
        'تم حذف: ${deletedProduct.name}',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error handling product deletion: $e');
      }
    }
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════

  void _applyFilters() {
    // Apply any active filters to update filteredProducts
    filteredProducts.assignAll(products);
  }

  // ════════════════════════════════════════════════════════════
  // Refresh Products
  // ════════════════════════════════════════════════════════════

  Future<void> refreshProducts() async {
    try {
      isLoading.value = true;

      // Fetch latest products from server
      // This would use ApiClientFactory to fetch from BridgeCore
      // For now, just reload from cache

      _loadProducts();

      if (kDebugMode) {
        print('✅ Products refreshed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing products: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
}

// ════════════════════════════════════════════════════════════
// Extension on ProductModel for copyWith
// ════════════════════════════════════════════════════════════

extension ProductModelExtension on ProductModel {
  ProductModel copyWith({
    dynamic id,
    String? name,
    String? defaultCode,
    double? listPrice,
    double? standardPrice,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      default_code: defaultCode ?? this.default_code,
      list_price: listPrice ?? this.list_price,
      standard_price: standardPrice ?? this.list_price,
      // Add other fields as needed
    );
  }
}
