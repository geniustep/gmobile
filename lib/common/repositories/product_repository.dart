// ════════════════════════════════════════════════════════════
// ProductRepository - With Optimistic Updates
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/repositories/base/optimistic_repository.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';

class ProductRepository extends OptimisticRepository<ProductModel> {
  ProductRepository._();

  static final ProductRepository instance = ProductRepository._();

  final StorageService _storage = StorageService.instance;

  // ════════════════════════════════════════════════════════════
  // Get Products (Cache-first strategy)
  // ════════════════════════════════════════════════════════════

  Future<List<ProductModel>> getProducts({
    bool forceRefresh = false,
    int? limit,
    int? offset,
  }) async {
    try {
      // Try cache first
      if (!forceRefresh) {
        final cached = await _storage.getProducts(limit: limit, offset: offset);

        if (cached.isNotEmpty) {
          if (kDebugMode) {
            print(
              '✅ ProductRepository: Loaded ${cached.length} products from cache',
            );
          }
          return cached;
        }
      }

      // Fetch from server
      final client = ApiClientFactory.instance;
      final completer = Completer<List<Map<String, dynamic>>>();

      await client.searchRead(
        model: 'product.product',
        domain: [
          ['sale_ok', '=', true],
        ],
        fields: [
          'id',
          'name',
          'default_code',
          'list_price',
          'standard_price',
          'qty_available',
        ],
        limit: limit ?? 1000,
        offset: offset,
        onResponse: (response) {
          final products = (response as List)
              .map((p) => p as Map<String, dynamic>)
              .toList();
          completer.complete(products);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final products = await completer.future;

      // Convert to ProductModel
      final productModels = products
          .map((p) => ProductModel.fromJson(p))
          .toList();

      // Save to cache
      if (offset == null || offset == 0) {
        await _storage.setProducts(productModels);
        await PrefUtils.setProducts(RxList(productModels));
      }

      if (kDebugMode) {
        print(
          '✅ ProductRepository: Fetched ${productModels.length} products from server',
        );
      }

      return productModels;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProductRepository: Error getting products: $e');
      }

      // Fallback to cache on error
      return await _storage.getProducts(limit: limit, offset: offset);
    }
  }

  // ════════════════════════════════════════════════════════════
  // Create Product (Optimistic)
  // ════════════════════════════════════════════════════════════

  Future<ProductModel> createProduct(ProductModel product) async {
    // Create snapshot for rollback
    final allProducts = await _storage.getProducts();
    createSnapshot(allProducts);

    // Temporary ID for optimistic update
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final optimisticProduct = ProductModel(
      id: tempId,
      name: product.name,
      default_code: product.default_code,
      list_price: product.list_price,
      standard_price: product.standard_price,
    );

    ProductModel? createdProduct;

    await optimisticUpdate(
      localUpdate: () {
        // Add product locally immediately
        allProducts.insert(0, optimisticProduct);
        _storage.setProducts(allProducts);
        PrefUtils.setProducts(RxList(allProducts));

        if (kDebugMode) {
          print('⚡ ProductRepository: Optimistically added product');
        }
      },

      serverUpdate: () async {
        // Send to server
        final client = ApiClientFactory.instance;
        final completer = Completer<Map<String, dynamic>>();

        await client.create(
          model: 'product.product',
          values: product.toJson(),
          onResponse: (response) {
            completer.complete(response as Map<String, dynamic>);
          },
          onError: (error, data) {
            completer.completeError(error);
          },
        );

        final result = await completer.future;

        // Update with real ID
        final realId = result['id'] as int;
        createdProduct = ProductModel(
          id: realId,
          name: product.name,
          default_code: product.default_code,
          list_price: product.list_price,
          standard_price: product.standard_price,
        );

        // Replace temp product with real one
        final index = allProducts.indexWhere((p) => p.id == tempId);
        if (index != -1) {
          allProducts[index] = createdProduct!;
          await _storage.setProducts(allProducts);
          await PrefUtils.setProducts(allProducts.obs);
        }

        if (kDebugMode) {
          print(
            '✅ ProductRepository: Product created on server with ID: $realId',
          );
        }
      },

      rollback: () {
        // Rollback to snapshot
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _storage.setProducts(snapshot);
          PrefUtils.setProducts(snapshot.obs);

          if (kDebugMode) {
            print('↩️ ProductRepository: Rolled back product creation');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        if (kDebugMode) {
          print('❌ ProductRepository: Error creating product: $error');
        }
      },
    );

    return createdProduct ?? optimisticProduct;
  }

  // ════════════════════════════════════════════════════════════
  // Update Product (Optimistic)
  // ════════════════════════════════════════════════════════════

  Future<void> updateProduct(int id, Map<String, dynamic> values) async {
    // Create snapshot for rollback
    final allProducts = await _storage.getProducts();
    createSnapshot(allProducts);

    // Find product
    final index = allProducts.indexWhere((p) => p.id == id);
    if (index == -1) {
      throw Exception('Product #$id not found');
    }

    final oldProduct = allProducts[index];

    await optimisticUpdate(
      localUpdate: () {
        // Update product locally immediately
        final updatedProduct = ProductModel(
          id: oldProduct.id,
          name: values['name'] ?? oldProduct.name,
          default_code: values['default_code'] ?? oldProduct.default_code,
          list_price: values['list_price'] ?? oldProduct.list_price,
          standard_price: values['standard_price'] ?? oldProduct.standard_price,
        );

        allProducts[index] = updatedProduct;
        _storage.setProducts(allProducts);
        PrefUtils.setProducts(RxList(allProducts));

        if (kDebugMode) {
          print('⚡ ProductRepository: Optimistically updated product #$id');
        }
      },

      serverUpdate: () async {
        // Send to server
        final client = ApiClientFactory.instance;
        final completer = Completer<void>();

        await client.write(
          model: 'product.product',
          ids: [id],
          values: values,
          onResponse: (_) {
            completer.complete();
          },
          onError: (error, data) {
            completer.completeError(error);
          },
        );

        await completer.future;

        if (kDebugMode) {
          print('✅ ProductRepository: Product #$id updated on server');
        }
      },

      rollback: () {
        // Rollback to snapshot
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _storage.setProducts(snapshot);
          PrefUtils.setProducts(snapshot.obs);

          if (kDebugMode) {
            print('↩️ ProductRepository: Rolled back product update');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        if (kDebugMode) {
          print('❌ ProductRepository: Error updating product: $error');
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Delete Product (Optimistic)
  // ════════════════════════════════════════════════════════════

  Future<void> deleteProduct(int id) async {
    // Create snapshot for rollback
    final allProducts = await _storage.getProducts();
    createSnapshot(allProducts);

    await optimisticUpdate(
      localUpdate: () {
        // Remove product locally immediately
        allProducts.removeWhere((p) => p.id == id);
        _storage.setProducts(allProducts);
        PrefUtils.setProducts(RxList(allProducts));

        if (kDebugMode) {
          print('⚡ ProductRepository: Optimistically deleted product #$id');
        }
      },

      serverUpdate: () async {
        // Send to server
        final client = ApiClientFactory.instance;
        final completer = Completer<void>();

        await client.unlink(
          model: 'product.product',
          ids: [id],
          onResponse: (_) {
            completer.complete();
          },
          onError: (error, data) {
            completer.completeError(error);
          },
        );

        await completer.future;

        if (kDebugMode) {
          print('✅ ProductRepository: Product #$id deleted on server');
        }
      },

      rollback: () {
        // Rollback to snapshot
        final snapshot = getSnapshot();
        if (snapshot != null) {
          _storage.setProducts(snapshot);
          PrefUtils.setProducts(snapshot.obs);

          if (kDebugMode) {
            print('↩️ ProductRepository: Rolled back product deletion');
          }
        }
      },

      onSuccess: () {
        clearSnapshot();
      },

      onError: (error) {
        if (kDebugMode) {
          print('❌ ProductRepository: Error deleting product: $error');
        }
      },
    );
  }

  // ════════════════════════════════════════════════════════════
  // Search Products
  // ════════════════════════════════════════════════════════════

  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final allProducts = await _storage.getProducts();

      if (query.isEmpty) {
        return allProducts;
      }

      // Search in cache first
      final results = allProducts.where((product) {
        final name = product.name?.toLowerCase() ?? '';
        final code = product.default_code?.toLowerCase() ?? '';
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) || code.contains(searchQuery);
      }).toList();

      if (kDebugMode) {
        print(
          '🔍 ProductRepository: Found ${results.length} products matching "$query"',
        );
      }

      return results;
    } catch (e) {
      if (kDebugMode) {
        print('❌ ProductRepository: Error searching products: $e');
      }
      return [];
    }
  }
}
