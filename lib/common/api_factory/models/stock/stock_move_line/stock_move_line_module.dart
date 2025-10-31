import 'package:gsloution_mobile/common/api_factory/models/stock/stock_move_line/stock_move_line_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/api_factory/modules/module.dart';

class StockMoveLineModule {
  StockMoveLineModule._();

  // دالة جلب جميع StockMoveLines (مثل OrderLineModule.searchReadPrders)
  static searchReadStockMoveLines({
    required OnResponse onResponse,
    bool showGlobalLoading = true,
  }) async {
    List<String> fields = [
      'id',
      'product_id',
      'product_uom_id',
      'location_id',
      'location_dest_id',
      'state',
      'lot_id',
      'lot_name',
      'reference',
      'origin',
      'display_name',
      'picking_id',
      'move_id',
      'company_id',
      'package_id',
      'result_package_id',
      'lots_visible',
      'owner_id',
      'is_locked',
      'quantity',
      'quantity_product_uom',
      'picked',
      'date',
      'scheduled_date',
      'tracking',
      'description_picking',
    ];
    try {
      print("🚀 Starting to load StockMoveLines...");
      await Module.getRecordsController<StockMoveLineModel>(
        model: "stock.move.line",
        fields: fields,
        domain: [],
        fromJson: (data) => StockMoveLineModel.fromJson(data),
        onResponse: (response) {
          print(
            "📦 StockMoveLines API response received: ${response.length} items",
          );
          onResponse(response);
        },
        showGlobalLoading: showGlobalLoading,
      );
    } catch (e) {
      print("Error obteniendo stock move lines: $e");
      handleApiError(e);
    }
  }

  static readStockMoveLine({
    required List<int> ids,
    required OnResponse<List<StockMoveLineModel>> onResponse,
  }) {
    List<String> fields = [
      "product_id",
      "company_id",
      "move_id",
      "picking_id",
      "location_id",
      "location_dest_id",
      "package_id",
      "result_package_id",
      "lots_visible",
      "owner_id",
      "state",
      "lot_id",
      "lot_name",
      "is_initial_demand_editable",
      "product_uom_qty",
      "is_locked",
      "qty_done",
      "product_uom_id",
    ];
    Api.read(
      model: "stock.move.line",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<StockMoveLineModel> partners = [];
        for (var element in response) {
          partners.add(StockMoveLineModel.fromJson(element));
        }
        onResponse(partners);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchStockMoveLine({
    int offset = 0,
    required OnResponse<Map<int, List<StockMoveLineModel>>> onResponse,
  }) {
    List<String> fields = [
      "product_id",
      "company_id",
      "move_id",
      "picking_id",
      "location_id",
      "location_dest_id",
      "package_id",
      "result_package_id",
      "lots_visible",
      "owner_id",
      "state",
      "lot_id",
      "lot_name",
      "product_uom_qty",
      "is_locked",
      "qty_done",
      "product_uom_id",
    ];
    const int LIMIT = 60;
    List<StockMoveLineModel> partners = [];
    Api.searchRead(
      model: "stock.move.line",
      domain: [],
      limit: LIMIT,
      offset: offset,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            partners.add(StockMoveLineModel.fromJson(element));
          }
          onResponse({response["length"]: partners});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static UpdateStockPiching({
    required List<int> ids,
    required Map<String, dynamic>? maps,
    required OnResponse onResponse,
  }) {
    Module.writeModule(
      model: "stock.picking",
      ids: ids,
      values: maps!,
      onResponse: (response) {
        onResponse(response);
      },
    );
  }
}
