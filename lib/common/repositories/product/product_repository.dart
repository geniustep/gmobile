// ════════════════════════════════════════════════════════════
// ProductRepository - تطبيق Repository Pattern مع Cache-First
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/repositories/product/product_repository_interface.dart';
import 'package:gsloution_mobile/common/repositories/product/product_remote_data_source.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/services/network/network_info.dart';
import 'package:gsloution_mobile/common/services/cache/cached_data_service.dart';
import 'package:gsloution_mobile/common/utils/result.dart';

class ProductRepository implements IProductRepository {
  final ProductRemoteDataSource _remote;
  final StorageService _storage;
  final INetworkInfo _network;

  ProductRepository({
    ProductRemoteDataSource? remote,
    StorageService? storage,
    INetworkInfo? network,
  })  : _remote = remote ?? ProductRemoteDataSource(),
        _storage = storage ?? StorageService.instance,
        _network = network ?? NetworkInfo.instance;

  // ════════════════════════════════════════════════════════════
  // Singleton
  // ════════════════════════════════════════════════════════════

  static ProductRepository? _instance;

  static ProductRepository get instance {
    _instance ??= ProductRepository();
    return _instance!;
  }

  // ════════════════════════════════════════════════════════════
  // Get Products with Cache-First Strategy
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<List<ProductModel>>> getProducts({
    int? limit,
    int? offset,
    String? searchQuery,
    bool forceRefresh = false,
  }) async {
    // إذا كان هناك بحث، لا نستخدم cache
    if (searchQuery != null && searchQuery.isNotEmpty) {
      return _getProductsFromServer(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
      );
    }

    // استخدام CachedDataService للـ Cache-First Strategy
    final cachedService = CachedDataService<ProductModel>(
      cacheKey: 'products',
      cacheValidity: const Duration(hours: 24), // صلاحية 24 ساعة
      fetchFromServer: () => _remote.getProducts(
        limit: limit,
        offset: offset,
      ),
      saveToCache: (products) => _storage.setProducts(products),
      getFromCache: () => _storage.getProducts(
        limit: limit,
        offset: offset,
      ),
    );

    return await cachedService.getData(forceRefresh: forceRefresh);
  }

  // ════════════════════════════════════════════════════════════
  // Get Products from Server (for search)
  // ════════════════════════════════════════════════════════════

  Future<Result<List<ProductModel>>> _getProductsFromServer({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    try {
      final isConnected = await _network.isConnected;

      if (!isConnected) {
        return Result.error(
          AppError.network('لا يوجد اتصال بالإنترنت'),
        );
      }

      final products = await _remote.getProducts(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
      );

      return Result.success(products);
    } on NetworkException catch (e) {
      return Result.error(
        AppError.network(e.message, e.originalError),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in _getProductsFromServer: $e');
      }
      return Result.error(
        AppError.unknown('حدث خطأ أثناء جلب المنتجات'),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Get Product by ID
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<ProductModel>> getProductById(int id) async {
    try {
      // محاولة الحصول عليه من الـ Cache أولاً
      final cachedProducts = await _storage.getProducts();
      final cachedProduct = cachedProducts.firstWhereOrNull(
        (p) => p.id == id,
      );

      if (cachedProduct != null) {
        if (kDebugMode) {
          print('💾 Product found in cache: $id');
        }
        return Result.success(cachedProduct);
      }

      // جلب من السيرفر
      final isConnected = await _network.isConnected;

      if (!isConnected) {
        return Result.error(
          AppError.network('لا يوجد اتصال بالإنترنت'),
        );
      }

      final product = await _remote.getProductById(id);
      return Result.success(product);
    } on NetworkException catch (e) {
      return Result.error(
        AppError.network(e.message, e.originalError),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getProductById: $e');
      }
      return Result.error(
        AppError.unknown('حدث خطأ أثناء جلب المنتج'),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Save Product
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<void>> saveProduct(ProductModel product) async {
    try {
      final isConnected = await _network.isConnected;

      if (!isConnected) {
        return Result.error(
          AppError.network('لا يوجد اتصال بالإنترنت'),
        );
      }

      // إنشاء منتج جديد على السيرفر
      await _remote.createProduct(product.toJson());

      // تحديث الـ cache
      await clearCache();

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in saveProduct: $e');
      }
      return Result.error(
        AppError.server('حدث خطأ أثناء حفظ المنتج'),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Update Product
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<void>> updateProduct(int id, ProductModel product) async {
    try {
      final isConnected = await _network.isConnected;

      if (!isConnected) {
        return Result.error(
          AppError.network('لا يوجد اتصال بالإنترنت'),
        );
      }

      await _remote.updateProduct(id, product.toJson());

      // تحديث الـ cache
      await clearCache();

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in updateProduct: $e');
      }
      return Result.error(
        AppError.server('حدث خطأ أثناء تحديث المنتج'),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Delete Product
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<void>> deleteProduct(int id) async {
    try {
      final isConnected = await _network.isConnected;

      if (!isConnected) {
        return Result.error(
          AppError.network('لا يوجد اتصال بالإنترنت'),
        );
      }

      await _remote.deleteProduct(id);

      // تحديث الـ cache
      await clearCache();

      return Result.success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in deleteProduct: $e');
      }
      return Result.error(
        AppError.server('حدث خطأ أثناء حذف المنتج'),
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // Search Products
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<List<ProductModel>>> searchProducts(String query) async {
    return getProducts(searchQuery: query);
  }

  // ════════════════════════════════════════════════════════════
  // Clear Cache
  // ════════════════════════════════════════════════════════════

  @override
  Future<void> clearCache() async {
    await _storage.clearProducts();

    if (kDebugMode) {
      print('🧹 Products cache cleared');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Sync with Server
  // ════════════════════════════════════════════════════════════

  @override
  Future<Result<void>> sync() async {
    try {
      if (kDebugMode) {
        print('🔄 Syncing products with server...');
      }

      final result = await getProducts(forceRefresh: true);

      return result.when(
        success: (products) {
          if (kDebugMode) {
            print('✅ Synced ${products.length} products');
          }
          return Result.success(null);
        },
        error: (error) => Result.error(error),
        loading: () => Result.loading(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in sync: $e');
      }
      return Result.error(
        AppError.unknown('حدث خطأ أثناء المزامنة'),
      );
    }
  }
}

// ════════════════════════════════════════════════════════════
// Extension for firstWhereOrNull
// ════════════════════════════════════════════════════════════

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
