import 'dart:async';

import 'package:gsloution_mobile/common/config/import.dart';

class ProductModule {
  ProductModule._();

  static readProducts({required List<int> ids, required OnResponse<List<ProductModel>> onResponse}) {
    List<String> fields = [
      "product_variant_count",
      "is_product_variant",
      "attribute_line_ids",
      "qty_available",
      "uom_name",
      "virtual_available",
      "reordering_min_qty",
      "reordering_max_qty",
      "nbr_reordering_rules",
      "sales_count",
      "id",
      "image_1920",
      "image_128",
      "image_256",
      "image_128",
      "name",
      "sale_ok",
      "purchase_ok",
      "active",
      "type",
      "categ_id",
      "default_code",
      "barcode",
      "list_price",
      "valuation",
      "cost_method",
      "pricelist_item_count",
      "taxes_id",
      "standard_price",
      "company_id",
      "uom_id",
      "uom_po_id",
      "currency_id",
      "cost_currency_id",
      "product_variant_id",
      "description",
      "invoice_policy",
      "service_type",
      "visible_expense_policy",
      "expense_policy",
      "description_sale",
      "sale_line_warn",
      "sale_line_warn_msg",
      "supplier_taxes_id",
      "route_ids",
      "route_from_categ_ids",
      "sale_delay",
      "tracking",
      "property_stock_production",
      "property_stock_inventory",
      "weight",
      "weight_uom_name",
      "volume",
      "volume_uom_name",
      "responsible_id",
      "packaging_ids",
      "description_pickingout",
      "description_pickingin",
      "description_picking",
      "property_account_income_id",
      "property_account_expense_id",
      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
      "display_name",
      "can_be_expensed"
    ];
    Api.read(
      model: "product.template",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<ProductModel> products = [];
        for (var element in response) {
          products.add(ProductModel.fromJson(element));
        }
        onResponse(products);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static createProduct({required Map<String, dynamic>? maps, int offset = 0, required OnResponse<Map<int, List<ProductModel>>> onResponse}) {
    Map<String, dynamic> newMap = Map.from(maps!);
    Api.create(
        model: "product.template",
        values: newMap,
        onResponse: (response) {
          ProductModule.readProducts(
              ids: [response],
              onResponse: (responseProducts) {
                response = responseProducts[0];
                // Get.off(() => ProductDetails(responseProducts[0]));
              });
        },
        onError: (String error, Map<String, dynamic> data) {
          print('error');
        });
  }

  static updateProduct({required Map<String, dynamic>? maps, required ProductModel product, required OnResponse onResponse}) {
    Api.write(
      model: "product.template",
      ids: [product.id],
      values: maps!,
      onResponse: (response) {
        readProducts(
            ids: [product.id],
            onResponse: (onResponse) {
              // Get.off(() => ProductDetails(onResponse[0]));
            });
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }
}
