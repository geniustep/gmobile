import 'package:json_annotation/json_annotation.dart';

part 'stock_move_line_model.g.dart';

@JsonSerializable()
class StockMoveLineModel {
  @JsonKey(name: 'id')
  dynamic id;

  @JsonKey(name: 'picking_id')
  dynamic pickingId;

  @JsonKey(name: 'move_id')
  dynamic moveId;

  @JsonKey(name: 'company_id')
  dynamic companyId;

  @JsonKey(name: 'product_id')
  dynamic productId;

  @JsonKey(name: 'product_uom_id')
  dynamic productUomId;

  @JsonKey(name: 'product_uom_category_id')
  dynamic productUomCategoryId;

  @JsonKey(name: 'product_category_name')
  dynamic productCategoryName;

  @JsonKey(name: 'quantity')
  dynamic quantity;

  @JsonKey(name: 'quantity_product_uom')
  dynamic quantityProductUom;

  @JsonKey(name: 'picked')
  dynamic picked;

  @JsonKey(name: 'package_id')
  dynamic packageId;

  @JsonKey(name: 'package_level_id')
  dynamic packageLevelId;

  @JsonKey(name: 'lot_id')
  dynamic lotId;

  @JsonKey(name: 'lot_name')
  dynamic lotName;

  @JsonKey(name: 'result_package_id')
  dynamic resultPackageId;

  @JsonKey(name: 'date')
  dynamic date;

  @JsonKey(name: 'scheduled_date')
  dynamic scheduledDate;

  @JsonKey(name: 'owner_id')
  dynamic ownerId;

  @JsonKey(name: 'location_id')
  dynamic locationId;

  @JsonKey(name: 'location_dest_id')
  dynamic locationDestId;

  @JsonKey(name: 'location_usage')
  dynamic locationUsage;

  @JsonKey(name: 'location_dest_usage')
  dynamic locationDestUsage;

  @JsonKey(name: 'lots_visible')
  dynamic lotsVisible;

  @JsonKey(name: 'picking_partner_id')
  dynamic pickingPartnerId;

  @JsonKey(name: 'picking_code')
  dynamic pickingCode;

  @JsonKey(name: 'picking_type_id')
  dynamic pickingTypeId;

  @JsonKey(name: 'picking_type_use_create_lots')
  dynamic pickingTypeUseCreateLots;

  @JsonKey(name: 'picking_type_use_existing_lots')
  dynamic pickingTypeUseExistingLots;

  @JsonKey(name: 'picking_type_entire_packs')
  dynamic pickingTypeEntirePacks;

  @JsonKey(name: 'state')
  dynamic state;

  @JsonKey(name: 'is_inventory')
  dynamic isInventory;

  @JsonKey(name: 'is_locked')
  dynamic isLocked;

  @JsonKey(name: 'consume_line_ids')
  dynamic consumeLineIds;

  @JsonKey(name: 'produce_line_ids')
  dynamic produceLineIds;

  @JsonKey(name: 'reference')
  dynamic reference;

  @JsonKey(name: 'tracking')
  dynamic tracking;

  @JsonKey(name: 'origin')
  dynamic origin;

  @JsonKey(name: 'description_picking')
  dynamic descriptionPicking;

  @JsonKey(name: 'quant_id')
  dynamic quantId;

  @JsonKey(name: 'product_packaging_qty')
  dynamic productPackagingQty;

  @JsonKey(name: 'picking_location_id')
  dynamic pickingLocationId;

  @JsonKey(name: 'picking_location_dest_id')
  dynamic pickingLocationDestId;

  @JsonKey(name: 'display_name')
  dynamic displayName;

  @JsonKey(name: 'create_uid')
  dynamic createUid;

  @JsonKey(name: 'create_date')
  dynamic createDate;

  @JsonKey(name: 'write_uid')
  dynamic writeUid;

  @JsonKey(name: 'write_date')
  dynamic writeDate;

  StockMoveLineModel({
    this.id,
    this.pickingId,
    this.moveId,
    this.companyId,
    this.productId,
    this.productUomId,
    this.productUomCategoryId,
    this.productCategoryName,
    this.quantity,
    this.quantityProductUom,
    this.picked,
    this.packageId,
    this.packageLevelId,
    this.lotId,
    this.lotName,
    this.resultPackageId,
    this.date,
    this.scheduledDate,
    this.ownerId,
    this.locationId,
    this.locationDestId,
    this.locationUsage,
    this.locationDestUsage,
    this.lotsVisible,
    this.pickingPartnerId,
    this.pickingCode,
    this.pickingTypeId,
    this.pickingTypeUseCreateLots,
    this.pickingTypeUseExistingLots,
    this.pickingTypeEntirePacks,
    this.state,
    this.isInventory,
    this.isLocked,
    this.consumeLineIds,
    this.produceLineIds,
    this.reference,
    this.tracking,
    this.origin,
    this.descriptionPicking,
    this.quantId,
    this.productPackagingQty,
    this.pickingLocationId,
    this.pickingLocationDestId,
    this.displayName,
    this.createUid,
    this.createDate,
    this.writeUid,
    this.writeDate,
  });

  factory StockMoveLineModel.fromJson(Map<String, dynamic> json) =>
      _$StockMoveLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockMoveLineModelToJson(this);
}
