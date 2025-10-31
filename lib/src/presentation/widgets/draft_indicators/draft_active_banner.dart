import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/src/data/services/draft_sale_service.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/controllers/controllers.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/create_new_order_form.dart';
import 'package:intl/intl.dart';

class DraftActiveBanner extends StatefulWidget {
  const DraftActiveBanner({super.key});

  @override
  State<DraftActiveBanner> createState() => _DraftActiveBannerState();
}

class _DraftActiveBannerState extends State<DraftActiveBanner> {
  final DraftSaleService _draftService = DraftSaleService.instance;
  final RxList<Map<String, dynamic>> _drafts = <Map<String, dynamic>>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
    // ✅ الاستماع للتحديثات في الوقت الحقيقي
    DraftSaleService.draftCountStream.listen((_) => _loadDrafts());
  }

  Future<void> _loadDrafts() async {
    try {
      _isLoading.value = true;
      final drafts = await _draftService.getAllDrafts();
      _drafts.assignAll(drafts);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading drafts: $e');
      }
    } finally {
      _isLoading.value = false;
    }
  }

  void _openDraft(Map<String, dynamic> draft) async {
    print('🔍 Loading draft from banner: ${draft['id']}');
    print('📋 Draft data: $draft');

    // إغلاق جميع الـ controllers الحالية بنفس طريقة DraftSalesScreen
    await Get.delete<OrderController>(force: true);
    await Get.delete<DraftController>(force: true);
    await Get.delete<PartnerController>(force: true);

    await Future.delayed(const Duration(milliseconds: 100));

    // فتح صفحة CreateNewOrder مع المسودة مباشرة
    final result = await Get.to(() => CreateNewOrder(draft: draft));

    // إذا تم حفظ المسودة بنجاح، قم بتحديث القائمة
    if (result == true) {
      _loadDrafts();
    }
  }

  void _deleteDraft(String draftId) async {
    try {
      await _draftService.deleteDraft(draftId);
      Get.snackbar(
        'تم الحذف',
        'تم حذف المسودة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف المسودة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd – HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  double _calculateDraftTotal(Map<String, dynamic> draft) {
    try {
      final products = draft['products'] as List? ?? [];
      double total = 0.0;

      for (var product in products) {
        final quantity = (product['quantity'] ?? 1).toDouble();
        final price = (product['price'] ?? 0).toDouble();
        total += quantity * price;
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  int _countProducts(Map<String, dynamic> draft) {
    try {
      final products = draft['products'] as List? ?? [];
      return products.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_isLoading.value) {
        return _buildLoadingBanner();
      }

      if (_drafts.isEmpty) {
        return const SizedBox.shrink();
      }
      final reversedDrafts = _drafts.reversed.toList();

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade50, Colors.lightGreen.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ الهيدر
            _buildBannerHeader(),

            // ✅ قائمة المسودات
            ...reversedDrafts.map(
              (draft) => InkWell(
                onTap: () => _openDraft(draft),
                child: _buildDraftCard(draft),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadingBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            color: Colors.green.shade600,
            strokeWidth: 2,
          ),
          const SizedBox(width: 12),
          Text(
            'جاري تحميل المسودات...',
            style: GoogleFonts.raleway(
              color: Colors.green.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.edit_note_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مسودات نشطة',
                  style: GoogleFonts.raleway(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'لديك ${_drafts.length} مسودة تحتاج الإكمال',
                  style: GoogleFonts.nunito(
                    color: Colors.green.shade700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_drafts.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> draft) {
    final total = _calculateDraftTotal(draft);
    final productCount = _countProducts(draft);
    final customerName = draft['customer'] ?? 'عميل';
    final lastModified = draft['lastModified'] != null
        ? _formatDate(draft['lastModified'])
        : 'غير معروف';

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ صف المعلومات العلوي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName.toString(),
                      style: GoogleFonts.raleway(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'آخر تعديل: $lastModified',
                      style: GoogleFonts.nunito(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  productCount > 1
                      ? '$productCount Produits'
                      : '$productCount Produit',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ✅ صف الإجراءات والسعر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${NumberFormat("#,##0.00").format(total)} MAD',
                style: GoogleFonts.nunito(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),

              const SizedBox(width: 8),

              // ✅ زر حذف المسودة
              _buildActionButton(
                'حذف',
                Icons.delete_outline,
                FunctionalColors.buttonDanger,
                () => _showDeleteConfirmation(draft),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> draft) {
    final customerName = draft['customerName'] ?? 'هذه المسودة';
    final draftId = draft['id']?.toString() ?? '';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            Text(
              'تأكيد الحذف',
              style: GoogleFonts.raleway(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف مسودة $customerName؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.nunito(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'إلغاء',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteDraft(draftId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FunctionalColors.buttonDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
