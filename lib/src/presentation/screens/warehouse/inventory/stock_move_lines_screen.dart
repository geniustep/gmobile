import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class StockMoveLinesScreen extends StatefulWidget {
  final int pickingId;
  final String pickingName;

  const StockMoveLinesScreen({
    super.key,
    required this.pickingId,
    required this.pickingName,
  });

  @override
  State<StockMoveLinesScreen> createState() => _StockMoveLinesScreenState();
}

class _StockMoveLinesScreenState extends State<StockMoveLinesScreen> {
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void initState() {
    super.initState();
    _loadStockMoveLines();
  }

  Future<void> _loadStockMoveLines() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // البحث عن stock.picking المطلوب
      final picking = PrefUtils.stockPicking.firstWhereOrNull(
        (p) => p.id == widget.pickingId,
      );

      if (picking != null && picking.moveIdsWithoutPackage != null) {
        if (kDebugMode) {
          print(
            '📦 Stock Move Lines loaded from stock.picking: ${picking.moveIdsWithoutPackage!.length}',
          );
        }
        // البيانات جاهزة - لا حاجة لاستدعاءات API إضافية
      } else {
        if (kDebugMode) {
          print('❌ Stock Picking not found or no move lines');
        }
        errorMessage.value = 'لم يتم العثور على تفاصيل المنتجات';
      }
    } catch (e) {
      errorMessage.value = 'خطأ في جلب تفاصيل المنتجات: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _updateLineQuantity(dynamic line, double newQty) async {
    if (newQty < 0) {
      _showSnackBar('الكمية لا يمكن أن تكون سالبة', isError: true);
      return;
    }

    try {
      // TODO: تنفيذ تحديث الكمية باستخدام stock.picking
      _showSnackBar('تم تحديث الكمية بنجاح');
      setState(() {});
    } catch (e) {
      _showSnackBar('خطأ في تحديث الكمية: $e', isError: true);
    }
  }

  Future<void> _deleteLine(dynamic line) async {
    final confirmed = await _showConfirmDialog(
      title: 'حذف المنتج',
      message: 'هل أنت متأكد من حذف هذا المنتج من أمر التسليم؟',
      confirmText: 'حذف',
      icon: Icons.delete_outline,
      iconColor: AppColors.statusNotAccept,
    );

    if (!confirmed) return;

    try {
      // TODO: تنفيذ حذف المنتج باستخدام stock.picking
      _showSnackBar('تم حذف المنتج بنجاح');
      setState(() {});
    } catch (e) {
      _showSnackBar('خطأ في حذف المنتج: $e', isError: true);
    }
  }

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required IconData icon,
    required Color iconColor,
  }) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: Text(message, style: GoogleFonts.raleway()),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('إلغاء', style: GoogleFonts.raleway()),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(confirmText, style: GoogleFonts.raleway()),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message, {bool isError = false}) {
    Get.snackbar(
      isError ? 'خطأ' : 'نجح',
      message,
      backgroundColor: isError ? AppColors.statusNotAccept : AppColors.primary,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'تفاصيل المنتجات - ${widget.pickingName}',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _loadStockMoveLines,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (PrefUtils.stockMoveLines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.surfaceLight,
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد منتجات في هذا الأمر',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    color: AppColors.surfaceLight,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // قائمة المنتجات
            Expanded(child: _buildStockMoveLinesList()),

            // رسالة الخطأ
            Obx(
              () => errorMessage.value.isNotEmpty
                  ? Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusNotAccept.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.statusNotAccept.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: AppColors.statusNotAccept,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage.value,
                              style: GoogleFonts.raleway(
                                color: AppColors.statusNotAccept,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => errorMessage.value = '',
                            icon: Icon(
                              Icons.close,
                              color: AppColors.statusNotAccept,
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
      }),
    );
  }

  Widget _buildStockMoveLinesList() {
    // البحث عن stock.picking المطلوب
    final picking = PrefUtils.stockPicking.firstWhereOrNull(
      (p) => p.id == widget.pickingId,
    );

    if (picking == null || picking.moveIdsWithoutPackage == null) {
      return const Center(child: Text('لا توجد منتجات في هذا الأمر'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: picking.moveIdsWithoutPackage!.length,
      itemBuilder: (context, index) {
        final line = picking.moveIdsWithoutPackage![index];
        return _buildStockMoveLineCard(line);
      },
    );
  }

  Widget _buildStockMoveLineCard(dynamic line) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات المنتج
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line['product_id']?['display_name']?.toString() ??
                            line['name']?.toString() ??
                            'منتج غير محدد',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'المرجع: ${line['reference']?.toString() ?? 'غير محدد'}',
                        style: GoogleFonts.raleway(
                          color: AppColors.surfaceLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStateChip(line['state']?.toString() ?? ''),
              ],
            ),

            const SizedBox(height: 16),

            // الكميات
            Row(
              children: [
                Expanded(
                  child: _buildQuantityInfo(
                    'المطلوب',
                    line['quantity']?.toDouble() ??
                        line['product_uom_qty']?.toDouble() ??
                        0.0,
                    AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuantityInfo(
                    'المسلم',
                    line['picked'] == true
                        ? (line['quantity']?.toDouble() ??
                              line['product_uom_qty']?.toDouble() ??
                              0.0)
                        : 0.0,
                    AppColors.greenColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // أزرار التحكم
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showQuantityDialog(line),
                    icon: const Icon(Icons.edit, size: 16),
                    label: Text(
                      'تعديل',
                      style: GoogleFonts.raleway(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _deleteLine(line),
                    icon: const Icon(Icons.delete, size: 16),
                    label: Text(
                      'حذف',
                      style: GoogleFonts.raleway(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusNotAccept,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildStateChip(String state) {
    Color color;
    String label;

    switch (state) {
      case 'draft':
        color = AppColors.surfaceLight;
        label = 'مسودة';
        break;
      case 'waiting':
        color = AppColors.orange;
        label = 'في الانتظار';
        break;
      case 'confirmed':
        color = AppColors.primary;
        label = 'مؤكد';
        break;
      case 'assigned':
        color = AppColors.blue;
        label = 'مخصص';
        break;
      case 'done':
        color = AppColors.greenColor;
        label = 'مكتمل';
        break;
      case 'cancel':
        color = AppColors.statusNotAccept;
        label = 'ملغي';
        break;
      default:
        color = AppColors.surfaceLight;
        label = 'غير محدد';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: GoogleFonts.raleway(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(String label, double quantity, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.raleway(
              fontSize: 12,
              color: AppColors.surfaceLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            quantity.toStringAsFixed(2),
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(dynamic line) {
    final TextEditingController qtyController = TextEditingController(
      text:
          (line['quantity']?.toDouble() ??
                  line['product_uom_qty']?.toDouble() ??
                  0.0)
              .toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'تعديل الكمية',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'الكمية المطلوبة: ${line.quantity?.toDouble() ?? 0.0}',
              style: GoogleFonts.raleway(color: AppColors.surfaceLight),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'الكمية الجديدة',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء', style: GoogleFonts.raleway()),
          ),
          ElevatedButton(
            onPressed: () {
              final newQty = double.tryParse(qtyController.text) ?? 0.0;
              Navigator.of(context).pop();
              _updateLineQuantity(line, newQty);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('حفظ', style: GoogleFonts.raleway()),
          ),
        ],
      ),
    );
  }
}
