// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_move_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockMoveModel _$StockMoveModelFromJson(Map<String, dynamic> json) =>
    StockMoveModel(
      id: json['id'],
      companyId: (json['company_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      name: json['name'] as String?,
      state: json['state'] as String?,
      pickingTypeId: (json['picking_type_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      locationId: (json['location_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      locationDestId: (json['location_dest_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      scrapped: json['scrapped'] as bool?,
      pickingCode: json['picking_code'] as String?,
      productType: json['product_type'] as String?,
      showDetailsVisible: json['show_details_visible'] as bool?,
      showReservedAvailability: json['show_reserved_availability'] as bool?,
      showOperations: json['show_operations'] as bool?,
      additional: json['additional'] as bool?,
      hasMoveLines: json['has_move_lines'] as bool?,
      isLocked: json['is_locked'] as bool?,
      productUomCategoryId: (json['product_uom_category_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      hasTracking: json['has_tracking'] as String?,
      displayAssignSerial: json['display_assign_serial'] as bool?,
      productId: (json['product_id'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
      descriptionPicking: json['description_picking'],
      dateExpected: json['date_expected'] as String?,
      isInitialDemandEditable: json['is_initial_demand_editable'] as bool?,
      isQuantityDoneEditable: json['is_quantity_done_editable'] as bool?,
      productUomQty: (json['product_uom_qty'] as num?)?.toDouble(),
      reservedAvailability: (json['reserved_availability'] as num?)?.toDouble(),
      quantityDone: (json['quantity_done'] as num?)?.toDouble(),
      productUom: (json['product_uom'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$StockMoveModelToJson(StockMoveModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'company_id': instance.companyId,
      'name': instance.name,
      'state': instance.state,
      'picking_type_id': instance.pickingTypeId,
      'location_id': instance.locationId,
      'location_dest_id': instance.locationDestId,
      'scrapped': instance.scrapped,
      'picking_code': instance.pickingCode,
      'product_type': instance.productType,
      'show_details_visible': instance.showDetailsVisible,
      'show_reserved_availability': instance.showReservedAvailability,
      'show_operations': instance.showOperations,
      'additional': instance.additional,
      'has_move_lines': instance.hasMoveLines,
      'is_locked': instance.isLocked,
      'product_uom_category_id': instance.productUomCategoryId,
      'has_tracking': instance.hasTracking,
      'display_assign_serial': instance.displayAssignSerial,
      'product_id': instance.productId,
      'description_picking': instance.descriptionPicking,
      'date_expected': instance.dateExpected,
      'is_initial_demand_editable': instance.isInitialDemandEditable,
      'is_quantity_done_editable': instance.isQuantityDoneEditable,
      'product_uom_qty': instance.productUomQty,
      'reserved_availability': instance.reservedAvailability,
      'quantity_done': instance.quantityDone,
      'product_uom': instance.productUom,
    };
