import 'package:json_annotation/json_annotation.dart';

part 'order_line_model.g.dart';

@JsonSerializable()
class OrderLineModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'sequence')
  dynamic sequence;
  @JsonKey(name: 'display_type')
  dynamic displayType;
  @JsonKey(name: 'product_uom_category_id')
  dynamic productUomCategoryId;
  @JsonKey(name: 'product_updatable')
  dynamic productUpdatable;
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'product_template_id')
  dynamic productTemplateId;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'analytic_tag_ids')
  dynamic analyticTagIds;
  @JsonKey(name: 'route_id')
  dynamic routeId;
  @JsonKey(name: 'product_uom_qty')
  dynamic productUomQty;
  @JsonKey(name: 'product_type')
  dynamic productType;
  @JsonKey(name: 'virtual_available_at_date')
  dynamic virtualAvailableAtDate;
  @JsonKey(name: 'qty_available_today')
  dynamic qtyAvailableToday;
  @JsonKey(name: 'free_qty_today')
  dynamic freeQtyToday;
  @JsonKey(name: 'scheduled_date')
  dynamic scheduledDate;
  @JsonKey(name: 'warehouse_id')
  dynamic warehouseId;
  @JsonKey(name: 'qty_to_deliver')
  dynamic qtyToDeliver;
  @JsonKey(name: 'is_mto')
  dynamic isMto;
  @JsonKey(name: 'display_qty_widget')
  dynamic displayQtyWidget;
  @JsonKey(name: 'qty_delivered')
  dynamic qtyDelivered;
  @JsonKey(name: 'qty_delivered_manual')
  dynamic qtyDeliveredManual;
  @JsonKey(name: 'qty_delivered_method')
  dynamic qtyDeliveredMethod;
  @JsonKey(name: 'qty_invoiced')
  dynamic qtyInvoiced;
  @JsonKey(name: 'qty_to_invoice')
  dynamic qtyToInvoice;
  @JsonKey(name: 'product_uom')
  dynamic productUom;
  @JsonKey(name: 'customer_lead')
  dynamic customerLead;
  @JsonKey(name: 'product_packaging')
  dynamic productPackaging;
  @JsonKey(name: 'price_unit')
  dynamic priceUnit;
  @JsonKey(name: 'tax_id')
  dynamic taxId;
  @JsonKey(name: 'discount')
  dynamic discount;
  @JsonKey(name: 'price_subtotal')
  dynamic priceSubtotal;
  @JsonKey(name: 'price_total')
  dynamic priceTotal;
  @JsonKey(name: 'state')
  dynamic state;
  @JsonKey(name: 'invoice_status')
  dynamic invoiceStatus;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'price_tax')
  dynamic priceTax;
  @JsonKey(name: 'company_id')
  dynamic companyId;

  OrderLineModel({
    this.id,
    this.sequence,
    this.displayType,
    this.productUomCategoryId,
    this.productUpdatable,
    this.productId,
    this.productTemplateId,
    this.name,
    this.analyticTagIds,
    this.routeId,
    this.productUomQty,
    this.productType,
    this.virtualAvailableAtDate,
    this.qtyAvailableToday,
    this.freeQtyToday,
    this.scheduledDate,
    this.warehouseId,
    this.qtyToDeliver,
    this.isMto,
    this.displayQtyWidget,
    this.qtyDelivered,
    this.qtyDeliveredManual,
    this.qtyDeliveredMethod,
    this.qtyInvoiced,
    this.qtyToInvoice,
    this.productUom,
    this.customerLead,
    this.productPackaging,
    this.priceUnit,
    this.taxId,
    this.discount,
    this.priceSubtotal,
    this.priceTotal,
    this.state,
    this.invoiceStatus,
    this.currencyId,
    this.priceTax,
    this.companyId,
  });

  factory OrderLineModel.fromJson(Map<String, dynamic> json) =>
      _$OrderLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderLineModelToJson(this);
}
