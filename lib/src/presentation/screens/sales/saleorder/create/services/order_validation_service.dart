// lib/src/presentation/screens/sales/saleorder/create/services/order_validation_service.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class OrderValidationService {
  // ============= Singleton =============

  static final OrderValidationService _instance =
      OrderValidationService._internal();
  factory OrderValidationService() => _instance;
  OrderValidationService._internal();

  // ============= Validate Order =============

  /// التحقق من صحة الطلب بالكامل
  bool validateOrder({
    required Map<String, dynamic> formData,
    required List<ProductLine> productLines,
    bool showMessages = true,
  }) {
    // 1. التحقق من بيانات النموذج
    if (!validateFormData(formData, showMessages: showMessages)) {
      return false;
    }

    // 2. التحقق من وجود منتجات
    if (!validateHasProducts(productLines, showMessages: showMessages)) {
      return false;
    }

    // 3. التحقق من صحة خطوط المنتجات
    if (!validateProductLines(productLines, showMessages: showMessages)) {
      return false;
    }

    return true;
  }

  // ============= Validate Form Data =============

  /// التحقق من بيانات النموذج
  bool validateFormData(
    Map<String, dynamic> formData, {
    bool showMessages = true,
  }) {
    if (kDebugMode) {
      print('\n📋 Validating form data...');
      formData.forEach((key, value) {
        print('   $key: $value');
      });
    }

    // التحقق من الشريك
    if (formData['partner_id'] == null) {
      if (kDebugMode) {
        print('❌ Partner ID is missing');
      }

      if (showMessages) {
        Get.snackbar(
          'خطأ',
          'يرجى اختيار العميل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }

      return false;
    }

    if (kDebugMode) {
      print('✅ Form data valid');
    }

    return true;
  }

  // ============= Validate Products =============

  /// التحقق من وجود منتجات
  bool validateHasProducts(
    List<ProductLine> productLines, {
    bool showMessages = true,
  }) {
    if (kDebugMode) {
      print('\n📦 Checking for products...');
    }

    if (productLines.isEmpty) {
      if (kDebugMode) {
        print('❌ No products in order');
      }

      if (showMessages) {
        Get.snackbar(
          'خطأ',
          'يجب إضافة منتج واحد على الأقل',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }

      return false;
    }

    if (kDebugMode) {
      print('✅ Has ${productLines.length} products');
    }

    return true;
  }

  // ============= Validate Product Lines =============

  /// التحقق من صحة خطوط المنتجات
  bool validateProductLines(
    List<ProductLine> productLines, {
    bool showMessages = true,
  }) {
    if (kDebugMode) {
      print('\n🔍 Validating product lines...');
    }

    for (var i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      // التحقق من المنتج
      if (line.productModel == null) {
        if (kDebugMode) {
          print('❌ Line $i: Product model is null');
        }

        if (showMessages) {
          Get.snackbar(
            'خطأ',
            'المنتج رقم ${i + 1} غير صالح',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }

        return false;
      }

      // التحقق من الكمية
      if (line.quantity <= 0) {
        if (kDebugMode) {
          print('❌ Line $i: Invalid quantity (${line.quantity})');
        }

        if (showMessages) {
          Get.snackbar(
            'خطأ',
            'الكمية غير صالحة للمنتج: ${line.productName}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }

        return false;
      }

      // التحقق من السعر
      if (line.priceUnit < 0) {
        if (kDebugMode) {
          print('❌ Line $i: Invalid price (${line.priceUnit})');
        }

        if (showMessages) {
          Get.snackbar(
            'خطأ',
            'السعر غير صالح للمنتج: ${line.productName}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.error, color: Colors.white),
          );
        }

        return false;
      }

      if (kDebugMode) {
        print('✅ Line $i valid: ${line.productName}');
        print('   Quantity: ${line.quantity}');
        print('   Price: ${line.priceUnit} Dh');
        print('   Discount: ${line.discountPercentage}%');
        print('   Total: ${line.getTotalPrice()} Dh');
      }
    }

    if (kDebugMode) {
      print('✅ All product lines validated');
    }

    return true;
  }

  // ============= Helpers =============
  // تم نقل _calculateTotal إلى OrderController

  // ============= Quick Validations =============

  /// التحقق السريع من الشريك
  bool validatePartner(dynamic partnerId) {
    if (partnerId == null) {
      if (kDebugMode) {
        print('❌ No partner selected');
      }
      return false;
    }
    return true;
  }

  /// التحقق السريع من المنتج
  bool validateProduct(ProductLine line) {
    return line.productModel != null &&
        line.quantity > 0 &&
        line.priceUnit >= 0;
  }

  /// التحقق من صحة الكمية
  bool validateQuantity(int quantity) {
    return quantity > 0;
  }

  /// التحقق من صحة السعر
  bool validatePrice(double price) {
    return price >= 0;
  }

  /// التحقق من صحة الخصم
  bool validateDiscount(double discount) {
    return discount >= 0 && discount <= 100;
  }

  // ============= Advanced Validation =============

  /// التحقق المتقدم من البيانات
  ValidationResult validateOrderAdvanced({
    required Map<String, dynamic> formData,
    required List<ProductLine> productLines,
    bool showMessages = true,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // 1. التحقق من العميل
    final partnerValidation = _validatePartner(formData['partner_id']);
    if (!partnerValidation.isValid) {
      errors.addAll(partnerValidation.errors);
    }

    // 2. التحقق من قائمة الأسعار
    final pricelistValidation = _validatePricelist(formData['pricelist_id']);
    if (!pricelistValidation.isValid) {
      warnings.addAll(pricelistValidation.errors);
    }

    // 3. التحقق من المنتجات
    final productsValidation = _validateProducts(productLines);
    if (!productsValidation.isValid) {
      errors.addAll(productsValidation.errors);
    }

    // 4. التحقق من الإجمالي
    final totalValidation = _validateOrderTotal(productLines);
    if (!totalValidation.isValid) {
      errors.addAll(totalValidation.errors);
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  ValidationResult _validatePartner(dynamic partnerId) {
    if (partnerId == null) {
      return ValidationResult(isValid: false, errors: ['يجب اختيار عميل']);
    }

    // التحقق من وجود العميل في القائمة
    final partner = PrefUtils.partners.firstWhereOrNull(
      (p) => p.id == partnerId,
    );
    if (partner == null) {
      return ValidationResult(
        isValid: false,
        errors: ['العميل المحدد غير موجود'],
      );
    }

    // التحقق من حالة العميل (إذا كان الحقل موجود)
    // if (partner.isBlocked == true) {
    //   return ValidationResult(
    //     isValid: false,
    //     errors: ['العميل محظور ولا يمكن إنشاء طلب له'],
    //   );
    // }

    return ValidationResult(isValid: true, errors: []);
  }

  ValidationResult _validatePricelist(dynamic pricelistId) {
    if (pricelistId == null) {
      return ValidationResult(
        isValid: true,
        errors: [],
        warnings: ['لم يتم اختيار قائمة أسعار'],
      );
    }

    return ValidationResult(isValid: true, errors: []);
  }

  ValidationResult _validateProducts(List<ProductLine> productLines) {
    final errors = <String>[];

    for (int i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      // التحقق من المنتج
      if (line.productModel == null) {
        errors.add('المنتج رقم ${i + 1} غير صالح');
        continue;
      }

      // التحقق من الكمية
      if (line.quantity <= 0) {
        errors.add('الكمية غير صحيحة للمنتج: ${line.productName}');
      }

      // التحقق من السعر
      if (line.priceUnit < 0) {
        errors.add('السعر غير صحيح للمنتج: ${line.productName}');
      }

      // التحقق من الخصم
      if (line.discountPercentage < 0 || line.discountPercentage > 100) {
        errors.add('نسبة الخصم غير صحيحة للمنتج: ${line.productName}');
      }
    }

    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  ValidationResult _validateOrderTotal(List<ProductLine> productLines) {
    final total = productLines.fold(
      0.0,
      (sum, line) => sum + line.getTotalPrice(),
    );

    if (total <= 0) {
      return ValidationResult(
        isValid: false,
        errors: ['إجمالي الطلب يجب أن يكون أكبر من صفر'],
      );
    }

    // التحقق من الحد الأدنى للطلب
    const minOrderTotal = 10.0; // يمكن جعلها قابلة للتكوين
    if (total < minOrderTotal) {
      return ValidationResult(
        isValid: false,
        errors: ['الحد الأدنى للطلب هو ${minOrderTotal} درهم'],
      );
    }

    return ValidationResult(isValid: true, errors: []);
  }
}
