import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/controllers/controllers.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/order_form_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_selection_dialog.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line_card.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line_editor.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/sales_quantity_selector.dart';
import 'package:gsloution_mobile/common/widgets/barcodeScannerPage.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/saleOrderDetail/sale_order_new_detail_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/services/order_update_service.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class UpdateOrder extends StatefulWidget {
  final OrderModel salesOrder;
  final RxList<OrderLineModel> orderLine;
  const UpdateOrder({
    super.key,
    required this.salesOrder,
    required this.orderLine,
  });

  @override
  // ignore: library_private_types_in_public_api
  _UpdateOrderState createState() => _UpdateOrderState();
}

class _UpdateOrderState extends State<UpdateOrder> {
  // ✅ استخدام نفس الكونترولرز من صفحة الإنشاء
  late final OrderController orderController;
  late final PartnerController partnerController;
  late final DraftController draftController;

  // ✅ متغيرات التطبيق
  final RxBool _isLoading = false.obs;
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  // ✅ بيانات الطلب الأصلي
  late final OrderModel _originalOrder;
  late final RxList<OrderLineModel> _originalOrderLines;
  final List<int> _originalOrderLineIds = [];
  final Map<int, int> _lineIdMap =
      {}; // خريطة بين ProductLine index و OrderLine ID

  // ✅ متغيرات الحالة
  final RxBool _hasChanges = false.obs;
  final RxBool _isSaving = false.obs;

  // ✅ Constructor
  _UpdateOrderState();

  @override
  void initState() {
    super.initState();
    _originalOrder = widget.salesOrder;
    _originalOrderLines = widget.orderLine;
    _initializeControllers();
    _loadOrderData();
  }

  @override
  void dispose() {
    // ✅ تنظيف الكونترولرز عند الخروج
    if (kDebugMode) {
      print('🗑️ UpdateOrder disposed');
    }
    super.dispose();
  }

  // ✅ تهيئة الكونترولرز
  void _initializeControllers() {
    if (kDebugMode) {
      print('📦 Initializing controllers for update...');
    }

    // تهيئة الكونترولرز
    orderController = Get.put(OrderController());
    partnerController = Get.put(PartnerController());
    draftController = Get.put(DraftController());

    // تهيئة البيانات
    final products = PrefUtils.products.toList();
    final priceLists = PrefUtils.listesPrix.toList();

    orderController.initialize(
      products: products,
      allPriceLists: priceLists.isEmpty ? [] : priceLists,
      priceListId: null, // سيتم تحديثه لاحقاً
    );

    // ✅ تهيئة PartnerController بشكل صحيح
    partnerController.initialize();

    // ✅ التأكد من تحميل الشركاء
    if (partnerController.partners.isEmpty) {
      partnerController.partners.value = PrefUtils.partners.toList();
    }

    // ✅ التأكد من تحميل قوائم الأسعار
    if (partnerController.allPriceLists.isEmpty) {
      partnerController.allPriceLists.value = PrefUtils.listesPrix.toList();
    }

    // ✅ تحديث OrderController بقائمة الأسعار من PartnerController
    if (partnerController.priceListId != null) {
      orderController.selectedPriceListId = partnerController.priceListId;
      if (kDebugMode) {
        print(
          '💰 Synced OrderController with PartnerController price list ID: ${partnerController.priceListId}',
        );
      }
    }

    if (kDebugMode) {
      print('✅ Controllers initialized for update');
    }
  }

  // ✅ تحميل بيانات الطلب
  Future<void> _loadOrderData() async {
    if (kDebugMode) {
      print('\n📥 ========== LOADING ORDER DATA ==========');
      print('Order ID: ${_originalOrder.id}');
      print('Order Name: ${_originalOrder.name}');
      print('Partner: ${_originalOrder.partnerId}');
      print('Order Lines: ${_originalOrderLines.length}');
      print('Widget SalesOrder ID: ${widget.salesOrder.id}');
      print('Widget SalesOrder Name: ${widget.salesOrder.name}');
    }

    try {
      _isLoading.value = true;

      // تحميل العميل
      if (_originalOrder.partnerId != null) {
        if (kDebugMode) {
          print('   👤 Loading partner: ${_originalOrder.partnerId}');
        }

        // ✅ التعامل مع partnerId كـ List أو int
        dynamic partnerId;
        if (_originalOrder.partnerId is List) {
          partnerId = (_originalOrder.partnerId as List).first as dynamic;
        } else {
          partnerId = _originalOrder.partnerId as dynamic;
        }

        if (partnerId != null) {
          // ✅ التأكد من أن الشركاء محملون قبل الاختيار
          if (partnerController.partners.isEmpty) {
            if (kDebugMode) {
              print('   ⚠️ Partners not loaded yet, loading from PrefUtils...');
            }
            // تحميل الشركاء من PrefUtils
            partnerController.partners.value = PrefUtils.partners.toList();
            await Future.delayed(const Duration(milliseconds: 200));
          }

          if (kDebugMode) {
            print(
              '   📋 Available partners: ${partnerController.partners.length}',
            );
            print('   Looking for partner ID: $partnerId');
          }

          // ✅ التحقق من وجود الشريك قبل الاختيار
          final partnerExists = partnerController.partners.any(
            (p) => p.id == partnerId,
          );
          if (!partnerExists) {
            if (kDebugMode) {
              print('   ❌ Partner with ID $partnerId not found');
              print(
                '   Available partner IDs: ${partnerController.partners.map((p) => p.id).toList()}',
              );
            }
          } else {
            partnerController.selectPartner(partnerId);
            await Future.delayed(const Duration(milliseconds: 200));
          }
        }
      }

      // تحميل قائمة الأسعار
      if (_originalOrder.pricelistId != null) {
        if (kDebugMode) {
          print('   💰 Loading price list: ${_originalOrder.pricelistId}');
        }

        // ✅ التعامل مع pricelistId كـ List أو int
        dynamic pricelistId;
        if (_originalOrder.pricelistId is List) {
          pricelistId = (_originalOrder.pricelistId as List).first as dynamic;
        } else {
          pricelistId = _originalOrder.pricelistId as dynamic;
        }

        if (pricelistId != null) {
          if (kDebugMode) {
            print('   🔍 Looking for price list ID: $pricelistId');
            print(
              '   Available price lists: ${partnerController.allPriceLists.length}',
            );
          }

          // ✅ البحث عن قائمة الأسعار وتحديدها
          try {
            final priceList = partnerController.allPriceLists.firstWhere(
              (p) => p.id == pricelistId,
            );
            partnerController.selectedPriceList.value = priceList;

            // ✅ تحديث قوائم الأسعار الخاصة بالشريك
            partnerController.partnerPriceLists.value = [priceList];

            if (kDebugMode) {
              print('   ✅ Price list selected: ${priceList.name}');
            }
          } catch (e) {
            if (kDebugMode) {
              print('   ❌ Price list with ID $pricelistId not found');
              print(
                '   Available price list IDs: ${partnerController.allPriceLists.map((p) => p.id).toList()}',
              );
            }
          }

          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      // تحميل المنتجات
      await _loadOrderLines();

      // ✅ تحديث OrderController بقائمة الأسعار المختارة
      if (partnerController.priceListId != null) {
        orderController.selectedPriceListId = partnerController.priceListId;
        if (kDebugMode) {
          print(
            '💰 Updated OrderController with price list ID: ${partnerController.priceListId}',
          );
        }
      }

      if (kDebugMode) {
        print('✅ Order data loaded successfully');
        print('   Products: ${orderController.productLines.length}');
        print('   Total: ${orderController.getOrderTotal()} Dh');
        print(
          '   Selected Partner: ${partnerController.selectedPartner.value?.name ?? "None"}',
        );
        print(
          '   Selected Price List: ${partnerController.selectedPriceList.value?.name ?? "None"}',
        );
        print(
          '   OrderController Price List ID: ${orderController.selectedPriceListId}',
        );
        print('=====================================\n');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR LOADING ORDER DATA ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('===============================================\n');
      }

      // ✅ تأجيل عرض رسالة الخطأ لتجنب مشكلة visitChildElements
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'خطأ',
          'حدث خطأ أثناء تحميل بيانات الطلب',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      });
    } finally {
      _isLoading.value = false;
    }
  }

  // ✅ تحميل خطوط الطلب
  Future<void> _loadOrderLines() async {
    if (kDebugMode) {
      print('📦 Loading ${_originalOrderLines.length} order lines...');
    }

    // ✅ مسح المنتجات الموجودة أولاً
    orderController.clearAll();

    for (var i = 0; i < _originalOrderLines.length; i++) {
      final orderLine = _originalOrderLines[i];

      try {
        // ✅ التعامل مع productId كـ List أو int
        dynamic productId;
        if (orderLine.productId is List) {
          productId = (orderLine.productId as List).first as dynamic;
        } else {
          productId = orderLine.productId as dynamic;
        }

        if (productId == null) {
          if (kDebugMode) {
            print('   ❌ Invalid product ID for line $i');
          }
          continue;
        }

        // البحث عن المنتج
        final product = PrefUtils.products.firstWhere((p) => p.id == productId);

        // ✅ إضافة المنتج مباشرة (بدون فحص التكرار في التعديل)
        final line = ProductLine(
          key: UniqueKey(),
          productId: product.id,
          productName: product.name,
          availableProducts: orderController.availableProducts,
        );

        line.setProduct(product);
        orderController.productLines.add(line);
        orderController.selectedProductIds.add(product.id);

        final formKey = GlobalKey<FormBuilderState>();
        orderController.lineFormKeys[orderController.productLines.length - 1] =
            formKey;
        line.setFormKey(formKey);

        // حفظ معرف خط الطلب الأصلي (إذا كان موجوداً)
        if (orderLine.id != null) {
          _originalOrderLineIds.add(orderLine.id!);
          _lineIdMap[orderController.productLines.length - 1] = orderLine.id!;

          // ✅ تعيين originalId للتتبع
          line.originalId = orderLine.id;
        }

        // تطبيق البيانات من خط الطلب
        line.quantity = orderLine.productUomQty?.toDouble() ?? 1.0;
        line.quantityController.text = line.quantity.toString();

        // ✅ تحميل البيانات الأصلية
        final originalPriceUnit = orderLine.priceUnit?.toDouble() ?? 0.0;
        final originalDiscount = orderLine.discount?.toDouble() ?? 0.0;

        if (kDebugMode) {
          print('   ✅ Product loaded: ${product.name}');
          print('      Quantity: ${line.quantity}');
          print('      Original Price Unit: $originalPriceUnit');
          print('      Original Discount: $originalDiscount%');
        }

        // ✅ تطبيق البيانات الأصلية
        if (originalDiscount > 0) {
          // إذا كان هناك خصم، السعر الأصلي هو originalPriceUnit
          line.listPrice = originalPriceUnit; // السعر الأصلي
          line.priceUnit =
              originalPriceUnit *
              (1 - originalDiscount / 100); // السعر النهائي (بعد الخصم)
          line.discountPercentage = originalDiscount;
        } else {
          // إذا لم يكن هناك خصم، استخدم السعر كما هو
          line.listPrice = originalPriceUnit;
          line.priceUnit = originalPriceUnit;
          line.discountPercentage = 0.0;
        }

        if (kDebugMode) {
          print('      Final Price Unit: ${line.priceUnit}');
          print('      List Price: ${line.listPrice}');
          print('      Discount: ${line.discountPercentage}%');
        }

        // تحديث الـ controllers
        line.priceController.text = line.priceUnit.toStringAsFixed(2);
        line.discountController.text = line.discountPercentage.toStringAsFixed(
          1,
        );

        // ✅ إجبار تحديث النموذج ليعرض الخصم
        line.quantityController.text = line.quantity.toString();

        // ✅ إجبار تحديث UI
        orderController.productLines.refresh();

        if (kDebugMode) {
          print('   📝 Controllers updated:');
          print('      Price: ${line.priceController.text}');
          print('      Discount: ${line.discountController.text}');
          print('      Quantity: ${line.quantityController.text}');
          print('      Total: ${line.getTotalPrice()} Dh');
        }

        // ✅ تطبيق قائمة الأسعار على المنتج (سيتم تطبيقه لاحقاً على جميع المنتجات)
        // orderController.updateLinePrice(orderController.productLines.length - 1);

        if (kDebugMode) {
          print('   ✅ Loaded: ${line.productName} x${line.quantity}');
          print('      Final Price: ${line.priceUnit} Dh');
          print('      List Price: ${line.listPrice} Dh');
          print('      Discount: ${line.discountPercentage}%');
          print('      Total: ${line.getTotalPrice()} Dh');
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('   ❌ Error loading order line $i: $e');
          print('   Stack trace: $stackTrace');
        }
      }
    }

    // ✅ تطبيق قائمة الأسعار على جميع المنتجات بعد التحميل
    // لكن فقط إذا لم يكن هناك خصم محفوظ مسبقاً
    if (partnerController.selectedPriceList.value != null) {
      if (kDebugMode) {
        print('💰 Checking if price list should be applied...');
        print(
          '   Price List: ${partnerController.selectedPriceList.value?.name}',
        );
        print('   Products to check: ${orderController.productLines.length}');
      }

      for (int i = 0; i < orderController.productLines.length; i++) {
        final line = orderController.productLines[i];

        // ✅ تطبيق قائمة الأسعار فقط إذا لم يكن هناك خصم محفوظ
        if (line.discountPercentage == 0.0) {
          if (kDebugMode) {
            print(
              '   🔄 Applying price list to product ${i + 1}: ${line.productName} (no existing discount)',
            );
            print(
              '      Before: Price=${line.priceUnit}, List=${line.listPrice}',
            );
          }

          await orderController.updateLinePrice(line);

          if (kDebugMode) {
            print(
              '      After: Price=${line.priceUnit}, List=${line.listPrice}',
            );
          }
        } else {
          if (kDebugMode) {
            print(
              '   ⏭️ Skipping product ${i + 1}: ${line.productName} (has existing discount: ${line.discountPercentage}%)',
            );
          }
        }
      }

      if (kDebugMode) {
        print('✅ Price list application completed');
      }
    }

    if (kDebugMode) {
      print(
        '✅ Order lines loaded: ${orderController.productLines.length} products',
      );
    }
  }

  // ✅ دالة إلغاء التعديل
  Future<void> _cancelUpdate() async {
    // التحقق من وجود تغييرات
    if (_hasChanges.value) {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('تأكيد الإلغاء'),
            ],
          ),
          content: const Text(
            'هل أنت متأكد من إلغاء التعديل؟\nسيتم فقدان جميع التغييرات المدخلة.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد الإلغاء'),
            ),
          ],
        ),
      );

      if (result != true) return;
    }

    // العودة للشاشة السابقة
    Get.back();
  }

  // ✅ دالة حفظ التعديلات
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.saveAndValidate()) {
      Get.snackbar(
        'خطأ',
        'يرجى ملء جميع الحقول المطلوبة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (!orderController.hasProducts) {
      Get.snackbar(
        'خطأ',
        'يرجى إضافة منتج واحد على الأقل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      _isSaving.value = true;

      if (kDebugMode) {
        print('\n💾 ========== SAVING ORDER CHANGES ==========');
        print('Order ID: ${_originalOrder.id}');
      }

      final updateService = OrderUpdateService();

      final formData = <String, dynamic>{
        'partner_id': partnerController.selectedPartner.value?.id,
        'pricelist_id': partnerController.priceListId,
        'payment_term_id': partnerController.paymentTermId,
        'commitment_date': null,
      };

      final success = await updateService.updateOrder(
        originalOrder: _originalOrder,
        formData: formData,
        productLines: orderController.productLines,
        originalOrderLines: _originalOrderLines,
        onProgress: (completed, total) {
          if (kDebugMode) {
            print('📊 Progress: $completed/$total');
          }
        },
      );

      if (success) {
        Get.snackbar(
          'تم الحفظ',
          'تم حفظ التعديلات بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // ✅ انتظار قليلاً للتأكد من اكتمال التحديث
        await Future.delayed(const Duration(milliseconds: 500));

        // ✅ إعادة تحميل الطلب المحدث
        final updatedOrder = await _getUpdatedOrderFromPrefs();

        if (updatedOrder != null && updatedOrder.id == _originalOrder.id) {
          if (kDebugMode) {
            print('✅ Navigating to detail screen with updated order');
          }

          // ✅ حذف جميع الصفحات حتى القائمة
          Get.until((route) => route.settings.name == AppRoutes.sales);

          // ✅ فتح صفحة تفاصيل جديدة
          Get.to(
            () => SaleOrderNewDetailScreen(
              salesOrder: updatedOrder,
              fromUpdate: true, // ✅ مهم جداً!
            ),
          );
        } else {
          if (kDebugMode) {
            print('⚠️ Failed to load updated order, going to sales list');
          }

          // ✅ في حالة الفشل، الذهاب للقائمة مباشرة
          Get.offAllNamed(AppRoutes.sales);
        }
      } else {
        throw Exception('Failed to update order');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving changes: $e');
      }

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء حفظ التعديلات: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      _isSaving.value = false;
    }
  }

  // ✅ دالة فتح اختيار المنتجات
  Future<void> _openProductSelection() async {
    if (!partnerController.hasPartner) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار العميل أولاً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.warning, color: Colors.white),
      );
      return;
    }

    if (kDebugMode) {
      print('🛒 Opening product selection dialog...');
      print('   Available products: ${PrefUtils.products.length}');
      print('   Selected product IDs: ${orderController.selectedProductIds}');
      print('   Price list ID: ${partnerController.priceListId}');
    }

    ProductModel? selectedProduct;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => ProductSelectionDialog(
        products: PrefUtils.products.toList(),
        selectedProductIds: orderController.selectedProductIds.toSet(),
        priceLists: partnerController.allPriceLists,
        selectedPriceListId: partnerController.priceListId,
        onProductSelected: (product) async {
          if (kDebugMode) {
            print('✅ Product selected: ${product.name}');
          }
          selectedProduct = product;
          if (kDebugMode) {
            print('🚪 [_openProductSelection] Get.back()');
          }
          // Get.back();

          await Future.delayed(const Duration(milliseconds: 100));

          if (kDebugMode) {
            print('🛒 Showing quantity selector: ${product.name}');
            print('🔍 _openProductSelection - mounted: $mounted');
          }

          // ✅ فحص إذا كان الـ widget لا يزال محملاً فوراً بعد Get.back()
          if (!mounted) {
            if (kDebugMode) {
              print(
                '❌ Widget unmounted in _openProductSelection - skipping quantity selector',
              );
            }
            return;
          }

          _showQuantitySelectorForProduct(product);
        },
      ),
    );

    if (kDebugMode) {
      print('Product selection dialog closed');
      if (selectedProduct != null) {
        print('Selected: ${selectedProduct!.name}');
      } else {
        print('No product selected');
      }
    }
  }

  // ✅ دالة عرض selector الكمية للمنتج الجديد
  Future<void> _showQuantitySelectorForProduct(ProductModel product) async {
    if (!mounted) return;

    if (kDebugMode) {
      print('\n🔢 ========== SHOWING QUANTITY SELECTOR ==========');
      print('Product: ${product.name}');
    }

    final selectedQuantity = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          SalesQuantitySelector(productName: product.name),
    );

    if (kDebugMode) {
      print('✅ Quantity selector closed');
      print('   Selected quantity: $selectedQuantity');
      print('   Mounted: $mounted');
    }

    if (selectedQuantity != null && selectedQuantity > 0 && mounted) {
      if (kDebugMode) {
        print('🛍️ Adding product with quantity: $selectedQuantity');
      }
      _addProductWithQuantity(product, selectedQuantity);
    }
  }

  // ✅ دالة عرض selector الكمية لسطر موجود
  Future<void> _showQuantitySelectorForLine(ProductLine line) async {
    if (!mounted) return;

    final selectedQuantity = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          SalesQuantitySelector(productName: line.productName),
    );

    if (selectedQuantity != null && selectedQuantity > 0 && mounted) {
      line.updateQuantity(selectedQuantity.toDouble());
      orderController.productLines.refresh();
      _hasChanges.value = true;
    }
  }

  // ✅ دالة إضافة منتج مع كمية محددة
  void _addProductWithQuantity(ProductModel product, int quantity) async {
    if (kDebugMode) {
      print('\n🛍️ ========== ADDING PRODUCT ==========');
      print('Product: ${product.name} (ID: ${product.id})');
      print('Quantity: $quantity');
      print('Current products: ${orderController.productLines.length}');
      print('🔍 _addProductWithQuantity START - mounted: $mounted');
    }

    // ✅ بدء Loading محلي
    _isLoading.value = true;

    // ✅ فحص إذا كان الـ widget لا يزال محملاً
    if (!mounted) {
      if (kDebugMode) {
        print('❌ Widget unmounted - skipping product addition');
      }
      _isLoading.value = false; // إنهاء Loading
      return;
    }

    // ✅ إضافة المنتج مباشرة (بدون فحص التكرار في التعديل)
    final line = ProductLine(
      key: UniqueKey(),
      productId: product.id,
      productName: product.name,
      availableProducts: orderController.availableProducts,
    );

    line.setProduct(product);

    if (kDebugMode) {
      print('✅ ProductLine created: ${line.productName}');
      print('   List Price: ${line.listPrice} Dh');
      print('   Price Unit: ${line.priceUnit} Dh');
    }

    orderController.productLines.add(line);
    orderController.selectedProductIds.add(product.id);

    if (kDebugMode) {
      print('✅ Product added to controller');
      print('   Total products: ${orderController.productLines.length}');
    }

    final formKey = GlobalKey<FormBuilderState>();
    orderController.lineFormKeys[orderController.productLines.length - 1] =
        formKey;
    line.setFormKey(formKey);

    // تحديث الكمية للمنتج المضاف
    line.updateQuantity(quantity.toDouble());

    if (kDebugMode) {
      print('✅ Quantity updated: ${line.quantity}');
      print('   Total: ${line.getTotalPrice()} Dh');
    }

    // ✅ إجبار تحديث الواجهة
    orderController.productLines.refresh();

    if (kDebugMode) {
      print('✅ UI refreshed');
    }

    // تطبيق قائمة الأسعار إذا كانت موجودة
    if (partnerController.priceListId != null) {
      // ✅ تحديث OrderController بقائمة الأسعار المختارة
      orderController.selectedPriceListId = partnerController.priceListId;

      await orderController.updateLinePrice(line);
    } else {
      if (kDebugMode) {
        print('⚠️ No price list selected - skipping price application');
      }
    }

    // تحديث حالة التغييرات
    if (mounted) {
      _hasChanges.value = true;
    }

    // ✅ إنهاء Loading محلي
    _isLoading.value = false;

    if (kDebugMode) {
      print('✅ Product added successfully: ${product.name}');
      print('   Total products: ${orderController.productLines.length}');
      print('   Total amount: ${orderController.getOrderTotal()} Dh');
      print('🔍 _addProductWithQuantity END - mounted: $mounted');
      print('==========================================');
    }
  }

  // ✅ Build Method الجديد
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('🔍 build() called - mounted: $mounted');
    }
    return Obx(() {
      return Scaffold(
        appBar: _buildAppBar(),
        body: _isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(),
      );
    });
  }

  // ✅ شريط التطبيق
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('تعديل طلب البيع - ${_originalOrder.name}'),
      actions: [
        // ✅ زر إلغاء التعديل
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _cancelUpdate,
          tooltip: 'إلغاء التعديل',
        ),
        // ✅ زر مسح الباركود
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: _scanBarcode,
          tooltip: 'مسح الباركود',
        ),
      ],
    );
  }

  // ✅ محتوى الشاشة
  Widget _buildBody() {
    return Column(
      children: [
        // نموذج الطلب (ثابت في الأعلى)
        _buildFixedOrderForm(),

        // قسم المنتجات (قابل للتمرير)
        Expanded(child: _buildScrollableContent()),

        // المجموع (ثابت أسفل الصفحة)
        _buildFixedTotalSection(),

        // أزرار الحفظ (ثابت في الأسفل)
        _buildFixedSaveButtons(),
      ],
    );
  }

  // ✅ نموذج الطلب الثابت
  Widget _buildFixedOrderForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Obx(
        () => OrderFormSection(
          formKey: _formKey,
          partners: PrefUtils.partners.toList(),
          priceLists: partnerController.partnerPriceLists,
          paymentTerms: PrefUtils.conditionsPaiement,
          selectedPartnerId: partnerController.partnerId,
          selectedPriceListId: partnerController.priceListId,
          selectedPaymentTermId: partnerController.paymentTermId,
          showDeliveryDate: partnerController.showDeliveryDate.value,
          deliveryDate: partnerController.deliveryDate.value,
          hasProducts: orderController.hasProducts,
          onPartnerChanged: (partnerId) async {
            partnerController.selectPartner(partnerId);
            _hasChanges.value = true;
          },
          onPriceListChanged: (priceListId) async {
            partnerController.selectPriceList(priceListId);
            _hasChanges.value = true;
          },
          onPaymentTermChanged: (paymentTermId) {
            partnerController.selectPaymentTerm(paymentTermId);
            _hasChanges.value = true;
          },
          onDeliveryDateToggled: (show) {
            partnerController.toggleDeliveryDate(show);
            _hasChanges.value = true;
          },
          onDeliveryDateChanged: (date) {
            partnerController.setDeliveryDate(date);
            _hasChanges.value = true;
          },
        ),
      ),
    );
  }

  // ✅ المحتوى القابل للتمرير
  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // قسم المنتجات فقط
          _buildProductsSection(),
        ],
      ),
    );
  }

  // ✅ قسم المنتجات
  Widget _buildProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'المنتجات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _openProductSelection,
              icon: const Icon(Icons.add),
              label: const Text('إضافة منتج'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // قائمة المنتجات - استخدام نفس بطاقة المنتجات من صفحة الإنشاء
        _buildProductsList(),
      ],
    );
  }

  // ✅ قائمة المنتجات - نفس صفحة الإنشاء
  Widget _buildProductsList() {
    return Obx(() {
      if (orderController.productLines.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد منتجات',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'اضغط على "إضافة منتج" لإضافة منتجات للطلب',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orderController.productLines.length,
        itemBuilder: (context, index) {
          final line = orderController.productLines[index];
          final isEditing = orderController.editingLineIndex.value == index;

          if (isEditing) {
            return ProductLineEditor(
              line: line,
              formKey: orderController.lineFormKeys[index]!,
              onQuantityChanged: (quantity) {
                line.updateQuantity(quantity);
                orderController.productLines.refresh();
              },
              onDiscountChanged: (discount) {
                line.updateDiscount(discount);
                orderController.productLines.refresh();
              },
              onPriceChanged: (price) {
                line.updatePrice(price);
                orderController.productLines.refresh();
              },
              onSave: () {
                orderController.saveLineEditing();
                _hasChanges.value = true;
              },
              onCancel: () {
                orderController.cancelEditing();
              },
            );
          }

          return ProductLineCard(
            index: index,
            line: line,
            onEdit: () => orderController.editLine(index),
            onDelete: () {
              orderController.deleteLine(index);
              _hasChanges.value = true;
            },
            onQuantityTap: () => _showQuantitySelectorForLine(line),
          );
        },
      );
    });
  }

  // ✅ قسم الإجمالي الثابت
  Widget _buildFixedTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        border: Border(top: BorderSide(color: Colors.blue[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'الإجمالي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Obx(
            () => Text(
              '${orderController.getOrderTotal().toStringAsFixed(2)} Dh',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ أزرار الحفظ الثابتة
  Widget _buildFixedSaveButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelUpdate,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => ElevatedButton(
                onPressed: _isSaving.value ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text('حفظ التعديلات'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ إعادة تحميل الطلب المحدث من SharedPreferences
  Future<OrderModel?> _getUpdatedOrderFromPrefs() async {
    try {
      if (kDebugMode) {
        print('\n🔄 ========== LOADING UPDATED ORDER FROM PREFS ==========');
        print('Order ID: ${_originalOrder.id}');
      }

      // إعادة تحميل البيانات من SharedPreferences
      final sales = await PrefUtils.getSales();

      // البحث عن الطلب المحدث
      final updatedOrder = sales.firstWhere(
        (s) => s.id == _originalOrder.id,
        orElse: () => _originalOrder,
      );

      if (kDebugMode) {
        print('✅ Order found in Prefs:');
        print('   Order ID: ${updatedOrder.id}');
        print('   Order Name: ${updatedOrder.name}');
        print('   Partner ID: ${updatedOrder.partnerId}');
        print('   Price List ID: ${updatedOrder.pricelistId}');
        print('   Order Lines: ${updatedOrder.orderLine.length}');
      }

      // التأكد من أن OrderLines محملة بشكل صحيح
      if (updatedOrder.orderLine.isNotEmpty) {
        final firstLine = updatedOrder.orderLine.first;
        if (kDebugMode) {
          print('   First Line Type: ${firstLine.runtimeType}');
          if (firstLine is int) {
            print('   ⚠️ Order lines are IDs, need to load full models');
          } else if (firstLine is OrderLineModel) {
            print('   ✅ Order lines are full models');
          }
        }

        // إذا كانت OrderLines عبارة عن IDs فقط، نحتاج لتحميلها
        if (firstLine is int) {
          final orderLineIds = updatedOrder.orderLine.cast<int>();
          final allOrderLines = PrefUtils.orderLine;

          final fullOrderLines = <OrderLineModel>[];
          for (final id in orderLineIds) {
            try {
              final line = allOrderLines.firstWhere((l) => l.id == id);
              fullOrderLines.add(line);
            } catch (e) {
              if (kDebugMode) {
                print('   ⚠️ Could not find order line with ID: $id');
              }
            }
          }

          if (kDebugMode) {
            print('   Loaded ${fullOrderLines.length} full order lines');
          }

          // استبدال IDs بالنماذج الكاملة
          updatedOrder.orderLine.clear();
          updatedOrder.orderLine.addAll(fullOrderLines);
        }
      }

      if (kDebugMode) {
        print('=========================================================\n');
      }

      return updatedOrder;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR LOADING ORDER FROM PREFS ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('====================================================\n');
      }
      return null;
    }
  }

  // ✅ دالة مسح الباركود
  Future<void> _scanBarcode() async {
    try {
      if (kDebugMode) {
        print('\n📷 Opening barcode scanner...');
      }

      final result = await Get.to(() => const BarcodeScannerPage());

      if (result != null && result is String) {
        if (kDebugMode) {
          print('📷 Barcode scanned: $result');
        }

        // البحث عن المنتج بالباركود
        final products = PrefUtils.products.toList();
        ProductModel? foundProduct;

        try {
          foundProduct = products.firstWhere(
            (p) => p.barcode?.toString() == result,
          );
        } catch (e) {
          // المنتج غير موجود
          foundProduct = null;
        }

        if (foundProduct != null) {
          if (kDebugMode) {
            print('✅ Product found: ${foundProduct.name}');
          }

          // ✅ عرض SalesQuantitySelector للمنتج الموجود
          await _showQuantitySelectorForProduct(foundProduct);
        } else {
          if (kDebugMode) {
            print('❌ Product not found for barcode: $result');
          }

          // ✅ عرض نافذة تنبيه أن المنتج غير موجود
          _showProductNotFoundDialog(result);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scanning barcode: $e');
      }
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء مسح الباركود',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // ✅ عرض نافذة تنبيه أن المنتج غير موجود
  void _showProductNotFoundDialog(String barcode) {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.search_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('منتج غير موجود'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('لم يتم العثور على منتج بالباركود:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                barcode,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'تأكد من أن الباركود صحيح أو أضف المنتج يدوياً.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _openProductSelection();
            },
            child: const Text('إضافة منتج'),
          ),
        ],
      ),
    );
  }
}
