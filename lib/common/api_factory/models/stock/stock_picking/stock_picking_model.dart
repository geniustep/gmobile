import 'package:json_annotation/json_annotation.dart';

part 'stock_picking_model.g.dart';

@JsonSerializable()
class StockPickingModel {
  dynamic id;
  dynamic isLocked;
  @JsonKey(name: 'show_mark_as_todo')
  dynamic showMarkAsTodo;
  @JsonKey(name: 'show_check_availability')
  dynamic showCheckAvailability;
  @JsonKey(name: 'show_validate')
  dynamic showValidate;
  @JsonKey(name: 'show_lots_text')
  dynamic showLotsText;
  @JsonKey(name: 'immediate_transfer')
  dynamic immediateTransfer;
  @JsonKey(name: 'show_operations')
  dynamic showOperations;
  @JsonKey(name: 'show_reserved')
  dynamic showReserved;
  @JsonKey(name: 'move_line_exist')
  dynamic moveLineExist;
  @JsonKey(name: 'has_packages')
  dynamic hasPackages;
  String? state;
  @JsonKey(name: 'picking_type_entire_packs')
  dynamic pickingTypeEntirePacks;
  @JsonKey(name: 'has_scrap_move')
  dynamic hasScrapMove;
  @JsonKey(name: 'has_tracking')
  dynamic hasTracking;
  String? name;
  @JsonKey(name: 'partner_id')
  dynamic partnerId;
  @JsonKey(name: 'picking_type_id')
  dynamic pickingTypeId;
  @JsonKey(name: 'location_id')
  dynamic locationId;
  @JsonKey(name: 'location_dest_id')
  dynamic locationDestId;
  @JsonKey(name: 'backorder_id')
  dynamic backorderId;
  @JsonKey(name: 'scheduled_date')
  String? scheduledDate;
  @JsonKey(name: 'date_done')
  dynamic dateDone;
  dynamic origin;
  @JsonKey(name: 'owner_id')
  dynamic ownerId;
  @JsonKey(name: 'move_line_nosuggest_ids')
  dynamic moveLineNosuggestIds;
  @JsonKey(name: 'package_level_ids_details')
  dynamic packageLevelIdsDetails;
  @JsonKey(name: 'move_line_ids_without_package')
  List<dynamic>? moveLineIdsWithoutPackage;
  @JsonKey(name: 'move_ids_without_package')
  List<dynamic>? moveIdsWithoutPackage;
  @JsonKey(name: 'package_level_ids')
  dynamic packageLevelIds;
  @JsonKey(name: 'picking_type_code')
  String? pickingTypeCode;
  @JsonKey(name: 'move_type')
  String? moveType;
  String? priority;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'group_id')
  dynamic groupId;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  dynamic note;
  @JsonKey(name: 'message_follower_ids')
  dynamic messageFollowerIds;
  @JsonKey(name: 'activity_ids')
  dynamic activityIds;
  @JsonKey(name: 'message_ids')
  dynamic messageIds;
  @JsonKey(name: 'message_attachment_count')
  dynamic messageAttachmentCount;
  @JsonKey(name: 'display_name')
  String? displayName;
  @JsonKey(name: 'stock_move_line')
  dynamic stockMoveLine;

  // الحقول المفقودة من JSON response
  @JsonKey(name: 'return_count')
  dynamic returnCount;
  @JsonKey(name: 'json_popover')
  dynamic jsonPopover;
  @JsonKey(name: 'date_deadline')
  dynamic dateDeadline;
  @JsonKey(name: 'products_availability_state')
  dynamic productsAvailabilityState;
  @JsonKey(name: 'products_availability')
  dynamic productsAvailability;
  @JsonKey(name: 'picking_properties')
  List<dynamic>? pickingProperties;
  @JsonKey(name: 'show_next_pickings')
  dynamic showNextPickings;
  @JsonKey(name: 'sale_id')
  dynamic saleId;

  // ✅ حقول إضافية من move_ids_without_package
  @JsonKey(name: 'is_quantity_done_editable')
  dynamic isQuantityDoneEditable;
  @JsonKey(name: 'is_initial_demand_editable')
  dynamic isInitialDemandEditable;
  @JsonKey(name: 'forecast_availability')
  double? forecastAvailability;
  @JsonKey(name: 'forecast_expected_date')
  dynamic forecastExpectedDate;
  @JsonKey(name: 'is_storable')
  dynamic isStorable;
  @JsonKey(name: 'scrapped')
  dynamic scrapped;
  @JsonKey(name: 'picking_code')
  String? pickingCode;
  @JsonKey(name: 'show_details_visible')
  dynamic showDetailsVisible;
  @JsonKey(name: 'additional')
  dynamic additional;
  @JsonKey(name: 'move_lines_count')
  dynamic moveLinesCount;
  @JsonKey(name: 'product_uom_category_id')
  dynamic productUomCategoryId;
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'description_picking')
  String? descriptionPicking;
  @JsonKey(name: 'date')
  String? date;
  @JsonKey(name: 'product_uom_qty')
  double? productUomQty;
  @JsonKey(name: 'product_qty')
  double? productQty;
  @JsonKey(name: 'quantity')
  double? quantity;
  @JsonKey(name: 'product_uom')
  dynamic productUom;
  @JsonKey(name: 'picked')
  dynamic picked;
  @JsonKey(name: 'show_quant')
  dynamic showQuant;
  @JsonKey(name: 'show_lots_m2o')
  dynamic showLotsM2o;
  @JsonKey(name: 'display_import_lot')
  dynamic displayImportLot;

  StockPickingModel({
    this.id,
    this.isLocked,
    this.showMarkAsTodo,
    this.showCheckAvailability,
    this.showValidate,
    this.showLotsText,
    this.immediateTransfer,
    this.showOperations,
    this.showReserved,
    this.moveLineExist,
    this.hasPackages,
    this.state,
    this.pickingTypeEntirePacks,
    this.hasScrapMove,
    this.hasTracking,
    this.name,
    this.partnerId,
    this.pickingTypeId,
    this.locationId,
    this.locationDestId,
    this.backorderId,
    this.scheduledDate,
    this.dateDone,
    this.origin,
    this.ownerId,
    this.moveLineNosuggestIds,
    this.packageLevelIdsDetails,
    this.moveLineIdsWithoutPackage,
    this.moveIdsWithoutPackage,
    this.packageLevelIds,
    this.pickingTypeCode,
    this.moveType,
    this.priority,
    this.userId,
    this.groupId,
    this.companyId,
    this.note,
    this.messageFollowerIds,
    this.activityIds,
    this.messageIds,
    this.messageAttachmentCount,
    this.displayName,
    this.stockMoveLine,
    this.returnCount,
    this.jsonPopover,
    this.dateDeadline,
    this.productsAvailabilityState,
    this.productsAvailability,
    this.pickingProperties,
    this.showNextPickings,
    this.saleId,
    this.isQuantityDoneEditable,
    this.isInitialDemandEditable,
    this.forecastAvailability,
    this.forecastExpectedDate,
    this.isStorable,
    this.scrapped,
    this.pickingCode,
    this.showDetailsVisible,
    this.additional,
    this.moveLinesCount,
    this.productUomCategoryId,
    this.productId,
    this.descriptionPicking,
    this.date,
    this.productUomQty,
    this.productQty,
    this.quantity,
    this.productUom,
    this.picked,
    this.showQuant,
    this.showLotsM2o,
    this.displayImportLot,
  });

  factory StockPickingModel.fromJson(Map<String, dynamic> json) =>
      _$StockPickingModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockPickingModelToJson(this);
}

@JsonSerializable()
class StockImmediatTransfer {
  dynamic id;
  @JsonKey(name: '__last_update')
  dynamic lastUpdate;
  @JsonKey(name: 'create_date')
  dynamic createDate;
  @JsonKey(name: 'create_uid')
  dynamic createUid;
  @JsonKey(name: 'display_name')
  String? displayName;
  @JsonKey(name: 'pick_ids')
  dynamic pickIds;
  @JsonKey(name: 'write_date')
  dynamic writeDate;
  @JsonKey(name: 'write_uid')
  dynamic writeUid;

  StockImmediatTransfer({
    this.id,
    this.lastUpdate,
    this.createDate,
    this.createUid,
    this.displayName,
    this.pickIds,
    this.writeDate,
    this.writeUid,
  });

  factory StockImmediatTransfer.fromJson(Map<String, dynamic> json) =>
      _$StockImmediatTransferFromJson(json);

  Map<String, dynamic> toJson() => _$StockImmediatTransferToJson(this);
}
