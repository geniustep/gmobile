import 'package:json_annotation/json_annotation.dart';

part 'stock_move_model.g.dart';

@JsonSerializable()
class StockMoveModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'company_id')
  List<int>? companyId;
  @JsonKey(name: 'name')
  String? name;
  @JsonKey(name: 'state')
  String? state;
  @JsonKey(name: 'picking_type_id')
  List<int>? pickingTypeId;
  @JsonKey(name: 'location_id')
  List<int>? locationId;
  @JsonKey(name: 'location_dest_id')
  List<int>? locationDestId;
  @JsonKey(name: 'scrapped')
  bool? scrapped;
  @JsonKey(name: 'picking_code')
  String? pickingCode;
  @JsonKey(name: 'product_type')
  String? productType;
  @JsonKey(name: 'show_details_visible')
  bool? showDetailsVisible;
  @JsonKey(name: 'show_reserved_availability')
  bool? showReservedAvailability;
  @JsonKey(name: 'show_operations')
  bool? showOperations;
  @JsonKey(name: 'additional')
  bool? additional;
  @JsonKey(name: 'has_move_lines')
  bool? hasMoveLines;
  @JsonKey(name: 'is_locked')
  bool? isLocked;
  @JsonKey(name: 'product_uom_category_id')
  List<int>? productUomCategoryId;
  @JsonKey(name: 'has_tracking')
  String? hasTracking;
  @JsonKey(name: 'display_assign_serial')
  bool? displayAssignSerial;
  @JsonKey(name: 'product_id')
  List<int>? productId;
  @JsonKey(name: 'description_picking')
  dynamic descriptionPicking;
  @JsonKey(name: 'date_expected')
  String? dateExpected;
  @JsonKey(name: 'is_initial_demand_editable')
  bool? isInitialDemandEditable;
  @JsonKey(name: 'is_quantity_done_editable')
  bool? isQuantityDoneEditable;
  @JsonKey(name: 'product_uom_qty')
  double? productUomQty;
  @JsonKey(name: 'reserved_availability')
  double? reservedAvailability;
  @JsonKey(name: 'quantity_done')
  double? quantityDone;
  @JsonKey(name: 'product_uom')
  List<int>? productUom;

  StockMoveModel({
    this.id,
    this.companyId,
    this.name,
    this.state,
    this.pickingTypeId,
    this.locationId,
    this.locationDestId,
    this.scrapped,
    this.pickingCode,
    this.productType,
    this.showDetailsVisible,
    this.showReservedAvailability,
    this.showOperations,
    this.additional,
    this.hasMoveLines,
    this.isLocked,
    this.productUomCategoryId,
    this.hasTracking,
    this.displayAssignSerial,
    this.productId,
    this.descriptionPicking,
    this.dateExpected,
    this.isInitialDemandEditable,
    this.isQuantityDoneEditable,
    this.productUomQty,
    this.reservedAvailability,
    this.quantityDone,
    this.productUom,
  });

  factory StockMoveModel.fromJson(Map<String, dynamic> json) =>
      _$StockMoveModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockMoveModelToJson(this);
}
