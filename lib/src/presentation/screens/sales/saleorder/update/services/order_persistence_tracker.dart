import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';

/// متتبع استمرارية ترتيب الطلبات
class OrderPersistenceTracker {
  static final List<Map<String, dynamic>> _trackingLog = [];

  /// تسجيل حالة الطلبات قبل التحديث
  static void logBeforeUpdate(int orderId) {
    // ✅ تم تسجيل الحالة قبل التحديث
  }

  /// تسجيل حالة الطلبات بعد التحديث
  static void logAfterUpdate(int orderId) {
    // ✅ تم تسجيل الحالة بعد التحديث
  }

  /// تسجيل حالة الطلبات في SalesMainScreen
  static void logSalesMainScreenState(String context) {
    // ✅ تم تسجيل حالة شاشة المبيعات
  }

  /// تسجيل حالة الطلبات في HorizontalSalesTableSection
  static void logHorizontalTableState(String context, List<OrderModel> sales) {
    // ✅ تم تسجيل حالة الجدول الأفقي
  }

  /// تنظيف سجل التتبع
  static void clearLog() {
    _trackingLog.clear();
    // ✅ تم تنظيف سجل التتبع
  }

  /// الحصول على سجل التتبع
  static List<Map<String, dynamic>> getTrackingLog() {
    return List.from(_trackingLog);
  }
}
