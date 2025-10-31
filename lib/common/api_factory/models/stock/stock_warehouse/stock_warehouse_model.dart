import 'package:json_annotation/json_annotation.dart';

part 'stock_warehouse_model.g.dart';

@JsonSerializable()
class StockWarehouseModel {
  @JsonKey(name: "id")
  dynamic id;
  @JsonKey(name: "name")
  dynamic name;
  @JsonKey(name: "active")
  dynamic active;
  @JsonKey(name: "code")
  dynamic code;
  @JsonKey(name: "company_id")
  dynamic companyId;
  @JsonKey(name: "partner_id")
  dynamic partnerId;
  @JsonKey(name: "reception_steps")
  dynamic receptionSteps;
  @JsonKey(name: "delivery_steps")
  dynamic deliverySteps;
  @JsonKey(name: "show_resupply")
  dynamic showResupply;
  @JsonKey(name: "warehouse_count")
  dynamic warehouseCount;
  @JsonKey(name: "buy_to_resupply")
  dynamic buyToResupply;
  @JsonKey(name: "resupply_wh_ids")
  dynamic resupplyWhIds;
  @JsonKey(name: "view_location_id")
  dynamic viewLocationId;
  @JsonKey(name: "lot_stock_id")
  dynamic lotStockId;
  @JsonKey(name: "wh_input_stock_loc_id")
  dynamic whInputStockLocId;
  @JsonKey(name: "wh_qc_stock_loc_id")
  dynamic whQcStockLocId;
  @JsonKey(name: "wh_pack_stock_loc_id")
  dynamic whPackStockLocId;
  @JsonKey(name: "wh_output_stock_loc_id")
  dynamic whOutputStockLocId;
  @JsonKey(name: "in_type_id")
  dynamic inTypeId;
  @JsonKey(name: "int_type_id")
  dynamic intTypeId;
  @JsonKey(name: "pick_type_id")
  dynamic pickTypeId;
  @JsonKey(name: "pack_type_id")
  dynamic packTypeId;
  @JsonKey(name: "out_type_id")
  dynamic outTypeId;
  @JsonKey(name: "display_name")
  dynamic displayName;

  StockWarehouseModel({
    this.id,
    this.name,
    this.active,
    this.code,
    this.companyId,
    this.partnerId,
    this.receptionSteps,
    this.deliverySteps,
    this.showResupply,
    this.warehouseCount,
    this.buyToResupply,
    this.resupplyWhIds,
    this.viewLocationId,
    this.lotStockId,
    this.whInputStockLocId,
    this.whQcStockLocId,
    this.whPackStockLocId,
    this.whOutputStockLocId,
    this.inTypeId,
    this.intTypeId,
    this.pickTypeId,
    this.packTypeId,
    this.outTypeId,
    this.displayName,
  });

  factory StockWarehouseModel.fromJson(Map<String, dynamic> json) =>
      _$StockWarehouseModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockWarehouseModelToJson(this);
}
