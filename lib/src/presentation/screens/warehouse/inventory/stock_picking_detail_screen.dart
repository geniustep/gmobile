// lib/src/presentation/screens/inventory/stock_picking_detail_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_backorder_confirmation_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_module.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/inventory/quantity_edit_screen.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:intl/intl.dart';

class StockPickingDetailScreen extends StatefulWidget {
  final StockPickingModel stockPicking;

  const StockPickingDetailScreen({super.key, required this.stockPicking});

  @override
  State<StockPickingDetailScreen> createState() =>
      _StockPickingDetailScreenState();
}

class _StockPickingDetailScreenState extends State<StockPickingDetailScreen> {
  late StockPickingModel currentPicking;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isInfoExpanded = false.obs;

  @override
  void initState() {
    super.initState();
    currentPicking = widget.stockPicking;

    if (kDebugMode) {
      print('\n🔄 ========== PICKING DETAIL LOADED ==========');
      print('Picking ID: ${currentPicking.id}');
      print('Picking Name: ${currentPicking.name}');
      print('Picking State: ${currentPicking.state}');
      print('Origin: ${currentPicking.origin}');
      print('Partner: ${_getPartnerName()}');
      _debugRelatedData();
    }
  }

  void _debugRelatedData() {
    if (kDebugMode) {
      print('\n🔍 ========== DEBUG RELATED DATA ==========');

      final relatedOrder = _findRelatedOrder();
      if (relatedOrder != null) {
        print('Related Order: ${relatedOrder.name} (ID: ${relatedOrder.id})');

        final relatedLines = _findRelatedOrderLines(relatedOrder);
        print('Related Order Lines: ${relatedLines.length}');

        for (var line in relatedLines) {
          print(' - Line: ${line.name} | Qty: ${line.productUomQty}');
        }

        print('Order State: ${relatedOrder.state}');
        print('Order Date: ${relatedOrder.dateOrder}');
        print('Order Partner: ${relatedOrder.partnerId}');
      } else {
        print('No related order found for origin: ${currentPicking.origin}');

        print('Available orders:');
        for (var order in PrefUtils.sales.take(3)) {
          print(' - ${order.name} (ID: ${order.id})');
        }
      }
      print('==========================================\n');
    }
  }

  OrderModel? _findRelatedOrder() {
    if (currentPicking.origin == null) return null;

    return PrefUtils.sales.firstWhere(
      (order) => order.name == currentPicking.origin,
      orElse: () => OrderModel(),
    );
  }

  List<OrderLineModel> _findRelatedOrderLines(OrderModel order) {
    return PrefUtils.orderLine
        .where(
          (line) =>
              line.id != null &&
              line.id is List &&
              line.id!.isNotEmpty &&
              line.id![0] == order.id,
        )
        .toList();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? FunctionalColors.buttonDanger
            : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateStockPickingInPrefs() async {
    try {
      final stockPickings = PrefUtils.stockPicking;
      final index = stockPickings.indexWhere((p) => p.id == currentPicking.id);

      if (index != -1) {
        stockPickings[index] = currentPicking;
        await PrefUtils.setStockPicking(stockPickings);

        if (kDebugMode) {
          print('✅ Stock Picking updated in PrefUtils');
          print('Updated state: ${currentPicking.state}');
          print('Updated dateDone: ${currentPicking.dateDone}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating Stock Picking in PrefUtils: $e');
      }
    }
  }

  void _showQuantityEditScreen() {
    if (currentPicking.id == null) {
      _showSnackBar('خطأ: معرف أمر التسليم غير متوفر', isError: true);
      return;
    }

    Get.to(() => QuantityEditScreen(stockPicking: currentPicking));
  }

  void _handleValidatePicking() async {
    if (currentPicking.id == null) {
      _showSnackBar('Erreur: ID du transfert manquant', isError: true);
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Confirmer le transfert',
      message:
          'Voulez-vous confirmer ce transfert? Cette action ne peut pas être annulée.',
      confirmText: 'Confirmer',
      icon: Icons.check_circle_outline,
      iconColor: AppColors.primary,
    );

    if (!confirmed) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (kDebugMode) {
        print('\n🔄 ========== PROCESSING DELIVERY ==========');
        print('Picking ID: ${currentPicking.id}');
        print('Picking Name: ${currentPicking.name}');
        print('Current State: ${currentPicking.state}');
        print('===============================================\n');
      }

      await _executeBackorderProcess();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error processing delivery: $e');
      }
      errorMessage.value = 'Erreur lors du traitement: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _handlePrint() {
    _showSnackBar('Fonction d\'impression en développement');
  }

  Future<void> _executeBackorderProcess() async {
    StockPickingModule.confirmStockPicking(
      args: [currentPicking.id!],
      onResponse: (response) async {
        if (kDebugMode) {
          print('✅ Picking Confirmed: $response');
        }

        if (response is Map && response.containsKey('res_model')) {
          final resModel = response['res_model'];

          if (resModel == 'stock.backorder.confirmation') {
            if (kDebugMode) {
              print('🔄 Odoo requests backorder confirmation');
            }

            final deliveryType = await _showDeliveryTypeDialog();

            if (deliveryType == 'deliver_and_keep') {
              await _handleBackorderWithNewModule(createBackorder: true);
            } else if (deliveryType == 'deliver_and_remove') {
              await _handleBackorderWithNewModule(createBackorder: false);
            }
          } else {
            await _executeDirectDelivery();
          }
        } else {
          await _executeDirectDelivery();
        }
      },
    );
  }

  Future<void> _handleBackorderWithNewModule({
    required bool createBackorder,
  }) async {
    isLoading.value = true;

    StockBackorderConfirmationModule.completeBackorderFlow(
      pickingId: currentPicking.id!,
      createBackorder: createBackorder,
      onResponse: (response) async {
        if (kDebugMode) {
          print('✅ Backorder Flow Completed: $response');
        }

        // ✅ تحديث محلياً
        currentPicking.state = 'done';
        currentPicking.dateDone = DateTime.now().toIso8601String();

        _showSnackBar(
          createBackorder
              ? 'تم التسليم وإنشاء backorder للباقي'
              : 'تم التسليم وإلغاء الباقي',
          isError: false,
        );

        setState(() {});
        isLoading.value = false;

        // ✅ العودة للشاشة السابقة بعد تأخير قصير
        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          // ✅ الانتقال لقائمة stock picking مع تحديث
          Get.back(result: true);
        }
      },
    );
  }

  Future<void> _executeDirectDelivery() async {
    if (kDebugMode) {
      print('✅ Direct Delivery - الكمية متوفرة بالكامل');
    }

    currentPicking.state = 'done';
    currentPicking.dateDone = DateTime.now().toIso8601String();

    await _updateStockPickingInPrefs();

    _showSnackBar('تم التسليم بنجاح!', isError: false);

    setState(() {});

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Get.back();
      }
    });
  }

  Future<String?> _showDeliveryTypeDialog() async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delivery_dining, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'نوع التسليم',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كيف تريد التعامل مع الكميات المتبقية؟',
              style: GoogleFonts.raleway(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _buildDialogOption(
              'تسليم والاحتفاظ',
              'تسليم الكمية المحددة والاحتفاظ بالباقي للطلب',
              Icons.save_outlined,
              AppColors.greenColor,
              'deliver_and_keep',
            ),
            const SizedBox(height: 12),
            _buildDialogOption(
              'تسليم والمسح',
              'تسليم الكمية المحددة ومسح الباقي من الطلب',
              Icons.delete_outline,
              AppColors.statusNotAccept,
              'deliver_and_remove',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.raleway()),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogOption(
    String title,
    String description,
    IconData icon,
    Color color,
    String value,
  ) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.raleway(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required IconData icon,
    required Color iconColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.nunito(
            color: AppColors.textSecondary,
            height: 1.5,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'Annuler',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              confirmText,
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.cardBackground,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: FunctionalColors.iconPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text(
        currentPicking.name ?? 'Transfert',
        style: GoogleFonts.jetBrainsMono(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.print, color: FunctionalColors.iconPrimary),
          onPressed: _handlePrint,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildStatusBar(),
        _buildCollapsibleInfo(),
        Expanded(child: _buildProductsSection()),
        _buildActionsSection(),
        Obx(
          () => errorMessage.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: FunctionalColors.buttonDanger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FunctionalColors.buttonDanger.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: FunctionalColors.buttonDanger,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage.value,
                          style: GoogleFonts.raleway(
                            color: FunctionalColors.buttonDanger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => errorMessage.value = '',
                        icon: Icon(
                          Icons.close,
                          color: FunctionalColors.buttonDanger,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    final currentState = currentPicking.state ?? 'draft';

    if (kDebugMode) {
      print('🔍 StatusBar Debug:');
      print('Current State: $currentState');
      print('Picking ID: ${currentPicking.id}');
      print('Picking Name: ${currentPicking.name}');
    }

    final statusColors = _getPickingStatusColors(currentState);
    final statusLabel = _getPickingStateLabel(currentState);
    final statusIcon = _getPickingStatusIcon(currentState);

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
          if (currentPicking.state == 'assigned')
            ElevatedButton(
              onPressed: _handleValidatePicking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: Text('Valider', style: GoogleFonts.raleway(fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleInfo() {
    final partnerName = _getPartnerName();

    return Obx(() {
      return Container(
        color: AppColors.cardBackground,
        child: Column(
          children: [
            InkWell(
              onTap: () => isInfoExpanded.value = !isInfoExpanded.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isInfoExpanded.value
                            ? partnerName
                            : '$partnerName - ${currentPicking.origin?.toString() ?? 'غير محدد'}',
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
                      isInfoExpanded.value
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            if (isInfoExpanded.value)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.description_outlined,
                      currentPicking.origin?.toString() ?? 'Non spécifié',
                    ),
                    _buildInfoRow(
                      Icons.date_range,
                      _formatDate(currentPicking.scheduledDate),
                    ),
                    if (currentPicking.dateDone != null)
                      _buildInfoRow(
                        Icons.check_circle,
                        'Terminé le ${_formatDate(currentPicking.dateDone)}',
                      ),
                    if (_getPartnerPhone() != null)
                      _buildInfoRow(Icons.phone, _getPartnerPhone()!),
                    if (_getPartnerEmail() != null)
                      _buildInfoRow(Icons.email, _getPartnerEmail()!),
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

  Widget _buildProductsSection() {
    final relatedOrderLines = _getRelatedOrderLines();
    final stockMoveLines = _getStockMoveLines();

    if (stockMoveLines.isNotEmpty) {
      return Column(
        children: [
          _buildStockMoveLinesHeader(stockMoveLines.length),
          Flexible(child: _buildStockMoveLinesList(stockMoveLines)),
        ],
      );
    }

    if (relatedOrderLines.isNotEmpty) {
      return Column(
        children: [
          _buildProductsHeader(relatedOrderLines.length),
          Flexible(child: _buildProductsList(relatedOrderLines)),
        ],
      );
    }

    return _buildEmptyProducts();
  }

  List<OrderLineModel> _getRelatedOrderLines() {
    final relatedOrder = _findRelatedOrder();
    if (relatedOrder?.id == null) return [];

    return PrefUtils.orderLine
        .where(
          (line) =>
              line.id != null &&
              line.id is List &&
              line.id!.isNotEmpty &&
              line.id![0] == relatedOrder!.id,
        )
        .toList();
  }

  List<dynamic> _getStockMoveLines() {
    if (currentPicking.moveIdsWithoutPackage == null) return [];

    if (kDebugMode) {
      print('\n🔍 ========== DEBUG STOCK MOVE LINES ==========');
      print('Picking ID: ${currentPicking.id}');
      print('Move IDs: ${currentPicking.moveIdsWithoutPackage}');
      print(
        'Move IDs type: ${currentPicking.moveIdsWithoutPackage.runtimeType}',
      );
    }

    return currentPicking.moveIdsWithoutPackage ?? [];
  }

  Widget _buildStockMoveLinesHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            'Produits transférés ($count)',
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockMoveLinesList(List<dynamic> lines) {
    return ListView.builder(
      itemCount: lines.length,
      itemBuilder: (context, index) {
        final line = lines[index];
        return _buildStockMoveLineItem(line);
      },
    );
  }

  Widget _buildStockMoveLineItem(dynamic line) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  line['product_id']?['display_name']?.toString() ??
                      line['name']?.toString() ??
                      'Produit inconnu',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildQuantityComparison(line),
          const SizedBox(height: 8),
          _buildDeliveryStatus(line),
        ],
      ),
    );
  }

  Widget _buildQuantityComparison(dynamic line) {
    final requiredQty = line['product_uom_qty']?.toDouble() ?? 0.0;
    final actualQty = line['quantity']?.toDouble() ?? 0.0;
    final picked = line['picked'] == true;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getQuantityStatusColor(
          requiredQty,
          actualQty,
          picked,
        ).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getQuantityStatusColor(requiredQty, actualQty, picked),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildQuantityCard(
                  'المطلوب',
                  requiredQty,
                  AppColors.primary,
                  Icons.shopping_cart,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildQuantityCard(
                  'المسلم',
                  actualQty,
                  _getQuantityStatusColor(requiredQty, actualQty, picked),
                  picked ? Icons.check_circle : Icons.pending,
                ),
              ),
            ],
          ),
          if (requiredQty != actualQty) ...[
            const SizedBox(height: 8),
            _buildStatusIndicator(requiredQty, actualQty, picked),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryStatus(dynamic line) {
    final state = line['state']?.toString() ?? 'unknown';
    final picked = line['picked'] == true;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _getStateColor(state).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _getStateColor(state)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStateIcon(state, picked),
                color: _getStateColor(state),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getStateLabel(state, picked),
                style: GoogleFonts.raleway(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStateColor(state),
                ),
              ),
            ],
          ),
        ),
        if (line['products_availability_state'] != null) ...[
          const SizedBox(height: 4),
          _buildAvailabilityAlert(line),
        ],
        if (line['is_quantity_done_editable'] == true) ...[
          const SizedBox(height: 4),
          _buildEditabilityInfo(line),
        ],
        if (line['has_tracking'] != null && line['has_tracking'] != 'none') ...[
          const SizedBox(height: 4),
          _buildTrackingInfo(line),
        ],
      ],
    );
  }

  Widget _buildQuantityCard(
    String label,
    double value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.raleway(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value.toStringAsFixed(0),
            style: GoogleFonts.raleway(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(double required, double actual, bool picked) {
    if (required == actual) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: AppColors.greenColor, size: 14),
          const SizedBox(width: 4),
          Text(
            'مكتمل',
            style: GoogleFonts.raleway(
              fontSize: 11,
              color: AppColors.greenColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else if (actual < required) {
      final shortage = required - actual;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: AppColors.orange, size: 14),
          const SizedBox(width: 4),
          Text(
            'نقص: ${shortage.toStringAsFixed(0)}',
            style: GoogleFonts.raleway(
              fontSize: 11,
              color: AppColors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    } else {
      final excess = actual - required;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle, color: AppColors.blue, size: 14),
          const SizedBox(width: 4),
          Text(
            'زيادة: ${excess.toStringAsFixed(0)}',
            style: GoogleFonts.raleway(
              fontSize: 11,
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
  }

  Color _getQuantityStatusColor(double required, double actual, bool picked) {
    if (required == actual && picked) {
      return AppColors.greenColor;
    } else if (actual < required) {
      return AppColors.orange;
    } else if (actual > required) {
      return AppColors.blue;
    } else {
      return AppColors.textSecondary;
    }
  }

  Color _getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'draft':
        return AppColors.textSecondary;
      case 'waiting':
        return AppColors.orange;
      case 'confirmed':
        return AppColors.blue;
      case 'assigned':
        return AppColors.primary;
      case 'done':
        return AppColors.greenColor;
      case 'cancel':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStateIcon(String state, bool picked) {
    if (picked) return Icons.check_circle;

    switch (state.toLowerCase()) {
      case 'draft':
        return Icons.edit;
      case 'waiting':
        return Icons.hourglass_empty;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'assigned':
        return Icons.inventory;
      case 'done':
        return Icons.check_circle;
      case 'cancel':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStateLabel(String state, bool picked) {
    if (picked) return 'تم التسليم';

    switch (state.toLowerCase()) {
      case 'draft':
        return 'مسودة';
      case 'waiting':
        return 'في الانتظار';
      case 'confirmed':
        return 'مؤكد';
      case 'assigned':
        return 'مخصص';
      case 'done':
        return 'مكتمل';
      case 'cancel':
        return 'ملغي';
      default:
        return 'غير معروف';
    }
  }

  Widget _buildAvailabilityAlert(dynamic line) {
    final availabilityState = line['products_availability_state']?.toString();
    final availability = line['products_availability']?.toString();
    final forecastAvailability =
        line['forecast_availability']?.toDouble() ?? 0.0;

    Color alertColor;
    IconData alertIcon;
    String alertText;

    if (availabilityState == 'late') {
      alertColor = Colors.red;
      alertIcon = Icons.warning;
      alertText = 'متأخر';
    } else if (availability == 'Pas disponible') {
      alertColor = Colors.orange;
      alertIcon = Icons.block;
      alertText = 'غير متوفر';
    } else if (forecastAvailability < 0) {
      alertColor = Colors.orange;
      alertIcon = Icons.inventory_2;
      alertText =
          'نقص في المخزون: ${forecastAvailability.abs().toStringAsFixed(0)}';
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: alertColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: alertColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(alertIcon, color: alertColor, size: 12),
          const SizedBox(width: 4),
          Text(
            alertText,
            style: GoogleFonts.raleway(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: alertColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditabilityInfo(dynamic line) {
    final isQuantityEditable = line['is_quantity_done_editable'] == true;
    final isInitialEditable = line['is_initial_demand_editable'] == true;

    if (!isQuantityEditable && !isInitialEditable) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit, color: AppColors.blue, size: 12),
          const SizedBox(width: 4),
          Text(
            isQuantityEditable ? 'قابل للتعديل' : 'مقيد',
            style: GoogleFonts.raleway(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingInfo(dynamic line) {
    final hasTracking = line['has_tracking']?.toString();
    final showLotsText = line['show_lots_text'] == true;
    final showLotsM2o = line['show_lots_m2o'] == true;

    if (hasTracking == 'none' && !showLotsText && !showLotsM2o) {
      return const SizedBox.shrink();
    }

    String trackingText = '';
    if (hasTracking != 'none') {
      trackingText = 'تتبع: $hasTracking';
    } else if (showLotsText) {
      trackingText = 'دفعات';
    } else if (showLotsM2o) {
      trackingText = 'أرقام تسلسلية';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code, color: AppColors.primary, size: 12),
          const SizedBox(width: 4),
          Text(
            trackingText,
            style: GoogleFonts.raleway(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsHeader(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.primary),
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
              '$count article${count > 1 ? 's' : ''}',
              style: GoogleFonts.raleway(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun produit disponible',
            style: GoogleFonts.raleway(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentPicking.state == 'done'
                ? 'Ce transfert est terminé.\nTous les produits ont été traités.'
                : 'Les produits liés à ce transfert\nseront affichés ici',
            textAlign: TextAlign.center,
            style: GoogleFonts.raleway(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(List<OrderLineModel> orderLines) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: orderLines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildProductCard(orderLines[index]),
    );
  }

  Widget _buildProductCard(OrderLineModel line) {
    final currency = NumberFormat("#,##0.00", "en_US");
    final productName = _getProductName(line);
    final totalPrice = (line.priceTotal ?? 0).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1),
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
                  productName,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quantité: ${line.productUomQty}',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (line.priceUnit != null)
                      Text(
                        'Prix unitaire: ${currency.format(line.priceUnit)} MAD',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${currency.format(totalPrice)} MAD',
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

  Widget _buildActionsSection() {
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Text('Retour', style: GoogleFonts.raleway()),
                ),
              ),
              const SizedBox(width: 12),
              if (currentPicking.state != 'done' &&
                  currentPicking.state != 'cancel')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQuantityEditScreen(),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text('تعديل الكميات', style: GoogleFonts.raleway()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              if (currentPicking.state == 'assigned')
                Expanded(
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : _handleValidatePicking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.surfaceLight,
                      ),
                      child: isLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Validation...',
                                  style: GoogleFonts.raleway(),
                                ),
                              ],
                            )
                          : Text('Valider', style: GoogleFonts.raleway()),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProductName(OrderLineModel line) {
    try {
      if (line.productId != null &&
          line.productId is List &&
          line.productId!.length > 1) {
        return line.productId![1].toString();
      }
      return line.name ?? 'Produit non défini';
    } catch (e) {
      return 'Produit non défini';
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

  Map<String, Color> _getPickingStatusColors(String state) {
    const Color doneColor = Color(0xFF059669);
    const Color doneBgColor = Color(0xFFD1FAE5);

    switch (state) {
      case 'draft':
        return {'color': StatusColors.draft, 'bg': StatusColors.draftBg};
      case 'confirmed':
        return {'color': StatusColors.sent, 'bg': StatusColors.sentBg};
      case 'assigned':
        return {'color': StatusColors.sale, 'bg': StatusColors.saleBg};
      case 'done':
        return {'color': doneColor, 'bg': doneBgColor};
      case 'cancel':
        return {'color': StatusColors.cancel, 'bg': StatusColors.cancelBg};
      default:
        return {'color': AppColors.textSecondary, 'bg': AppColors.background};
    }
  }

  String _getPartnerName() {
    if (currentPicking.partnerId == null) return 'غير محدد';

    if (currentPicking.partnerId is Map) {
      return currentPicking.partnerId['display_name']?.toString() ?? 'غير محدد';
    } else if (currentPicking.partnerId is List &&
        currentPicking.partnerId.length > 1) {
      return currentPicking.partnerId[1]?.toString() ?? 'غير محدد';
    }

    return 'غير محدد';
  }

  String? _getPartnerPhone() {
    if (currentPicking.partnerId != null && currentPicking.partnerId is Map) {
      return currentPicking.partnerId['phone']?.toString();
    }
    return null;
  }

  String? _getPartnerEmail() {
    if (currentPicking.partnerId != null && currentPicking.partnerId is Map) {
      return currentPicking.partnerId['email']?.toString();
    }
    return null;
  }

  IconData _getPickingStatusIcon(String state) {
    switch (state) {
      case 'draft':
        return Icons.edit_outlined;
      case 'confirmed':
        return Icons.checklist_outlined;
      case 'assigned':
        return Icons.inventory_2_outlined;
      case 'done':
        return Icons.check_circle_outlined;
      case 'cancel':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Non défini';
    try {
      if (date is String) {
        final dateTime = DateTime.parse(date);
        return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
      }
      return date.toString();
    } catch (e) {
      return 'Non défini';
    }
  }
}
