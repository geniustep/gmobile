// lib/src/presentation/screens/sales/saleorder/update/services/order_line_change_tracker.dart

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/models/order_line_change.dart';

class OrderLineChangeTracker {
  // ============= Compare Order Lines =============

  /// مقارنة السطور القديمة والجديدة وإرجاع التغييرات
  static List<OrderLineChange> compareOrderLines({
    required List<OrderLineModel> originalLines,
    required List<ProductLine> currentLines,
  }) {
    if (kDebugMode) {
      print('\n🔍 ========== COMPARING ORDER LINES ==========');
      print('Original lines: ${originalLines.length}');
      print('Current lines: ${currentLines.length}');
    }

    List<OrderLineChange> changes = [];

    // 1. تتبع السطور المحذوفة
    for (final originalLine in originalLines) {
      final stillExists = currentLines.any(
        (line) => line.originalId == originalLine.id,
      );

      if (!stillExists) {
        changes.add(OrderLineChange.delete(originalLine.id!));
        if (kDebugMode) {
          print('   🗑️ DELETE: Line ${originalLine.id}');
        }
      }
    }

    // 2. تتبع السطور المحدثة/المضافة
    for (final currentLine in currentLines) {
      if (currentLine.originalId == null) {
        // سطر جديد
        changes.add(OrderLineChange.create(currentLine.toMap()));
        if (kDebugMode) {
          print('   ➕ CREATE: ${currentLine.productName}');
        }
      } else {
        // سطر موجود - تحقق من التغييرات
        final originalLine = originalLines.firstWhere(
          (line) => line.id == currentLine.originalId,
          orElse: () => throw Exception(
            'Original line not found: ${currentLine.originalId}',
          ),
        );

        if (_hasChanges(originalLine, currentLine)) {
          changes.add(
            OrderLineChange.update(
              currentLine.originalId!,
              currentLine.toMap(),
            ),
          );
          if (kDebugMode) {
            print('   🔄 UPDATE: Line ${currentLine.originalId}');
          }
        } else {
          if (kDebugMode) {
            print('   ✅ NO CHANGE: Line ${currentLine.originalId}');
          }
        }
      }
    }

    if (kDebugMode) {
      print('Total changes: ${changes.length}');
      print('==============================================\n');
    }

    return changes;
  }

  // ============= Check for Changes =============

  /// التحقق من وجود تغييرات في السطر
  static bool _hasChanges(
    OrderLineModel originalLine,
    ProductLine currentLine,
  ) {
    // مقارنة الكمية
    final quantityChanged =
        (originalLine.productUomQty?.toDouble() ?? 0.0) != currentLine.quantity;

    // مقارنة السعر
    final priceChanged =
        (originalLine.priceUnit?.toDouble() ?? 0.0) != currentLine.priceUnit;

    // مقارنة الخصم
    final discountChanged =
        (originalLine.discount?.toDouble() ?? 0.0) !=
        currentLine.discountPercentage;

    // مقارنة المنتج
    final productChanged = originalLine.productId != currentLine.productId;

    if (kDebugMode &&
        (quantityChanged ||
            priceChanged ||
            discountChanged ||
            productChanged)) {
      print('   📊 Changes detected in line ${originalLine.id}:');
      if (quantityChanged) {
        print(
          '      Quantity: ${originalLine.productUomQty} → ${currentLine.quantity}',
        );
      }
      if (priceChanged) {
        print(
          '      Price: ${originalLine.priceUnit} → ${currentLine.priceUnit}',
        );
      }
      if (discountChanged) {
        print(
          '      Discount: ${originalLine.discount} → ${currentLine.discountPercentage}',
        );
      }
      if (productChanged) {
        print(
          '      Product: ${originalLine.productId} → ${currentLine.productId}',
        );
      }
    }

    return quantityChanged || priceChanged || discountChanged || productChanged;
  }

  // ============= Build Web Save Data =============

  /// بناء بيانات web_save للتحديث
  static Map<String, dynamic> buildWebSaveData({
    required int orderId,
    required List<OrderLineChange> changes,
    Map<String, dynamic>? additionalData,
  }) {
    if (kDebugMode) {
      print('\n📦 ========== BUILDING WEB SAVE DATA ==========');
      print('Order ID: $orderId');
      print('Changes: ${changes.length}');
    }

    // بناء order_line data
    List<dynamic> orderLineData = [];

    for (final change in changes) {
      orderLineData.add(change.toOdooData());

      if (kDebugMode) {
        print('   ${change.action.toUpperCase()}: ${change.toOdooData()}');
      }
    }

    // البيانات الأساسية
    final data = <String, dynamic>{'order_line': orderLineData};

    // إضافة بيانات إضافية إذا كانت متاحة
    if (additionalData != null) {
      data.addAll(additionalData);
    }

    if (kDebugMode) {
      print('Web Save Data: $data');
      print('==============================================\n');
    }

    return data;
  }
}
