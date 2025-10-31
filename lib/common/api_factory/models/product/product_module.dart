import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/common/config/field_presets/fallback_level.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class ProductModule {
  ProductModule._();
  static List<String> _getDefaultFields() {
    return [
      'id',
      'name',
      'display_name',
      'qty_available',
      'taxes_id',
      'lst_price',
      'description',
      'barcode',
      'product_tag_ids',
      'default_code',
      'standard_price',
      'list_price',
      'active',
      'responsible_id',
      'categ_id',
      'uom_id',
      'type',
      'sale_ok',
      'purchase_ok',
      if (kReleaseMode) 'image_1920',
    ];
  }

  // ────────────────────────────────────────────────────────
  // Search Read Products مع Fallback Strategy
  // ────────────────────────────────────────────────────────

  static Future<void> searchReadProducts<T>({
    OnResponse? onResponse,
    bool showGlobalLoading = true,
    List<String>? customFields, // ✅ إمكانية تمرير حقول مخصصة
  }) async {
    // تحديد الحقول المستخدمة
    final fields = customFields ?? _getDefaultFields();

    print('📦 Loading products...');
    print('   Initial fields: ${fields.length}');

    // إنشاء Strategy
    final strategy = FieldFallbackStrategy(
      model: 'product.product',
      onFieldsGet: (model) async {
        // استدعاء fields_get من Api
        final completer = Completer<Map<String, dynamic>>();

        Api.fieldsGetWithInfo(
          model: model,
          onResponse: (fieldsInfo) {
            completer.complete(fieldsInfo);
          },
          onError: (error, data) {
            completer.completeError(error);
          },
          showGlobalLoading: false,
        );

        return await completer.future;
      },
    );

    // تهيئة بالحقول الافتراضية
    strategy.initialize(fields);

    // بدء المحاولات
    await _attemptSearchRead(
      strategy: strategy,
      onResponse: onResponse,
      showGlobalLoading: showGlobalLoading,
    );
  }

  static Future<void> _attemptSearchRead({
    required FieldFallbackStrategy strategy,
    required OnResponse? onResponse,
    required bool showGlobalLoading,
  }) async {
    try {
      final currentFields = strategy.getCurrentFields();

      await Module.getRecordsController<ProductModel>(
        model: "product.product",
        fields: currentFields,
        domain: [
          "&",
          "&",
          "&",
          ["sale_ok", "=", "True"],
          [
            "type",
            "in",
            ["consu", "product"],
          ],
          ["can_be_expensed", "!=", "True"],
          ["active", "=", "True"],
        ],
        fromJson: (data) => ProductModel.fromJson(data),
        onResponse: (response) {
          print("✅ Products loaded: ${response.length}");
          print(
            "   Level used: ${strategy.currentLevel.toString().split('.').last}",
          );
          print("   Fields count: ${currentFields?.length ?? 'ALL'}");

          // طباعة الإحصائيات
          final status = strategy.getStatus();
          if (status['retry_count'] > 0) {
            print("   Retries: ${status['retry_count']}");
            print(
              "   Invalid fields removed: ${status['cached_invalid_fields']}",
            );
          }

          onResponse!(response);
        },
        showGlobalLoading: showGlobalLoading,
      );
    } catch (e) {
      final errorStr = e.toString();

      // تحقق: هل الخطأ Invalid field؟
      if (errorStr.contains('Invalid field')) {
        print("⚠️  Invalid field error detected");

        try {
          // معالجة الخطأ والحصول على الحقول الجديدة
          final newFields = await strategy.handleInvalidField(errorStr);

          if (newFields != null && newFields.isNotEmpty) {
            // إعادة المحاولة مع الحقول الجديدة
            print("🔄 Retrying with new fields...");

            await _attemptSearchRead(
              strategy: strategy,
              onResponse: onResponse,
              showGlobalLoading: false, // تم عرض loading مسبقاً
            );
            return;
          }
        } catch (strategyError) {
          print("❌ Strategy error: $strategyError");
          throw strategyError;
        }
      }

      // خطأ آخر أو فشلت كل المحاولات
      print("❌ Error loading products: $e");
      throw e;
    }
  }

  static searchReadProductsOlder<T>({
    OnResponse? onResponse,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    try {
      await Module.getRecordsController<ProductModel>(
        model: "product.product",
        fields: _getDefaultFields(),
        domain: [
          "&",
          "&",
          "&",
          ["sale_ok", "=", "True"],
          [
            "type",
            "in",
            ["consu", "product"],
          ],
          ["can_be_expensed", "!=", "True"],
          ["active", "=", "True"],
        ],
        fromJson: (data) => ProductModel.fromJson(data),
        onResponse: (response) {
          print("Productos obtenidos: ${response.length}");
          onResponse!(response);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
    }
  }

  static readProducts({
    required List<int> ids,
    required OnResponse<List<ProductModel>> onResponse,
  }) {
    List<String> fields = [
      "product_variant_count",
      "is_product_variant",
      "attribute_line_ids",
      "qty_available",
      "uom_name",
      "virtual_available",
      "reordering_min_qty",
      "reordering_max_qty",
      "nbr_reordering_rules",
      "sales_count",
      "id",
      "image_1920",
      "image_128",
      "image_256",
      "image_128",
      "name",
      "sale_ok",
      "purchase_ok",
      "active",
      "type",
      "categ_id",
      "default_code",
      "barcode",
      "list_price",
      "valuation",
      "cost_method",
      "pricelist_item_count",
      "taxes_id",
      "standard_price",
      "company_id",
      "uom_id",
      "uom_po_id",
      "currency_id",
      "cost_currency_id",
      "product_variant_id",
      "description",
      "invoice_policy",
      "service_type",
      "visible_expense_policy",
      "expense_policy",
      "description_sale",
      "sale_line_warn",
      "sale_line_warn_msg",
      "supplier_taxes_id",
      "route_ids",
      "route_from_categ_ids",
      "sale_delay",
      "tracking",
      "property_stock_production",
      "property_stock_inventory",
      "weight",
      "weight_uom_name",
      "volume",
      "volume_uom_name",
      "responsible_id",
      "packaging_ids",
      "description_pickingout",
      "description_pickingin",
      "description_picking",
      "property_account_income_id",
      "property_account_expense_id",
      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
      "display_name",
      "can_be_expensed",
      "product_tag_ids",
    ];
    Api.read(
      model: "product.template",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<ProductModel> products = [];
        for (var element in response) {
          products.add(ProductModel.fromJson(element));
        }
        onResponse(products);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static createProduct({
    required Map<String, dynamic>? maps,
    int offset = 0,
    required OnResponse<Map<int, List<ProductModel>>> onResponse,
  }) {
    Map<String, dynamic> newMap = Map.from(maps!);
    Api.create(
      model: "product.template",
      values: newMap,
      onResponse: (response) {
        ProductModule.readProducts(
          ids: [response],
          onResponse: (responseProducts) {
            // إضافة المنتج الجديد إلى PrefUtils.products
            PrefUtils.products.add(responseProducts[0]);

            // إرجاع المنتج الجديد عند العودة
            Get.back(result: responseProducts[0]);
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static updateProduct({
    required Map<String, dynamic>? maps,
    required int id,
    required OnResponse onResponse,
  }) {
    Api.write(
      model: "product.template",
      ids: [id],
      values: maps!,
      onResponse: (response) {
        readProducts(
          ids: [id],
          onResponse: (onResponse) {
            // Get.off(() => ProductDetails(onResponse[0]));
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static deleteProduct({
    required int id,
    required OnResponse onResponse,
    required BuildContext context,
  }) {
    Api.unlink(
      model: "product.template",
      ids: [id],
      onResponse: (response) {
        if (response) {
          onResponse(response);
        }
      },
      onError: (String error, Map<String, dynamic> data) {
        // استخراج الرسالة من JSON
        String errorMessage = error;
        if (data.containsKey('error') &&
            data['error']['data'] != null &&
            data['error']['data']['message'] != null) {
          errorMessage = data['error']['data']['message'];
        }

        // عرض رسالة الخطأ داخل Dialog
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        print('Error: $errorMessage');
      },
    );
  }

  /// 🎯 حساب سعر المنتج من قائمة الأسعار المحلية
  static Future<Map<String, dynamic>?> getProductPriceFromLocalPricelist({
    required int productId,
    required int pricelistId,
    required double productListPrice,
    required int quantity,
  }) async {
    try {
      // البحث عن قائمة الأسعار
      final pricelist = PrefUtils.listesPrix.firstWhereOrNull(
        (p) => p.id == pricelistId,
      );

      if (pricelist == null || pricelist.items == null) {
        if (kDebugMode) {
          print('⚠️ Pricelist not found or has no items');
        }
        return null;
      }

      // ترتيب القواعد حسب الأولوية
      final sortedRules = _sortPricelistRules(pricelist.items!);

      // البحث عن القاعدة المناسبة
      PricelistItem? matchingRule;

      for (var rule in sortedRules) {
        if (_doesRuleApply(rule, productId, quantity)) {
          matchingRule = rule;
          break;
        }
      }

      if (matchingRule == null) {
        if (kDebugMode) {
          print('⚠️ No matching pricelist rule found');
        }
        return null;
      }

      // حساب السعر النهائي
      final priceData = _calculatePrice(
        rule: matchingRule,
        productListPrice: productListPrice,
        quantity: quantity,
      );

      if (kDebugMode) {
        print('✅ Price calculated from pricelist');
        print('   Rule: ${matchingRule.name}');
        print('   Applied on: ${matchingRule.appliedOn}');
        print('   Compute price: ${matchingRule.computePrice}');
        print('   Final discount: ${priceData['discount']}%');
        print('   Final price: ${priceData['price']} Dh');
      }

      return priceData;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error calculating price from pricelist: $e');
      }
      return null;
    }
  }

  /// 🔄 تحديث سعر المنتج عند تغيير الكمية
  static Future<Map<String, dynamic>?> updatePriceOnQuantityChange({
    required int productId,
    required int pricelistId,
    required double productListPrice,
    required int newQuantity,
  }) async {
    return await getProductPriceFromLocalPricelist(
      productId: productId,
      pricelistId: pricelistId,
      productListPrice: productListPrice,
      quantity: newQuantity,
    );
  }

  /// 🎯 جلب جميع القواعد المطبقة على منتج معين
  static List<PricelistItem> getApplicableRulesForProduct({
    required int productId,
    required int pricelistId,
    required int quantity,
  }) {
    final pricelist = PrefUtils.listesPrix.firstWhereOrNull(
      (p) => p.id == pricelistId,
    );

    if (pricelist == null || pricelist.items == null) {
      return [];
    }

    return pricelist.items!.where((rule) {
      return _doesRuleApply(rule, productId, quantity);
    }).toList();
  }

  /// ترتيب قواعد قائمة الأسعار حسب الأولوية
  static List<PricelistItem> _sortPricelistRules(List<PricelistItem> rules) {
    final sortedRules = List<PricelistItem>.from(rules);

    sortedRules.sort((a, b) {
      // 1. حسب نوع التطبيق (applied_on)
      final priorityA = _getAppliedOnPriority(a.appliedOn);
      final priorityB = _getAppliedOnPriority(b.appliedOn);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // 2. حسب الكمية الأدنى (الأكبر أولاً)
      final minQtyA = _parseDouble(a.minQuantity) ?? 0.0;
      final minQtyB = _parseDouble(b.minQuantity) ?? 0.0;

      return minQtyB.compareTo(minQtyA);
    });

    return sortedRules;
  }

  /// تحديد أولوية نوع التطبيق
  static int _getAppliedOnPriority(dynamic appliedOn) {
    final appliedOnStr = appliedOn.toString();

    if (appliedOnStr.contains('0_product_variant')) return 1;
    if (appliedOnStr.contains('1_product')) return 2;
    if (appliedOnStr.contains('2_product_category')) return 3;
    if (appliedOnStr.contains('3_global')) return 4;

    return 5;
  }

  /// التحقق من تطبيق القاعدة على المنتج
  static bool _doesRuleApply(PricelistItem rule, int productId, int quantity) {
    // التحقق من الكمية الأدنى
    final minQty = _parseDouble(rule.minQuantity) ?? 0.0;
    if (quantity < minQty) {
      return false;
    }

    // التحقق من تاريخ البدء والانتهاء
    if (!_isDateValid(rule.dateStart, rule.dateEnd)) {
      return false;
    }

    final appliedOnStr = rule.appliedOn.toString();

    // 1. قاعدة عامة
    if (appliedOnStr.contains('3_global')) {
      return true;
    }

    // 2. منتج محدد
    if (appliedOnStr.contains('0_product_variant') ||
        appliedOnStr.contains('1_product')) {
      if (rule.productTmplId == false || rule.productTmplId == null) {
        return false;
      }

      int ruleProductId;
      if (rule.productTmplId is List && rule.productTmplId.length > 0) {
        ruleProductId = rule.productTmplId[0];
      } else if (rule.productTmplId is int) {
        ruleProductId = rule.productTmplId;
      } else {
        return false;
      }

      return ruleProductId == productId;
    }

    // 3. فئة المنتج
    if (appliedOnStr.contains('2_product_category')) {
      return false;
    }

    return false;
  }

  /// التحقق من صلاحية التاريخ
  static bool _isDateValid(dynamic dateStart, dynamic dateEnd) {
    final now = DateTime.now();

    if (dateStart != null && dateStart != false && dateStart is String) {
      try {
        final startDate = DateTime.parse(dateStart);
        if (now.isBefore(startDate)) {
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error parsing date_start: $e');
        }
      }
    }

    if (dateEnd != null && dateEnd != false && dateEnd is String) {
      try {
        final endDate = DateTime.parse(dateEnd);
        if (now.isAfter(endDate)) {
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error parsing date_end: $e');
        }
      }
    }

    return true;
  }

  /// حساب السعر النهائي بناءً على القاعدة
  // product_module.dart - إصلاح قراءة price_discount

  static Map<String, dynamic> _calculatePrice({
    required PricelistItem rule,
    required double productListPrice,
    required int quantity,
  }) {
    final computePriceStr = rule.computePrice.toString();
    double finalPrice = productListPrice;
    double discount = 0.0;

    if (computePriceStr == 'fixed') {
      finalPrice = _parseDouble(rule.price) ?? productListPrice;
      discount = ((productListPrice - finalPrice) / productListPrice) * 100;
    } else if (computePriceStr == 'percentage') {
      // ✅ قراءة الخصم من JSON بشكل صحيح
      discount =
          _parseDiscountFromPrice(rule.price) ??
          _parseDouble(rule.priceDiscount) ??
          0.0;
      finalPrice = productListPrice * (1 - discount / 100);
    } else if (computePriceStr == 'formula') {
      discount = _parseDouble(rule.priceDiscount) ?? 0.0;
      finalPrice = productListPrice * (1 - discount / 100);
    }

    if (finalPrice < 0) {
      finalPrice = 0;
    }

    if (discount < 0) {
      discount = 0;
    }

    return {
      'price': finalPrice,
      'discount': discount,
      'rule_name': rule.name,
      'applied_on': rule.appliedOn,
    };
  }

  /// استخراج نسبة الخصم من النص مثل "10 % discount on..."
  static double? _parseDiscountFromPrice(dynamic priceValue) {
    if (priceValue == null || priceValue == false) return null;

    if (priceValue is String) {
      // استخراج الرقم من النص "10 % discount"
      final match = RegExp(r'(\d+\.?\d*)\s*%').firstMatch(priceValue);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '0');
      }
    }

    return null;
  }

  /// تحويل قيمة إلى double
  static double? _parseDouble(dynamic value) {
    if (value == null || value == false) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);

    return null;
  }
}
