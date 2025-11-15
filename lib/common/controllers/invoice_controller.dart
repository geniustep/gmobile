// lib/common/controllers/invoice_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_module.dart';

class InvoiceController extends GetxController {
  // ============= State =============
  final RxList<AccountMoveModel> invoices = <AccountMoveModel>[].obs;
  final RxList<AccountMoveModel> filteredInvoices = <AccountMoveModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, draft, posted, cancel

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    loadInvoices();
    if (kDebugMode) {
      print('✅ InvoiceController initialized');
    }
  }

  // ============= Load Invoices =============

  Future<void> loadInvoices({List<dynamic>? domain}) async {
    try {
      isLoading.value = true;

      domain ??= [];

      await AccountMoveModule.searchReadAccountMove(
        onResponse: (response) {
          if (response != null && response.isNotEmpty) {
            invoices.assignAll(response);
            applyFilter();
            if (kDebugMode) {
              print('✅ Loaded ${invoices.length} invoices');
            }
          }
          isLoading.value = false;
        },
        domain: domain,
        showGlobalLoading: false,
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('❌ Error loading invoices: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load invoices: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============= Search & Filter =============

  void applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredInvoices.assignAll(invoices);
    } else {
      filteredInvoices.assignAll(
        invoices.where((invoice) => invoice.state == selectedFilter.value).toList(),
      );
    }

    if (searchQuery.value.isNotEmpty) {
      filteredInvoices.assignAll(
        filteredInvoices.where((invoice) {
          final query = searchQuery.value.toLowerCase();
          final name = invoice.name?.toString().toLowerCase() ?? '';
          final ref = invoice.ref?.toString().toLowerCase() ?? '';
          return name.contains(query) || ref.contains(query);
        }).toList(),
      );
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    applyFilter();
  }

  void search(String query) {
    searchQuery.value = query;
    applyFilter();
  }

  // ============= Create Invoice =============

  Future<bool> createInvoice({
    required Map<String, dynamic> invoiceData,
  }) async {
    try {
      isCreating.value = true;

      bool success = false;

      await AccountMoveModule.createInvoicePurchaseCall(
        invoiceData: invoiceData,
        onResponse: (response) {
          if (response != null) {
            success = true;
            Get.snackbar(
              'Success',
              'Invoice created successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
            loadInvoices(); // Reload invoices list
          }
        },
      );

      isCreating.value = false;
      return success;
    } catch (e) {
      isCreating.value = false;
      if (kDebugMode) {
        print('❌ Error creating invoice: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to create invoice: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ============= Confirm/Post Invoice =============

  Future<bool> confirmInvoice(int invoiceId) async {
    try {
      bool success = false;

      await AccountMoveModule.comptabliseInvoiceSales(
        args: [invoiceId],
        onResponse: (response) {
          if (response == true) {
            success = true;
            Get.snackbar(
              'Success',
              'Invoice confirmed successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
            loadInvoices();
          }
        },
      );

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error confirming invoice: $e');
      }
      return false;
    }
  }

  // ============= Read Single Invoice =============

  Future<AccountMoveModel?> getInvoiceById(int invoiceId) async {
    try {
      AccountMoveModel? invoice;

      await AccountMoveModule.readInvoice(
        ids: [invoiceId],
        onResponse: (response) {
          if (response.isNotEmpty) {
            invoice = response.first;
          }
        },
      );

      return invoice;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting invoice: $e');
      }
      return null;
    }
  }

  // ============= Helpers =============

  String getInvoiceStateLabel(String? state) {
    switch (state) {
      case 'draft':
        return 'Draft';
      case 'posted':
        return 'Posted';
      case 'cancel':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String getPaymentStateLabel(String? paymentState) {
    switch (paymentState) {
      case 'not_paid':
        return 'Not Paid';
      case 'in_payment':
        return 'In Payment';
      case 'paid':
        return 'Paid';
      case 'partial':
        return 'Partially Paid';
      case 'reversed':
        return 'Reversed';
      case 'invoicing_legacy':
        return 'Invoicing App Legacy';
      default:
        return 'Unknown';
    }
  }

  // ============= Refresh =============

  Future<void> refresh() async {
    await loadInvoices();
  }
}
