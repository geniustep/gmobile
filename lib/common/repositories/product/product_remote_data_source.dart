// ════════════════════════════════════════════════════════════
// ProductRemoteDataSource - جلب البيانات من السيرفر
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/services/api/api_request_manager.dart';
import 'package:gsloution_mobile/common/services/cache/cached_data_service.dart';

class ProductRemoteDataSource {
  final ApiRequestManager _requestManager = ApiRequestManager.instance;

  // ════════════════════════════════════════════════════════════
  // Fetch Products from Server
  // ════════════════════════════════════════════════════════════

  Future<List<ProductModel>> getProducts({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    // إنشاء مفتاح فريد للطلب
    final requestKey = createRequestKey(
      'product.product',
      limit: limit,
      offset: offset,
    );

    try {
      return await _requestManager.request<List<ProductModel>>(
        key: requestKey,
        fetcher: () => _fetchProductsFromApi(
          limit: limit,
          offset: offset,
          searchQuery: searchQuery,
        ),
        cacheFor: const Duration(seconds: 30), // cache للطلبات المتكررة
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching products: $e');
      }
      throw NetworkException('فشل جلب المنتجات من السيرفر', e);
    }
  }

  // ════════════════════════════════════════════════════════════
  // Internal API Call
  // ════════════════════════════════════════════════════════════

  Future<List<ProductModel>> _fetchProductsFromApi({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    final completer = Completer<List<ProductModel>>();

    // بناء الـ domain للفلترة
    final domain = <dynamic>[];

    if (searchQuery != null && searchQuery.isNotEmpty) {
      domain.add([
        '|',
        ['name', 'ilike', searchQuery],
        ['default_code', 'ilike', searchQuery],
        ['barcode', 'ilike', searchQuery],
      ]);
    }

    // الحقول المطلوبة
    final fields = [
      'id',
      'name',
      'display_name',
      'list_price',
      'standard_price',
      'barcode',
      'default_code',
      'qty_available',
      'virtual_available',
      'categ_id',
      'image_128',
      'active',
      'type',
      'uom_name',
    ];

    Api.searchRead(
      model: 'product.product',
      fields: fields,
      domain: domain,
      limit: limit ?? 50,
      offset: offset ?? 0,
      onResponse: (response) {
        try {
          if (response is List) {
            final products = response
                .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList();

            completer.complete(products);
          } else {
            completer.completeError('Invalid response format');
          }
        } catch (e) {
          completer.completeError('Error parsing products: $e');
        }
      },
      onError: (error, data) {
        completer.completeError('API Error: $error');
      },
      showGlobalLoading: false,
    );

    return completer.future;
  }

  // ════════════════════════════════════════════════════════════
  // Get Product by ID
  // ════════════════════════════════════════════════════════════

  Future<ProductModel> getProductById(int id) async {
    final completer = Completer<ProductModel>();

    Api.read(
      model: 'product.product',
      ids: [id],
      onResponse: (response) {
        try {
          if (response is List && response.isNotEmpty) {
            final product = ProductModel.fromJson(
              response.first as Map<String, dynamic>,
            );
            completer.complete(product);
          } else {
            completer.completeError('Product not found');
          }
        } catch (e) {
          completer.completeError('Error parsing product: $e');
        }
      },
      onError: (error, data) {
        completer.completeError('API Error: $error');
      },
      showGlobalLoading: false,
    );

    return completer.future;
  }

  // ════════════════════════════════════════════════════════════
  // Create Product
  // ════════════════════════════════════════════════════════════

  Future<int> createProduct(Map<String, dynamic> values) async {
    final completer = Completer<int>();

    Api.create(
      model: 'product.product',
      values: values,
      onResponse: (response) {
        if (response is int) {
          completer.complete(response);
        } else {
          completer.completeError('Invalid response');
        }
      },
      onError: (error, data) {
        completer.completeError('API Error: $error');
      },
    );

    return completer.future;
  }

  // ════════════════════════════════════════════════════════════
  // Update Product
  // ════════════════════════════════════════════════════════════

  Future<bool> updateProduct(int id, Map<String, dynamic> values) async {
    final completer = Completer<bool>();

    Api.write(
      model: 'product.product',
      ids: [id],
      values: values,
      onResponse: (response) {
        completer.complete(true);
      },
      onError: (error, data) {
        completer.completeError('API Error: $error');
      },
    );

    return completer.future;
  }

  // ════════════════════════════════════════════════════════════
  // Delete Product
  // ════════════════════════════════════════════════════════════

  Future<bool> deleteProduct(int id) async {
    final completer = Completer<bool>();

    Api.unlink(
      model: 'product.product',
      ids: [id],
      onResponse: (response) {
        completer.complete(true);
      },
      onError: (error, data) {
        completer.completeError('API Error: $error');
      },
    );

    return completer.future;
  }
}
