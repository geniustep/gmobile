import 'package:json_annotation/json_annotation.dart';

part 'pricelist_model.g.dart';

// في ملف pricelist_model.dart - تحديث toJson

@JsonSerializable(explicitToJson: true)
class PricelistModel {
  @JsonKey(name: 'id')
  dynamic id;

  @JsonKey(name: 'name')
  dynamic name;

  @JsonKey(name: 'currency_id', fromJson: _currencyFromJson)
  CurrencyInfo? currencyId;

  @JsonKey(name: 'active')
  dynamic active;

  @JsonKey(name: 'country_group_ids', fromJson: _listFromJson)
  List<int>? countryGroupIds;

  @JsonKey(name: 'item_ids', fromJson: _listFromJson)
  List<int>? itemIds;

  @JsonKey(name: 'display_name')
  dynamic displayName;

  @JsonKey(includeFromJson: false, includeToJson: false)
  List<PricelistItem>? items;

  PricelistModel({
    this.id,
    this.name,
    this.currencyId,
    this.active,
    this.countryGroupIds,
    this.itemIds,
    this.displayName,
    this.items,
  });

  static CurrencyInfo? _currencyFromJson(dynamic json) {
    if (json == null || json == false) return null;
    if (json is Map<String, dynamic>) {
      return CurrencyInfo.fromJson(json);
    }
    if (json is List && json.length >= 2) {
      return CurrencyInfo(id: json[0], displayName: json[1]);
    }
    return null;
  }

  static List<int>? _listFromJson(dynamic json) {
    if (json == null) return null;
    if (json == false) return [];
    if (json is List) {
      return json.map((e) => e is int ? e : int.parse(e.toString())).toList();
    }
    return [];
  }

  factory PricelistModel.fromJson(Map<String, dynamic> json) =>
      _$PricelistModelFromJson(json);

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = _$PricelistModelToJson(this);

    // إضافة items يدوياً للحفظ في SharedPreferences
    if (items != null) {
      json['items'] = items!.map((item) => item.toJson()).toList();
    }

    return json;
  }
}

@JsonSerializable()
class CurrencyInfo {
  @JsonKey(name: 'id')
  dynamic id;

  @JsonKey(name: 'display_name')
  dynamic displayName;

  CurrencyInfo({this.id, this.displayName});

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) =>
      _$CurrencyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrencyInfoToJson(this);
}

@JsonSerializable()
class PricelistItem {
  @JsonKey(name: 'id')
  dynamic id;

  @JsonKey(name: 'product_tmpl_id')
  dynamic productTmplId;

  @JsonKey(name: 'name')
  dynamic name;

  @JsonKey(name: 'price')
  dynamic price;

  @JsonKey(name: 'min_quantity')
  dynamic minQuantity;

  @JsonKey(name: 'date_start')
  dynamic dateStart;

  @JsonKey(name: 'date_end')
  dynamic dateEnd;

  @JsonKey(name: 'base')
  dynamic base;

  @JsonKey(name: 'price_discount')
  dynamic priceDiscount;

  @JsonKey(name: 'applied_on')
  dynamic appliedOn;

  @JsonKey(name: 'compute_price')
  dynamic computePrice;

  PricelistItem({
    this.id,
    this.productTmplId,
    this.name,
    this.price,
    this.minQuantity,
    this.dateStart,
    this.dateEnd,
    this.base,
    this.priceDiscount,
    this.appliedOn,
    this.computePrice,
  });

  factory PricelistItem.fromJson(Map<String, dynamic> json) =>
      _$PricelistItemFromJson(json);

  Map<String, dynamic> toJson() => _$PricelistItemToJson(this);
}
