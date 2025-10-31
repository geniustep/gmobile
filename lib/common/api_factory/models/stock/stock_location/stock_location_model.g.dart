// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stock_location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StockLocationModel _$StockLocationModelFromJson(Map<String, dynamic> json) =>
    StockLocationModel(
      id: json['id'],
      name: json['name'],
      locationId: json['location_id'],
      active: json['active'],
      usage: json['usage'],
      companyId: json['company_id'],
      scrapLocation: json['scrap_location'],
      returnLocation: json['return_location'],
      valuationInAccountId: json['valuation_in_account_id'],
      valuationOutAccountId: json['valuation_out_account_id'],
      removalStrategyId: json['removal_strategy_id'],
      comment: json['comment'],
      completeName: json['complete_name'],
    );

Map<String, dynamic> _$StockLocationModelToJson(StockLocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'location_id': instance.locationId,
      'active': instance.active,
      'usage': instance.usage,
      'company_id': instance.companyId,
      'scrap_location': instance.scrapLocation,
      'return_location': instance.returnLocation,
      'valuation_in_account_id': instance.valuationInAccountId,
      'valuation_out_account_id': instance.valuationOutAccountId,
      'removal_strategy_id': instance.removalStrategyId,
      'comment': instance.comment,
      'complete_name': instance.completeName,
    };
