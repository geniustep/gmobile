// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricelist_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PricelistModel _$PricelistModelFromJson(Map<String, dynamic> json) =>
    PricelistModel(
      id: json['id'],
      name: json['name'],
      currencyId: PricelistModel._currencyFromJson(json['currency_id']),
      active: json['active'],
      countryGroupIds: PricelistModel._listFromJson(json['country_group_ids']),
      itemIds: PricelistModel._listFromJson(json['item_ids']),
      displayName: json['display_name'],
    );

Map<String, dynamic> _$PricelistModelToJson(PricelistModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'currency_id': instance.currencyId?.toJson(),
      'active': instance.active,
      'country_group_ids': instance.countryGroupIds,
      'item_ids': instance.itemIds,
      'display_name': instance.displayName,
    };

CurrencyInfo _$CurrencyInfoFromJson(Map<String, dynamic> json) =>
    CurrencyInfo(id: json['id'], displayName: json['display_name']);

Map<String, dynamic> _$CurrencyInfoToJson(CurrencyInfo instance) =>
    <String, dynamic>{'id': instance.id, 'display_name': instance.displayName};

PricelistItem _$PricelistItemFromJson(Map<String, dynamic> json) =>
    PricelistItem(
      id: json['id'],
      productTmplId: json['product_tmpl_id'],
      name: json['name'],
      price: json['price'],
      minQuantity: json['min_quantity'],
      dateStart: json['date_start'],
      dateEnd: json['date_end'],
      base: json['base'],
      priceDiscount: json['price_discount'],
      appliedOn: json['applied_on'],
      computePrice: json['compute_price'],
    );

Map<String, dynamic> _$PricelistItemToJson(PricelistItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'product_tmpl_id': instance.productTmplId,
      'name': instance.name,
      'price': instance.price,
      'min_quantity': instance.minQuantity,
      'date_start': instance.dateStart,
      'date_end': instance.dateEnd,
      'base': instance.base,
      'price_discount': instance.priceDiscount,
      'applied_on': instance.appliedOn,
      'compute_price': instance.computePrice,
    };
