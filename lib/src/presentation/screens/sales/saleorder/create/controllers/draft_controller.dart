// lib/src/presentation/screens/sales/saleorder/create/controllers/draft_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/services/draft/draft_sale_service.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/controllers/order_controller.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class DraftController extends GetxController {
  // ============= State =============

  /// معرف المسودة الحالية
  final Rxn<String> currentDraftId = Rxn<String>();

  /// هل يوجد مسودة نشطة؟
  final RxBool hasActiveDraft = false.obs;

  /// عدد المسودات المحفوظة
  final RxInt draftsCount = 0.obs;

  /// تاريخ آخر حفظ
  final Rxn<DateTime> lastSavedAt = Rxn<DateTime>();

  // ============= Services =============

  final DraftSaleService _draftService = DraftSaleService.instance;

  // ============= Dependencies =============

  OrderController get orderController => Get.find<OrderController>();

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();

    // تحديث عدد المسودات
    _updateDraftsCount();
  }

  // ============= Draft Loading =============

  /// فحص وتحميل المسودة النشطة
  Future<void> checkAndLoadDraft({
    required String customerName,
    dynamic partnerId,
    dynamic priceListId,
  }) async {
    if (kDebugMode) {
      print('\n📋 Checking for active draft...');
    }

    final draft = await _draftService.getActiveDraft();

    if (draft != null) {
      hasActiveDraft.value = true;
      final productsCount = (draft['products'] as List?)?.length ?? 0;

      if (kDebugMode) {
        print('   Found draft:');
        print('   ID: ${draft['id']}');
        print('   Customer: ${draft['customer']}');
        print('   Products: $productsCount');
        print('   Total: ${draft['totalAmount']} Dh');
      }

      // عرض حوار للمستخدم
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.drafts, color: Colors.blue),
              SizedBox(width: 8),
              Text('مسودة محفوظة'),
            ],
          ),
          content: Text(
            'لديك مسودة محفوظة تحتوي على $productsCount منتج.\nهل تريد استكمالها؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('بداية جديدة'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('استكمال'),
            ),
          ],
        ),
      );

      if (result == true) {
        await loadAndApplyDraft(draft);
      } else {
        await clearActiveDraft();
      }
    } else {
      hasActiveDraft.value = false;

      if (kDebugMode) {
        print('   No active draft found');
      }
    }
  }

  /// تحميل وتطبيق المسودة
  Future<void> loadAndApplyDraft(Map<String, dynamic> draft) async {
    try {
      if (kDebugMode) {
        print('\n📥 ========== LOADING DRAFT ==========');
        print('Draft ID: ${draft['id']}');
      }

      currentDraftId.value = draft['id'];

      // تحميل المنتجات
      final products = draft['products'] as List? ?? [];
      await orderController.loadFromDraft(products);

      // تحديث تاريخ آخر حفظ
      if (draft['lastModified'] != null) {
        lastSavedAt.value = DateTime.parse(draft['lastModified']);
      }

      if (kDebugMode) {
        print('✅ Draft loaded successfully');
        print('   Products: ${orderController.productsCount}');
        print('   Total: ${orderController.getOrderTotal()} Dh');
        print('=====================================\n');
      }

      // ✅ إزالة الرسالة المزعجة عند تحميل المسودة
      // Get.snackbar(
      //   'تم التحميل',
      //   'تم تحميل ${orderController.productsCount} منتج من المسودة',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.green.withOpacity(0.8),
      //   colorText: Colors.white,
      //   duration: const Duration(seconds: 2),
      //   icon: const Icon(Icons.check_circle, color: Colors.white),
      // );
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR LOADING DRAFT ==========');
        print('Error: $e');
        print('Stack trace: $stackTrace');
        print('=========================================\n');
      }

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء تحميل المسودة: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // ============= Draft Saving =============

  /// حفظ المسودة تلقائياً
  Future<void> autoSaveDraft({
    required String customerName,
    required int partnerId,
    dynamic priceListId,
  }) async {
    // التحقق من وجود منتجات
    if (!orderController.hasProducts) {
      if (kDebugMode) {
        print('⚠️ No products to save in draft');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('\n💾 ========== AUTO SAVING DRAFT ==========');
        print('Customer: $customerName (ID: $partnerId)');
        print('Pricelist ID: $priceListId');
        print('Products count: ${orderController.productsCount}');
      }

      final draftData = {
        'id': currentDraftId.value,
        'partnerId': partnerId,
        'customer': customerName,
        'priceListId': priceListId,
        'products': orderController.getProductLinesData(),
        'totalAmount': orderController.getOrderTotal(),
        'lastModified': DateTime.now().toIso8601String(),
      };

      currentDraftId.value = await _draftService.saveDraft(draftData);
      lastSavedAt.value = DateTime.now();
      hasActiveDraft.value = true;

      await _updateDraftsCount();

      if (kDebugMode) {
        print('✅ Draft saved successfully: ${currentDraftId.value}');
        print('   Total: ${draftData['totalAmount']} Dh');
        print('=========================================\n');
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error saving draft: $e');
        print('Stack trace: $stackTrace');
      }
    }
  }

  // ============= Draft Management =============

  /// فتح صفحة المسودات
  Future<void> openDraftsScreen() async {
    if (kDebugMode) {
      print('\n📋 Opening drafts screen...');
    }

    final result = await Get.toNamed(AppRoutes.draftSales);

    if (result != null && result is Map<String, dynamic>) {
      if (kDebugMode) {
        print('📥 Draft selected from screen');
      }
      await loadAndApplyDraft(result);
    }
  }

  /// حذف المسودة الحالية
  Future<void> deleteCurrentDraft() async {
    if (currentDraftId.value == null) return;

    try {
      if (kDebugMode) {
        print('\n🗑️ Deleting draft: ${currentDraftId.value}');
      }

      await _draftService.deleteDraft(currentDraftId.value!);
      await clearActiveDraft();

      if (kDebugMode) {
        print('✅ Draft deleted successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting draft: $e');
      }
    }
  }

  /// مسح المسودة النشطة
  Future<void> clearActiveDraft() async {
    if (kDebugMode) {
      print('\n🗑️ Clearing active draft...');
    }

    await _draftService.clearActiveDraft();
    currentDraftId.value = null;
    hasActiveDraft.value = false;
    lastSavedAt.value = null;

    await _updateDraftsCount();

    if (kDebugMode) {
      print('✅ Active draft cleared');
    }
  }

  /// تحديث عدد المسودات
  Future<void> _updateDraftsCount() async {
    try {
      final drafts = await _draftService.getAllDrafts();
      draftsCount.value = drafts.length;

      if (kDebugMode) {
        print('📊 Drafts count updated: ${draftsCount.value}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error updating drafts count: $e');
      }
    }
  }

  // ============= Formatting =============

  /// تنسيق تاريخ المسودة
  String formatDraftDate(String? dateStr) {
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'الآن';
      } else if (difference.inMinutes < 60) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} يوم';
      } else {
        return DateFormat('dd/MM/yyyy').format(date);
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error formatting date: $e');
      }
      return '';
    }
  }

  /// تنسيق وقت آخر حفظ
  String get lastSavedText {
    if (lastSavedAt.value == null) return '';
    return 'آخر حفظ: ${formatDraftDate(lastSavedAt.value!.toIso8601String())}';
  }

  // ============= Getters =============

  /// هل يوجد مسودة حالية؟
  bool get hasDraft => currentDraftId.value != null;

  /// معرف المسودة الحالية
  String? get draftId => currentDraftId.value;
}
