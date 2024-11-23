import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_module.dart';

class Controller extends GetxController {
  int size = 0;
  // قائمة المنتجات
  var products = <ProductModel>[].obs;

  // حالة التحميل
  var isLoading = false.obs;

  Future<void> getProductsController({OnResponse? onResponse}) async {
    await ProductModule.searchReadProducts(
      domain: [],
      offset: products.length,
      onResponse: (response) {
        try {
          products.clear();
          size = response.keys.toList()[0];
          products.addAll(response[size]!);
          int key = products.isNotEmpty ? products[0].id as int : 0;
          onResponse!({key: products});
        } catch (e) {
          print(e);
        }
      },
    );
  }
}
