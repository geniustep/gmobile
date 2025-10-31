import 'package:gsloution_mobile/common/api_factory/models/stock/stock_location/stock_location_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class StockLocationModule {
  StockLocationModule._();

  static readStockLocation({
    required List<int> ids,
    List<String>? fields,
    required OnResponse<List<StockLocationModel>> onResponse,
  }) {
    List<String> fields = [
      "id",
      "name",
      "location_id",
      "active",
      "usage",
      "company_id",
      "scrap_location",
      "return_location",
      "valuation_in_account_id",
      "valuation_out_account_id",
      "removal_strategy_id",
      "comment",
      "complete_name",
    ];
    Api.read(
      model: "stock.location",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          List<StockLocationModel> stockLocation = [];
          for (var element in response) {
            stockLocation.add(StockLocationModel.fromJson(element));
          }
          onResponse(stockLocation);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadStockLocation({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<StockLocationModel>>> onResponse,
    List? groupby,
    List<String>? fields,
  }) {
    List<String> fields = [
      "id",
      "name",
      "location_id",
      "active",
      "usage",
      "company_id",
      "scrap_location",
      "return_location",
      "valuation_in_account_id",
      "valuation_out_account_id",
      "removal_strategy_id",
      "comment",
      "complete_name",
    ];
    const int LIMIT = 80;
    List<StockLocationModel> saleLocation = [];
    Api.searchRead(
      model: "stock.location",
      domain: domain,
      limit: LIMIT,
      offset: offset,
      fields: fields,
      order: "id",
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            saleLocation.add(StockLocationModel.fromJson(element));
          }
          onResponse({response["length"]: saleLocation});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static nameSearchStockLocation({required OnResponse onResponse}) {
    dynamic kwargs = {};
    kwargs["context"] = Api.getContext({});
    kwargs["args"] = [
      [
        "usage",
        "in",
        ["internal"],
      ],
    ];

    Api.callKW(
      model: "stock.location",
      method: "name_search",
      kwargs: kwargs,
      args: [],
      onResponse: onResponse,
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
