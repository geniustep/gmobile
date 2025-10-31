// lib/src/presentation/screens/sales/saleorder/create/services/price_management_service.dart

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';

/// خدمة إدارة الأسعار - فصل منطق حساب الأسعار
class PriceManagementService {
  // ============= Singleton =============

  static final PriceManagementService _instance =
      PriceManagementService._internal();
  factory PriceManagementService() => _instance;
  PriceManagementService._internal();

  // ============= Price Calculation =============

  /// حساب السعر النهائي بناءً على نوع القاعدة
  PriceCalculationResult calculatePrice({
    required ProductLine line,
    required PricelistItem rule,
  }) {
    final basePrice = line.listPrice;
    final ruleValue = _extractNumericValue(rule.price);
    final isNegative = _isNegativeValue(rule.price);

    if (ruleValue == null) {
      return PriceCalculationResult(
        finalPrice: basePrice,
        discount: 0.0,
        isMarkup: false,
        appliedRule: null,
      );
    }

    double finalPrice = basePrice;
    double discount = 0.0;
    bool isMarkup = false;

    switch (rule.computePrice) {
      case 'fixed':
        // سعر ثابت
        finalPrice = ruleValue;
        discount = _calculateDiscountPercentage(basePrice, finalPrice);
        break;

      case 'percentage':
        if (isNegative) {
          // زيادة على السعر (markup)
          finalPrice = basePrice * (1 + ruleValue / 100);
          isMarkup = true;
        } else {
          // خصم
          discount = ruleValue;
          finalPrice = basePrice * (1 - ruleValue / 100);
        }
        break;

      case 'formula':
        // صيغة حسابية (نفس منطق النسبة)
        if (isNegative) {
          finalPrice = basePrice * (1 + ruleValue / 100);
          isMarkup = true;
        } else {
          discount = ruleValue;
          finalPrice = basePrice * (1 - ruleValue / 100);
        }
        break;

      default:
        return PriceCalculationResult(
          finalPrice: basePrice,
          discount: 0.0,
          isMarkup: false,
          appliedRule: null,
        );
    }

    return PriceCalculationResult(
      finalPrice: finalPrice,
      discount: discount,
      isMarkup: isMarkup,
      appliedRule: rule,
    );
  }

  /// البحث عن القاعدة المناسبة للمنتج
  PricelistItem? findMatchingRule({
    required ProductLine line,
    required List<PricelistItem> rules,
  }) {
    if (kDebugMode) {
      print('\n🔍 ========== FINDING MATCHING RULE ==========');
      print('Product: ${line.productName}');
      print('Product Template ID: ${line.productModel?.product_tmpl_id}');
      print('Quantity: ${line.quantity}');
      print('Available rules: ${rules.length}');
    }

    PricelistItem? bestMatch;

    for (var rule in rules) {
      // التحقق من مطابقة المنتج
      final productMatch = _matchesProduct(line, rule);

      // التحقق من مطابقة الكمية
      final quantityMatch = _matchesQuantity(line, rule);

      if (kDebugMode) {
        print('   Rule: ${rule.name}');
        print('     Product Match: $productMatch');
        print('     Quantity Match: $quantityMatch');
        print('     Min Quantity: ${rule.minQuantity}');
      }

      if (productMatch && quantityMatch) {
        // اختيار القاعدة الأفضل (أعلى كمية مطلوبة)
        if (bestMatch == null ||
            (rule.minQuantity ?? 0) > (bestMatch.minQuantity ?? 0)) {
          bestMatch = rule;
        }
      }
    }

    if (kDebugMode) {
      if (bestMatch != null) {
        print('✅ Best match found: ${bestMatch.name}');
      } else {
        print('❌ No matching rule found');
      }
      print('==========================================\n');
    }

    return bestMatch;
  }

  // ============= Helper Methods =============

  /// استخراج القيمة الرقمية من النص
  double? _extractNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String && value.isNotEmpty) {
      final match = RegExp(r'-?(\d+\.?\d*)').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }

    return null;
  }

  /// التحقق من كون القيمة سالبة
  bool _isNegativeValue(dynamic value) {
    if (value is num) {
      return value < 0;
    }

    if (value is String) {
      return value.contains('-');
    }

    return false;
  }

  /// حساب نسبة الخصم
  double _calculateDiscountPercentage(double originalPrice, double finalPrice) {
    if (originalPrice == 0) return 0.0;
    return ((originalPrice - finalPrice) / originalPrice * 100).clamp(0, 100);
  }

  /// التحقق من مطابقة المنتج
  bool _matchesProduct(ProductLine line, PricelistItem rule) {
    // إذا لم يكن هناك product_tmpl_id محدد، فهي قاعدة عامة
    if (rule.productTmplId == null ||
        rule.productTmplId == false ||
        rule.productTmplId == 0) {
      return true;
    }

    // مطابقة product_tmpl_id
    return line.productModel?.product_tmpl_id == rule.productTmplId;
  }

  /// التحقق من مطابقة الكمية
  bool _matchesQuantity(ProductLine line, PricelistItem rule) {
    final minQuantity = rule.minQuantity ?? 0;
    return line.quantity >= minQuantity;
  }
}

/// نتيجة حساب السعر
class PriceCalculationResult {
  final double finalPrice;
  final double discount;
  final bool isMarkup;
  final PricelistItem? appliedRule;

  PriceCalculationResult({
    required this.finalPrice,
    required this.discount,
    required this.isMarkup,
    this.appliedRule,
  });

  /// هل تم تطبيق قاعدة؟
  bool get hasAppliedRule => appliedRule != null;

  /// المبلغ الموفر (إذا كان خصم)
  double get savings => isMarkup ? 0.0 : (finalPrice * discount / 100);

  /// المبلغ الإضافي (إذا كان markup)
  double get markup =>
      isMarkup ? (finalPrice - (finalPrice / (1 + discount / 100))) : 0.0;
}
