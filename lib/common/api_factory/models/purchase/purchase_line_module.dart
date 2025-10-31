import 'package:gsloution_mobile/common/api_factory/models/purchase/purchase_line_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:intl/intl.dart';

class PurchaseLineModule {
  PurchaseLineModule._();
  static readPurchaseLine({
    required List<int> ids,
    required OnResponse<List<PurchaseLineModel>> onResponse,
  }) {
    List<String> fields = [
      "display_type",
      "currency_id",
      "state",
      "product_type",
      "product_uom_category_id",
      "invoice_lines",
      "sequence",
      "product_id",
      "name",
      "date_planned",
      "move_dest_ids",
      "account_analytic_id",
      "analytic_tag_ids",
      "product_qty",
      "qty_received_manual",
      "qty_received_method",
      "qty_received",
      "qty_invoiced",
      "product_uom",
      "price_unit",
      "taxes_id",
      "price_subtotal",
    ];
    Api.read(
      model: "purchase.order.line",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<PurchaseLineModel> purchaseLine = [];
        for (var element in response) {
          purchaseLine.add(PurchaseLineModel.fromJson(element));
        }
        onResponse(purchaseLine);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadPurchaseLine({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<PurchaseLineModel>>> onResponse,
    List? groupby,
  }) {
    List<String> fields = [
      "display_type",
      "currency_id",
      "state",
      "product_type",
      "product_uom_category_id",
      "invoice_lines",
      "sequence",
      "product_id",
      "name",
      "date_planned",
      "move_dest_ids",
      "account_analytic_id",
      "analytic_tag_ids",
      "product_qty",
      "qty_received_manual",
      "qty_received_method",
      "qty_received",
      "qty_invoiced",
      "product_uom",
      "price_unit",
      "taxes_id",
      "price_subtotal",
    ];
    const int LIMIT = 80;
    List<PurchaseLineModel> purchaseLine = [];
    Api.searchRead(
      model: "purchase.order.line",
      domain: domain,
      limit: LIMIT,
      offset: offset,
      fields: fields,
      order: "id",
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            purchaseLine.add(PurchaseLineModel.fromJson(element));
          }
          onResponse({response["length"]: purchaseLine});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static addPurchaseLine({
    required int purchaseOrderId,
    required ProductModel product,
    required double quantity,
    required double price,
    required OnResponse onResponse,
  }) {
    Map<String, dynamic> maps = <String, dynamic>{};

    maps["order_id"] = purchaseOrderId;
    maps["name"] = product.name;
    maps["date_planned"] = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());
    maps["price_unit"] = price;
    maps["product_id"] = product.product_variant_id != null
        ? product.product_variant_id[0]
        : product.id;
    maps["product_qty"] = quantity;
    maps["product_uom"] = product.uom_name;
    maps["qty_received_manual"] = 0;
    maps["product_uom"] = 1;
    maps["account_analytic_id"] = false;
    maps["display_type"] = false;

    Module.addModule(
      model: "purchase.order.line",
      maps: maps,
      onResponse: (response) {
        onResponse(response);
      },
    );
  }
}
