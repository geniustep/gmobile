import 'package:gsloution_mobile/common/api_factory/models/stock/stock_warehouse/stock_warehouse_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class StockWarehouseModule {
  StockWarehouseModule._();

  static readStockWarehouse({
    required List<int> ids,
    required OnResponse<List<StockWarehouseModel>> onResponse,
  }) {
    List<String> fields = [
      "name",
      "active",
      "code",
      "company_id",
      "partner_id",
      "reception_steps",
      "delivery_steps",
      "show_resupply",
      "warehouse_count",
      "buy_to_resupply",
      "resupply_wh_ids",
      "view_location_id",
      "lot_stock_id",
      "wh_input_stock_loc_id",
      "wh_qc_stock_loc_id",
      "wh_pack_stock_loc_id",
      "wh_output_stock_loc_id",
      "in_type_id",
      "int_type_id",
      "pick_type_id",
      "pack_type_id",
      "out_type_id",
      "display_name",
    ];
    Api.read(
      model: "stock.warehouse",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<StockWarehouseModel> stockQuant = [];
        for (var element in response) {
          stockQuant.add(StockWarehouseModel.fromJson(element));
        }
        onResponse(stockQuant);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchStockWarehouse({
    int offset = 0,
    required OnResponse<Map<int, List<StockWarehouseModel>>> onResponse,
    required List domain,
  }) {
    List<String> fields = [
      "name",
      "active",
      "code",
      "company_id",
      "partner_id",
      "reception_steps",
      "delivery_steps",
      "show_resupply",
      "warehouse_count",
      "buy_to_resupply",
      "resupply_wh_ids",
      "view_location_id",
      "lot_stock_id",
      "wh_input_stock_loc_id",
      "wh_qc_stock_loc_id",
      "wh_pack_stock_loc_id",
      "wh_output_stock_loc_id",
      "in_type_id",
      "int_type_id",
      "pick_type_id",
      "pack_type_id",
      "out_type_id",
      "display_name",
    ];
    const int LIMIT = 100;
    List<StockWarehouseModel> stockQuant = [];
    Api.searchRead(
      model: "stock.warehouse",
      domain: domain,
      limit: LIMIT,
      offset: offset,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            stockQuant.add(StockWarehouseModel.fromJson(element));
          }
          onResponse({response["length"]: stockQuant});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
