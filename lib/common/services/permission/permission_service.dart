import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

/// Permission service for role-based access control
/// Manages user permissions and access rights
class PermissionService extends GetxController {
  static const String _tag = '🔐 PermissionService';

  // User role
  final Rx<UserRole> userRole = UserRole.employee.obs;
  final RxBool isManager = false.obs;
  final RxBool isAccountant = false.obs;
  final RxBool isAdmin = false.obs;

  // Permission limits
  final RxDouble approvalLimit = 0.0.obs; // Maximum amount user can approve
  final RxBool canCreateInvoices = false.obs;
  final RxBool canApproveExpenses = false.obs;
  final RxBool canManageProducts = false.obs;
  final RxBool canViewReports = false.obs;
  final RxBool canManageUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserRole();
    if (kDebugMode) {
      print('$_tag Initialized');
    }
  }

  /// Load user role from preferences
  void _loadUserRole() {
    // This would typically come from the backend
    // For now, we'll use a placeholder
    final roleString = PrefUtils.getUserRole() ?? 'employee';

    switch (roleString.toLowerCase()) {
      case 'admin':
        setRole(UserRole.admin);
        break;
      case 'manager':
        setRole(UserRole.manager);
        break;
      case 'accountant':
        setRole(UserRole.accountant);
        break;
      case 'employee':
      default:
        setRole(UserRole.employee);
        break;
    }
  }

  /// Set user role and update permissions
  void setRole(UserRole role) {
    userRole.value = role;
    isAdmin.value = role == UserRole.admin;
    isManager.value = role == UserRole.manager || role == UserRole.admin;
    isAccountant.value = role == UserRole.accountant || role == UserRole.admin;

    _updatePermissions();
  }

  /// Update permissions based on role
  void _updatePermissions() {
    switch (userRole.value) {
      case UserRole.admin:
        approvalLimit.value = double.infinity;
        canCreateInvoices.value = true;
        canApproveExpenses.value = true;
        canManageProducts.value = true;
        canViewReports.value = true;
        canManageUsers.value = true;
        break;

      case UserRole.manager:
        approvalLimit.value = 10000.0;
        canCreateInvoices.value = true;
        canApproveExpenses.value = true;
        canManageProducts.value = true;
        canViewReports.value = true;
        canManageUsers.value = false;
        break;

      case UserRole.accountant:
        approvalLimit.value = 5000.0;
        canCreateInvoices.value = true;
        canApproveExpenses.value = true;
        canManageProducts.value = false;
        canViewReports.value = true;
        canManageUsers.value = false;
        break;

      case UserRole.employee:
        approvalLimit.value = 0.0;
        canCreateInvoices.value = false;
        canApproveExpenses.value = false;
        canManageProducts.value = false;
        canViewReports.value = false;
        canManageUsers.value = false;
        break;
    }

    if (kDebugMode) {
      print('$_tag Updated permissions for role: ${userRole.value.name}');
    }
  }

  // ============= Permission Checks =============

  /// Check if user can create invoices
  bool hasPermissionToCreateInvoices() {
    return canCreateInvoices.value;
  }

  /// Check if user can approve expenses
  bool hasPermissionToApproveExpenses() {
    return canApproveExpenses.value;
  }

  /// Check if user can approve expense with specific amount
  bool hasPermissionToApproveAmount(double amount) {
    return canApproveExpenses.value && amount <= approvalLimit.value;
  }

  /// Check if user can manage products
  bool hasPermissionToManageProducts() {
    return canManageProducts.value;
  }

  /// Check if user can view reports
  bool hasPermissionToViewReports() {
    return canViewReports.value;
  }

  /// Check if user can manage users
  bool hasPermissionToManageUsers() {
    return canManageUsers.value;
  }

  /// Check if user can delete records
  bool hasPermissionToDelete() {
    return isManager.value;
  }

  /// Check if user can edit specific record
  bool hasPermissionToEdit(String recordType, {int? userId}) {
    switch (recordType) {
      case 'invoice':
        return canCreateInvoices.value;
      case 'expense':
        // Employees can only edit their own expenses
        if (userRole.value == UserRole.employee) {
          return userId == PrefUtils.getUserId();
        }
        return true;
      case 'product':
        return canManageProducts.value;
      default:
        return false;
    }
  }

  /// Check if user can confirm/post invoice
  bool hasPermissionToConfirmInvoice() {
    return isAccountant.value || isManager.value;
  }

  /// Check if user can cancel invoice
  bool hasPermissionToCancelInvoice() {
    return isManager.value;
  }

  /// Get user role display name
  String getRoleDisplayName() {
    switch (userRole.value) {
      case UserRole.admin:
        return 'مدير النظام';
      case UserRole.manager:
        return 'مدير';
      case UserRole.accountant:
        return 'محاسب';
      case UserRole.employee:
        return 'موظف';
    }
  }

  /// Get approval limit display text
  String getApprovalLimitText() {
    if (approvalLimit.value == double.infinity) {
      return 'غير محدود';
    } else if (approvalLimit.value == 0) {
      return 'لا يوجد';
    } else {
      return '\$${approvalLimit.value.toStringAsFixed(2)}';
    }
  }

  /// Show permission denied message
  void showPermissionDenied({String? message}) {
    Get.snackbar(
      'غير مصرح',
      message ?? 'ليس لديك صلاحية للقيام بهذا الإجراء',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
    );
  }
}

/// User roles enum
enum UserRole {
  admin,
  manager,
  accountant,
  employee,
}

/// Extension for PrefUtils
extension PrefUtilsPermission on PrefUtils {
  static String? getUserRole() {
    // This would typically be stored in SharedPreferences
    // For now, return a default value
    return 'employee';
  }

  static int? getUserId() {
    // This would typically be stored in SharedPreferences
    return null;
  }
}
