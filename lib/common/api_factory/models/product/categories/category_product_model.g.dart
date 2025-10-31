// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductCategoryModel _$ProductCategoryModelFromJson(
  Map<String, dynamic> json,
) => ProductCategoryModel(
  id: json['id'],
  productCount: json['product_count'],
  name: json['name'],
  displayName: json['display_name'],
  parentId: json['parent_id'],
  routeIds: json['route_ids'],
  totalRouteIds: json['total_route_ids'],
  removalStrategyId: json['removal_strategy_id'],
  propertyCostMethod: json['property_cost_method'],
  propertyValuation: json['property_valuation'],
  propertyAccountCreditorPriceDifferenceCateg:
      json['property_account_creditor_price_difference_categ'],
  propertyCccountIncomeCategId: json['property_account_income_categ_id'],
  propertyAccountExpenseCategId: json['property_account_expense_categ_id'],
  propertyStockAccountInputCategId:
      json['property_stock_account_input_categ_id'],
  propertyStockAccountOutputCategId:
      json['property_stock_account_output_categ_id'],
  propertyStockValuationAccountId: json['property_stock_valuation_account_id'],
  propertyStockJournal: json['property_stock_journal'],
);

Map<String, dynamic> _$ProductCategoryModelToJson(
  ProductCategoryModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'product_count': instance.productCount,
  'name': instance.name,
  'display_name': instance.displayName,
  'parent_id': instance.parentId,
  'route_ids': instance.routeIds,
  'total_route_ids': instance.totalRouteIds,
  'removal_strategy_id': instance.removalStrategyId,
  'property_cost_method': instance.propertyCostMethod,
  'property_valuation': instance.propertyValuation,
  'property_account_creditor_price_difference_categ':
      instance.propertyAccountCreditorPriceDifferenceCateg,
  'property_account_income_categ_id': instance.propertyCccountIncomeCategId,
  'property_account_expense_categ_id': instance.propertyAccountExpenseCategId,
  'property_stock_account_input_categ_id':
      instance.propertyStockAccountInputCategId,
  'property_stock_account_output_categ_id':
      instance.propertyStockAccountOutputCategId,
  'property_stock_valuation_account_id':
      instance.propertyStockValuationAccountId,
  'property_stock_journal': instance.propertyStockJournal,
};
