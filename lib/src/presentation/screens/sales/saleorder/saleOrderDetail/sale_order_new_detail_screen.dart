// lib/src/presentation/screens/sales/saleorder/saleOrderDetail/sale_order_new_detail_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_module.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/saleOrderDetail/widget/button_order.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/update_order_form.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/inventory/stock_picking_detail_screen.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_app_bar_badge.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:intl/intl.dart';

class SaleOrderNewDetailScreen extends StatefulWidget {
  final OrderModel salesOrder;
  final bool fromUpdate;

  const SaleOrderNewDetailScreen({
    super.key,
    required this.salesOrder,
    this.fromUpdate = false,
  });

  @override
  State<SaleOrderNewDetailScreen> createState() =>
      _SaleOrderNewDetailScreenState();
}

class _SaleOrderNewDetailScreenState extends State<SaleOrderNewDetailScreen> {
  late PartnerModel partner;
  late OrderModel currentOrder;

  final RxList<OrderLineModel> orderLine = <OrderLineModel>[].obs;
  final RxList<AccountMoveModel> accountMove = <AccountMoveModel>[].obs;
  final RxList<StockPickingModel> stockPickings = <StockPickingModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingOrderLines = true.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isClientInfoExpanded = false.obs;
  final RxBool dataLoaded = false.obs;

  late final NumberFormat _currencyFormat;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.salesOrder;
    _currencyFormat = NumberFormat("#,##0.00", "en_US");
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final result = ModalRoute.of(context)?.settings.arguments;
    if (result == true) {
      _refreshData();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      // ✅ تم بدء تهيئة تفاصيل الطلب

      final partnerId = currentOrder.partnerId is List
          ? currentOrder.partnerId[0]
          : currentOrder.partnerId;

      partner = PrefUtils.partners.firstWhere(
        (element) => element.id == partnerId,
        orElse: () => PartnerModel(),
      );

      // ✅ تم العثور على العميل

      await _loadOrderLines();
      await _loadStockPickings();

      if (mounted && !_isDisposed) {
        isLoading.value = false;
        dataLoaded.value = true;

        // ✅ تم تحميل البيانات بنجاح
      }
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR LOADING DATA ==========');
        print('Error: $e');
        print('======================================\n');
      }

      if (mounted && !_isDisposed) {
        isLoading.value = false;
        errorMessage.value = 'Erreur de chargement: $e';
      }
    }
  }

  Future<void> _refreshData() async {
    try {
      if (kDebugMode) {
        print('\n🔄 Refreshing order data...');
      }

      isLoading.value = true;

      await _loadStockPickings();
      await _loadOrderLines();

      if (mounted) {
        setState(() {});
      }

      isLoading.value = false;

      if (kDebugMode) {
        print('✅ Data refreshed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing data: $e');
      }
      isLoading.value = false;
    }
  }

  Future<void> _loadStockPickings() async {
    try {
      // ✅ تم بدء تحميل أوامر التسليم

      final pickingIds = currentOrder.pickingIds;

      // ✅ تم استخراج IDs أوامر التسليم

      if (pickingIds != null && pickingIds.isNotEmpty) {
        final cachedPickings = PrefUtils.stockPicking
            .where(
              (picking) =>
                  picking.id != null && pickingIds.contains(picking.id!),
            )
            .toList();

        if (cachedPickings.isNotEmpty) {
          stockPickings.assignAll(cachedPickings);
          // ✅ تم استخدام أوامر التسليم المحفوظة
          return;
        }

        await _updateStockPickingsFromServer(ids: pickingIds.cast<int>());
      } else {
        // ✅ لا توجد أوامر تسليم
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading stock pickings: $e');
      }
    }
  }

  Future<void> _loadOrderLines() async {
    try {
      // ✅ تم بدء تحميل أسطر الطلب

      final orderLineIds = _extractOrderLineIds();

      // ✅ تم استخراج IDs أسطر الطلب

      final cachedLines = _getCachedOrderLines(orderLineIds);

      if (cachedLines.isNotEmpty) {
        orderLine.assignAll(cachedLines);
        isLoadingOrderLines.value = false;
        // ✅ تم استخدام الأسطر المحفوظة
        return;
      }

      if (orderLineIds.isNotEmpty) {
        await _loadOrderLinesFromServer(orderLineIds);
      } else {
        isLoadingOrderLines.value = false;
        // ✅ لا توجد أسطر طلب
      }
    } catch (e) {
      isLoadingOrderLines.value = false;
      if (kDebugMode) {
        print('❌ Error loading order lines: $e');
      }
      rethrow;
    }
  }

  List<int> _extractOrderLineIds() {
    if (currentOrder.orderLine is! List) return [];

    final orderLineList = currentOrder.orderLine as List;
    if (orderLineList.isEmpty) return [];

    if (orderLineList.first is int) {
      return orderLineList.cast<int>();
    }

    return orderLineList
        .map((line) {
          if (line is OrderLineModel && line.id != null) {
            return line.id as int;
          } else if (line is Map && line.containsKey('id')) {
            return line['id'] as int;
          }
          return 0;
        })
        .where((id) => id > 0)
        .toList();
  }

  List<OrderLineModel> _getCachedOrderLines(List<int> orderLineIds) {
    if (orderLineIds.isEmpty) return [];

    return PrefUtils.orderLine
        .where((line) => line.id != null && orderLineIds.contains(line.id!))
        .toList();
  }

  Future<void> _loadOrderLinesFromServer(List<int> orderLineIds) async {
    if (kDebugMode) {
      print('🔄 Fetching from server: ${orderLineIds.length} lines');
    }

    await OrderLineModule.readOrderLines(
      ids: orderLineIds,
      onResponse: (response) {
        if (response.isNotEmpty) {
          PrefUtils.orderLine.addAll(response);
          orderLine.assignAll(response);

          if (kDebugMode) {
            print('✅ Server lines loaded: ${response.length}');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ No lines returned from server');
          }
        }
        isLoadingOrderLines.value = false;
      },
    );
  }

  Future<void> _updateOrder(int idAccount) async {
    try {
      if (kDebugMode) {
        print('\n🔄 Updating order...');
      }

      await OrderModule.readOrders(
        ids: [currentOrder.id],
        onResponse: (resOrder) async {
          if (resOrder.isNotEmpty) {
            OrderModel updatedOrder = resOrder.first;

            currentOrder = updatedOrder;

            await _updateStockPickingsFromServer(
              ids: updatedOrder.pickingIds.cast<int>(),
            );
            _updateSaleOrderList(updatedOrder);

            if (kDebugMode) {
              print('✅ Order updated successfully');
              print('New State: ${updatedOrder.state}');
              print('New Invoice Count: ${updatedOrder.invoiceCount}');
              print('New Delivery Count: ${updatedOrder.deliveryCount}');
            }

            setState(() {});
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating order: $e');
      }
      if (mounted) {
        _showSnackBar('Erreur: $e', isError: true);
      }
    }
  }

  Future<void> _updateStockPickingsFromServer({required List<int> ids}) async {
    await StockPickingModule.webReadStockPicking(
      ids: ids,
      onResponse: (response) {
        stockPickings.clear();

        if (kDebugMode) {
          print('✅ Stock pickings updated from server: ${response.length}');
        }

        if (response.isNotEmpty) {
          stockPickings.assignAll(response);
          PrefUtils.stockPicking.assignAll(response);
          PrefUtils.stockPicking.refresh();
        }
      },
    );
  }

  void _updateSaleOrderList(OrderModel order) {
    int index = PrefUtils.sales.indexWhere((element) => element.id == order.id);
    if (index != -1) {
      PrefUtils.sales[index] = order;
      PrefUtils.sales.refresh();
    }
    if (mounted) {
      setState(() {
        currentOrder = order;
      });
    }
  }

  void _navigateToEdit() {
    try {
      if (kDebugMode) {
        print('📝 Opening update order from details: ${currentOrder.name}');
        print('   Order lines: ${orderLine.length}');
      }

      Get.to(() => UpdateOrder(salesOrder: currentOrder, orderLine: orderLine));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error opening update order from details: $e');
      }

      _showSnackBar('حدث خطأ أثناء فتح صفحة التعديل', isError: true);
    }
  }

  void _handlePrint() {
    _showSnackBar('Fonction d\'impression en développement');
  }

  void _showMoreOptions() {
    final canEdit =
        currentOrder.state != "sale" && currentOrder.state != "cancel";

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (canEdit)
              ListTile(
                leading: Icon(Icons.edit, color: FunctionalColors.iconPrimary),
                title: Text('Modifier', style: GoogleFonts.raleway()),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEdit();
                },
              ),
            ListTile(
              leading: Icon(Icons.copy, color: FunctionalColors.iconPrimary),
              title: Text('Dupliquer', style: GoogleFonts.raleway()),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Fonction en développement');
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: FunctionalColors.iconPrimary),
              title: Text('Partager', style: GoogleFonts.raleway()),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Fonction en développement');
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.delete, color: FunctionalColors.buttonDanger),
              title: Text(
                'Supprimer',
                style: GoogleFonts.raleway(
                  color: FunctionalColors.buttonDanger,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Fonction en développement');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? FunctionalColors.buttonDanger
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  bool _canShowButtons() {
    return orderLine.isNotEmpty &&
        currentOrder.state != "sale" &&
        currentOrder.state != "cancel";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (isLoading.value) {
          return _buildLoadingState();
        }

        if (errorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        return _buildContent();
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text('Chargement des détails...', style: GoogleFonts.raleway()),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: StatusColors.cancel.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: StatusColors.cancel,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    isLoading.value = true;
                    errorMessage.value = '';
                    _initializeData();
                  },
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back, size: 18),
                  label: Text('Retour'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildStatusBar(),
        _buildCollapsibleClientInfo(),
        Expanded(child: _buildOrderLinesSection()),
        _buildTotalSection(),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final hasInvoices = currentOrder.invoiceCount > 0;
    final hasDeliveries = currentOrder.deliveryCount > 0;

    if (kDebugMode) {
      print('🔍 AppBar Debug:');
      print('Invoice Count: ${currentOrder.invoiceCount}');
      print('Delivery Count: ${currentOrder.deliveryCount}');
      print('Has Invoices: $hasInvoices');
      print('Has Deliveries: $hasDeliveries');
    }

    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: FunctionalColors.iconPrimary),
        onPressed: () {
          if (widget.fromUpdate) {
            Get.offAllNamed(AppRoutes.sales);
          } else {
            // ✅ العودة إلى قائمة المبيعات بدلاً من الصفحة السابقة
            Get.offAllNamed(AppRoutes.sales);
          }
        },
      ),
      title: Text(
        currentOrder.name,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      actions: [
        DraftAppBarBadge(
          showOnlyWhenHasDrafts: true,
          iconColor: FunctionalColors.buttonPrimary,
          badgeColor: Colors.orange,
        ),
        if (hasInvoices)
          IconButton(
            icon: Badge(
              label: Text('${currentOrder.invoiceCount}'),
              child: Icon(
                Icons.receipt_outlined,
                color: FunctionalColors.iconPrimary,
              ),
            ),
            onPressed: _handleInvoiceTap,
          ),
        if (hasDeliveries)
          IconButton(
            icon: Badge(
              label: Text('${currentOrder.deliveryCount}'),
              child: Icon(
                Icons.local_shipping_outlined,
                color: FunctionalColors.iconPrimary,
              ),
            ),
            onPressed: () => _handleDeliveryTap(stockPickings: stockPickings),
          ),
        IconButton(
          icon: Icon(Icons.print, color: FunctionalColors.iconPrimary),
          onPressed: _handlePrint,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: FunctionalColors.iconPrimary),
          onPressed: _showMoreOptions,
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final statusColors = StatusColors.getColors(currentOrder.state);
    final statusLabel = StatusColors.getLabel(currentOrder.state);
    final statusIcon = StatusColors.getIcon(currentOrder.state);

    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: statusColors['bg'],
          border: Border(
            top: BorderSide(color: statusColors['color']!, width: 3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(statusIcon, size: 18, color: statusColors['color']),
            const SizedBox(width: 8),
            Text(
              statusLabel,
              style: GoogleFonts.raleway(
                color: statusColors['color'],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (_canShowButtons()) ...[
              SizedBox(
                height: 32,
                child: ButtonOrder(
                  state: currentOrder.state,
                  order: currentOrder,
                  onUpdate: _updateOrder,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: ButtonOrder(
                  state: "annuler",
                  order: currentOrder,
                  onUpdate: _updateOrder,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildCollapsibleClientInfo() {
    return Obx(() {
      return Container(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            InkWell(
              onTap: () {
                isClientInfoExpanded.value = !isClientInfoExpanded.value;
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${partner.name} ${_hasValue(partner.city) ? '(${partner.city})' : ''}',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isClientInfoExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (isClientInfoExpanded.value)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    if (_hasValue(partner.phone))
                      _buildInfoRow(
                        Icons.phone_outlined,
                        partner.phone.toString(),
                      ),
                    if (_hasValue(partner.email))
                      _buildInfoRow(
                        Icons.email_outlined,
                        partner.email.toString(),
                      ),
                    _buildInfoRow(
                      Icons.calendar_today_outlined,
                      _formatDate(currentOrder.dateOrder),
                    ),
                    _buildInfoRow(
                      Icons.local_offer_outlined,
                      _getFieldValue(currentOrder.pricelistId),
                    ),
                  ],
                ),
              ),
            Divider(height: 1, color: AppColors.border),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: FunctionalColors.iconSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLinesSection() {
    return Obx(() {
      if (isLoadingOrderLines.value) {
        return _buildLoadingOrderLines();
      }

      if (orderLine.isEmpty) {
        return _buildEmptyOrderLines();
      }

      return _buildOrderLinesList();
    });
  }

  Widget _buildLoadingOrderLines() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            'Chargement des produits...',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyOrderLines() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun produit',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ce bon de commande ne contient aucun produit',
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            if (_canShowButtons())
              ElevatedButton.icon(
                onPressed: _navigateToEdit,
                icon: Icon(Icons.add, size: 18),
                label: Text('Ajouter des produits'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderLinesList() {
    final totalAmount = orderLine.fold<double>(
      0,
      (sum, line) => sum + (line.priceTotal ?? 0),
    );

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 20,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Produits',
                style: GoogleFonts.raleway(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${orderLine.length} article${orderLine.length > 1 ? 's' : ''}',
                  style: GoogleFonts.raleway(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currencyFormat.format(totalAmount)} MAD',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: orderLine.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _buildCompactProductCard(orderLine[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCompactProductCard(OrderLineModel line) {
    final priceUnit = _calculatePriceUnit(line);
    final hasDiscount = (line.discount ?? 0.0) > 0;

    final productUomQty = line.productUomQty ?? 0.0;
    final priceTotal = line.priceTotal ?? 0.0;

    final safePriceTotal = priceTotal.isNaN ? 0.0 : priceTotal;
    final safeProductUomQty = productUomQty.isNaN ? 0.0 : productUomQty;

    final calculatedPriceTotal = safePriceTotal > 0
        ? safePriceTotal
        : (priceUnit * safeProductUomQty);

    if (kDebugMode) {
      print('🔍 Building product card for: ${line.name}');
      print('   Price Unit: ${line.priceUnit}');
      print('   Price Total: ${line.priceTotal}');
      print('   Calculated Price Total: $priceTotal');
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: FunctionalColors.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getProductName(line),
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${safeProductUomQty} × ${_currencyFormat.format(priceUnit)} MAD',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (hasDiscount)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: StatusColors.saleBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '-${line.discount ?? 0}%',
                    style: GoogleFonts.raleway(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: StatusColors.sale,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '${_currencyFormat.format(calculatedPriceTotal)} MAD',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    final showHT = currentOrder.amountUntaxed != currentOrder.amountTotal;
    final showTaxes =
        currentOrder.amountTax != null && currentOrder.amountTax != 0;

    return Obx(() {
      if (!dataLoaded.value) {
        return const SizedBox.shrink();
      }

      double calculatedTotal = currentOrder.amountTotal ?? 0.0;
      if (orderLine.isNotEmpty) {
        calculatedTotal = orderLine.fold(0.0, (sum, line) {
          final priceUnit = _calculatePriceUnit(line);
          final quantity = line.productUomQty ?? 0.0;
          return sum + (priceUnit * quantity);
        });
      }

      return Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          boxShadow: [
            BoxShadow(
              color: FunctionalColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHT)
                  _buildTotalRow(
                    'Montant HT',
                    '${_currencyFormat.format(currentOrder.amountUntaxed)} MAD',
                  ),
                if (showTaxes) ...[
                  const SizedBox(height: 4),
                  _buildTotalRow(
                    'Taxes',
                    '${_currencyFormat.format(currentOrder.amountTax)} MAD',
                  ),
                  const SizedBox(height: 8),
                  Divider(color: AppColors.border, height: 1),
                  const SizedBox(height: 8),
                ],
                _buildTotalRow(
                  'Total',
                  '${_currencyFormat.format(calculatedTotal)} MAD',
                  isBold: true,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.nunito(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  double _calculatePriceUnit(OrderLineModel line) {
    final priceUnit = line.priceUnit ?? 0.0;
    final discount = line.discount ?? 0.0;

    if (discount > 0) {
      return priceUnit * (1 - (discount / 100));
    }
    return priceUnit;
  }

  String _getProductName(OrderLineModel line) {
    if (line.name != null && line.name!.isNotEmpty) {
      return line.name!;
    }

    if (line.productId != null &&
        line.productId is List &&
        line.productId!.length > 1) {
      return line.productId![1].toString();
    }

    if (line.productId != null && line.productId is String) {
      return line.productId.toString();
    }

    return 'Produit non défini';
  }

  bool _hasValue(dynamic value) {
    return value != null && value != false && value.toString().isNotEmpty;
  }

  String _formatDate(dynamic date) {
    if (date == null || date.toString() == 'false') return 'Non défini';
    try {
      final dateTime = DateTime.parse(date.toString());
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return date.toString();
    }
  }

  String _getFieldValue(dynamic field) {
    if (field == null || field == false) return 'Non défini';
    if (field is List && field.length > 1) return field[1].toString();
    return field.toString();
  }

  void _handleInvoiceTap() {
    accountMove.assignAll(
      PrefUtils.accountMove
          .where((p0) => p0.invoiceOrigin == currentOrder.name)
          .toList(),
    );
    if (accountMove.isEmpty) {
      _showSnackBar('Aucune facture disponible');
    } else {
      _showSnackBar('Ouverture: ${accountMove[0].name}');
    }
  }

  void _handleDeliveryTap({
    required List<StockPickingModel> stockPickings,
  }) async {
    if (stockPickings.isEmpty) {
      _showSnackBar('Aucun transfert disponible');
      return;
    }

    if (stockPickings.length == 1) {
      final result = await Get.to(
        () => StockPickingDetailScreen(stockPicking: stockPickings.first),
      );

      if (result == true) {
        await _refreshData();
      }
    } else {
      _showStockPickingSelectionDialog(stockPickings);
    }
  }

  void _showStockPickingSelectionDialog(List<StockPickingModel> pickings) {
    if (pickings.isEmpty) {
      _showSnackBar('Aucun transfert disponible');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(
          pickings.length == 1
              ? 'Transfert disponible'
              : 'Sélectionner un transfert (${pickings.length})',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pickings.length,
            itemBuilder: (context, index) {
              final picking = pickings[index];
              final statusColors = _getPickingStatusColors(picking.state!);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: AppColors.background,
                child: ListTile(
                  leading: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColors['color'],
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(
                    picking.name.toString(),
                    style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    'État: ${_getPickingStateLabel(picking.state!)}',
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () async {
                    Navigator.pop(context);

                    final result = await Get.to(
                      () => StockPickingDetailScreen(stockPicking: picking),
                    );

                    if (result == true) {
                      await _refreshData();
                    }
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler', style: GoogleFonts.raleway()),
          ),
        ],
      ),
    );
  }

  Map<String, Color> _getPickingStatusColors(String state) {
    const Color doneColor = Color(0xFF059669);
    const Color doneBgColor = Color(0xFFD1FAE5);
    const Color assignedColor = Color(0xFFF59E0B);
    const Color assignedBgColor = Color(0xFFFEF3C7);

    switch (state) {
      case 'draft':
        return {'color': StatusColors.draft, 'bg': StatusColors.draftBg};
      case 'confirmed':
        return {'color': StatusColors.sent, 'bg': StatusColors.sentBg};
      case 'assigned':
        return {'color': assignedColor, 'bg': assignedBgColor};
      case 'done':
        return {'color': doneColor, 'bg': doneBgColor};
      case 'cancel':
        return {'color': StatusColors.cancel, 'bg': StatusColors.cancelBg};
      default:
        return {'color': AppColors.textSecondary, 'bg': AppColors.background};
    }
  }

  String _getPickingStateLabel(String state) {
    switch (state) {
      case 'draft':
        return 'Brouillon';
      case 'confirmed':
        return 'Confirmé';
      case 'assigned':
        return 'Assigné';
      case 'done':
        return 'Terminé';
      case 'cancel':
        return 'Annulé';
      default:
        return state;
    }
  }
}
