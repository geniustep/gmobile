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
      partnerId: model.partner_id is List
          ? (model.partner_id as List).isNotEmpty
              ? _toInt((model.partner_id as List)[0])
              : null
          : _toInt(model.partner_id),
      partnerName: model.partner_id is List
          ? (model.partner_id as List).length > 1
              ? (model.partner_id as List)[1].toString()
              : null
          : null,
      dateOrder: model.date_order?.toString(),
      amountTotal: _toDouble(model.amount_total),
      amountUntaxed: _toDouble(model.amount_untaxed),
      amountTax: _toDouble(model.amount_tax),
      state: model.state?.toString(),
      pricelistId: model.pricelist_id is List
          ? (model.pricelist_id as List).isNotEmpty
              ? _toInt((model.pricelist_id as List)[0])
              : null
          : _toInt(model.pricelist_id),
      paymentTermId: model.payment_term_id is List
          ? (model.payment_term_id as List).isNotEmpty
              ? _toInt((model.payment_term_id as List)[0])
              : null
          : _toInt(model.payment_term_id),
      note: model.note?.toString(),
      orderLineIds: model.order_line is List
          ? (model.order_line as List)
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
      partner_id: partnerId != null ? [partnerId, partnerName] : null,
      date_order: dateOrder,
      amount_total: amountTotal,
      amount_untaxed: amountUntaxed,
      amount_tax: amountTax,
      state: state,
      pricelist_id: pricelistId,
      payment_term_id: paymentTermId,
      note: note,
      order_line: orderLineIds,
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
