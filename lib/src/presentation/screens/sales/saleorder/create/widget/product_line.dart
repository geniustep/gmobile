import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';

// ✅ إزالة ChangeNotifier لتجنب الـ loops
class ProductLine {
  // ============= Properties =============

  /// معلومات المنتج
  int productId;
  String productName;
  ProductModel? productModel;

  /// معرف السطر الأصلي (للتتبع في التعديل)
  dynamic _originalId;

  dynamic get originalId => _originalId;
  set originalId(dynamic value) => _originalId = value;

  /// الأسعار
  double listPrice = 0.0;
  double priceUnit = 0.0;
  double discountPercentage = 0.0;

  /// الكمية
  double quantity = 1;

  /// Controllers
  final TextEditingController quantityController;
  final TextEditingController discountController;
  final TextEditingController priceController;

  /// Form Key
  GlobalKey<FormBuilderState>? _formKey;

  /// القائمة الكاملة للمنتجات (للبحث)
  final List<ProductModel> availableProducts;

  /// Widget Key
  final Key? key;

  /// حالة التحديث (لمنع الحلقات اللا نهائية)
  bool _isUpdatingControllers = false;

  // ============= Constructor =============

  ProductLine({
    required this.productId,
    required this.productName,
    required this.availableProducts,
    this.key,
    double? defaultQuantity,
    double? defaultPrice,
    double? defaultDiscount,
  }) : quantityController = TextEditingController(),
       discountController = TextEditingController(),
       priceController = TextEditingController() {
    // تهيئة القيم بعد إنشاء الـ controllers
    _initializeValues(
      quantity: defaultQuantity,
      price: defaultPrice,
      discount: defaultDiscount,
    );

    if (kDebugMode) {
      print('✅ ProductLine created: $productName (ID: $productId)');
    }
  }

  /// تهيئة القيم الأولية بشكل آمن
  void _initializeValues({double? quantity, double? price, double? discount}) {
    _isUpdatingControllers = true;

    this.quantity = quantity ?? 1;
    quantityController.text = this.quantity.toStringAsFixed(0);

    if (price != null) {
      priceUnit = price;
      listPrice = price;
    }
    priceController.text = priceUnit.toStringAsFixed(2);

    discountPercentage = discount ?? 0.0;
    discountController.text = discountPercentage.toStringAsFixed(1);

    _isUpdatingControllers = false;
  }

  // ============= Setters =============

  /// تعيين Form Key
  void setFormKey(GlobalKey<FormBuilderState> key) {
    _formKey = key;

    if (kDebugMode) {
      print('🔑 Form key set for: $productName');
    }
  }

  /// تعيين المنتج
  void setProduct(ProductModel product) {
    productModel = product;
    productId = product.id;
    productName = product.name;
    listPrice = product.lst_price?.toDouble() ?? 0.0;
    priceUnit = listPrice;
    discountPercentage = 0.0;

    // تحديث الـ controllers بشكل آمن
    _updateControllers();

    if (kDebugMode) {
      print('📦 Product set: $productName');
      print('   List Price: $listPrice Dh');
      print('   Price Unit: $priceUnit Dh');
    }
  }

  // ============= Price & Discount =============

  /// تطبيق خصم
  void applyDiscount(double discount) {
    if (discount < 0) discount = 0;
    if (discount > 100) discount = 100;

    discountPercentage = discount;
    priceUnit = listPrice * (1 - discount / 100);

    // تحديث الـ controllers بشكل آمن
    _updateControllers();

    if (kDebugMode) {
      print('💰 Discount applied: $discount%');
      print('   New Price: $priceUnit Dh');
      print('   Savings: ${getSavings()} Dh');
    }
  }

  /// تحديث السعر
  void updatePrice(double newPrice) {
    setPrice(newPrice);
  }

  void setPrice(double price) {
    if (price < 0) price = 0;

    priceUnit = price;

    // حساب نسبة الخصم من السعر الجديد
    if (listPrice > 0) {
      discountPercentage = ((listPrice - price) / listPrice) * 100;
      if (discountPercentage < 0) discountPercentage = 0;
      if (discountPercentage > 100) discountPercentage = 100;
    } else {
      discountPercentage = 0.0;
    }

    // تحديث الـ controllers
    _updateControllers();

    if (kDebugMode) {
      print('💵 Price set: $price Dh');
      print(
        '   Calculated discount: ${discountPercentage.toStringAsFixed(1)}%',
      );
    }
  }

  /// تحديث جميع الـ controllers بشكل آمن
  void _updateControllers() {
    if (_isUpdatingControllers) return;

    _isUpdatingControllers = true;

    // تحديث Quantity Controller
    final quantityText = quantity.toStringAsFixed(0);
    if (quantityController.text != quantityText) {
      quantityController.text = quantityText;
    }

    // تحديث Price Controller
    final priceText = priceUnit.toStringAsFixed(2);
    if (priceController.text != priceText) {
      priceController.text = priceText;
    }

    // تحديث Discount Controller
    final discountText = discountPercentage.toStringAsFixed(1);
    if (discountController.text != discountText) {
      discountController.text = discountText;
    }

    _isUpdatingControllers = false;
  }

  /// تطبيق سعر وخصم معاً
  void applyPriceAndDiscount({
    required double price,
    required double discount,
  }) {
    if (discount < 0) discount = 0;
    if (discount > 100) discount = 100;

    priceUnit = price;
    discountPercentage = discount;

    // تحديث الـ controllers بشكل آمن
    _updateControllers();

    if (kDebugMode) {
      print('💰 Price and discount set:');
      print('   Price: $price Dh');
      print('   Discount: $discount%');
    }
  }

  // ============= Calculations =============

  /// حساب السعر الإجمالي
  double getTotalPrice() {
    return priceUnit * quantity;
  }

  /// حساب المبلغ الموفر
  double getSavings() {
    return (listPrice - priceUnit) * quantity;
  }

  /// حساب نسبة الخصم الفعلي
  double getActualDiscountPercentage() {
    if (listPrice == 0) return 0.0;
    return ((listPrice - priceUnit) / listPrice) * 100;
  }

  // ============= Validation =============

  /// التحقق من صحة البيانات
  bool validate() {
    // التحقق من Form
    if (!(_formKey?.currentState?.saveAndValidate() ?? false)) {
      return false;
    }

    // التحقق من المنتج
    if (productModel == null) {
      return false;
    }

    // التحقق من الكمية
    if (quantity <= 0) {
      return false;
    }

    return true;
  }

  // ============= Helpers =============

  /// تحديث الكمية
  void updateQuantity(double newQuantity) {
    if (newQuantity <= 0) return;

    quantity = newQuantity;

    // تحديث الـ controller فقط إذا لم يكن في حالة تحديث
    if (!_isUpdatingControllers) {
      _isUpdatingControllers = true;
      quantityController.text = newQuantity.toStringAsFixed(0);
      _isUpdatingControllers = false;
    }

    // ✅ إزالة notifyListeners() - سيتم التحديث يدوياً من OrderController
  }

  /// تحديث الخصم
  void updateDiscount(double newDiscount) {
    applyDiscount(newDiscount);
  }

  /// الحصول على حالة التحديث (للاستخدام الخارجي)
  bool get isUpdating => _isUpdatingControllers;

  /// نسخ ProductLine
  ProductLine copy() {
    final copy = ProductLine(
      productId: productId,
      productName: productName,
      availableProducts: availableProducts,
      key: key,
      defaultQuantity: quantity,
      defaultPrice: priceUnit,
      defaultDiscount: discountPercentage,
    );

    copy.productModel = productModel;
    copy.listPrice = listPrice;
    copy._formKey = _formKey;

    return copy;
  }

  // ============= Getters =============

  /// هل المنتج صالح؟
  bool get isValid => productModel != null && quantity > 0 && priceUnit >= 0;

  /// هل يوجد خصم؟
  bool get hasDiscount => discountPercentage > 0;

  /// معرف المنتج الآمن
  int get safeProductId => productModel?.id ?? productId;

  /// اسم المنتج الآمن
  String get safeProductName => productModel?.name ?? productName;

  // ============= Cleanup =============

  /// تنظيف الموارد
  void dispose() {
    quantityController.dispose();
    discountController.dispose();
    priceController.dispose();
    if (kDebugMode) {
      print('🗑️ ProductLine disposed: $productName');
    }
  }

  // ============= Debug =============

  @override
  String toString() {
    return 'ProductLine('
        'id: $productId, '
        'name: $productName, '
        'quantity: $quantity, '
        'price: $priceUnit, '
        'discount: $discountPercentage%, '
        'total: ${getTotalPrice()}'
        ')';
  }

  /// طباعة معلومات مفصلة
  void printDetails() {
    if (kDebugMode) {
      print('\n📦 ========== PRODUCT LINE DETAILS ==========');
      print('Product ID: $productId');
      print('Product Name: $productName');
      print('Quantity: $quantity');
      print('List Price: ${listPrice.toStringAsFixed(2)} Dh');
      print('Discount: ${discountPercentage.toStringAsFixed(1)}%');
      print('Price Unit: ${priceUnit.toStringAsFixed(2)} Dh');
      print('Total Price: ${getTotalPrice().toStringAsFixed(2)} Dh');
      print('Savings: ${getSavings().toStringAsFixed(2)} Dh');
      print('Valid: $isValid');
      print('Is Updating: $_isUpdatingControllers');
      print('==========================================\n');
    }
  }

  // ============= Helper Methods =============

  /// تحويل إلى Map للاستخدام في API
  Map<String, dynamic> toMap() {
    // ✅ إرسال السعر الصحيح حسب الحالة
    final isDiscount = priceUnit < listPrice; // خصم

    return {
      'product_id': productId,
      'product_uom_qty': quantity,
      'price_unit': isDiscount
          ? listPrice
          : priceUnit, // السعر الأصلي للخصم، السعر النهائي للزيادة
      'discount': isDiscount
          ? discountPercentage
          : 0.0, // الخصم فقط عند وجود خصم
      'name': productName,
    };
  }

  /// التحقق من وجود تغييرات
  bool hasChanges(ProductLine other) {
    return productId != other.productId ||
        quantity != other.quantity ||
        priceUnit != other.priceUnit ||
        discountPercentage != other.discountPercentage;
  }
}
