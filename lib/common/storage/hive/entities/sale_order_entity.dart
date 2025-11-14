// ════════════════════════════════════════════════════════════
// SaleOrderEntity - Hive Model للمبيعات
// ════════════════════════════════════════════════════════════

import 'package:hive/hive.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';

part 'sale_order_entity.g.dart';

@HiveType(typeId: 2)
class SaleOrderEntity extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int? partnerId;

  @HiveField(3)
  final String? partnerName;

  @HiveField(4)
  final String? dateOrder;

  @HiveField(5)
  final double? amountTotal;

  @HiveField(6)
  final double? amountUntaxed;

  @HiveField(7)
  final double? amountTax;

  @HiveField(8)
  final String? state;

  @HiveField(9)
  final int? pricelistId;

  @HiveField(10)
  final int? paymentTermId;

  @HiveField(11)
  final String? note;

  @HiveField(12)
  final List<int>? orderLineIds;

  @HiveField(13)
  final DateTime lastSync;

  SaleOrderEntity({
    required this.id,
    required this.name,
    this.partnerId,
    this.partnerName,
    this.dateOrder,
    this.amountTotal,
    this.amountUntaxed,
    this.amountTax,
    this.state,
    this.pricelistId,
    this.paymentTermId,
    this.note,
    this.orderLineIds,
    required this.lastSync,
  });

  factory SaleOrderEntity.fromModel(OrderModel model) {
    return SaleOrderEntity(
      id: model.id is int ? model.id : int.tryParse(model.id.toString()) ?? 0,
      name: model.name?.toString() ?? '',
      partnerId: model.partnerId is List
          ? (model.partnerId as List).isNotEmpty
              ? _toInt((model.partnerId as List)[0])
              : null
          : _toInt(model.partnerId),
      partnerName: model.partnerId is List
          ? (model.partnerId as List).length > 1
              ? (model.partnerId as List)[1].toString()
              : null
          : null,
      dateOrder: model.dateOrder?.toString(),
      amountTotal: _toDouble(model.amountTotal),
      amountUntaxed: _toDouble(model.amountUntaxed),
      amountTax: _toDouble(model.amountTax),
      state: model.state?.toString(),
      pricelistId: model.pricelistId is List
          ? (model.pricelistId as List).isNotEmpty
              ? _toInt((model.pricelistId as List)[0])
              : null
          : _toInt(model.pricelistId),
      paymentTermId: model.paymentTermId is List
          ? (model.paymentTermId as List).isNotEmpty
              ? _toInt((model.paymentTermId as List)[0])
              : null
          : _toInt(model.paymentTermId),
      note: model.note?.toString(),
      orderLineIds: model.orderLine is List
          ? (model.orderLine as List)
              .map((e) => _toInt(e))
              .whereType<int>()
              .toList()
          : null,
      lastSync: DateTime.now(),
    );
  }

  OrderModel toModel() {
    return OrderModel(
      id: id,
      name: name,
      partnerId: partnerId != null ? [partnerId, partnerName] : null,
      dateOrder: dateOrder,
      amountTotal: amountTotal,
      amountUntaxed: amountUntaxed,
      amountTax: amountTax,
      state: state,
      pricelistId: pricelistId,
      paymentTermId: paymentTermId,
      note: note,
      orderLine: orderLineIds,
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

  bool isExpired(Duration validity) {
    return DateTime.now().difference(lastSync) > validity;
  }
}
