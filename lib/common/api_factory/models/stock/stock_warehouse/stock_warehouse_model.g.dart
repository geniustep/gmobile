// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_warehouse_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockWarehouseModel _$StockWarehouseModelFromJson(Map<String, dynamic> json) =>
    StockWarehouseModel(
      id: json['id'],
      name: json['name'],
      active: json['active'],
      code: json['code'],
      companyId: json['company_id'],
      partnerId: json['partner_id'],
      receptionSteps: json['reception_steps'],
      deliverySteps: json['delivery_steps'],
      showResupply: json['show_resupply'],
      warehouseCount: json['warehouse_count'],
      buyToResupply: json['buy_to_resupply'],
      resupplyWhIds: json['resupply_wh_ids'],
      viewLocationId: json['view_location_id'],
      lotStockId: json['lot_stock_id'],
      whInputStockLocId: json['wh_input_stock_loc_id'],
      whQcStockLocId: json['wh_qc_stock_loc_id'],
      whPackStockLocId: json['wh_pack_stock_loc_id'],
      whOutputStockLocId: json['wh_output_stock_loc_id'],
      inTypeId: json['in_type_id'],
      intTypeId: json['int_type_id'],
      pickTypeId: json['pick_type_id'],
      packTypeId: json['pack_type_id'],
      outTypeId: json['out_type_id'],
      displayName: json['display_name'],
    );

Map<String, dynamic> _$StockWarehouseModelToJson(
        StockWarehouseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'active': instance.active,
      'code': instance.code,
      'company_id': instance.companyId,
      'partner_id': instance.partnerId,
      'reception_steps': instance.receptionSteps,
      'delivery_steps': instance.deliverySteps,
      'show_resupply': instance.showResupply,
      'warehouse_count': instance.warehouseCount,
      'buy_to_resupply': instance.buyToResupply,
      'resupply_wh_ids': instance.resupplyWhIds,
      'view_location_id': instance.viewLocationId,
      'lot_stock_id': instance.lotStockId,
      'wh_input_stock_loc_id': instance.whInputStockLocId,
      'wh_qc_stock_loc_id': instance.whQcStockLocId,
      'wh_pack_stock_loc_id': instance.whPackStockLocId,
      'wh_output_stock_loc_id': instance.whOutputStockLocId,
      'in_type_id': instance.inTypeId,
      'int_type_id': instance.intTypeId,
      'pick_type_id': instance.pickTypeId,
      'pack_type_id': instance.packTypeId,
      'out_type_id': instance.outTypeId,
      'display_name': instance.displayName,
    };
