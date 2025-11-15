// lib/common/controllers/expense_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/hr_expense/hr_expens_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/hr_expense/hr_expense_module.dart';

class ExpenseController extends GetxController {
  // ============= State =============
  final RxList<HrExpenseModel> expenses = <HrExpenseModel>[].obs;
  final RxList<HrExpenseModel> filteredExpenses = <HrExpenseModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isCreating = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter =
      'all'.obs; // all, draft, reported, approved, done, refused

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
    if (kDebugMode) {
      print('✅ ExpenseController initialized');
    }
  }

  // ============= Load Expenses =============

  Future<void> loadExpenses({List<dynamic>? domain}) async {
    try {
      isLoading.value = true;

      domain ??= [];

      HrExpenseModule.searchReadHrExpense(
        offset: 0,
        domain: domain,
        onResponse: (response) {
          if (response != null && response.isNotEmpty) {
            final length = response.keys.first;
            final expensesList = response[length]!;
            expenses.assignAll(expensesList);
            applyFilter();
            if (kDebugMode) {
              print('✅ Loaded ${expenses.length} expenses');
            }
          }
          isLoading.value = false;
        },
      );
    } catch (e) {
      isLoading.value = false;
      if (kDebugMode) {
        print('❌ Error loading expenses: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to load expenses: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============= Search & Filter =============

  void applyFilter() {
    if (selectedFilter.value == 'all') {
      filteredExpenses.assignAll(expenses);
    } else {
      filteredExpenses.assignAll(
        expenses
            .where((expense) => expense.state == selectedFilter.value)
            .toList(),
      );
    }

    if (searchQuery.value.isNotEmpty) {
      filteredExpenses.assignAll(
        filteredExpenses.where((expense) {
          final query = searchQuery.value.toLowerCase();
          final name = expense.name?.toString().toLowerCase() ?? '';
          final amount = expense.totalAmount?.toString().toLowerCase() ?? '';
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

  // ============= Create Expense =============

  Future<bool> createExpense({
    required Map<String, dynamic> expenseData,
    int? idBank,
  }) async {
    try {
      isCreating.value = true;

      bool success = false;

      await HrExpenseModule.createHrExpense(
        maps: expenseData,
        offset: 0,
        onResponse: (response) {
          if (response != null) {
            success = true;
            Get.snackbar(
              'Success',
              'Expense created successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
            loadExpenses(); // Reload expenses list
          }
        },
      );

      isCreating.value = false;
      return success;
    } catch (e) {
      isCreating.value = false;
      if (kDebugMode) {
        print('❌ Error creating expense: $e');
      }
      Get.snackbar(
        'Error',
        'Failed to create expense: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ============= Submit Expense =============

  Future<bool> submitExpense(int expenseId, int idBank) async {
    try {
      bool success = false;

      await HrExpenseModule.submitExpenses(
        args: [expenseId],
        idBank: idBank,
        onResponse: (response) {
          if (response != null) {
            success = true;
            Get.snackbar(
              'Success',
              'Expense submitted successfully',
              snackPosition: SnackPosition.BOTTOM,
            );
            loadExpenses();
          }
        },
      );

      return success;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error submitting expense: $e');
      }
      return false;
    }
  }

  // ============= Read Single Expense =============

  Future<HrExpenseModel?> getExpenseById(int expenseId) async {
    try {
      HrExpenseModel? expense;

      await HrExpenseModule.readHrExpense(
        ids: [expenseId],
        onResponse: (response) {
          if (response.isNotEmpty) {
            expense = response.first;
          }
        },
      );

      return expense;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting expense: $e');
      }
      return null;
    }
  }

  // ============= Helpers =============

  String getExpenseStateLabel(String? state) {
    switch (state) {
      case 'draft':
        return 'To Submit';
      case 'reported':
        return 'Submitted';
      case 'approved':
        return 'Approved';
      case 'done':
        return 'Posted';
      case 'refused':
        return 'Refused';
      default:
        return 'Unknown';
    }
  }

  // ============= Refresh =============

  Future<void> refresh() async {
    await loadExpenses();
  }
}
