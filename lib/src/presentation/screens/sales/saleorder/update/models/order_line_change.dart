// lib/src/presentation/screens/sales/saleorder/update/models/order_line_change.dart

/// يمثل تغيير في سطر طلب
class OrderLineChange {
  final String action; // 'create', 'update', 'delete'
  final dynamic lineId;
  final Map<String, dynamic>? data;
  final String? virtualId;

  const OrderLineChange._({
    required this.action,
    this.lineId,
    this.data,
    this.virtualId,
  });

  /// إنشاء سطر جديد
  factory OrderLineChange.create(Map<String, dynamic> data) {
    return OrderLineChange._(
      action: 'create',
      data: data,
      virtualId: 'virtual_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  /// تحديث سطر موجود
  factory OrderLineChange.update(int lineId, Map<String, dynamic> data) {
    return OrderLineChange._(action: 'update', lineId: lineId, data: data);
  }

  /// حذف سطر
  factory OrderLineChange.delete(int lineId) {
    return OrderLineChange._(action: 'delete', lineId: lineId);
  }

  /// تحويل إلى بيانات Odoo
  List<dynamic> toOdooData() {
    switch (action) {
      case 'create':
        return [0, virtualId, data!];
      case 'update':
        return [1, lineId, data!];
      case 'delete':
        return [2, lineId];
      default:
        throw Exception('Unknown action: $action');
    }
  }

  @override
  String toString() {
    return 'OrderLineChange(action: $action, lineId: $lineId, virtualId: $virtualId)';
  }
}
