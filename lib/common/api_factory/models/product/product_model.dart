import 'package:json_annotation/json_annotation.dart';

part 'product_model.g.dart';

@JsonSerializable()
class ProductModel {
  final dynamic id;
  final dynamic lst_price;
  final dynamic active;
  final dynamic barcode;
  final dynamic is_product_variant;
  final dynamic standard_price;
  final dynamic volume;
  final dynamic weight;
  final dynamic packaging_ids;
  final dynamic image_128;
  final dynamic write_date;
  final dynamic display_name;
  final dynamic create_uid;
  final dynamic create_date;
  final dynamic write_uid;
  final dynamic description;
  final dynamic list_price;
  final dynamic name;
  final dynamic total_value;
  final dynamic sales_count;

  ProductModel({
    this.id,
    this.lst_price,
    this.active,
    this.barcode,
    this.is_product_variant,
    this.standard_price,
    this.volume,
    this.weight,
    this.packaging_ids,
    this.image_128,
    this.write_date,
    this.display_name,
    this.create_uid,
    this.create_date,
    this.write_uid,
    this.description,
    this.list_price,
    this.name,
    this.total_value,
    this.sales_count,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);
}
