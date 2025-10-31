import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/barcodeScannerPage.dart';
import 'package:gsloution_mobile/src/data/services/draft_sale_service.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/controllers/controllers.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/services/services.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/sales_quantity_selector.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/widgets.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/saleOrderDetail/sale_order_new_detail_screen.dart';

class CreateNewOrder extends StatefulWidget {
  final PartnerModel? partner;
  final Map<String, dynamic>? draft;

  const CreateNewOrder({super.key, this.partner, this.draft});

  @override
  State<CreateNewOrder> createState() => _CreateNewOrderState();
}

class _CreateNewOrderState extends State<CreateNewOrder> {
  // ============= Controllers =============
  final OrderController orderController = Get.put(OrderController());
  final DraftController draftController = Get.put(DraftController());
  final PartnerController partnerController = Get.put(PartnerController());

  // ============= Services =============
  final OrderCreationService orderService = OrderCreationService();
  final OrderValidationService validationService = OrderValidationService();

  // ============= Form =============
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  // ============= State (بدون Rx) =============
  bool _isLoading = false;
  bool _isSaving = false;
  bool isSending = false;
  String? _lastSavedText;

  // ============= Scroll Controller =============
  final ScrollController _scrollController = ScrollController();

  // ============= Worker للاستماع فقط لـ lastSavedAt =============
  Worker? _lastSavedWorker;

  @override
  void initState() {
    super.initState();

    // ✅ Worker محدد فقط لـ lastSavedAt
    _lastSavedWorker = ever(draftController.lastSavedAt, (_) {
      if (mounted) {
        setState(() {
          _lastSavedText = draftController.lastSavedText;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeControllers();

      if (widget.draft != null) {
        _loadDraftData(widget.draft!);
      } else if (widget.partner != null) {
        _checkAndLoadDraft();
      }

      _loadServerData();
    });
  }

  void _initializeControllers() {
    final products = PrefUtils.products.toList();
    final priceLists = PrefUtils.listesPrix.toList();

    orderController.initialize(
      products: products,
      allPriceLists: priceLists.isEmpty ? [] : priceLists,
    );
    partnerController.initialize(preSelectedPartner: widget.partner);

    if (partnerController.hasPriceLists &&
        partnerController.priceListId != null) {
      orderController.selectedPriceListId = partnerController.priceListId;
    }

    ever(
      partnerController.selectedPriceList,
      (priceList) {
        if (priceList != null && partnerController.hasPriceLists) {
          orderController.selectedPriceListId = priceList.id;
        }
      },
      condition: () => partnerController.hasPriceLists,
    );
  }

  Future<void> _loadDraftData(Map<String, dynamic> draft) async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      if (draft['partnerId'] != null) {
        partnerController.selectPartner(draft['partnerId']);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (draft['priceListId'] != null) {
        partnerController.selectPriceList(draft['priceListId']);
        orderController.selectedPriceListId = draft['priceListId'];
        await Future.delayed(const Duration(milliseconds: 100));
      }

      if (draft['paymentTermId'] != null) {
        partnerController.selectPaymentTerm(draft['paymentTermId']);
      }

      final products = draft['products'] as List? ?? [];

      for (var productData in products) {
        try {
          final product = PrefUtils.products.toList().firstWhere(
            (p) => p.id == productData['productId'],
          );

          await orderController.addProduct(product);

          final line = orderController.productLines.last;

          final quantity = productData['quantity'];
          final price = productData['price'];
          final discount = productData['discount'];

          line.quantity = quantity is int
              ? quantity.toInt()
              : (quantity ?? 1.0).toInt();
          line.quantityController.text = line.quantity.toString();

          line.priceUnit = price is int
              ? price.toDouble()
              : (price ?? 0.0).toDouble();
          line.discountPercentage = discount is int
              ? discount.toDouble()
              : (discount ?? 0.0).toDouble();

          if (line.discountPercentage > 0) {
            line.listPrice =
                line.priceUnit / (1 - line.discountPercentage / 100);
          } else {
            line.listPrice = line.priceUnit;
          }

          line.priceController.text = line.priceUnit.toStringAsFixed(2);
          line.discountController.text = line.discountPercentage
              .toStringAsFixed(1);
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error loading product: $e');
          }
        }
      }

      setState(() {});

      draftController.currentDraftId.value = draft['id'];
      if (draft['lastModified'] != null) {
        draftController.lastSavedAt.value = DateTime.parse(
          draft['lastModified'],
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading draft: $e');
      }
    }
  }

  @override
  void dispose() {
    _lastSavedWorker?.dispose();
    _scrollController.dispose();
    Get.delete<OrderController>();
    Get.delete<DraftController>();
    Get.delete<PartnerController>();
    super.dispose();
  }

  Future<void> _loadServerData() async {
    setState(() => _isLoading = true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading server data: $e');
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAndLoadDraft() async {
    if (!partnerController.hasPartner) return;
    await draftController.checkAndLoadDraft(
      customerName: partnerController.partnerName ?? '',
      partnerId: partnerController.partnerId,
      priceListId: partnerController.priceListId,
    );
  }

  Future<void> _createOrder() async {
    print('isSending: $isSending started');
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

    final formData = partnerController.getFormData();
    final productLines = orderController.productLines;

    if (!partnerController.shouldSendPriceListId) {
      formData.remove('pricelist_id');
    }

    if (!validationService.validateOrder(
      formData: formData,
      productLines: productLines,
    )) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      await orderService.createOrder(
        showGlobalLoading: true,
        formData: formData,
        productLines: productLines,
        onResponse: (orderId) async {
          if (orderId != null) {
            if (draftController.hasDraft) {
              unawaited(draftController.deleteCurrentDraft());
            }
            if (orderId != null) {
              // ✅ حذف المسودة بشكل غير متزامن

              // ✅ قراءة الطلب والانتقال فوراً
              // ✅ تحسين الأداء: استخدام readOrders العادي (أسرع)
              unawaited(
                OrderModule.readOrders(
                  ids: [orderId],
                  onResponse: (response) async {
                    if (response.isNotEmpty) {
                      final newOrder = response[0];

                      // ✅ تحسين الأداء: إضافة في النهاية بدلاً من البداية
                      PrefUtils.sales.add(newOrder);

                      // ✅ تحديث الواجهة مرة واحدة فقط
                      PrefUtils.sales.refresh();

                      // ✅ حفظ في الخلفية بدون انتظار
                      unawaited(PrefUtils.saveSales(PrefUtils.sales));

                      // ✅ الانتقال فوراً بدون تأخير
                      _navigateToOrderDetail(newOrder);
                    }
                  },
                ),
              );
            }
          }
        },
      );
    } catch (e) {
      // ✅ استخدام معالجة الأخطاء المحسنة
      OrderErrorHandler.handleOrderCreationError(e, context: 'order_creation');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _navigateToOrderDetail(OrderModel order) {
    isSending = true;
    hideLoading();
    print('isSending: $isSending finished');

    // ✅ استخدام Get.to بدلاً من Get.off للعودة الصحيحة
    Get.to(
      () => SaleOrderNewDetailScreen(salesOrder: order),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> _scanBarcode() async {
    try {
      final result = await Get.to(() => const BarcodeScannerPage());

      if (result != null && result is String) {
        final products = PrefUtils.products.toList();
        ProductModel? foundProduct;

        try {
          foundProduct = products.firstWhere(
            (p) => p.barcode?.toString() == result,
          );
        } catch (e) {
          foundProduct = null;
        }

        if (foundProduct != null) {
          await _showQuantitySelectorForProduct(foundProduct);
        } else {
          _showProductNotFoundDialog(result);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error scanning barcode: $e');
      }
    }
  }

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
              child: Text(barcode),
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

  Future<void> _autoSaveDraft() async {
    if (!partnerController.hasPartner) return;

    try {
      await draftController.autoSaveDraft(
        customerName: partnerController.partnerName!,
        partnerId: partnerController.partnerId!,
        priceListId: partnerController.priceListId,
      );

      final currentDrafts = await DraftSaleService.instance.getAllDrafts();
      DraftSaleService.notifyDraftCountChanged(currentDrafts.length);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in auto-save: $e');
      }
    }
  }

  Future<void> _openProductSelection() async {
    if (!partnerController.hasPartner) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار العميل أولاً',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
      return;
    }

    showProductSelectionDialog(
      products: PrefUtils.products.toList(),
      selectedProductIds: orderController.selectedProductIds.toSet(),
      priceLists: partnerController.allPriceLists,
      selectedPriceListId: partnerController.priceListId,
      onProductSelected: (product) async {
        orderController.selectedPriceListId = partnerController.priceListId;
        await orderController.addProduct(product);

        if (!mounted) return;

        setState(() {});
        await _autoSaveDraft();

        // ✅ ثم عرض SalesQuantitySelector
        if (mounted) {
          await _showQuantitySelectorForProduct(product);
        }
      },
    );
  }

  Future<void> _showQuantitySelectorForProduct(ProductModel product) async {
    if (!mounted) return;

    final quantity = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SalesQuantitySelector(productName: product.name),
    );

    if (quantity != null && quantity > 1 && mounted) {
      await _updateProductQuantity(product, quantity);
    }
  }

  Future<void> _updateProductQuantity(
    ProductModel product,
    int quantity,
  ) async {
    final lineIndex = orderController.productLines.indexWhere(
      (line) => line.productId == product.id,
    );

    if (lineIndex == -1) return;

    final line = orderController.productLines[lineIndex];
    line.updateQuantity(quantity.toDouble());

    setState(() {});

    await _autoSaveDraft();
  }

  Future<void> _cancelOrder() async {
    if (orderController.hasProducts) {
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
            'هل أنت متأكد من إلغاء الإنشاء؟\nسيتم فقدان جميع البيانات المدخلة.',
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

    if (draftController.hasDraft) {
      await draftController.deleteCurrentDraft();
    }

    Get.back();
  }

  // ============= UI =============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('طلب بيع جديد'),
      actions: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          onPressed: _cancelOrder,
          tooltip: 'إلغاء الإنشاء',
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: _scanBarcode,
          tooltip: 'مسح الباركود',
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // ✅ عرض آخر حفظ بدون Obx
        if (_lastSavedText != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16),
                const SizedBox(width: 8),
                Text(_lastSavedText!, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

        _buildFixedOrderForm(),

        Expanded(child: _buildScrollableContent()),

        _buildFixedSaveButton(),

        // ✅ مؤشر التقدم المحسن
        _buildProgressIndicator(),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    return _ProgressIndicator(
      hasPartner: partnerController.hasPartner,
      hasProducts: orderController.hasProducts,
    );
  }

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
      child: OrderFormSection(
        key: ValueKey(orderController.productLines.length),
        formKey: _formKey,
        partners: PrefUtils.partners.toList(),
        priceLists: [],
        paymentTerms: PrefUtils.conditionsPaiement,
        selectedPartnerId: partnerController.partnerId,
        selectedPriceListId: partnerController.priceListId,
        selectedPaymentTermId: partnerController.paymentTermId,
        showDeliveryDate: partnerController.showDeliveryDate.value,
        deliveryDate: partnerController.deliveryDate.value,
        hasProducts: orderController.hasProducts,
        onPartnerChanged: (partnerId) async {
          partnerController.selectPartner(partnerId);
          orderController.selectedPriceListId = partnerController.priceListId;

          if (partnerController.priceListId != null &&
              orderController.hasProducts) {
            await orderController.updateAllProductsPrices(
              partnerController.priceListId!,
            );
          }

          setState(() {});
          await _autoSaveDraft();
        },
        onPriceListChanged: (priceListId) async {
          partnerController.selectPriceList(priceListId);
          orderController.selectedPriceListId = priceListId;
          if (priceListId != null && orderController.hasProducts) {
            await orderController.updateAllProductsPrices(priceListId);
          }
          await _autoSaveDraft();
        },
        onPaymentTermChanged: (paymentTermId) {
          partnerController.selectPaymentTerm(paymentTermId);
          _autoSaveDraft();
        },
        onDeliveryDateToggled: (show) {
          partnerController.toggleDeliveryDate(show);
          _autoSaveDraft();
        },
        onDeliveryDateChanged: (date) {
          partnerController.setDeliveryDate(date);
          _autoSaveDraft();
        },
      ),
    );
  }

  Widget _buildProductsList() {
    return GetBuilder<OrderController>(
      id: 'product_lines',
      builder: (controller) {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.productLines.length,
          itemBuilder: (context, index) {
            final line = controller.productLines[index];
            final isEditing = controller.editingLineIndex.value == index;

            if (isEditing) {
              return ProductLineEditor(
                line: line,
                formKey: controller.lineFormKeys[index]!,
                onQuantityChanged: (quantity) {
                  line.updateQuantity(quantity);
                },
                onDiscountChanged: (discount) {
                  line.updateDiscount(discount);
                },
                onPriceChanged: (price) {
                  line.updatePrice(price);
                },
                onSave: () {
                  controller.saveLineEditing();
                  _autoSaveDraft();
                },
                onCancel: () {
                  controller.cancelEditing();
                },
              );
            }

            return ProductLineCard(
              index: index,
              line: line,
              onEdit: () => controller.editLine(index),
              onDelete: () {
                controller.deleteLine(index);
                setState(() {});
                _autoSaveDraft();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFixedSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ✅ الإجمالي - تصميم مدمج وأصغر
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الإجمالي:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${orderController.getOrderTotal().toStringAsFixed(2)} Dh',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ✅ زر الحفظ - أصغر وأنيق
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _createOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSaving ? Colors.grey : Colors.blue,
          foregroundColor: Colors.white,
          elevation: _isSaving ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'جاري الحفظ...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.save_outlined, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حفظ الطلب',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _ProductsHeaderDelegate(
            onAddProduct: _openProductSelection,
            productsCount: orderController.productsCount,
            hasProducts: orderController.hasProducts,
          ),
        ),

        SliverToBoxAdapter(
          child: GetBuilder<OrderController>(
            id: 'product_lines',
            builder: (controller) {
              return controller.hasProducts
                  ? _buildProductsList()
                  : EmptyProductsView(onAddProduct: _openProductSelection);
            },
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

class _ProductsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onAddProduct;
  final int productsCount;
  final bool hasProducts;

  _ProductsHeaderDelegate({
    required this.onAddProduct,
    required this.productsCount,
    required this.hasProducts,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'المنتجات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              if (hasProducts)
                Text(
                  '$productsCount منتج',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('إضافة منتج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

// ============= Enhanced UI Components =============

/// مؤشر التقدم المحسن
class _ProgressIndicator extends StatelessWidget {
  final bool hasPartner;
  final bool hasProducts;

  const _ProgressIndicator({
    required this.hasPartner,
    required this.hasProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ مؤشر التقدم
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: hasPartner ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'اختيار العميل',
                style: TextStyle(
                  color: hasPartner ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.check_circle,
                color: hasProducts ? Colors.green : Colors.grey,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'إضافة المنتجات',
                style: TextStyle(
                  color: hasProducts ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ✅ شريط التقدم
          LinearProgressIndicator(
            value: _calculateProgress(),
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    double progress = 0.0;
    if (hasPartner) progress += 0.5;
    if (hasProducts) progress += 0.5;
    return progress;
  }
}
