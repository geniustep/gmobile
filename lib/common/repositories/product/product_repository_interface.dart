// ════════════════════════════════════════════════════════════
// IProductRepository - واجهة مستودع المنتجات
// ════════════════════════════════════════════════════════════

import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/utils/result.dart';

abstract class IProductRepository {
  /// جلب جميع المنتجات مع pagination
  Future<Result<List<ProductModel>>> getProducts({
    int? limit,
    int? offset,
    String? searchQuery,
    bool forceRefresh = false,
  });

  /// جلب منتج بواسطة ID
  Future<Result<ProductModel>> getProductById(int id);

  /// حفظ منتج
  Future<Result<void>> saveProduct(ProductModel product);

  /// حذف منتج
  Future<Result<void>> deleteProduct(int id);

  /// تحديث منتج
  Future<Result<void>> updateProduct(int id, ProductModel product);

  /// البحث عن منتجات
  Future<Result<List<ProductModel>>> searchProducts(String query);

  /// مسح الـ cache
  Future<void> clearCache();

  /// مزامنة مع السيرفر
  Future<Result<void>> sync();
}
