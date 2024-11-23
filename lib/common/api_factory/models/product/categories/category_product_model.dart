import 'package:json_annotation/json_annotation.dart';

part 'category_product_model.g.dart';

@JsonSerializable()
class ProductCategoryModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'product_count')
  dynamic productCount;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'display_name')
  dynamic displayName;
  @JsonKey(name: 'parent_id')
  dynamic parentId;
  @JsonKey(name: 'route_ids')
  dynamic routeIds;
  @JsonKey(name: 'total_route_ids')
  dynamic totalRouteIds;
  @JsonKey(name: 'removal_strategy_id')
  dynamic removalStrategyId;
  @JsonKey(name: 'property_cost_method')
  dynamic propertyCostMethod;
  @JsonKey(name: 'property_valuation')
  dynamic propertyValuation;
  @JsonKey(name: 'property_account_creditor_price_difference_categ')
  dynamic propertyAccountCreditorPriceDifferenceCateg;
  @JsonKey(name: 'property_account_income_categ_id')
  dynamic propertyCccountIncomeCategId;
  @JsonKey(name: 'property_account_expense_categ_id')
  dynamic propertyAccountExpenseCategId;
  @JsonKey(name: 'property_stock_account_input_categ_id')
  dynamic propertyStockAccountInputCategId;
  @JsonKey(name: 'property_stock_account_output_categ_id')
  dynamic propertyStockAccountOutputCategId;
  @JsonKey(name: 'property_stock_valuation_account_id')
  dynamic propertyStockValuationAccountId;
  @JsonKey(name: 'property_stock_journal')
  dynamic propertyStockJournal;

  ProductCategoryModel({
    this.id,
    this.productCount,
    this.name,
    this.displayName,
    this.parentId,
    this.routeIds,
    this.totalRouteIds,
    this.removalStrategyId,
    this.propertyCostMethod,
    this.propertyValuation,
    this.propertyAccountCreditorPriceDifferenceCateg,
    this.propertyCccountIncomeCategId,
    this.propertyAccountExpenseCategId,
    this.propertyStockAccountInputCategId,
    this.propertyStockAccountOutputCategId,
    this.propertyStockValuationAccountId,
    this.propertyStockJournal,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$ProductCategoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductCategoryModelToJson(this);
}
