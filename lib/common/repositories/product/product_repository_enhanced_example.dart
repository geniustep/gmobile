// ════════════════════════════════════════════════════════════
// ProductRepository Enhanced Example
// مثال توضيحي لكيفية دمج Real-time و Optimistic Updates
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/repositories/base/optimistic_repository.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_manager.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_event.dart';

// مثال على Product Model
class Product {
  final int id;
  final String name;
  final double price;
  final int qtyAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.qtyAvailable,
  });

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? qtyAvailable,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      qtyAvailable: qtyAvailable ?? this.qtyAvailable,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'list_price': price,
      'qty_available': qtyAvailable,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['list_price'] as num).toDouble(),
      qtyAvailable: json['qty_available'] as int? ?? 0,
    );
  }
}

// Repository مع دعم Optimistic Updates و Real-time
class ProductRepositoryEnhanced extends OptimisticRepository<Product> {
  // Local products list
  final List<Product> _products = [];
  final _productsController = StreamController<List<Product>>.broadcast();

  // WebSocket subscription
  StreamSubscription<WebSocketEvent>? _wsSubscription;

  Stream<List<Product>> get productsStream => _productsController.stream;
  List<Product> get products => List.unmodifiable(_products);

  // ════════════════════════════════════════════════════════════
  // Real-time WebSocket Integration
  // ════════════════════════════════════════════════════════════

  /// تفعيل Real-time updates للمنتجات
  void enableRealtimeUpdates(List<int> productIds) {
    // Subscribe to WebSocket updates
    WebSocketManager.instance.subscribe('product.product', productIds);

    // Listen to events
    _wsSubscription?.cancel();
    _wsSubscription = WebSocketManager.instance.events.listen((event) {
      if (event.model == 'product.product') {
        _handleRealtimeUpdate(event);
      }
    });

    if (kDebugMode) {
      print('✅ Real-time updates enabled for ${productIds.length} products');
    }
  }

  void _handleRealtimeUpdate(WebSocketEvent event) {
    if (event.operation == 'update') {
      // Update existing product
      final index = _products.indexWhere((p) => p.id == event.id);
      if (index != -1) {
        final updatedProduct = Product.fromJson({
          ..._products[index].toJson(),
          ...event.data,
        });

        _products[index] = updatedProduct;
        _productsController.add(_products);

        if (kDebugMode) {
          print('📬 Product #${event.id} updated in real-time: ${updatedProduct.name}');
        }
      }
    } else if (event.operation == 'create') {
      // Add new product
      final newProduct = Product.fromJson(event.data);
      _products.insert(0, newProduct);
      _productsController.add(_products);

      if (kDebugMode) {
        print('📬 New product #${event.id} added in real-time: ${newProduct.name}');
      }
    } else if (event.operation == 'delete') {
      // Remove product
      _products.removeWhere((p) => p.id == event.id);
      _productsController.add(_products);

      if (kDebugMode) {
        print('📬 Product #${event.id} deleted in real-time');
      }
    }
  }

  /// إيقاف Real-time updates
  void disableRealtimeUpdates() {
    _wsSubscription?.cancel();
    _wsSubscription = null;

    if (kDebugMode) {
      print('🛑 Real-time updates disabled');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Optimistic Updates
  // ════════════════════════════════════════════════════════════

  /// تحديث سعر منتج مع Optimistic Update
  Future<void> updateProductPriceOptimistic(int productId, double newPrice) async {
    // Find product
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) {
      throw Exception('Product not found');
    }

    final oldProduct = _products[index];
    final updatedProduct = oldProduct.copyWith(price: newPrice);

    // Create snapshot for rollback
    createSnapshot(_products);

    await optimisticUpdate(
      // Local update (immediate UI update)
      localUpdate: () {
        _products[index] = updatedProduct;
        _productsController.add(_products);

        if (kDebugMode) {
          print('⚡ Optimistic: Updated price for "${oldProduct.name}" to $newPrice');
        }
      },

      // Server update
      serverUpdate: () async {
        // Simulate API call
        // في التطبيق الحقيقي، استخدم ApiClientFactory
        await Future.delayed(const Duration(seconds: 1));

        // Uncomment في الإنتاج:
        // await ApiClientFactory.instance.write(
        //   model: 'product.product',
        //   ids: [productId],
        //   values: {'list_price': newPrice},
        //   onResponse: (response) {},
        //   onError: (error, data) => throw Exception(error),
        // );

        if (kDebugMode) {
          print('✅ Server confirmed price update');
        }
      },

      // Rollback on failure
      rollback: () {
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _products.clear();
          _products.addAll(snapshot);
          _productsController.add(_products);

          if (kDebugMode) {
            print('🔙 Rolled back price update for "${oldProduct.name}"');
          }
        }
      },

      // Success callback
      onSuccess: () {
        clearSnapshot();
        if (kDebugMode) {
          print('✨ Price update completed successfully');
        }
      },

      // Error callback
      onError: (error) {
        clearSnapshot();
        if (kDebugMode) {
          print('❌ Price update failed: $error');
        }
      },
    );
  }

  /// إضافة منتج جديد مع Optimistic Update
  Future<void> addProductOptimistic(Product product) async {
    createSnapshot(_products);

    await optimisticUpdate(
      localUpdate: () {
        _products.insert(0, product);
        _productsController.add(_products);

        if (kDebugMode) {
          print('⚡ Optimistic: Added product "${product.name}"');
        }
      },

      serverUpdate: () async {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        if (kDebugMode) {
          print('✅ Server confirmed product creation');
        }
      },

      rollback: () {
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _products.clear();
          _products.addAll(snapshot);
          _productsController.add(_products);

          if (kDebugMode) {
            print('🔙 Rolled back product addition');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        clearSnapshot();
      },
    );
  }

  /// حذف منتج مع Optimistic Update
  Future<void> deleteProductOptimistic(int productId) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index == -1) return;

    final deletedProduct = _products[index];
    createSnapshot(_products);

    await optimisticUpdate(
      localUpdate: () {
        _products.removeAt(index);
        _productsController.add(_products);

        if (kDebugMode) {
          print('⚡ Optimistic: Deleted product "${deletedProduct.name}"');
        }
      },

      serverUpdate: () async {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));

        if (kDebugMode) {
          print('✅ Server confirmed deletion');
        }
      },

      rollback: () {
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _products.clear();
          _products.addAll(snapshot);
          _productsController.add(_products);

          if (kDebugMode) {
            print('🔙 Rolled back deletion');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        clearSnapshot();
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Cleanup
  // ════════════════════════════════════════════════════════════

  void dispose() {
    _wsSubscription?.cancel();
    _productsController.close();
  }
}

// ════════════════════════════════════════════════════════════
// Usage Example
// ════════════════════════════════════════════════════════════

/*
void exampleUsage() async {
  final repository = ProductRepositoryEnhanced();

  // 1. Enable real-time updates for products
  repository.enableRealtimeUpdates([1, 2, 3, 4, 5]);

  // 2. Listen to product updates
  repository.productsStream.listen((products) {
    print('Products updated: ${products.length}');
  });

  // 3. Update product price with optimistic update
  await repository.updateProductPriceOptimistic(1, 99.99);

  // 4. Add new product
  final newProduct = Product(
    id: 100,
    name: 'New Product',
    price: 49.99,
    qtyAvailable: 10,
  );
  await repository.addProductOptimistic(newProduct);

  // 5. Delete product
  await repository.deleteProductOptimistic(100);

  // 6. Cleanup
  repository.disableRealtimeUpdates();
  repository.dispose();
}
*/
