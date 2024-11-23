// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'],
      lst_price: json['lst_price'],
      active: json['active'],
      barcode: json['barcode'],
      is_product_variant: json['is_product_variant'],
      standard_price: json['standard_price'],
      volume: json['volume'],
      weight: json['weight'],
      packaging_ids: json['packaging_ids'],
      image_512: json['image_512'],
      write_date: json['write_date'],
      display_name: json['display_name'],
      create_uid: json['create_uid'],
      create_date: json['create_date'],
      write_uid: json['write_uid'],
      description: json['description'],
      list_price: json['list_price'],
      name: json['name'],
      total_value: json['total_value'],
      sales_count: json['sales_count'],
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'lst_price': instance.lst_price,
      'active': instance.active,
      'barcode': instance.barcode,
      'is_product_variant': instance.is_product_variant,
      'standard_price': instance.standard_price,
      'volume': instance.volume,
      'weight': instance.weight,
      'packaging_ids': instance.packaging_ids,
      'image_512': instance.image_512,
      'write_date': instance.write_date,
      'display_name': instance.display_name,
      'create_uid': instance.create_uid,
      'create_date': instance.create_date,
      'write_uid': instance.write_uid,
      'description': instance.description,
      'list_price': instance.list_price,
      'name': instance.name,
      'total_value': instance.total_value,
      'sales_count': instance.sales_count,
    };
