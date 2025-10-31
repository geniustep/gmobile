// lib/src/presentation/screens/sales/saleorder/create/controllers/order_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/services/price_management_service.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class OrderController extends GetxController {
  // ============= State =============

  final RxList<ProductLine> productLines = <ProductLine>[].obs;
  final RxSet<int> selectedProductIds = <int>{}.obs;
  final RxInt editingLineIndex = (-1).obs;
  final RxDouble orderTotal = 0.0.obs;
  final Map<int, GlobalKey<FormBuilderState>> lineFormKeys = {};

  List<ProductModel> availableProducts = [];
  dynamic selectedPriceListId;
  List<PricelistModel> priceLists = [];

  // ============= Performance Optimization =============
  bool _isBatchUpdating = false;
  Timer? _updateTimer;
  Timer? _totalCalculationTimer;

  // ============= Services =============
  final PriceManagementService _priceService = PriceManagementService();

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    // ✅ إزالة ever() - سنقوم بالتحديث يدوياً عند الحاجة فقط
    if (kDebugMode) {
      print('✅ OrderController initialized');
    }
  }

  @override
  void onClose() {
    // ✅ إلغاء الـ timers
    _updateTimer?.cancel();
    _totalCalculationTimer?.cancel();

    for (var line in productLines) {
      line.dispose();
    }
    if (kDebugMode) {
      print('🗑️ OrderController disposed');
    }
    super.onClose();
  }

  // ============= Initialization =============

  void initialize({
    required List<ProductModel> products,
    required List<PricelistModel> allPriceLists,
    dynamic priceListId,
  }) {
    availableProducts = products;
    priceLists = allPriceLists;
    selectedPriceListId = priceListId;

    if (kDebugMode) {
      print('📦 OrderController initialized with:');
      print('   Products: ${products.length}');
      print('   Price Lists: ${allPriceLists.length}');
      print('   Selected Price List: $priceListId');
    }
  }

  // ============= Performance Optimization Methods =============

  /// جدولة التحديث مع debounce لتقليل التحديثات
  void _scheduleUpdate() {
    if (_isBatchUpdating) return;

    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 100), () {
      _isBatchUpdating = true;
      _calculateTotal();
      update(['product_lines']);
      _isBatchUpdating = false;
    });
  }

  // تم دمج _scheduleTotalCalculation في _scheduleUpdate

  /// تحديث الكمية مع batch update
  void updateQuantity(int index, double quantity) {
    if (index >= 0 && index < productLines.length) {
      productLines[index].updateQuantity(quantity);
      _scheduleUpdate(); // بدلاً من update مباشرة
    }
  }

  /// تحديث السعر مع batch update
  void updatePrice(int index, double price) {
    if (index >= 0 && index < productLines.length) {
      productLines[index].updatePrice(price);
      _scheduleUpdate();
    }
  }

  /// تحديث الخصم مع batch update
  void updateDiscount(int index, double discount) {
    if (index >= 0 && index < productLines.length) {
      productLines[index].updateDiscount(discount);
      _scheduleUpdate();
    }
  }

  // ============= Product Management =============

  Future<void> addProduct(ProductModel product) async {
    if (kDebugMode) {
      print('\n➕ Adding product: ${product.name} (ID: ${product.id})');
    }

    if (selectedProductIds.contains(product.id)) {
      if (kDebugMode) {
        print('⚠️ Product already exists');
      }
      return;
    }

    final line = ProductLine(
      key: UniqueKey(),
      productId: product.id,
      productName: product.name,
      availableProducts: availableProducts,
    );

    line.setProduct(product);

    productLines.add(line);
    selectedProductIds.add(product.id);

    final formKey = GlobalKey<FormBuilderState>();
    lineFormKeys[productLines.length - 1] = formKey;
    line.setFormKey(formKey);

    // ✅ استخدام await إذا كانت هناك قوائم أسعار
    if (priceLists.isNotEmpty && selectedPriceListId != null) {
      await updateLinePrice(line);
    } else {
      // إذا لم تكن هناك قوائم أسعار، نحدث الإجمالي مباشرة
      _calculateTotal();
    }

    // ✅ تحديث UI
    update(['product_lines']);

    if (kDebugMode) {
      print('✅ Product added successfully');
      print('   Total products: ${productLines.length}');
      print('   Total amount: ${orderTotal.value.toStringAsFixed(2)} Dh');
    }
  }

  Future<void> _applyPriceListToLine(ProductLine line) async {
    if (selectedPriceListId == null ||
        line.productModel == null ||
        priceLists.isEmpty) {
      return;
    }

    try {
      // تقليل الـ logging للتحسين من الأداء
      if (kDebugMode) {
        print('💰 Applying pricelist to: ${line.productName}');
      }

      // البحث عن قائمة الأسعار
      final priceList = priceLists.firstWhereOrNull(
        (p) => p.id == selectedPriceListId,
      );

      if (priceList == null ||
          priceList.items == null ||
          priceList.items!.isEmpty) {
        return;
      }

      // ✅ استخدام الخدمة الجديدة للبحث عن القاعدة المناسبة
      final matchingRule = _priceService.findMatchingRule(
        line: line,
        rules: priceList.items!,
      );

      if (matchingRule != null) {
        // ✅ استخدام الخدمة الجديدة لحساب السعر
        final result = _priceService.calculatePrice(
          line: line,
          rule: matchingRule,
        );

        if (result.hasAppliedRule) {
          // تطبيق السعر النهائي
          line.applyPriceAndDiscount(
            price: result.finalPrice,
            discount: result.discount,
          );

          if (kDebugMode) {
            print('   ✅ Price applied: ${line.priceUnit} Dh');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('   ❌ Error applying pricelist: $e');
        print('   Stack trace: ${StackTrace.current}');
      }
    }
  }

  // ============= Price List Updates =============

  /// تحديث أسعار جميع المنتجات بقائمة أسعار جديدة
  Future<void> updateAllProductsPrices(int priceListId) async {
    // ✅ التحقق من وجود قوائم أسعار قبل التحديث
    if (priceLists.isEmpty) {
      if (kDebugMode) {
        print('⚠️ No price lists available - skipping price updates');
      }
      return;
    }

    if (productLines.isEmpty) {
      if (kDebugMode) {
        print('⚠️ No products to update');
      }
      return;
    }

    if (kDebugMode) {
      print('\n🔄 ========== UPDATING ALL PRICES ==========');
      print('New Pricelist ID: $priceListId');
      print('Products count: ${productLines.length}');
      print('Available price lists: ${priceLists.length}');
    }

    selectedPriceListId = priceListId;

    // عرض dialog التحديث
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحديث الأسعار...'),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    int completed = 0;
    int updated = 0;

    for (var line in productLines) {
      if (line.productModel != null) {
        final oldPrice = line.priceUnit;
        final oldDiscount = line.discountPercentage;

        await _applyPriceListToLine(line);

        if (line.priceUnit != oldPrice ||
            line.discountPercentage != oldDiscount) {
          updated++;

          if (kDebugMode) {
            print('   ✅ ${line.productName}:');
            print(
              '      Old: ${oldPrice.toStringAsFixed(2)} Dh (-${oldDiscount.toStringAsFixed(1)}%)',
            );
            print(
              '      New: ${line.priceUnit.toStringAsFixed(2)} Dh (-${line.discountPercentage.toStringAsFixed(1)}%)',
            );
          }
        }
      }
      completed++;
    }

    // إغلاق Dialog
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    // ✅ تحديث UI مرة واحدة فقط بعد الانتهاء من كل المنتجات
    update(['product_lines']);
    _calculateTotal();

    // عرض رسالة النجاح فقط إذا تم تحديث شيء
    if (updated > 0) {
      Get.snackbar(
        'تم التحديث',
        'تم تحديث $updated من $completed منتج',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    }

    if (kDebugMode) {
      print('\n✅ ========== PRICES UPDATE COMPLETE ==========');
      print('Updated: $updated / $completed products');
      print('New Total: ${orderTotal.value.toStringAsFixed(2)} Dh');
      print('=========================================\n');
    }
  }

  /// تحديث السعر لمنتج واحد
  Future<void> updateLinePrice(ProductLine line) async {
    await _applyPriceListToLine(line);
    // ✅ تحديث الإجمالي يدوياً
    _calculateTotal();
  }

  // ============= Line Editing =============

  void editLine(int index) {
    if (kDebugMode) {
      print('\n✏️ Editing line $index');
    }

    if (editingLineIndex.value != -1) {
      saveLineEditing();
    }

    editingLineIndex.value = index;
  }

  void saveLineEditing() {
    if (editingLineIndex.value == -1) return;

    final line = productLines[editingLineIndex.value];

    if (kDebugMode) {
      print('\n💾 Saving line edits');
      print('   Product: ${line.productName}');
      print('   Quantity: ${line.quantity}');
      print('   Price: ${line.priceUnit} Dh');
      print('   Discount: ${line.discountPercentage}%');
    }

    editingLineIndex.value = -1;

    // ✅ تحديث UI
    update(['product_lines']);

    // ✅ تحديث الإجمالي يدوياً
    _calculateTotal();
  }

  void cancelEditing() {
    if (kDebugMode) {
      print('\n❌ Canceling line edits');
    }

    editingLineIndex.value = -1;

    // ✅ تحديث UI
    update(['product_lines']);
  }

  // ============= Line Management =============

  void deleteLine(int index) {
    if (kDebugMode) {
      print('\n🗑️ Deleting line $index');
    }

    if (index < 0 || index >= productLines.length) {
      if (kDebugMode) {
        print('❌ Invalid index: $index');
      }
      return;
    }

    final line = productLines[index];
    selectedProductIds.remove(line.productId);
    line.dispose();

    productLines.removeAt(index);
    lineFormKeys.remove(index);

    final keysToUpdate = <int, GlobalKey<FormBuilderState>>{};
    for (var i = index; i < productLines.length; i++) {
      if (lineFormKeys.containsKey(i + 1)) {
        keysToUpdate[i] = lineFormKeys[i + 1]!;
      }
    }
    lineFormKeys.removeWhere((key, value) => key > index);
    keysToUpdate.forEach((key, value) {
      lineFormKeys[key] = value;
    });

    // ✅ تحديث UI
    update(['product_lines']);

    // ✅ تحديث الإجمالي يدوياً
    _calculateTotal();

    if (kDebugMode) {
      print('✅ Line deleted');
      print('   Remaining products: ${productLines.length}');
      print('   Total: ${orderTotal.value.toStringAsFixed(2)} Dh');
    }
  }

  // ============= Calculations =============

  void _calculateTotal() {
    if (_isBatchUpdating) return;

    final total = productLines.fold<double>(
      0.0,
      (sum, line) => sum + line.getTotalPrice(),
    );

    orderTotal.value = total;
  }

  double getOrderTotal() {
    return orderTotal.value;
  }

  double getOrderSubtotal() {
    return productLines.fold(0.0, (sum, line) {
      return sum + (line.listPrice * line.quantity);
    });
  }

  double getOrderDiscount() {
    return getOrderSubtotal() - getOrderTotal();
  }

  double getOrderSavings() {
    return productLines.fold(0.0, (sum, line) => sum + line.getSavings());
  }

  // ============= Validation =============

  bool validateAllLines() {
    if (kDebugMode) {
      print('\n🔍 Validating all product lines...');
    }

    if (productLines.isEmpty) {
      if (kDebugMode) {
        print('❌ No products to validate');
      }
      return false;
    }

    for (var i = 0; i < productLines.length; i++) {
      final line = productLines[i];

      if (line.productModel == null) {
        if (kDebugMode) {
          print('❌ Line $i: Product model is null');
        }
        return false;
      }

      if (line.quantity <= 0) {
        if (kDebugMode) {
          print('❌ Line $i: Invalid quantity (${line.quantity})');
        }
        return false;
      }

      if (line.priceUnit < 0) {
        if (kDebugMode) {
          print('❌ Line $i: Invalid price (${line.priceUnit})');
        }
        return false;
      }

      if (kDebugMode) {
        print('✅ Line $i valid: ${line.productName} x${line.quantity}');
      }
    }

    if (kDebugMode) {
      print('✅ All lines validated successfully');
    }

    return true;
  }

  // ============= Data Retrieval =============

  List<Map<String, dynamic>> getProductLinesData() {
    if (kDebugMode) {
      print('\n💾 ========== SAVING DRAFT DATA ==========');
    }

    return productLines.map((line) {
      if (kDebugMode) {
        print('Product: ${line.productName}');
        print('  listPrice: ${line.listPrice}');
        print('  priceUnit: ${line.priceUnit}');
        print('  discountPercentage: ${line.discountPercentage}%');
        print('  quantity: ${line.quantity}');
        print('  total: ${line.getTotalPrice()} Dh');
      }

      return {
        'productId': line.productModel?.id ?? line.productId,
        'productName': line.productModel?.name ?? line.productName,
        'quantity': line.quantity.toDouble(),
        'price': line.priceUnit,
        'discount': line.discountPercentage,
        'listPrice': line.listPrice,
      };
    }).toList();
  }

  // ============= Server Data (for Odoo API) =============

  List<Map<String, dynamic>> getServerProductLinesData() {
    return productLines.map((line) {
      return {
        'product_id': line.productModel?.id ?? line.productId,
        'product_uom_qty': line.quantity.toDouble(),
        'price_unit': line.listPrice,
        'discount': line.discountPercentage,
      };
    }).toList();
  }

  List<Map<String, dynamic>> getDisplayProductLinesData() {
    return productLines.map((line) {
      return {
        'productId': line.productModel?.id ?? line.productId,
        'productName': line.productModel?.name ?? line.productName,
        'quantity': line.quantity.toDouble(),
        'displayPrice': line.priceUnit,
        'originalPrice': line.listPrice,
        'discount': line.discountPercentage,
        'total': line.getTotalPrice(),
      };
    }).toList();
  }

  Future<void> loadFromDraft(List<dynamic> productsData) async {
    if (kDebugMode) {
      print('\n📥 ========== LOADING DRAFT ==========');
      print('Products count: ${productsData.length}');
    }

    clearAll();

    for (var i = 0; i < productsData.length; i++) {
      final productData = productsData[i];

      try {
        final productId = productData['productId'];
        final quantity = (productData['quantity'] ?? 1.0).toDouble();
        final price = (productData['price'] ?? 0.0).toDouble();
        final discount = (productData['discount'] ?? 0.0).toDouble();

        if (kDebugMode) {
          print('\n🔍 ========== LOADING PRODUCT $i ==========');
          print('Product ID: $productId');
          print('Quantity: $quantity');
          print('Price from draft: $price');
          print('Discount from draft: $discount%');
        }

        final product = availableProducts.firstWhere((p) => p.id == productId);

        if (kDebugMode) {
          print('Product found: ${product.name}');
          print('Product list_price: ${product.list_price}');
        }

        final line = ProductLine(
          key: UniqueKey(),
          productId: product.id,
          productName: product.name,
          availableProducts: availableProducts,
          defaultQuantity: quantity.toInt(),
          defaultPrice: price,
          defaultDiscount: discount,
        );

        line.setProduct(product);

        if (kDebugMode) {
          print('After setProduct:');
          print('  listPrice: ${line.listPrice}');
          print('  priceUnit: ${line.priceUnit}');
          print('  discountPercentage: ${line.discountPercentage}%');
        }

        line.priceUnit = price;
        line.discountPercentage = discount;
        line.quantity = quantity.toInt();
        line.quantityController.text = quantity.toInt().toString();

        if (kDebugMode) {
          print('After applyPriceAndDiscount:');
          print('  listPrice: ${line.listPrice}');
          print('  priceUnit: ${line.priceUnit}');
          print('  discountPercentage: ${line.discountPercentage}%');
        }

        if (discount > 0) {
          line.listPrice = price / (1 - discount / 100);
        } else {
          line.listPrice = price;
        }

        line.priceController.text = line.priceUnit.toStringAsFixed(2);
        line.discountController.text = line.discountPercentage.toStringAsFixed(
          1,
        );

        if (kDebugMode) {
          print('After recalculating listPrice:');
          print('  listPrice: ${line.listPrice}');
          print('  priceUnit: ${line.priceUnit}');
          print('  discountPercentage: ${line.discountPercentage}%');
          print('  Total: ${line.getTotalPrice()} Dh');
          print('==========================================\n');
        }

        final formKey = GlobalKey<FormBuilderState>();
        lineFormKeys[i] = formKey;
        line.setFormKey(formKey);

        productLines.add(line);
        selectedProductIds.add(product.id);

        if (kDebugMode) {
          print('   ✅ Loaded: ${line.productName} x${line.quantity}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('   ❌ Error loading product $i: $e');
        }
      }
    }

    _calculateTotal();

    if (kDebugMode) {
      print('✅ Draft loaded: ${productLines.length} products');
      print('   Total: ${orderTotal.value.toStringAsFixed(2)} Dh');
    }
  }

  void clearAll() {
    if (kDebugMode) {
      print('\n🗑️ Clearing all order data...');
    }

    for (var line in productLines) {
      line.dispose();
    }

    productLines.clear();
    selectedProductIds.clear();
    lineFormKeys.clear();
    editingLineIndex.value = -1;
    orderTotal.value = 0.0;

    if (kDebugMode) {
      print('✅ All data cleared');
    }
  }

  // ============= Getters =============

  bool get hasProducts => productLines.isNotEmpty;
  int get productsCount => productLines.length;
  bool get isEditing => editingLineIndex.value != -1;

  ProductLine? get editingLine {
    if (editingLineIndex.value == -1) return null;
    if (editingLineIndex.value >= productLines.length) return null;
    return productLines[editingLineIndex.value];
  }

  GlobalKey<FormBuilderState>? get editingFormKey {
    if (editingLineIndex.value == -1) return null;
    return lineFormKeys[editingLineIndex.value];
  }
}
