// ════════════════════════════════════════════════════════════
// PartnerEntity - Hive Model للشركاء/العملاء
// ════════════════════════════════════════════════════════════

import 'package:hive/hive.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';

part 'partner_entity.g.dart';

@HiveType(typeId: 1)
class PartnerEntity extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? displayName;

  @HiveField(3)
  final String? email;

  @HiveField(4)
  final String? phone;

  @HiveField(5)
  final String? mobile;

  @HiveField(6)
  final String? street;

  @HiveField(7)
  final String? city;

  @HiveField(8)
  final String? country;

  @HiveField(9)
  final String? vat;

  @HiveField(10)
  final bool? isCompany;

  @HiveField(11)
  final String? image128;

  @HiveField(12)
  final double? creditLimit;

  @HiveField(13)
  final int? propertyPaymentTermId;

  @HiveField(14)
  final int? propertyProductPricelistId;

  @HiveField(15)
  final DateTime lastSync;

  PartnerEntity({
    required this.id,
    required this.name,
    this.displayName,
    this.email,
    this.phone,
    this.mobile,
    this.street,
    this.city,
    this.country,
    this.vat,
    this.isCompany,
    this.image128,
    this.creditLimit,
    this.propertyPaymentTermId,
    this.propertyProductPricelistId,
    required this.lastSync,
  });

  factory PartnerEntity.fromModel(PartnerModel model) {
    return PartnerEntity(
      id: model.id is int ? model.id : int.tryParse(model.id.toString()) ?? 0,
      name: model.name?.toString() ?? '',
      displayName: model.displayName?.toString(),
      email: model.email?.toString(),
      phone: model.phone?.toString(),
      mobile: model.mobile?.toString(),
      street: model.street?.toString(),
      city: model.city?.toString(),
      country: model.countryId is List
          ? (model.countryId as List).length > 1
                ? (model.countryId as List)[1].toString()
                : null
          : null,
      vat: model.vat?.toString(),
      isCompany: model.isCompany is bool ? model.isCompany : false,
      image128: model.image_128?.toString(),
      creditLimit: _toDouble(model.credit),
      propertyPaymentTermId: model.propertyPaymentTermId is List
          ? (model.propertyPaymentTermId as List).isNotEmpty
                ? _toInt((model.propertyPaymentTermId as List)[0])
                : null
          : _toInt(model.propertyPaymentTermId),
      propertyProductPricelistId: model.propertyProductPricelist is List
          ? (model.propertyProductPricelist as List).isNotEmpty
                ? _toInt((model.propertyProductPricelist as List)[0])
                : null
          : _toInt(model.propertyProductPricelist),
      lastSync: DateTime.now(),
    );
  }

  PartnerModel toModel() {
    return PartnerModel(
      id: id,
      name: name,
      displayName: displayName,
      email: email,
      phone: phone,
      mobile: mobile,
      street: street,
      city: city,
      vat: vat,
      isCompany: isCompany,
      image_128: image128,
      credit: creditLimit,
      propertyPaymentTermId: propertyPaymentTermId,
      propertyProductPricelist: propertyProductPricelistId,
    );
  }

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

  bool matchesSearch(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        (displayName?.toLowerCase().contains(lowerQuery) ?? false) ||
        (email?.toLowerCase().contains(lowerQuery) ?? false) ||
        (phone?.toLowerCase().contains(lowerQuery) ?? false) ||
        (mobile?.toLowerCase().contains(lowerQuery) ?? false);
  }

  bool isExpired(Duration validity) {
    return DateTime.now().difference(lastSync) > validity;
  }
}
