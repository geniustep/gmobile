import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class OrderLineModule {
  OrderLineModule._();
  static readOrderLines({
    required List<int> ids,
    required OnResponse<List<OrderLineModel>> onResponse,
  }) {
    List<String> fields = [
      "sequence",
      "display_type",
      "product_uom_category_id",
      "product_updatable",
      "product_id",
      "product_template_id",
      "name",
      // "analytic_tag_ids",
      "route_id",
      "product_uom_qty",
      "product_type",
      "virtual_available_at_date",
      "qty_available_today",
      "free_qty_today",
      "scheduled_date",
      "warehouse_id",
      "qty_to_deliver",
      "is_mto",
      "display_qty_widget",
      "qty_delivered",
      // "qty_delivered_manual",
      // "qty_delivered_method",
      "qty_invoiced",
      "qty_to_invoice",
      "product_uom",
      "customer_lead",
      // "product_packaging",
      "price_unit",
      "tax_id",
      "discount",
      "price_subtotal",
      "price_total",
      "state",
      "invoice_status",
      "currency_id",
      "price_tax",
      "company_id",
    ];
    Api.read(
      model: "sale.order.line",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<OrderLineModel> partners = [];
        for (var element in response) {
          partners.add(OrderLineModel.fromJson(element));
        }
        onResponse(partners);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadPrders({
    required OnResponse onResponse,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    List<String> fields = [
      'product_id',
      'product_uom',
      'price_total',
      'discount',
    ];
    try {
      await Module.getRecordsController<OrderLineModel>(
        model: "sale.order.line",
        fields: fields,
        domain: [],
        fromJson: (data) => OrderLineModel.fromJson(data),
        onResponse: (response) {
          onResponse(response);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
      handleApiError(e);
    }
  }

  static createSaleOrderLine({
    required Map<String, dynamic>? maps,
    required OnResponse onResponse,
  }) {
    Api.addModule(
      model: "sale.order.line",
      maps: maps,
      onResponse: (response) {
        onResponse(response);
      },
    );
  }

  static updateSaleOrderLine({
    required Map<String, dynamic>? maps,
    required List<int> ids,
    required OnResponse onResponse,
  }) {
    Api.write(
      model: "sale.order.line",
      ids: ids,
      values: maps!,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {},
    );
  }
}
