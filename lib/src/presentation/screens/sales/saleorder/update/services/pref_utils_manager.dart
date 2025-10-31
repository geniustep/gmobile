import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';

/// مدير PrefUtils مع دوال مراقبة وإدارة البيانات
class PrefUtilsManager {
  // ============= مراقبة PrefUtils =============

  /// مراقبة حالة PrefUtils
  static void monitorPrefUtils() {
    if (kDebugMode) {
      print('\n📊 ========== PREFUTILS MONITOR ==========');
      print('📦 Sales Orders: ${PrefUtils.sales.length}');
      print('📋 Order Lines: ${PrefUtils.orderLine.length}');
      print('👥 Partners: ${PrefUtils.partners.length}');
      print('🛍️ Products: ${PrefUtils.products.length}');
      // print('💰 Price Lists: ${PrefUtils.priceList.length}');
      print('==========================================\n');
    }
  }

  /// مراقبة أسطر طلب معين
  static void monitorOrderLines(int orderId) {
    if (kDebugMode) {
      print('\n🔍 ========== ORDER LINES MONITOR ==========');
      print('Order ID: $orderId');

      final orderLines = PrefUtils.orderLine
          .where((line) => line.id != null)
          .toList();

      print('📋 Total Order Lines: ${orderLines.length}');

      for (final line in orderLines) {
        print('   Line: ${line.name} (ID: ${line.id})');
      }

      print('==========================================\n');
    }
  }

  // ============= حذف البيانات =============

  /// حذف طلب مع أسطره
  static void deleteOrder(int orderId) {
    if (kDebugMode) {
      print('\n🗑️ ========== DELETING ORDER ==========');
      print('Order ID: $orderId');
    }

    // حذف الطلب
    final ordersBefore = PrefUtils.sales.length;
    PrefUtils.sales.removeWhere((order) => order.id == orderId);
    final ordersAfter = PrefUtils.sales.length;

    // ✅ حذف أسطر الطلب - البحث عن الأسطر المرتبطة بالطلب
    final linesBefore = PrefUtils.orderLine.length;

    // البحث عن الأسطر المرتبطة بالطلب
    final orderLinesToDelete = <int>[];
    for (final order in PrefUtils.sales) {
      if (order.id == orderId && order.orderLine is List) {
        final orderLineList = order.orderLine as List;
        if (orderLineList.isNotEmpty && orderLineList.first is int) {
          orderLinesToDelete.addAll(orderLineList.cast<int>());
        }
      }
    }

    // حذف الأسطر المرتبطة
    PrefUtils.orderLine.removeWhere(
      (line) => orderLinesToDelete.contains(line.id),
    );

    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Order deleted: ${ordersBefore - ordersAfter}');
      print('✅ Lines deleted: ${linesBefore - linesAfter}');
      print('   Order line IDs to delete: $orderLinesToDelete');
      print('==========================================\n');
    }
  }

  /// حذف أسطر طلب معين
  static void deleteOrderLines(int orderId) {
    if (kDebugMode) {
      print('\n🗑️ ========== DELETING ORDER LINES ==========');
      print('Order ID: $orderId');
    }

    final linesBefore = PrefUtils.orderLine.length;

    // ✅ البحث عن الأسطر المرتبطة بالطلب
    final orderLinesToDelete = <int>[];
    for (final order in PrefUtils.sales) {
      if (order.id == orderId && order.orderLine is List) {
        final orderLineList = order.orderLine as List;
        if (orderLineList.isNotEmpty && orderLineList.first is int) {
          orderLinesToDelete.addAll(orderLineList.cast<int>());
        }
      }
    }

    // حذف الأسطر المرتبطة
    PrefUtils.orderLine.removeWhere(
      (line) => orderLinesToDelete.contains(line.id),
    );

    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Lines deleted: ${linesBefore - linesAfter}');
      print('   Order line IDs to delete: $orderLinesToDelete');
      print('==========================================\n');
    }
  }

  /// حذف أسطر محددة
  static void deleteSpecificOrderLines(List<int> lineIds) {
    if (kDebugMode) {
      print('\n🗑️ ========== DELETING SPECIFIC LINES ==========');
      print('Line IDs: $lineIds');
    }

    final linesBefore = PrefUtils.orderLine.length;
    PrefUtils.orderLine.removeWhere((line) => lineIds.contains(line.id));
    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Lines deleted: ${linesBefore - linesAfter}');
      print('==========================================\n');
    }
  }

  /// حذف الأسطر المرتبطة بطلب معين (بدون حذف الطلب)
  static void deleteOrderLinesByOrderId(
    int orderId, {
    List<int>? orderLineIds,
  }) {
    if (kDebugMode) {
      print('\n🗑️ ========== DELETING ORDER LINES BY ORDER ID ==========');
      print('Order ID: $orderId');
      print('Provided order line IDs: $orderLineIds');
    }

    final linesBefore = PrefUtils.orderLine.length;

    // ✅ استخدام الـ IDs المرسلة مباشرة أو البحث عنها
    final orderLinesToDelete = <int>[];

    if (orderLineIds != null && orderLineIds.isNotEmpty) {
      // استخدام الـ IDs المرسلة مباشرة
      orderLinesToDelete.addAll(orderLineIds);
    } else {
      // البحث عن الأسطر المرتبطة بالطلب
      for (final order in PrefUtils.sales) {
        if (order.id == orderId && order.orderLine is List) {
          final orderLineList = order.orderLine as List;
          if (orderLineList.isNotEmpty && orderLineList.first is int) {
            orderLinesToDelete.addAll(orderLineList.cast<int>());
          }
        }
      }
    }

    // حذف الأسطر المرتبطة
    if (orderLinesToDelete.isNotEmpty) {
      PrefUtils.orderLine.removeWhere(
        (line) => orderLinesToDelete.contains(line.id),
      );
    }

    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Lines deleted: ${linesBefore - linesAfter}');
      print('   Order line IDs to delete: $orderLinesToDelete');
      print('==========================================\n');
    }
  }

  /// حذف الأسطر المرتبطة بطلب معين باستخدام الـ IDs مباشرة
  static void deleteOrderLinesByIds(List<int> orderLineIds) {
    if (kDebugMode) {
      print('\n🗑️ ========== DELETING ORDER LINES BY IDs ==========');
      print('Order line IDs: $orderLineIds');
    }

    if (orderLineIds.isEmpty) {
      if (kDebugMode) {
        print('⚠️ No order line IDs provided');
        print('==========================================\n');
      }
      return;
    }

    final linesBefore = PrefUtils.orderLine.length;

    // حذف الأسطر المرتبطة
    PrefUtils.orderLine.removeWhere((line) => orderLineIds.contains(line.id));

    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Lines deleted: ${linesBefore - linesAfter}');
      print('   Deleted order line IDs: $orderLineIds');
      print('==========================================\n');
    }
  }

  // ============= تحديث البيانات =============

  /// تحديث طلب مع أسطره
  static Future<void> updateOrder(
    OrderModel updatedOrder,
    List<OrderLineModel> updatedLines,
  ) async {
    if (kDebugMode) {
      print('\n🔄 ========== UPDATING ORDER ==========');
      print('Order ID: ${updatedOrder.id}');
      print('Order Name: ${updatedOrder.name}');
      print('Lines Count: ${updatedLines.length}');
    }

    // ✅ 1. البحث عن الأسطر المرتبطة بالطلب قبل حذف الطلب
    final orderLinesToDelete = <int>[];
    for (final order in PrefUtils.sales) {
      if (order.id == updatedOrder.id && order.orderLine is List) {
        final orderLineList = order.orderLine as List;
        if (orderLineList.isNotEmpty && orderLineList.first is int) {
          orderLinesToDelete.addAll(orderLineList.cast<int>());
        }
      }
    }

    if (kDebugMode) {
      print('🔍 Found order lines to delete: $orderLinesToDelete');
    }

    // ✅ 2. البحث عن موقع الطلب الأصلي والحفاظ على الترتيب
    final originalIndex = PrefUtils.sales.indexWhere(
      (order) => order.id == updatedOrder.id,
    );

    if (kDebugMode) {
      print('🔍 Original index found: $originalIndex');
      print('   Total orders before update: ${PrefUtils.sales.length}');
      print('   Looking for order ID: ${updatedOrder.id}');
      print(
        '   Available order IDs: ${PrefUtils.sales.map((o) => o.id).toList()}',
      );

      // ✅ طباعة أول 5 طلبات فقط لتقليل العمليات المكثفة
      final maxLog = PrefUtils.sales.length > 5 ? 5 : PrefUtils.sales.length;
      for (int i = 0; i < maxLog; i++) {
        print(
          '   [$i] ${PrefUtils.sales[i].name} (ID: ${PrefUtils.sales[i].id})',
        );
      }
      if (PrefUtils.sales.length > 5) {
        print('   ... and ${PrefUtils.sales.length - 5} more orders');
      }
    }

    // ✅ 3. حذف الأسطر المرتبطة بالطلب أولاً
    if (orderLinesToDelete.isNotEmpty) {
      final linesBefore = PrefUtils.orderLine.length;
      PrefUtils.orderLine.removeWhere(
        (line) => orderLinesToDelete.contains(line.id),
      );
      final linesAfter = PrefUtils.orderLine.length;

      if (kDebugMode) {
        print('🗑️ Deleted ${linesBefore - linesAfter} old order lines');
        print('   Deleted order line IDs: $orderLinesToDelete');
      }
    } else {
      if (kDebugMode) {
        print('⚠️ No order lines found to delete');
      }
    }

    // ✅ 4. تحديث الطلب في موقعه الأصلي بدلاً من حذفه وإعادة إضافته
    if (originalIndex != -1) {
      // استبدال الطلب في موقعه الأصلي
      PrefUtils.sales[originalIndex] = updatedOrder;
      if (kDebugMode) {
        print('📍 Order updated at original position: $originalIndex');
        print(
          '   Order name at position $originalIndex: ${PrefUtils.sales[originalIndex].name}',
        );
        print(
          '   Order ID at position $originalIndex: ${PrefUtils.sales[originalIndex].id}',
        );
      }
    } else {
      // إضافة في النهاية إذا لم نجد الطلب
      PrefUtils.sales.add(updatedOrder);
      if (kDebugMode) {
        print('📍 Order added at end (original order not found)');
        print('   This should not happen - order should exist before update');
        print(
          '   Available order IDs: ${PrefUtils.sales.map((o) => o.id).toList()}',
        );
      }
    }

    // ✅ 5. إضافة الأسطر الجديدة
    PrefUtils.orderLine.addAll(updatedLines);

    if (kDebugMode) {
      print('✅ Order updated successfully');
      print('   New order lines added: ${updatedLines.length}');
      print('==========================================\n');
    }

    // ✅ 6. حفظ التغييرات في SharedPreferences لضمان قراءتها فوراً في الشاشات اللاحقة
    await _persistAfterUpdate();

    // ✅ 7. إجبار تحديث الواجهة المتفاعلة (فقط عند الحاجة)
    if (originalIndex != -1) {
      PrefUtils.sales.refresh();
    }
    if (updatedLines.isNotEmpty) {
      PrefUtils.orderLine.refresh();
    }

    // ✅ 8. التحقق من الترتيب النهائي (فقط أول 5 طلبات)
    if (kDebugMode) {
      print('🔍 Final order verification:');
      final maxLog = PrefUtils.sales.length > 5 ? 5 : PrefUtils.sales.length;
      for (int i = 0; i < maxLog; i++) {
        print(
          '   [$i] ${PrefUtils.sales[i].name} (ID: ${PrefUtils.sales[i].id})',
        );
      }
      if (PrefUtils.sales.length > 5) {
        print('   ... and ${PrefUtils.sales.length - 5} more orders');
      }
    }
  }

  /// حفظ قوائم PrefUtils إلى SharedPreferences بعد أي تحديث
  static Future<void> _persistAfterUpdate() async {
    try {
      await PrefUtils.saveSales(PrefUtils.sales);
      await PrefUtils.setSalesLine(PrefUtils.orderLine);
      if (kDebugMode) {
        print(
          '💾 Prefs persisted: sales=${PrefUtils.sales.length}, lines=${PrefUtils.orderLine.length}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error persisting Prefs after update: $e');
      }
    }
  }

  /// تحديث أسطر طلب معين
  static void updateOrderLines(int orderId, List<OrderLineModel> newLines) {
    if (kDebugMode) {
      print('\n🔄 ========== UPDATING ORDER LINES ==========');
      print('Order ID: $orderId');
      print('New Lines Count: ${newLines.length}');
    }

    // حذف الأسطر القديمة
    deleteOrderLines(orderId);

    // إضافة الأسطر الجديدة
    PrefUtils.orderLine.addAll(newLines);

    if (kDebugMode) {
      print('✅ Order lines updated successfully');
      print('==========================================\n');
    }
  }

  /// إضافة أسطر جديدة
  static void addOrderLines(List<OrderLineModel> newLines) {
    if (kDebugMode) {
      print('\n➕ ========== ADDING ORDER LINES ==========');
      print('New Lines Count: ${newLines.length}');
    }

    PrefUtils.orderLine.addAll(newLines);

    if (kDebugMode) {
      print('✅ Order lines added successfully');
      print('==========================================\n');
    }
  }

  // ============= البحث والفلترة =============

  /// البحث عن أسطر طلب معين
  static List<OrderLineModel> getOrderLines(int orderId) {
    final lines = PrefUtils.orderLine
        .where((line) => line.id == orderId)
        .toList();

    if (kDebugMode) {
      print('\n🔍 ========== GETTING ORDER LINES ==========');
      print('Order ID: $orderId');
      print('Found Lines: ${lines.length}');
      for (final line in lines) {
        print('   Line: ${line.name} (ID: ${line.id})');
      }
      print('==========================================\n');
    }

    return lines;
  }

  /// البحث عن أسطر محددة
  static List<OrderLineModel> getSpecificOrderLines(List<int> lineIds) {
    final lines = PrefUtils.orderLine
        .where((line) => lineIds.contains(line.id))
        .toList();

    if (kDebugMode) {
      print('\n🔍 ========== GETTING SPECIFIC LINES ==========');
      print('Line IDs: $lineIds');
      print('Found Lines: ${lines.length}');
      for (final line in lines) {
        print('   Line: ${line.name} (ID: ${line.id})');
      }
      print('==========================================\n');
    }

    return lines;
  }

  // ============= تنظيف البيانات =============

  /// تنظيف البيانات المكررة
  static void cleanDuplicateData() {
    if (kDebugMode) {
      print('\n🧹 ========== CLEANING DUPLICATE DATA ==========');
    }

    final salesBefore = PrefUtils.sales.length;
    final linesBefore = PrefUtils.orderLine.length;

    // إزالة المبيعات المكررة
    final uniqueSales = <int, OrderModel>{};
    for (final order in PrefUtils.sales) {
      if (order.id != null) {
        uniqueSales[order.id!] = order;
      }
    }
    PrefUtils.sales.clear();
    PrefUtils.sales.addAll(uniqueSales.values);

    // إزالة الأسطر المكررة
    final uniqueLines = <int, OrderLineModel>{};
    for (final line in PrefUtils.orderLine) {
      if (line.id != null) {
        uniqueLines[line.id!] = line;
      }
    }
    PrefUtils.orderLine.clear();
    PrefUtils.orderLine.addAll(uniqueLines.values);

    final salesAfter = PrefUtils.sales.length;
    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Sales cleaned: ${salesBefore - salesAfter} duplicates removed');
      print('✅ Lines cleaned: ${linesBefore - linesAfter} duplicates removed');
      print('==========================================\n');
    }
  }

  /// تنظيف البيانات القديمة
  static void cleanOldData({dynamic daysOld}) {
    if (kDebugMode) {
      print('\n🧹 ========== CLEANING OLD DATA ==========');
      print('Days old: ${daysOld ?? 'Not specified'}');
    }

    final now = DateTime.now();
    final cutoffDate = daysOld != null
        ? now.subtract(Duration(days: daysOld))
        : now.subtract(const Duration(days: 30));

    final salesBefore = PrefUtils.sales.length;
    final linesBefore = PrefUtils.orderLine.length;

    // تنظيف المبيعات القديمة
    PrefUtils.sales.removeWhere((order) {
      if (order.dateOrder == null) return false;
      return DateTime.parse(order.dateOrder!).isBefore(cutoffDate);
    });

    // تنظيف الأسطر القديمة
    PrefUtils.orderLine.removeWhere((line) {
      if (line.id == null) return false;
      // يمكن إضافة منطق أكثر تعقيداً هنا
      return false;
    });

    final salesAfter = PrefUtils.sales.length;
    final linesAfter = PrefUtils.orderLine.length;

    if (kDebugMode) {
      print('✅ Old sales cleaned: ${salesBefore - salesAfter}');
      print('✅ Old lines cleaned: ${linesBefore - linesAfter}');
      print('==========================================\n');
    }
  }
}
