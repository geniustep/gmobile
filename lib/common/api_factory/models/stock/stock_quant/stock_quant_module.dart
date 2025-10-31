import 'package:gsloution_mobile/common/api_factory/models/stock/stock_quant/stock_quant_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_sections/product_details.dart';

class StockQuantModule {
  StockQuantModule._();

  static readStockQuant({
    required List<int> ids,
    required OnResponse<List<StockQuantModel>> onResponse,
  }) {
    List<String> fields = [
      "product_id",
      "product_tmpl_id",
      "product_uom_id",
      "company_id",
      "location_id",
      "lot_id",
      "package_id",
      "owner_id",
      "quantity",
      "inventory_quantity",
      "reserved_quantity",
      "in_date",
      "tracking",
      "on_hand",
      "value",
      "currency_id",
      "id",
      "display_name",
      "create_uid",
      "create_date",
      "write_uid",
      "write_date",
      "__last_update",
    ];
    Api.read(
      model: "stock.quant",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<StockQuantModel> stockQuant = [];
        for (var element in response) {
          stockQuant.add(StockQuantModel.fromJson(element));
        }
        onResponse(stockQuant);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchStockQuant({
    int offset = 0,
    required OnResponse<Map<int, List<StockQuantModel>>> onResponse,
    required List domain,
  }) {
    List<String> fields = [
      "product_id",
      "product_tmpl_id",
      "product_uom_id",
      "company_id",
      "location_id",
      "lot_id",
      "package_id",
      "owner_id",
      "quantity",
      "inventory_quantity",
      "reserved_quantity",
      "in_date",
      "tracking",
      "on_hand",
      "value",
      "currency_id",
      "id",
      "display_name",
      "create_uid",
      "create_date",
      "write_uid",
      "write_date",
      "__last_update",
    ];
    const int LIMIT = 100;
    List<StockQuantModel> stockQuant = [];
    Api.searchRead(
      model: "stock.quant",
      domain: domain,
      limit: LIMIT,
      offset: offset,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            stockQuant.add(StockQuantModel.fromJson(element));
          }
          onResponse({response["length"]: stockQuant});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static updateStockQuant({
    required int locationId,
    required ProductModel product,
    required Map<String, dynamic>? maps,
    required OnResponse onResponse,
  }) {
    Map<String, dynamic> context = {};
    context["inventory_mode"] = true;
    Api.callKW(
      model: "stock.quant",
      method: "write",
      args: [
        [locationId],
        maps,
      ],
      context: context,
      onResponse: (response) {
        ProductModule.readProducts(
          ids: [product.id],
          onResponse: (onResponse) {
            Get.off(() => ProductDetails(product: onResponse[0]));
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static createStockQuant({
    required ProductModel product,
    required Map<String, dynamic>? maps,
    required OnResponse onResponse,
  }) {
    Map<String, dynamic> context = {};
    context["inventory_mode"] = true;
    Api.callKW(
      model: "stock.quant",
      method: "create",
      args: [maps],
      context: context,
      onResponse: (response) {
        ProductModule.readProducts(
          ids: [product.id],
          onResponse: (onResponse) {
            Get.off(() => ProductDetails(product: onResponse[0]));
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }
}
