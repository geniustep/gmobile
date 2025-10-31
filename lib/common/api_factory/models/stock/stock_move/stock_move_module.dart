import 'package:gsloution_mobile/common/api_factory/models/stock/stock_move/stock_move_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class StockMoveModule {
  StockMoveModule._();

  static readStockMove({
    required List<int> ids,
    required OnResponse<List<StockMoveModel>> onResponse,
  }) {
    List<String> fields = [
      "company_id",
      "name",
      "state",
      "picking_type_id",
      "location_id",
      "location_dest_id",
      "scrapped",
      "picking_code",
      "product_type",
      "show_details_visible",
      "show_reserved_availability",
      "show_operations",
      "additional",
      "has_move_lines",
      "is_locked",
      "product_uom_category_id",
      "has_tracking",
      "display_assign_serial",
      "product_id",
      "description_picking",
      "date_expected",
      "is_initial_demand_editable",
      "is_quantity_done_editable",
      "product_uom_qty",
      "reserved_availability",
      "quantity_done",
      "product_uom",
    ];
    Api.read(
      model: "stock.move",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<StockMoveModel> partners = [];
        for (var element in response) {
          partners.add(StockMoveModel.fromJson(element));
        }
        onResponse(partners);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchStockMove({
    int offset = 0,
    required OnResponse<Map<int, List<StockMoveModel>>> onResponse,
  }) {
    List<String> fields = [
      "company_id",
      "name",
      "state",
      "picking_type_id",
      "location_id",
      "location_dest_id",
      "scrapped",
      "picking_code",
      "product_type",
      "show_details_visible",
      "show_reserved_availability",
      "show_operations",
      "additional",
      "has_move_lines",
      "is_locked",
      "product_uom_category_id",
      "has_tracking",
      "display_assign_serial",
      "product_id",
      "description_picking",
      "date_expected",
      "is_initial_demand_editable",
      "is_quantity_done_editable",
      "product_uom_qty",
      "reserved_availability",
      "quantity_done",
      "product_uom",
    ];
    const int LIMIT = 60;
    List<StockMoveModel> partners = [];
    Api.searchRead(
      model: "stock.move",
      domain: [],
      limit: LIMIT,
      offset: offset,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            partners.add(StockMoveModel.fromJson(element));
          }
          onResponse({response["length"]: partners});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
