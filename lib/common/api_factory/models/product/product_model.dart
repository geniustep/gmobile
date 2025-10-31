import 'package:json_annotation/json_annotation.dart';
import 'dart:typed_data';
import 'dart:convert';

part 'product_model.g.dart';

@JsonSerializable()
class ProductTagModel {
  final int id;
  final String display_name;

  ProductTagModel({required this.id, required this.display_name});

  factory ProductTagModel.fromJson(Map<String, dynamic> json) =>
      _$ProductTagModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductTagModelToJson(this);
}

class ProductTagConverter
    implements JsonConverter<List<ProductTagModel>?, dynamic> {
  const ProductTagConverter();

  @override
  List<ProductTagModel>? fromJson(dynamic json) {
    if (json == null) return null;

    if (json is List) {
      if (json.isEmpty) return [];
      if (json.first is int) {
        return json
            .map((e) => ProductTagModel(id: e as int, display_name: ''))
            .toList();
      } else if (json.first is Map<String, dynamic>) {
        return json
            .map((e) => ProductTagModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return null;
  }

  @override
  dynamic toJson(List<ProductTagModel>? object) =>
      object?.map((e) => e.toJson()).toList();
}

class Base64ImageConverter implements JsonConverter<Uint8List?, dynamic> {
  const Base64ImageConverter();

  @override
  Uint8List? fromJson(dynamic json) {
    if (json == null || json == false) return null;
    if (json is String) {
      try {
        return base64Decode(json);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  String? toJson(Uint8List? object) {
    if (object == null) return null;
    return base64Encode(object);
  }
}

@JsonSerializable(explicitToJson: true)
class ProductModel {
  final dynamic id;
  final dynamic lst_price;
  final dynamic active;
  final dynamic barcode;
  final dynamic is_product_variant;
  final dynamic standard_price;
  final dynamic volume;
  final dynamic weight;
  final dynamic packaging_ids;
  final dynamic image_128;
  final dynamic image_256;

  
  final dynamic image_1920;

  final dynamic image_512;
  final dynamic write_date;
  final dynamic display_name;
  final dynamic create_uid;
  final dynamic create_date;
  final dynamic write_uid;
  final dynamic description;
  final dynamic list_price;
  final dynamic name;
  final dynamic total_value;
  final dynamic sales_count;
  final dynamic categ_id;
  final dynamic qty_available;
  final dynamic virtual_available;
  final dynamic incoming_qty;
  final dynamic outgoing_qty;
  final dynamic product_tmpl_id;
  final dynamic default_code;

  @ProductTagConverter()
  final List<ProductTagModel>? product_tag_ids;

  final dynamic product_variant_count;
  final dynamic service_type;
  final dynamic visible_expense_policy;
  final dynamic attribute_line_ids;
  final dynamic company_id;
  final dynamic fiscal_country_codes;
  final dynamic pricelist_item_count;
  final dynamic tracking;
  final dynamic show_on_hand_qty_status_button;
  final dynamic show_forecasted_qty_status_button;
  final dynamic uom_name;
  final dynamic product_document_count;
  final dynamic purchased_product_qty;
  final dynamic reordering_min_qty;
  final dynamic reordering_max_qty;
  final dynamic nbr_reordering_rules;
  final dynamic nbr_moves_in;
  final dynamic nbr_moves_out;
  final dynamic is_favorite;
  final dynamic sale_ok;
  final dynamic purchase_ok;
  final dynamic can_be_expensed;
  final dynamic type;
  final dynamic invoice_policy;
  final dynamic is_storable;
  final dynamic combo_ids;
  final dynamic service_tracking;
  final dynamic product_tooltip;
  final dynamic lot_valuated;
  final dynamic taxes_id;
  final dynamic tax_string;
  final dynamic supplier_taxes_id;
  final dynamic valid_product_template_attribute_line_ids;
  final dynamic currency_id;
  final dynamic cost_currency_id;
  final dynamic product_variant_id;
  final dynamic product_properties;
  final dynamic optional_product_ids;
  final dynamic description_sale;
  final dynamic expense_policy;
  final dynamic seller_ids;
  final dynamic variant_seller_ids;
  final dynamic service_to_purchase;
  final dynamic purchase_method;
  final dynamic description_purchase;
  final dynamic has_available_route_ids;
  final dynamic route_ids;
  final dynamic route_from_categ_ids;
  final dynamic responsible_id;
  final dynamic weight_uom_name;
  final dynamic volume_uom_name;
  final dynamic sale_delay;
  final dynamic property_stock_production;
  final dynamic property_stock_inventory;
  final dynamic description_pickingin;
  final dynamic description_pickingout;
  final dynamic property_account_income_id;
  final dynamic property_account_expense_id;
  final dynamic property_account_creditor_price_difference;

  ProductModel({
    this.id,
    this.lst_price,
    this.active,
    this.barcode,
    this.is_product_variant,
    this.standard_price,
    this.volume,
    this.weight,
    this.packaging_ids,
    this.image_128,
    this.image_256,
    this.write_date,
    this.display_name,
    this.create_uid,
    this.create_date,
    this.write_uid,
    this.description,
    this.list_price,
    this.name,
    this.total_value,
    this.sales_count,
    this.categ_id,
    this.qty_available,
    this.virtual_available,
    this.incoming_qty,
    this.outgoing_qty,
    this.product_tmpl_id,
    this.image_1920,
    this.image_512,
    this.product_tag_ids,
    this.default_code,
    this.product_variant_count,
    this.service_type,
    this.visible_expense_policy,
    this.attribute_line_ids,
    this.company_id,
    this.fiscal_country_codes,
    this.pricelist_item_count,
    this.tracking,
    this.show_on_hand_qty_status_button,
    this.show_forecasted_qty_status_button,
    this.uom_name,
    this.product_document_count,
    this.purchased_product_qty,
    this.reordering_min_qty,
    this.reordering_max_qty,
    this.nbr_reordering_rules,
    this.nbr_moves_in,
    this.nbr_moves_out,
    this.is_favorite,
    this.sale_ok,
    this.purchase_ok,
    this.can_be_expensed,
    this.type,
    this.invoice_policy,
    this.is_storable,
    this.combo_ids,
    this.service_tracking,
    this.product_tooltip,
    this.lot_valuated,
    this.taxes_id,
    this.tax_string,
    this.supplier_taxes_id,
    this.valid_product_template_attribute_line_ids,
    this.currency_id,
    this.cost_currency_id,
    this.product_variant_id,
    this.product_properties,
    this.optional_product_ids,
    this.description_sale,
    this.expense_policy,
    this.seller_ids,
    this.variant_seller_ids,
    this.service_to_purchase,
    this.purchase_method,
    this.description_purchase,
    this.has_available_route_ids,
    this.route_ids,
    this.route_from_categ_ids,
    this.responsible_id,
    this.weight_uom_name,
    this.volume_uom_name,
    this.sale_delay,
    this.property_stock_production,
    this.property_stock_inventory,
    this.description_pickingin,
    this.description_pickingout,
    this.property_account_income_id,
    this.property_account_expense_id,
    this.property_account_creditor_price_difference,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
