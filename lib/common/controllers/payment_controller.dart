// lib/common/controllers/payment_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_payment/account_payment_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_payment/account_payment_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_journal/account_journal_model.dart';

class PaymentController extends GetxController {
  // ============= State =============
  final RxList<AccountPaymentModel> payments = <AccountPaymentModel>[].obs;
  final RxList<AccountPaymentModel> filteredPayments = <AccountPaymentModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // all, draft, posted, reconciled

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    loadPayments();
    if (kDebugMode) {
      print('✅ PaymentController initialized');
    }
  }

  // ============= Load Payments =============

  Future<void> loadPayments({List<dynamic>? domain}) async {
    try {
      isLoading.value = true;

      domain ??= [];

      AccountPaymentModule.searchReadAccountPayment(
        offset: 0,
        domain: domain,
        onResponse: (response) {
          if (response != null && response.isNotEmpty) {
            final length = response.keys.first;
            final paymentsList = response[length]!;
            payments.assignAll(paymentsList);
            applyFilter();
            if (kDebugMode) {
              print('✅ Loaded ${payments.length} payments');
            }
          }
          isLoading.value = false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('❌ Error loading payments: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load payments: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============= Search & Filter =============

  void applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredPayments.assignAll(payments);
    } else {
      filteredPayments.assignAll(
        payments.where((payment) => payment.state == selectedFilter.value).toList(),
      );
    }

    if (searchQuery.value.isNotEmpty) {
      filteredPayments.assignAll(
        filteredPayments.where((payment) {
          final query = searchQuery.value.toLowerCase();
          final name = payment.name?.toString().toLowerCase() ?? '';
          final amount = payment.amount?.toString().toLowerCase() ?? '';
          return name.contains(query) || amount.contains(query);
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

  // ============= Create Payment =============

  Future<bool> createPayment({
    required Map<String, dynamic> paymentData,
    Map<String, dynamic>? context,
  }) async {
    try {
      isCreating.value = true;

      bool success = false;

      await AccountPaymentModule.createAccountPayments(
        maps: paymentData,
        context: context,
        onResponse: (response) {
          if (response != null) {
            success = true;
            Get.snackbar(
              'Success',
              'Payment created successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
            loadPayments(); // Reload payments list
          }
        },
      );

      isCreating.value = false;
      return success;
    } catch (e) {
      isCreating.value = false;
      if (kDebugMode) {
        print('❌ Error creating payment: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to create payment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ============= Read Single Payment =============

  Future<AccountPaymentModel?> getPaymentById(int paymentId) async {
    try {
      AccountPaymentModel? payment;

      await AccountPaymentModule.readAccountPayment(
        ids: [paymentId],
        onResponse: (response) {
          if (response.isNotEmpty) {
            payment = response.first;
          }
        },
      );

      return payment;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting payment: $e');
      }
      return null;
    }
  }

  // ============= Helpers =============

  String getPaymentStateLabel(String? state) {
    switch (state) {
      case 'draft':
        return 'Draft';
      case 'posted':
        return 'Posted';
      case 'sent':
        return 'Sent';
      case 'reconciled':
        return 'Reconciled';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  String getPaymentTypeLabel(String? paymentType) {
    switch (paymentType) {
      case 'inbound':
        return 'Receive Payment';
      case 'outbound':
        return 'Send Payment';
      default:
        return 'Payment';
    }
  }

  // ============= Refresh =============

  Future<void> refresh() async {
    await loadPayments();
  }
}
