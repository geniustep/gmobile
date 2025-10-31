import 'package:json_annotation/json_annotation.dart';

part 'stock_location_model.g.dart';

@JsonSerializable()
class StockLocationModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'location_id')
  dynamic locationId;
  @JsonKey(name: 'active')
  dynamic active;
  @JsonKey(name: 'usage')
  dynamic usage;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'scrap_location')
  dynamic scrapLocation;
  @JsonKey(name: 'return_location')
  dynamic returnLocation;
  @JsonKey(name: 'valuation_in_account_id')
  dynamic valuationInAccountId;
  @JsonKey(name: 'valuation_out_account_id')
  dynamic valuationOutAccountId;
  @JsonKey(name: 'removal_strategy_id')
  dynamic removalStrategyId;
  @JsonKey(name: 'comment')
  dynamic comment;
  @JsonKey(name: 'complete_name')
  dynamic completeName;

  StockLocationModel({
    this.id,
    this.name,
    this.locationId,
    this.active,
    this.usage,
    this.companyId,
    this.scrapLocation,
    this.returnLocation,
    this.valuationInAccountId,
    this.valuationOutAccountId,
    this.removalStrategyId,
    this.comment,
    this.completeName,
  });

  factory StockLocationModel.fromJson(Map<String, dynamic> json) =>
      _$StockLocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$StockLocationModelToJson(this);
}
