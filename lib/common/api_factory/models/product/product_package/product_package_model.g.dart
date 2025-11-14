// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductPackageModel _$ProductPackageModelFromJson(Map<String, dynamic> json) =>
    ProductPackageModel(
      name: json['name'],
      displayName: json['display_name'],
      id: json['id'],
      qty: json['qty'],
      productUomId: json['product_uom_id'],
      productId: json['product_id'],
      barcode: json['barcode'],
      companyId: json['company_id'],
    );

Map<String, dynamic> _$ProductPackageModelToJson(
        ProductPackageModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'display_name': instance.displayName,
      'id': instance.id,
      'qty': instance.qty,
      'product_uom_id': instance.productUomId,
      'product_id': instance.productId,
      'barcode': instance.barcode,
      'company_id': instance.companyId,
    };
