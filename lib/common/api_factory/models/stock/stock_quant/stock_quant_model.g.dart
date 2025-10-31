// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_quant_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockQuantModel _$StockQuantModelFromJson(Map<String, dynamic> json) =>
    StockQuantModel(
      productId: json['product_id'],
      productTmplId: json['product_tmpl_id'],
      productUomId: json['product_uom_id'],
      companyId: json['company_id'],
      locationId: json['location_id'],
      lotId: json['lot_id'],
      packageId: json['package_id'],
      ownerId: json['owner_id'],
      quantity: json['quantity'],
      inventoryQuantity: json['inventory_quantity'],
      reservedQuantity: json['reserved_quantity'],
      inDate: json['in_date'],
      tracking: json['tracking'],
      onHand: json['on_hand'],
      value: json['value'],
      currencyId: json['currency_id'],
      id: json['id'],
      displayName: json['display_name'],
      createUid: json['create_uid'],
      createDate: json['create_date'],
      writeUid: json['write_uid'],
      writeDate: json['write_date'],
      pLastUpdate: json['__last_update'],
    );

Map<String, dynamic> _$StockQuantModelToJson(StockQuantModel instance) =>
    <String, dynamic>{
      'product_id': instance.productId,
      'product_tmpl_id': instance.productTmplId,
      'product_uom_id': instance.productUomId,
      'company_id': instance.companyId,
      'location_id': instance.locationId,
      'lot_id': instance.lotId,
      'package_id': instance.packageId,
      'owner_id': instance.ownerId,
      'quantity': instance.quantity,
      'inventory_quantity': instance.inventoryQuantity,
      'reserved_quantity': instance.reservedQuantity,
      'in_date': instance.inDate,
      'tracking': instance.tracking,
      'on_hand': instance.onHand,
      'value': instance.value,
      'currency_id': instance.currencyId,
      'id': instance.id,
      'display_name': instance.displayName,
      'create_uid': instance.createUid,
      'create_date': instance.createDate,
      'write_uid': instance.writeUid,
      'write_date': instance.writeDate,
      '__last_update': instance.pLastUpdate,
    };
