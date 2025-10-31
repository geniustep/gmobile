import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_module.dart';

class QuantityEditScreen extends StatefulWidget {
  final StockPickingModel stockPicking;

  const QuantityEditScreen({super.key, required this.stockPicking});

  @override
  State<QuantityEditScreen> createState() => _QuantityEditScreenState();
}

class _QuantityEditScreenState extends State<QuantityEditScreen> {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Map<int, double> quantityChanges = {}; // product_id -> new_quantity

  // Safely extract Many2one/various forms to an int id
  dynamic _extractId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is int) return first;
      if (first is String) return int.tryParse(first);
    }
    if (value is Map) {
      final dynamic id = value['id'];
      if (id is int) return id;
      if (id is String) return int.tryParse(id);
    }
    return null;
  }

  // Extract display name from Many2one-like values
  String _extractDisplayName(dynamic value, {String fallback = 'غير محدد'}) {
    if (value is List && value.length > 1) return value[1].toString();
    if (value is Map) {
      return (value['display_name'] ?? value['name'] ?? fallback).toString();
    }
    return fallback;
  }

  @override
  void initState() {
    super.initState();
    _initializeQuantities();
  }

  void _initializeQuantities() {
    // تهيئة الكميات الحالية
    if (widget.stockPicking.moveIdsWithoutPackage != null) {
      for (var move in widget.stockPicking.moveIdsWithoutPackage!) {
        if (move is Map && move['product_id'] != null) {
          final dynamic productId = _extractId(move['product_id']);
          final currentQty = move['product_uom_qty']?.toDouble() ?? 0.0;
          if (productId != null) {
            quantityChanges[productId] = currentQty;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: _buildAppBar(), body: _buildContent());
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'تعديل الكميات',
        style: GoogleFonts.raleway(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        Obx(
          () => isLoading.value
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  onPressed: _handleSaveChanges,
                  icon: const Icon(Icons.save_outlined),
                  tooltip: 'حفظ التغييرات',
                ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // معلومات أمر التسليم
        _buildPickingInfo(),

        // قائمة المنتجات
        Expanded(child: _buildProductsList()),

        // رسالة الخطأ
        Obx(
          () => errorMessage.value.isNotEmpty
              ? _buildErrorMessage()
              : Container(),
        ),

        // أزرار الإجراءات
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildPickingInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'أمر التسليم: ${widget.stockPicking.name ?? 'غير محدد'}',
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'الحالة: ${_getStateLabel(widget.stockPicking.state ?? 'غير محدد')}',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (widget.stockPicking.moveIdsWithoutPackage == null ||
        widget.stockPicking.moveIdsWithoutPackage!.isEmpty) {
      return const Center(child: Text('لا توجد منتجات في هذا الأمر'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.stockPicking.moveIdsWithoutPackage!.length,
      itemBuilder: (context, index) {
        final move = widget.stockPicking.moveIdsWithoutPackage![index];
        return _buildProductCard(move);
      },
    );
  }

  Widget _buildProductCard(dynamic move) {
    if (move is! Map) return Container();

    final dynamic productId = _extractId(move['product_id']);
    final String productName = _extractDisplayName(
      move['product_id'],
      fallback: move['name']?.toString() ?? 'منتج غير محدد',
    );
    final originalQty = move['product_uom_qty']?.toDouble() ?? 0.0;
    final currentQty = productId != null
        ? (quantityChanges[productId] ?? originalQty)
        : originalQty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اسم المنتج
            Row(
              children: [
                Icon(Icons.inventory_2, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    productName,
                    style: GoogleFonts.raleway(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // الكمية المطلوبة الأصلية
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shopping_cart, color: AppColors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'الكمية المطلوبة: ${originalQty.toStringAsFixed(2)}',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      color: AppColors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // تعديل الكمية
            Row(
              children: [
                Expanded(
                  child: Text(
                    'الكمية الجديدة:',
                    style: GoogleFonts.raleway(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: currentQty.toString(),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'أدخل الكمية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (value) {
                      final newQty = double.tryParse(value) ?? 0.0;
                      if (newQty >= 0 && productId != null) {
                        setState(() {
                          quantityChanges[productId] = newQty;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),

            // مؤشر التغيير
            if (currentQty != originalQty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: currentQty > originalQty
                      ? AppColors.greenColor.withOpacity(0.1)
                      : AppColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: currentQty > originalQty
                        ? AppColors.greenColor.withOpacity(0.3)
                        : AppColors.orange.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      currentQty > originalQty
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: currentQty > originalQty
                          ? AppColors.greenColor
                          : AppColors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      currentQty > originalQty
                          ? 'زيادة: +${(currentQty - originalQty).toStringAsFixed(2)}'
                          : 'نقصان: -${(originalQty - currentQty).toStringAsFixed(2)}',
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: currentQty > originalQty
                            ? AppColors.greenColor
                            : AppColors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusNotAccept.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.statusNotAccept.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.statusNotAccept, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage.value,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: AppColors.statusNotAccept,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
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
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.cancel_outlined),
              label: Text('إلغاء', style: GoogleFonts.raleway()),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _handleSaveChanges,
              icon: const Icon(Icons.save_outlined),
              label: Text('حفظ التغييرات', style: GoogleFonts.raleway()),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSaveChanges() async {
    // التحقق من وجود تغييرات
    bool hasChanges = false;
    for (var move in widget.stockPicking.moveIdsWithoutPackage!) {
      if (move is Map && move['product_id'] != null) {
        final dynamic productId = _extractId(move['product_id']);
        final originalQty = move['product_uom_qty']?.toDouble() ?? 0.0;
        final newQty = productId != null
            ? (quantityChanges[productId] ?? originalQty)
            : originalQty;

        if (newQty != originalQty) {
          hasChanges = true;
          break;
        }
      }
    }

    if (!hasChanges) {
      _showSnackBar('لم يتم إجراء أي تغييرات', isError: true);
      return;
    }

    // عرض dialog للاختيار بين التسليم والمسح أو التسليم والاحتفاظ
    final result = await _showDeliveryDialog();
    if (result != null) {
      await _executeChanges(result);
    }
  }

  Future<String?> _showDeliveryDialog() async {
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delivery_dining, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'تأكيد التسليم',
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
              'تسليم والمسح',
              'تسليم الكمية المحددة ومسح الباقي من الطلب',
              Icons.delete_outline,
              AppColors.statusNotAccept,
              'deliver_and_remove',
            ),
            const SizedBox(height: 12),
            _buildDialogOption(
              'تسليم والاحتفاظ',
              'تسليم الكمية المحددة والاحتفاظ بالباقي للطلب',
              Icons.save_outlined,
              AppColors.greenColor,
              'deliver_and_keep',
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

  Future<void> _executeChanges(String deliveryType) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // فقط تحديث الكميات باستخدام web_save
      await _updateQuantitiesWithWebSave();

      // العودة للشاشة السابقة
      Navigator.pop(context, true);
    } catch (e) {
      errorMessage.value = 'خطأ في تحديث الكميات: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateQuantitiesWithWebSave() async {
    // استخدام web_save لتحديث الكميات
    final List<Map<String, dynamic>> moveUpdates = [];

    for (var move in widget.stockPicking.moveIdsWithoutPackage!) {
      if (move is Map && move['product_id'] != null) {
        final dynamic productId = _extractId(move['product_id']);
        final newQty = productId != null
            ? (quantityChanges[productId] ?? 0.0)
            : 0.0;
        final originalQty = move['product_uom_qty']?.toDouble() ?? 0.0;

        if (newQty != originalQty) {
          moveUpdates.add({'id': move['id'], 'quantity': newQty});
        }
      }
    }

    if (moveUpdates.isNotEmpty) {
      // استخدام web_save API
      await _callWebSave(moveUpdates);
    }
  }

  Future<void> _callWebSave(List<Map<String, dynamic>> moveUpdates) async {
    // تنفيذ web_save API call
    StockPickingModule.webSaveStockPicking(
      pickingId: widget.stockPicking.id!,
      moveUpdates: moveUpdates,
      onResponse: (response) {
        print('✅ Web Save - تم تحديث الكميات: $response');
        _showSnackBar('تم تحديث الكميات بنجاح');
      },
    );
  }

  String _getStateLabel(String state) {
    switch (state) {
      case 'draft':
        return 'مسودة';
      case 'confirmed':
        return 'مؤكد';
      case 'assigned':
        return 'معين';
      case 'done':
        return 'مكتمل';
      case 'cancel':
        return 'ملغي';
      default:
        return state;
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: isError
            ? AppColors.statusNotAccept
            : AppColors.greenColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
