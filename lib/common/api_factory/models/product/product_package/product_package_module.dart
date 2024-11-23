import 'package:gsloution_mobile/common/config/import.dart';

class ProductPackageModule {
  ProductPackageModule._();

  static readProductsPackage(
      {required List<int> ids,
      required OnResponse<List<ProductPackageModel>> onResponse}) {
    List<String> fields = [
      "name",
      "display_name",
      "qty",
      "product_uom_id",
      "product_id",
      "barcode",
      "company_id"
    ];
    Api.read(
      model: "product.packaging",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<ProductPackageModel> productPackage = [];
        for (var element in response) {
          productPackage.add(ProductPackageModel.fromJson(element));
        }
        onResponse(productPackage);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadProductPackage(
      {List? domain,
      required OnResponse<Map<int, List<ProductPackageModel>>> onResponse}) {
    List<String> fields = [
      "name",
      "display_name",
      "qty",
      "product_uom_id",
      "product_id",
      "barcode",
      "company_id"
    ];
    const int LIMIT = 100;
    List<ProductPackageModel> productPackage = [];
    Api.searchRead(
        model: "product.packaging",
        domain: [],
        limit: LIMIT,
        fields: fields,
        onResponse: (response) {
          if (response != null) {
            for (var element in response["records"]) {
              productPackage.add(ProductPackageModel.fromJson(element));
            }
            onResponse({response["length"]: productPackage});
          }
        },
        onError: (error, data) {
          handleApiError(error);
        });
  }

  static CreateProductPackage(
      {required Map<String, dynamic>? maps,
      required OnResponse<int> onResponse}) {
    Api.create(
        model: "product.packaging",
        values: maps!,
        onResponse: (response) {
          onResponse(response);
        },
        onError: (String error, Map<String, dynamic> data) {
          print('error');
        });
  }
}
