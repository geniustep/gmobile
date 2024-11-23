import 'package:gsloution_mobile/common/config/import.dart';

class ProductCategoryModule {
  ProductCategoryModule._();

  static readProductsCategory(
      {required List<int> ids,
      required OnResponse<List<ProductCategoryModel>> onResponse}) {
    List<String> fields = [
      "product_count",
      "name",
      "id",
      "parent_id",
      "route_ids",
      "total_route_ids",
      "removal_strategy_id",
      "property_cost_method",
      "property_valuation",
      "property_account_creditor_price_difference_categ",
      "property_account_income_categ_id",
      "property_account_expense_categ_id",
      "property_stock_account_input_categ_id",
      "property_stock_account_output_categ_id",
      "property_stock_valuation_account_id",
      "property_stock_journal"
    ];
    Api.read(
      model: "product.category",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<ProductCategoryModel> products = [];
        for (var element in response) {
          products.add(ProductCategoryModel.fromJson(element));
        }
        onResponse(products);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadProductsCategory(
      {List? domain,
      required OnResponse<Map<int, List<ProductCategoryModel>>> onResponse}) {
    List<String> fields = [
      "product_count",
      "name",
      "display_name",
      "id",
      "parent_id",
      "route_ids",
      "total_route_ids",
      "removal_strategy_id",
      "property_cost_method",
      "property_valuation",
      "property_account_creditor_price_difference_categ",
      "property_account_income_categ_id",
      "property_account_expense_categ_id",
      "property_stock_account_input_categ_id",
      "property_stock_account_output_categ_id",
      "property_stock_valuation_account_id",
      "property_stock_journal"
    ];
    const int LIMIT = 100;
    List<ProductCategoryModel> products = [];
    Api.searchRead(
        model: "product.category",
        domain: [],
        limit: LIMIT,
        fields: fields,
        onResponse: (response) {
          if (response != null) {
            for (var element in response["records"]) {
              products.add(ProductCategoryModel.fromJson(element));
            }
            onResponse({response["length"]: products});
          }
        },
        onError: (error, data) {
          handleApiError(error);
        });
  }

  static CreateProductCategory(
      {required Map<String, dynamic>? maps,
      required OnResponse<int> onResponse}) {
    Api.create(
        model: "product.category",
        values: maps!,
        onResponse: (response) {
          onResponse(response);
        },
        onError: (String error, Map<String, dynamic> data) {
          print('error');
        });
  }
}
