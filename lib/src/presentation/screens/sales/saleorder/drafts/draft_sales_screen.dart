// draft_sales_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/services/draft/draft_sale_service.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/controllers/controllers.dart';
import 'package:gsloution_mobile/src/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_active_banner.dart';

class DraftSalesScreen extends StatefulWidget {
  const DraftSalesScreen({super.key});

  @override
  State<DraftSalesScreen> createState() => _DraftSalesScreenState();
}

class _DraftSalesScreenState extends State<DraftSalesScreen> {
  final DraftSaleService _draftService = DraftSaleService.instance;
  final PartnerController partnerController = Get.put(PartnerController());
  List<Map<String, dynamic>> drafts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  Future<void> _loadDrafts() async {
    setState(() => isLoading = true);
    drafts = await _draftService.getAllDrafts();
    drafts.sort(
      (a, b) => (b['lastModified'] ?? '').compareTo(a['lastModified'] ?? ''),
    );
    setState(() => isLoading = false);
  }

  // Future<void> _deleteDraft(String draftId) async {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('حذف المسودة'),
  //       content: const Text('هل أنت متأكد من حذف هذه المسودة؟'),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('إلغاء'),
  //         ),
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           style: TextButton.styleFrom(foregroundColor: Colors.red),
  //           child: const Text('حذف'),
  //         ),
  //       ],
  //     ),
  //   );

  //   if (confirm == true) {
  //     await _draftService.deleteDraft(draftId);
  //     _loadDrafts();
  //     if (mounted) {
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('تم حذف المسودة')));
  //     }
  //   }
  // }

  // draft_sales_screen.dart - تعديل _loadDraft

  // Future<void> _loadDraft(Map<String, dynamic> draft) async {
  //   print('🔍 Loading draft: ${draft['id']}');
  //   print('📋 Draft data: $draft');

  //   if (mounted) {
  //     await Get.delete<OrderController>(force: true);
  //     await Get.delete<DraftController>(force: true);
  //     await Get.delete<PartnerController>(force: true);

  //     await Future.delayed(const Duration(milliseconds: 100));

  //     final result = await Get.to(() => CreateNewOrder(draft: draft));

  //     if (result == true) {
  //       _loadDrafts();
  //     }
  //   }
  // }

  // String _formatDate(String? dateStr) {
  //   if (dateStr == null) return '';
  //   try {
  //     final date = DateTime.parse(dateStr);
  //     return DateFormat('dd/MM/yyyy HH:mm').format(date);
  //   } catch (e) {
  //     return '';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: drafts.isEmpty
          ? const PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: CustomAppBar(navigateName: "المسودات"),
            )
          : AppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : drafts.isEmpty
          ? _buildEmptyState()
          : _draftActiveBanner(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.drafts_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'لا توجد مسودات محفوظة',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سيتم حفظ المبيعات تلقائياً هنا',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // Widget _buildDraftsList() {
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(16),
  //     itemCount: drafts.length,
  //     itemBuilder: (context, index) {
  //       final draft = drafts[index];
  //       final products = draft['products'] as List? ?? [];
  //       final totalAmount = draft['totalAmount'] ?? 0.0;
  //       final customer = draft['customer'] ?? 'عميل غير محدد';

  //       return Card(
  //         margin: const EdgeInsets.only(bottom: 12),
  //         elevation: 2,
  //         child: InkWell(
  //           onTap: () => _loadDraft(draft),
  //           borderRadius: BorderRadius.circular(8),
  //           child: Padding(
  //             padding: const EdgeInsets.all(16),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Expanded(
  //                       child: Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             customer,
  //                             style: const TextStyle(
  //                               fontSize: 16,
  //                               fontWeight: FontWeight.bold,
  //                             ),
  //                           ),
  //                           const SizedBox(height: 4),
  //                           Text(
  //                             _formatDate(draft['lastModified']),
  //                             style: TextStyle(
  //                               fontSize: 12,
  //                               color: Colors.grey[600],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     IconButton(
  //                       icon: const Icon(
  //                         Icons.delete_outline,
  //                         color: Colors.red,
  //                       ),
  //                       onPressed: () => _deleteDraft(draft['id']),
  //                     ),
  //                   ],
  //                 ),
  //                 const Divider(height: 16),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                   children: [
  //                     Row(
  //                       children: [
  //                         Icon(
  //                           Icons.shopping_cart,
  //                           size: 16,
  //                           color: Colors.grey[600],
  //                         ),
  //                         const SizedBox(width: 4),
  //                         Text(
  //                           '${products.length} منتج',
  //                           style: TextStyle(
  //                             fontSize: 14,
  //                             color: Colors.grey[700],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     Text(
  //                       '${totalAmount.toStringAsFixed(2)} د.م.',
  //                       style: TextStyle(
  //                         fontSize: 16,
  //                         fontWeight: FontWeight.bold,
  //                         color: AppColors.primary,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _draftActiveBanner() {
    return const DraftActiveBanner();
  }
}
