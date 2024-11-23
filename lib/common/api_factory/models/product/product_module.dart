import 'package:gsloution_mobile/common/config/import.dart';

class ProductModule {
  ProductModule._();

  static readProducts(
      {required List<int> ids,
      required OnResponse<List<ProductModel>> onResponse}) {
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
      "image_512",
      "image_256",
      "image_128",
      "__last_update",
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

  static searchReadProducts({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<ProductModel>>> onResponse,
  }) {
    List<String> fields = [
      "price_extra",
      "lst_price",
      "code",
      "active",
      "barcode",
      "is_product_variant",
      "standard_price",
      "volume",
      "weight",
      "packaging_ids",
      "image_variant_512",
      "image_512",
      "can_image_1024_be_zoomed",
      "write_date",
      "id",
      "display_name",
      "create_uid",
      "create_date",
      "write_uid",
      "tax_string",
      "stock_quant_ids",
      "stock_move_ids",
      "qty_available",
      "virtual_available",
      "free_qty",
      "incoming_qty",
      "outgoing_qty",
      "nbr_moves_in",
      "nbr_moves_out",
      "nbr_reordering_rules",
      "reordering_min_qty",
      "reordering_max_qty",
      "valid_ean",
      "lot_properties_definition",
      "standard_price_update_warning",
      "purchased_product_qty",
      "is_in_purchase_order",
      "total_value",
      "company_currency_id",
      "valuation",
      "cost_method",
      "purchase_order_line_ids",
      "sales_count",
      "product_catalog_product_is_in_sale_order",
      "name",
      "sequence",
      "description",
      "type",
      "combo_ids",
      "service_tracking",
      "categ_id",
      "currency_id",
      "cost_currency_id",
      "list_price",
      "volume_uom_name",
      "weight_uom_name",
      "sale_ok",
      "purchase_ok",
      "uom_id",
      "uom_name",
      "uom_po_id",
      "company_id",
      "seller_ids",
      "variant_seller_ids",
      "color",
      "attribute_line_ids",
      "valid_product_template_attribute_line_ids",
      "product_variant_ids",
      "product_variant_id",
      "product_variant_count",
      "is_favorite",
      "product_tag_ids",
      "product_properties",
      "taxes_id",
      "supplier_taxes_id",
      "is_storable",
      "responsible_id",
      "property_stock_production",
      "property_stock_inventory",
      "sale_delay",
      "tracking",
      "description_picking",
      "description_pickingout",
      "description_pickingin",
      "location_id",
      "warehouse_id",
      "has_available_route_ids",
      "route_ids",
      "route_from_categ_ids",
      "can_be_expensed",
      "purchase_method",
      "purchase_line_warn",
      "purchase_line_warn_msg",
      "lot_valuated",
      "service_type",
      "sale_line_warn",
      "sale_line_warn_msg",
      "expense_policy",
      "visible_expense_policy",
      "invoice_policy",
      "optional_product_ids",
      "service_to_purchase",
      "expense_policy_tooltip"
    ];
    const int limit = 10;

    List<ProductModel> products = [];

    Api.callKW(
      method: 'search_read',
      model: "product.product",
      args: [domain, fields],
      kwargs: {
        "limit": limit,
        "offset": offset,
      },
      onResponse: (response) {
        if (response is List) {
          for (var element in response) {
            if (element is Map<String, dynamic>) {
              products.add(ProductModel.fromJson(element));
            }
          }
          onResponse({products.length: products});
        }
      },
      onError: (error, data) {
        print("Error: $error");
        print("Data: $data");

        handleApiError(error);
      },
    );
  }

  static createProduct(
      {required Map<String, dynamic>? maps,
      int offset = 0,
      required OnResponse<Map<int, List<ProductModel>>> onResponse}) {
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

  static updateProduct(
      {required Map<String, dynamic>? maps,
      required ProductModel product,
      required OnResponse onResponse}) {
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
