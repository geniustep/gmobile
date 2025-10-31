import 'package:json_annotation/json_annotation.dart';

part 'stock_quant_model.g.dart';

@JsonSerializable()
class StockQuantModel {
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'product_tmpl_id')
  dynamic productTmplId;
  @JsonKey(name: 'product_uom_id')
  dynamic productUomId;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'location_id')
  dynamic locationId;
  @JsonKey(name: 'lot_id')
  dynamic lotId;
  @JsonKey(name: 'package_id')
  dynamic packageId;
  @JsonKey(name: 'owner_id')
  dynamic ownerId;
  @JsonKey(name: 'quantity')
  dynamic quantity;
  @JsonKey(name: 'inventory_quantity')
  dynamic inventoryQuantity;
  @JsonKey(name: 'reserved_quantity')
  dynamic reservedQuantity;
  @JsonKey(name: 'in_date')
  dynamic inDate;
  @JsonKey(name: 'tracking')
  dynamic tracking;
  @JsonKey(name: 'on_hand')
  dynamic onHand;
  @JsonKey(name: 'value')
  dynamic value;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'id')
  dynamic id;
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
  @JsonKey(name: '__last_update')
  dynamic pLastUpdate;

  StockQuantModel({
    this.productId,
    this.productTmplId,
    this.productUomId,
    this.companyId,
    this.locationId,
    this.lotId,
    this.packageId,
    this.ownerId,
    this.quantity,
    this.inventoryQuantity,
    this.reservedQuantity,
    this.inDate,
    this.tracking,
    this.onHand,
    this.value,
    this.currencyId,
    this.id,
    this.displayName,
    this.createUid,
    this.createDate,
    this.writeUid,
    this.writeDate,
    this.pLastUpdate,
  });

  factory StockQuantModel.fromJson(Map<String, dynamic> json) =>
      _$StockQuantModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockQuantModelToJson(this);
}
