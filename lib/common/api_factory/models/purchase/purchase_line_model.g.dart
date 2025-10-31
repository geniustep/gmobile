// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_line_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseLineModel _$PurchaseLineModelFromJson(Map<String, dynamic> json) =>
    PurchaseLineModel(
      id: json['id'],
      displayType: json['display_type'],
      currencyId: json['currency_id'],
      state: json['state'],
      productType: json['product_type'],
      productUomCategoryId: json['product_uom_category_id'],
      invoiceLines: json['invoice_lines'],
      sequence: json['sequence'],
      productId: json['product_id'],
      name: json['name'],
      datePlanned: json['date_planned'],
      moveDestIds: json['move_dest_ids'],
      accountAnalyticId: json['account_analytic_id'],
      analyticTagIds: json['analytic_tag_ids'],
      productQty: json['product_qty'],
      qtyReceivedManual: json['qty_received_manual'],
      qtyReceivedMethod: json['qty_received_method'],
      qtyReceived: json['qty_received'],
      qtyInvoiced: json['qty_invoiced'],
      productUom: json['product_uom'],
      priceUnit: json['price_unit'],
      taxesId: json['taxes_id'],
      priceSubtotal: json['price_subtotal'],
    );

Map<String, dynamic> _$PurchaseLineModelToJson(PurchaseLineModel instance) =>
    <String, dynamic>{
      'display_type': instance.displayType,
      'id': instance.id,
      'currency_id': instance.currencyId,
      'state': instance.state,
      'product_type': instance.productType,
      'product_uom_category_id': instance.productUomCategoryId,
      'invoice_lines': instance.invoiceLines,
      'sequence': instance.sequence,
      'product_id': instance.productId,
      'name': instance.name,
      'date_planned': instance.datePlanned,
      'move_dest_ids': instance.moveDestIds,
      'account_analytic_id': instance.accountAnalyticId,
      'analytic_tag_ids': instance.analyticTagIds,
      'product_qty': instance.productQty,
      'qty_received_manual': instance.qtyReceivedManual,
      'qty_received_method': instance.qtyReceivedMethod,
      'qty_received': instance.qtyReceived,
      'qty_invoiced': instance.qtyInvoiced,
      'product_uom': instance.productUom,
      'price_unit': instance.priceUnit,
      'taxes_id': instance.taxesId,
      'price_subtotal': instance.priceSubtotal,
    };
