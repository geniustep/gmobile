import 'package:json_annotation/json_annotation.dart';

part 'purchase_line_model.g.dart';

@JsonSerializable()
class PurchaseLineModel {
  @JsonKey(name: 'display_type')
  dynamic displayType;
    @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'state')
  dynamic state;
  @JsonKey(name: 'product_type')
  dynamic productType;
  @JsonKey(name: 'product_uom_category_id')
  dynamic productUomCategoryId;
  @JsonKey(name: 'invoice_lines')
  dynamic invoiceLines;
  @JsonKey(name: 'sequence')
  dynamic sequence;
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'date_planned')
  dynamic datePlanned;
  @JsonKey(name: 'move_dest_ids')
  dynamic moveDestIds;
  @JsonKey(name: 'account_analytic_id')
  dynamic accountAnalyticId;
  @JsonKey(name: 'analytic_tag_ids')
  dynamic analyticTagIds;
  @JsonKey(name: 'product_qty')
  dynamic productQty;
  @JsonKey(name: 'qty_received_manual')
  dynamic qtyReceivedManual;
  @JsonKey(name: 'qty_received_method')
  dynamic qtyReceivedMethod;
  @JsonKey(name: 'qty_received')
  dynamic qtyReceived;
  @JsonKey(name: 'qty_invoiced')
  dynamic qtyInvoiced;
  @JsonKey(name: 'product_uom')
  dynamic productUom;
  @JsonKey(name: 'price_unit')
  dynamic priceUnit;
  @JsonKey(name: 'taxes_id')
  dynamic taxesId;
  @JsonKey(name: 'price_subtotal')
  dynamic priceSubtotal;

  PurchaseLineModel({
    this.id,
    this.displayType,
    this.currencyId,
    this.state,
    this.productType,
    this.productUomCategoryId,
    this.invoiceLines,
    this.sequence,
    this.productId,
    this.name,
    this.datePlanned,
    this.moveDestIds,
    this.accountAnalyticId,
    this.analyticTagIds,
    this.productQty,
    this.qtyReceivedManual,
    this.qtyReceivedMethod,
    this.qtyReceived,
    this.qtyInvoiced,
    this.productUom,
    this.priceUnit,
    this.taxesId,
    this.priceSubtotal,
  });

  factory PurchaseLineModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseLineModelToJson(this);
}
