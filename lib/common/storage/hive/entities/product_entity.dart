// ════════════════════════════════════════════════════════════
// ProductEntity - Hive Model للمنتجات
// ════════════════════════════════════════════════════════════

import 'package:hive/hive.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';

part 'product_entity.g.dart';

@HiveType(typeId: 0)
class ProductEntity extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final double? listPrice;

  @HiveField(4)
  final double? standardPrice;

  @HiveField(5)
  final String? barcode;

  @HiveField(6)
  final String? defaultCode;

  @HiveField(7)
  final double? qtyAvailable;

  @HiveField(8)
  final double? virtualAvailable;

  @HiveField(9)
  final int? categId;

  @HiveField(10)
  final String? image128;

  @HiveField(11)
  final bool? active;

  @HiveField(12)
  final String? type;

  @HiveField(13)
  final String? uomName;

  @HiveField(14)
  final DateTime lastSync;

  ProductEntity({
    required this.id,
    required this.name,
    this.displayName,
    this.listPrice,
    this.standardPrice,
    this.barcode,
    this.defaultCode,
    this.qtyAvailable,
    this.virtualAvailable,
    this.categId,
    this.image128,
    this.active,
    this.type,
    this.uomName,
    required this.lastSync,
  });

  // ════════════════════════════════════════════════════════════
  // Conversion من ProductModel إلى ProductEntity
  // ════════════════════════════════════════════════════════════
  factory ProductEntity.fromModel(ProductModel model) {
    return ProductEntity(
      id: model.id is int ? model.id : int.tryParse(model.id.toString()) ?? 0,
      name: model.name?.toString() ?? '',
      displayName: model.display_name?.toString(),
      listPrice: _toDouble(model.list_price),
      standardPrice: _toDouble(model.standard_price),
      barcode: model.barcode?.toString(),
      defaultCode: model.default_code?.toString(),
      qtyAvailable: _toDouble(model.qty_available),
      virtualAvailable: _toDouble(model.virtual_available),
      categId: model.categ_id is List
          ? (model.categ_id as List).isNotEmpty
              ? _toInt((model.categ_id as List)[0])
              : null
          : _toInt(model.categ_id),
      image128: model.image_128?.toString(),
      active: model.active is bool ? model.active : true,
      type: model.type?.toString(),
      uomName: model.uom_name?.toString(),
      lastSync: DateTime.now(),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Conversion من ProductEntity إلى ProductModel
  // ════════════════════════════════════════════════════════════
  ProductModel toModel() {
    return ProductModel(
      id: id,
      name: name,
      display_name: displayName,
      list_price: listPrice,
      standard_price: standardPrice,
      barcode: barcode,
      default_code: defaultCode,
      qty_available: qtyAvailable,
      virtual_available: virtualAvailable,
      categ_id: categId,
      image_128: image128,
      active: active,
      type: type,
      uom_name: uomName,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════
  static double? _toDouble(dynamic value) {
    if (value == null || value == false) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value == null || value == false) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // ════════════════════════════════════════════════════════════
  // للبحث والفلترة
  // ════════════════════════════════════════════════════════════
  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        (displayName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (barcode?.toLowerCase().contains(lowerQuery) ?? false) ||
        (defaultCode?.toLowerCase().contains(lowerQuery) ?? false);
  }

  bool isExpired(Duration validity) {
    return DateTime.now().difference(lastSync) > validity;
  }
}
