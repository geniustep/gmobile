// lib/src/presentation/screens/sales/saleorder/create/services/order_creation_service.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_module.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';

class OrderCreationService {
  // ============= Singleton =============

  static final OrderCreationService _instance =
      OrderCreationService._internal();
  factory OrderCreationService() => _instance;
  OrderCreationService._internal();

  // Counter للـ virtual IDs
  int _virtualIdCounter = 0;

  // ============= Helper Methods =============

  /// استخراج الـ ID من قيمة متعددة الأشكال
  /// يدعم: int, Map, false, null
  dynamic _extractId(dynamic value) {
    if (value == null) return false;
    if (value == false) return false;
    if (value is int) return value;
    if (value is Map && value.containsKey('id')) return value['id'];
    return false;
  }

  // ============= Create Order =============

  /// إنشاء طلب كامل (Order + Order Lines في استدعاء واحد)
  Future<dynamic> createOrder({
    bool? showGlobalLoading,
    required Map<String, dynamic> formData,
    required List<ProductLine> productLines,
    Function(int completed, int total)? onProgress,
    required OnResponse onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🚀 ========== STARTING ORDER CREATION ==========');
        print('Product Lines: ${productLines.length}');
        print('Partner ID: ${formData['partner_id']}');
        print('Pricelist ID: ${formData['pricelist_id']}');
        print('Payment Term ID: ${formData['payment_term_id']}');
        print('==============================================\n');
      }

      // ✅ التحقق من البيانات قبل الإرسال
      final validationResult = await _validateOrderData(formData, productLines);
      if (!validationResult.isValid) {
        throw OrderValidationException(validationResult.errors);
      }

      // تحديث التقدم
      onProgress?.call(1, 2);

      // إنشاء Order + Order Lines في استدعاء واحد
      final orderId = await _createCompleteOrder(
        showGlobalLoading: showGlobalLoading,
        formData: formData,
        productLines: productLines,
      );

      if (orderId == null) {
        throw Exception('Failed to create complete order');
      }

      // تحديث التقدم
      onProgress?.call(2, 2);

      if (kDebugMode) {
        print('\n✅ ========== ORDER CREATED SUCCESSFULLY ==========');
        print('Order ID: $orderId');
        print('Order Lines: ${productLines.length}');
        print('=================================================\n');
      }

      onResponse(orderId);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ORDER CREATION FAILED ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('============================================\n');
      }
      // ✅ استخدام معالجة الأخطاء المحسنة
      OrderErrorHandler.handleOrderCreationError(e, context: 'order_creation');
      rethrow;
    }
    return null;
  }

  // ============= Create Complete Order =============

  /// إنشاء طلب كامل (Order + Order Lines في استدعاء واحد)
  Future<dynamic> _createCompleteOrder({
    bool? showGlobalLoading,
    required Map<String, dynamic> formData,
    required List<ProductLine> productLines,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🛒 ========== CREATING SALE ORDER ==========');
        print('Form Data:');
        formData.forEach((key, value) {
          print('   $key: $value');
        });
      }

      // التحقق من البيانات المطلوبة
      if (formData['partner_id'] == null) {
        throw Exception('Partner ID is required');
      }

      // إعادة تعيين counter
      _virtualIdCounter = 0;

      // ✅ استخراج IDs باستخدام الدالة المساعدة
      final pricelistId = _extractId(formData['pricelist_id']);
      final paymentTermId = _extractId(formData['payment_term_id']);

      if (kDebugMode) {
        print('\n📊 Extracted IDs:');
        print(
          '   Pricelist ID: $pricelistId (type: ${pricelistId.runtimeType})',
        );
        print(
          '   Payment Term ID: $paymentTermId (type: ${paymentTermId.runtimeType})',
        );
      }

      // بناء البيانات الكاملة (Order + Order Lines)
      final completeOrderData = <String, dynamic>{
        'partner_id': formData['partner_id'],
        'partner_invoice_id': formData['partner_id'],
        'partner_shipping_id': formData['partner_id'],
        'validity_date': DateFormat(
          'yyyy-MM-dd',
        ).format(DateTime.now().add(const Duration(days: 30))),
        'date_order': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        'company_id': 1,

        // ✅ استخدام القيم المستخرجة (int أو false)
        'pricelist_id': pricelistId,
        'payment_term_id': paymentTermId,

        // ✅ بناء order_line بصيغة Odoo الصحيحة
        'order_line': _buildOrderLinesData(productLines),

        'note':
            '<p>Conditions générales : <a href="http://app.propanel.ma/terms" target="_blank" rel="noreferrer noopener">http://app.propanel.ma/terms</a> </p>',
        'sale_order_option_ids': [],
        'quotation_document_ids': [],
        'user_id': 2,
        'team_id': 1,
        'warehouse_id': 1,
        'picking_policy': 'direct',
      };

      // ✅ إضافة تاريخ التسليم إذا كان موجوداً
      if (formData['commitment_date'] != null) {
        if (formData['commitment_date'] is DateTime) {
          completeOrderData['commitment_date'] = DateFormat(
            'yyyy-MM-dd HH:mm:ss',
          ).format(formData['commitment_date']);
        } else {
          completeOrderData['commitment_date'] = formData['commitment_date'];
        }
      } else {
        completeOrderData['commitment_date'] = false;
      }

      if (kDebugMode) {
        print('\n📦 Complete Order Data to send:');
        completeOrderData.forEach((key, value) {
          if (key == 'order_line') {
            print('   $key: ${value.length} lines');
            // طباعة أول سطر كمثال
            if ((value as List).isNotEmpty) {
              print('\n   📋 First line example:');
              final firstLine = value[0];
              print(
                '      Command: [${firstLine[0]}, "${firstLine[1]}", {...}]',
              );
              print('      Product: ${firstLine[2]['name']}');
              print('      Quantity: ${firstLine[2]['product_uom_qty']}');
              print('      Price: ${firstLine[2]['price_unit']}');
              print('      Discount: ${firstLine[2]['discount']}%');
            }
          } else if (key == 'pricelist_id' || key == 'payment_term_id') {
            print('   $key: $value (${value.runtimeType})');
          } else {
            print('   $key: $value');
          }
        });
        print('\n');
      }

      // إنشاء الطلب الكامل
      final completer = Completer<dynamic>();

      OrderModule.createSaleOrder(
        showGlobalLoading: showGlobalLoading,
        maps: completeOrderData,
        onResponse: (orderId) {
          if (orderId != null) {
            completer.complete(orderId);
          } else {
            completer.completeError(Exception('No order ID returned'));
          }
        },
      );

      final orderId = await completer.future;

      if (kDebugMode) {
        print('✅ Complete Order created successfully: $orderId');
        print('=========================================\n');
      }

      return orderId;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR CREATING SALE ORDER ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('================================================\n');
      }
      rethrow;
    }
  }

  // ============= Build Order Lines Data =============

  /// بناء بيانات Order Lines بصيغة Odoo الصحيحة
  /// يدعم جميع الحالات: بدون خصم، مع خصم، بدون قائمة أسعار
  List<List<dynamic>> _buildOrderLinesData(List<ProductLine> productLines) {
    final orderLinesData = <List<dynamic>>[];

    for (int i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      // توليد virtual_id فريد
      _virtualIdCounter++;
      final virtualId =
          'virtual_${DateTime.now().millisecondsSinceEpoch}_$_virtualIdCounter';

      // ✅ حساب discount بناءً على listPrice و priceUnit
      double discount = 0.0;
      double priceToSend = line.priceUnit;

      if (line.listPrice > 0 && line.priceUnit < line.listPrice) {
        // حالة الخصم
        discount = ((line.listPrice - line.priceUnit) / line.listPrice) * 100;
        priceToSend = line.listPrice; // نرسل السعر الأصلي
      } else if (line.listPrice > 0) {
        // حالة بدون خصم لكن listPrice موجود
        priceToSend = line.listPrice;
        discount = 0.0;
      } else {
        // حالة listPrice غير موجود
        priceToSend = line.priceUnit;
        discount = 0.0;
      }

      final orderLineData = <String, dynamic>{
        'sequence': (i + 1) * 10,

        // ✅ product_id و product_template_id
        'product_id': line.productModel?.id ?? line.productId,
        'product_template_id':
            line.productModel?.product_tmpl_id ?? line.productId,

        'product_custom_attribute_value_ids': [],
        'product_no_variant_attribute_value_ids': [],

        'name': line.productModel?.name ?? line.productName,

        // ✅ الكمية
        'product_uom_qty': line.quantity.toDouble(),

        'move_ids': [],
        'product_uom': 1,
        'customer_lead': 0,

        // ✅ السعر (الأصلي إذا كان هناك خصم، النهائي إذا لم يكن)
        'price_unit': priceToSend,

        // ✅ سعر الشراء من المنتج
        'purchase_price': line.productModel?.standard_price?.toDouble() ?? 0.0,

        // ✅ technical_price_unit
        'technical_price_unit': priceToSend,

        // ✅ الخصم (0 أو النسبة المئوية)
        'discount': discount,

        'tax_id': [],
        'product_document_ids': [],
        'invoice_lines': [],
      };

      // ✅ استخدام صيغة Odoo Command الصحيحة: [0, virtual_id, data]
      orderLinesData.add([0, virtualId, orderLineData]);
    }

    if (kDebugMode) {
      print('\n✅ Built ${orderLinesData.length} order lines');
    }

    return orderLinesData;
  }

  // ============= Error Handling =============
  // تم نقل معالجة الأخطاء إلى OrderErrorHandler في utils.dart

  // ============= Advanced Validation =============

  /// التحقق المتقدم من بيانات الطلب
  Future<ValidationResult> _validateOrderData(
    Map<String, dynamic> formData,
    List<ProductLine> productLines,
  ) async {
    final errors = <String>[];
    final warnings = <String>[];

    // التحقق من العميل
    if (formData['partner_id'] == null) {
      errors.add('يجب اختيار عميل');
    }

    // التحقق من المنتجات
    if (productLines.isEmpty) {
      errors.add('يجب إضافة منتج واحد على الأقل');
    }

    // التحقق من كل منتج
    for (int i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      if (line.productModel == null) {
        errors.add('المنتج رقم ${i + 1} غير صالح');
        continue;
      }

      if (line.quantity <= 0) {
        errors.add('الكمية غير صحيحة للمنتج: ${line.productName}');
      }

      if (line.priceUnit < 0) {
        errors.add('السعر غير صحيح للمنتج: ${line.productName}');
      }

      if (line.discountPercentage < 0 || line.discountPercentage > 100) {
        errors.add('نسبة الخصم غير صحيحة للمنتج: ${line.productName}');
      }
    }

    // التحقق من الإجمالي
    final total = productLines.fold(
      0.0,
      (sum, line) => sum + line.getTotalPrice(),
    );
    if (total <= 0) {
      errors.add('إجمالي الطلب يجب أن يكون أكبر من صفر');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }
}
