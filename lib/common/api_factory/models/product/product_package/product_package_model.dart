import 'package:json_annotation/json_annotation.dart';

part 'product_package_model.g.dart';

@JsonSerializable()
class ProductPackageModel {
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'display_name')
  dynamic displayName;
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'qty')
  dynamic qty;
  @JsonKey(name: 'product_uom_id')
  dynamic productUomId;
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'barcode')
  dynamic barcode;
  @JsonKey(name: 'company_id')
  dynamic companyId;

  ProductPackageModel({
    this.name,
    this.displayName,
    this.id,
    this.qty,
    this.productUomId,
    this.productId,
    this.barcode,
    this.companyId,
  });

  factory ProductPackageModel.fromJson(Map<String, dynamic> json) =>
      _$ProductPackageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductPackageModelToJson(this);
}
