// lib/src/presentation/screens/sales/saleorder/update/services/order_update_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_module.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/services/order_line_change_tracker.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/services/pref_utils_manager.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/services/order_persistence_tracker.dart';

class OrderUpdateService {
  // ============= Singleton =============

  static final OrderUpdateService _instance = OrderUpdateService._internal();
  factory OrderUpdateService() => _instance;
  OrderUpdateService._internal();

  // ============= Update Order =============

  /// تحديث طلب كامل (Order + Order Lines)
  Future<bool> updateOrder({
    required OrderModel originalOrder,
    required Map<String, dynamic> formData,
    required List<ProductLine> productLines,
    required List<OrderLineModel> originalOrderLines,
    Function(int completed, int total)? onProgress,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🔄 ========== STARTING ORDER UPDATE ==========');
        print('Order ID: ${originalOrder.id}');
        print('Form Data: $formData');
        print('Product Lines: ${productLines.length}');
        print('Original Lines: ${originalOrderLines.length}');
        print('==============================================\n');
      }

      // 1. تحديث بيانات الطلب الأساسية
      await _updateSaleOrderData(
        orderId: originalOrder.id!,
        formData: formData,
      );

      if (kDebugMode) {
        print('✅ Sale Order data updated');
        print('📦 Now updating order lines...');
      }

      // 2. تحديث خطوط الطلب باستخدام التتبع
      await _updateOrderLinesWithTracking(
        orderId: originalOrder.id!,
        productLines: productLines,
        originalOrderLines: originalOrderLines,
        onProgress: onProgress,
      );

      if (kDebugMode) {
        print('\n✅ ========== ORDER UPDATED SUCCESSFULLY ==========');
        print('Order ID: ${originalOrder.id}');
        print('Updated Lines: ${productLines.length}');
        print('==================================================\n');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ORDER UPDATE FAILED ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('==========================================\n');
      }
      rethrow;
    }
  }

  // ============= Update Sale Order Data =============

  /// تحديث بيانات طلب البيع الأساسية
  Future<void> _updateSaleOrderData({
    required int orderId,
    required Map<String, dynamic> formData,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🛒 ========== UPDATING SALE ORDER DATA ==========');
        print('Order ID: $orderId');
        print('Form Data:');
        formData.forEach((key, value) {
          print('   $key: $value');
        });
      }

      // التحقق من البيانات المطلوبة
      if (formData['partner_id'] == null) {
        throw Exception('Partner ID is required');
      }

      // بناء البيانات للتحديث
      final updateData = <String, dynamic>{
        'partner_id': formData['partner_id'],
        'date_order': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      };

      // ✅ إضافة pricelist_id فقط إذا كان متاحاً
      if (formData['pricelist_id'] != null) {
        updateData['pricelist_id'] = formData['pricelist_id'];
      }

      // إضافة payment_term_id إذا كان موجوداً
      if (formData['payment_term_id'] != null) {
        updateData['payment_term_id'] = formData['payment_term_id'];
      }

      // إضافة تاريخ التسليم إذا كان موجوداً
      if (formData['commitment_date'] != null) {
        if (formData['commitment_date'] is DateTime) {
          updateData['commitment_date'] = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(formData['commitment_date']);
        } else {
          updateData['commitment_date'] = formData['commitment_date'];
        }
      }

      if (kDebugMode) {
        print('\nSale Order Update Data:');
        updateData.forEach((key, value) {
          print('   $key: $value');
        });
      }

      // تحديث الطلب
      final completer = Completer<bool>();

      OrderModule.updateSaleOrder(
        maps: updateData,
        ids: [orderId],
        onResponse: (response) {
          if (kDebugMode) {
            print('✅ Sale Order update response: $response');
          }
          completer.complete(true);
        },
      );

      await completer.future;

      if (kDebugMode) {
        print('✅ Sale Order data updated successfully');
        print('=========================================\n');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR UPDATING SALE ORDER ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('==================================================\n');
      }
      rethrow;
    }
  }

  // ============= Update Order Lines With Tracking =============

  /// تحديث خطوط الطلب باستخدام تتبع التغييرات
  Future<void> _updateOrderLinesWithTracking({
    required int orderId,
    required List<ProductLine> productLines,
    required List<OrderLineModel> originalOrderLines,
    Function(int completed, int total)? onProgress,
  }) async {
    if (kDebugMode) {
      print('\n📦 ========== UPDATING ORDER LINES WITH TRACKING ==========');
      print('Order ID: $orderId');
      print('New lines: ${productLines.length}');
      print('Original lines: ${originalOrderLines.length}');
    }

    // 1. مقارنة السطور وإيجاد التغييرات
    final changes = OrderLineChangeTracker.compareOrderLines(
      originalLines: originalOrderLines,
      currentLines: productLines,
    );

    if (changes.isEmpty) {
      if (kDebugMode) {
        print('✅ No changes detected - skipping update');
      }
      return;
    }

    // 2. بناء بيانات web_save
    final webSaveData = OrderLineChangeTracker.buildWebSaveData(
      orderId: orderId,
      changes: changes,
    );

    // 3. إرسال التحديث باستخدام web_save
    await _sendWebSaveUpdate(
      orderId: orderId,
      data: webSaveData,
      productLines: productLines,
    );

    if (kDebugMode) {
      print('\n✅ ========== ORDER LINES UPDATED WITH TRACKING ==========');
      print('Total changes: ${changes.length}');
      print('========================================================\n');
    }
  }

  /// إرسال تحديث web_save
  Future<void> _sendWebSaveUpdate({
    required int orderId,
    required Map<String, dynamic> data,
    required List<ProductLine> productLines,
  }) async {
    try {
      if (kDebugMode) {
        print('\n📤 ========== SENDING WEB SAVE UPDATE ==========');
        print('Order ID: $orderId');
        print('Data: $data');
      }

      final completer = Completer<bool>();

      Api.webSave(
        model: "sale.order",
        ids: [orderId],
        values: data,
        specification: {},
        onResponse: (response) {
          if (kDebugMode) {
            print('✅ Web save response: $response');
          }
          completer.complete(true);
        },
        onError: (error, data) {
          if (kDebugMode) {
            print('❌ Web save error: $error');
          }
          completer.completeError(Exception('Web save failed: $error'));
        },
      );

      await completer.future;

      // ✅ جلب البيانات المحدثة من الخادم بعد web_save
      await _fetchUpdatedOrderLines(orderId);

      if (kDebugMode) {
        print('✅ Web save update completed successfully');
        print('==========================================\n');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR IN WEB SAVE UPDATE ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('==============================================\n');
      }
      rethrow;
    }
  }

  /// جلب البيانات المحدثة من الخادم بعد web_save
  Future<void> _fetchUpdatedOrderLines(int orderId) async {
    try {
      if (kDebugMode) {
        print('\n🔄 ========== FETCHING UPDATED ORDER LINES ==========');
        print('Order ID: $orderId');
      }

      // ✅ تسجيل حالة الطلبات قبل التحديث
      OrderPersistenceTracker.logBeforeUpdate(orderId);

      // ✅ مراقبة PrefUtils قبل التحديث
      PrefUtilsManager.monitorPrefUtils();
      PrefUtilsManager.monitorOrderLines(orderId);

      // 1️⃣ قراءة Order المحدثة
      final completer = Completer<void>();

      OrderModule.readOrders(
        ids: [orderId],
        onResponse: (response) async {
          if (response.isNotEmpty) {
            final updatedOrder = response.first;

            if (kDebugMode) {
              print('✅ Updated order fetched: ${updatedOrder.name}');
              print('   Order lines count: ${updatedOrder.orderLine.length}');
            }

            // 2️⃣ استخراج OrderLine IDs
            final orderLineIds = updatedOrder.orderLine.cast<int>();

            if (kDebugMode) {
              print('📋 Order line IDs: $orderLineIds');
            }

            // 3️⃣ قراءة OrderLines منفصلة
            if (orderLineIds.isNotEmpty) {
              final orderLinesCompleter = Completer<void>();

              OrderLineModule.readOrderLines(
                ids: orderLineIds,
                onResponse: (orderLinesResponse) {
                  if (kDebugMode) {
                    print(
                      '✅ Order lines fetched: ${orderLinesResponse.length}',
                    );
                  }

                  // 4️⃣ تحديث البيانات باستخدام PrefUtilsManager
                  PrefUtilsManager.updateOrder(
                    updatedOrder,
                    orderLinesResponse,
                  );

                  // ✅ تسجيل حالة الطلبات بعد التحديث
                  OrderPersistenceTracker.logAfterUpdate(orderId);

                  // ✅ مراقبة PrefUtils بعد التحديث
                  PrefUtilsManager.monitorPrefUtils();
                  PrefUtilsManager.monitorOrderLines(orderId);

                  if (kDebugMode) {
                    print('✅ Data updated in Prefs:');
                    print('   Sales: ${PrefUtils.sales.length}');
                    print('   Order Lines: ${PrefUtils.orderLine.length}');
                  }

                  orderLinesCompleter.complete();
                },
              );

              await orderLinesCompleter.future;
            } else {
              // إذا لم تكن هناك order lines
              PrefUtils.sales.removeWhere((order) => order.id == orderId);
              PrefUtils.sales.add(updatedOrder);

              if (kDebugMode) {
                print('✅ Order updated (no order lines)');
              }
            }

            completer.complete();
          } else {
            completer.complete();
          }
        },
      );

      await completer.future;

      if (kDebugMode) {
        print('===============================================\n');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error fetching updated order lines: $e');
      }
    }
  }

  // ============= Update Order Lines (Legacy) =============

  /// تحديث خطوط الطلب (الطريقة القديمة - للاحتياط) - غير مستخدم
  @Deprecated('Use _updateOrderLinesWithTracking instead')
  // ignore: unused_element
  Future<void> _updateOrderLines({
    required int orderId,
    required List<ProductLine> productLines,
    required List<OrderLineModel> originalOrderLines,
    Function(int completed, int total)? onProgress,
  }) async {
    if (kDebugMode) {
      print('\n📦 ========== UPDATING ORDER LINES ==========');
      print('Order ID: $orderId');
      print('New lines: ${productLines.length}');
      print('Original lines: ${originalOrderLines.length}');
    }

    int completedLines = 0;
    final int totalLines = productLines.length;

    // عرض Progress Dialog
    _showProgressDialog(completedLines, totalLines);

    // 1. حذف جميع الخطوط الموجودة أولاً
    await _deleteAllOrderLines(orderId);

    // 2. إضافة الخطوط الجديدة
    for (var i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      try {
        if (kDebugMode) {
          print('\nCreating line ${i + 1}/$totalLines:');
          print('   Product ID: ${line.productId}');
          print('   Product Name: ${line.productName}');
          print('   Quantity: ${line.quantity}');
          print('   List Price: ${line.listPrice} Dh');
          print('   Display Price: ${line.priceUnit} Dh');
          print('   Discount: ${line.discountPercentage}%');
        }

        // التحقق من صحة البيانات
        if (line.productModel == null) {
          throw Exception('Product model is null for line ${i + 1}');
        }

        if (line.quantity <= 0) {
          throw Exception('Invalid quantity for line ${i + 1}');
        }

        // إنشاء OrderLine مع order_id - إرسال السعر الصحيح حسب الحالة
        final isDiscount = line.priceUnit < line.listPrice; // خصم
        final isMarkup = line.priceUnit > line.listPrice; // زيادة

        final orderLineData = {
          'order_id': orderId,
          'product_id': line.productModel!.id,
          'product_uom_qty': line.quantity.toDouble(),
          'price_unit': isDiscount
              ? line.listPrice
              : line.priceUnit, // ⬅️ السعر الأصلي للخصم، السعر النهائي للزيادة
          'discount': isDiscount
              ? line.discountPercentage
              : 0.0, // ⬅️ الخصم فقط عند وجود خصم
        };

        if (kDebugMode) {
          print('   Order Line Data:');
          orderLineData.forEach((key, value) {
            print('     $key: $value');
          });
          print('   💰 Sending to server:');
          if (isDiscount) {
            print('      Case: DISCOUNT');
            print('      List Price: ${line.listPrice} Dh');
            print('      Discount: ${line.discountPercentage}%');
            print(
              '      Expected Total: ${line.listPrice * line.quantity * (1 - line.discountPercentage / 100)} Dh',
            );
          } else if (isMarkup) {
            print('      Case: MARKUP');
            print('      Final Price: ${line.priceUnit} Dh');
            print('      Discount: 0.0%');
            print('      Expected Total: ${line.priceUnit * line.quantity} Dh');
          } else {
            print('      Case: NORMAL PRICE');
            print('      Price: ${line.priceUnit} Dh');
            print('      Discount: 0.0%');
            print('      Expected Total: ${line.priceUnit * line.quantity} Dh');
          }
        }

        // استخدام Completer
        final completer = Completer<int>();

        OrderLineModule.createSaleOrderLine(
          maps: orderLineData,
          onResponse: (lineId) {
            if (lineId != null) {
              if (kDebugMode) {
                print('   ✅ Order line created: $lineId');
              }
              completer.complete(lineId);
            } else {
              completer.completeError(Exception('No line ID returned'));
            }
          },
        );

        await completer.future;

        completedLines++;
        onProgress?.call(completedLines, totalLines);
        _updateProgressDialog(completedLines, totalLines);

        if (kDebugMode) {
          print('   ✅ Line ${i + 1} completed successfully');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('\n❌ ========== ERROR CREATING LINE ${i + 1} ==========');
          print('Error: $e');
          print('Stack trace: $stackTrace');
          print('================================================\n');
        }
        rethrow;
      }
    }

    // إخفاء Progress Dialog
    _hideProgressDialog();

    if (kDebugMode) {
      print('\n✅ ========== ALL ORDER LINES UPDATED ==========');
      print('Total lines updated: $completedLines');
      print('==============================================\n');
    }
  }

  // ============= Delete All Order Lines =============

  /// حذف جميع خطوط الطلب الموجودة
  Future<void> _deleteAllOrderLines(int orderId) async {
    try {
      if (kDebugMode) {
        print('\n🗑️ ========== DELETING ALL ORDER LINES ==========');
        print('Order ID: $orderId');
      }

      final completer = Completer<bool>();

      Api.unlink(
        model: "sale.order.line",
        ids: [orderId], // سيحذف جميع الخطوط المرتبطة بالطلب
        onResponse: (response) {
          if (kDebugMode) {
            print('✅ Order lines deletion response: $response');
          }
          completer.complete(true);
        },
        onError: (error, data) {
          if (kDebugMode) {
            print('❌ Error deleting order lines: $error');
          }
          completer.completeError(
            Exception('Failed to delete order lines: $error'),
          );
        },
      );

      await completer.future;

      if (kDebugMode) {
        print('✅ All order lines deleted successfully');
        print('==========================================\n');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR DELETING ORDER LINES ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('================================================\n');
      }
      rethrow;
    }
  }

  // ============= Progress Dialog =============

  /// عرض Progress Dialog
  void _showProgressDialog(int completed, int total) {
    Get.dialog(
      AlertDialog(
        title: const Text('جاري التحديث...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: completed / total,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(Get.context!).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text('تم تحديث $completed من $total خط'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// تحديث Progress Dialog
  void _updateProgressDialog(int completed, int total) {
    // إعادة بناء الـ dialog مع البيانات الجديدة
    Get.dialog(
      AlertDialog(
        title: const Text('جاري التحديث...'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: completed / total,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(Get.context!).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text('تم تحديث $completed من $total خط'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// إخفاء Progress Dialog
  void _hideProgressDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
