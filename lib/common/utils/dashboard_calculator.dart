import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';

/// Helper class to calculate dashboard statistics
class DashboardCalculator {
  /// Check if a date string is today
  static bool isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } catch (e) {
      return false;
    }
  }

  /// Convert dynamic value to double
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Calculate today's total sales
  /// Includes confirmed sale orders (state = 'sale' or 'done')
  static double calculateTodaySales(List<OrderModel> salesOrders) {
    return salesOrders
        .where((order) {
          // Check if it's today
          final isTodayOrder = isToday(order.dateOrder?.toString());
          // Check if it's a confirmed sale (not draft or cancelled)
          final isConfirmed = order.state == 'sale' || order.state == 'done';
          return isTodayOrder && isConfirmed;
        })
        .fold(0.0, (sum, order) => sum + _toDouble(order.amountTotal));
  }

  /// Calculate today's total purchases
  /// Includes vendor bills (type = 'in_invoice')
  static double calculateTodayPurchases(List<AccountMoveModel> accountMove) {
    return accountMove
        .where((move) {
          // Check if it's today
          final isTodayMove = isToday(move.invoiceDate?.toString()) ||
                             isToday(move.date?.toString());
          // Check if it's a vendor bill
          final isPurchase = move.type == 'in_invoice';
          // Check if it's posted (not draft)
          final isPosted = move.state == 'posted';
          return isTodayMove && isPurchase && isPosted;
        })
        .fold(0.0, (sum, move) => sum + _toDouble(move.amountTotal));
  }

  /// Calculate today's total expenses
  /// Includes journal entries marked as expenses
  /// You can customize this based on your business logic
  static double calculateTodayExpenses(List<AccountMoveModel> accountMove) {
    return accountMove
        .where((move) {
          // Check if it's today
          final isTodayMove = isToday(move.invoiceDate?.toString()) ||
                             isToday(move.date?.toString());
          // Check if it's an expense entry
          // This can be customized based on your journal type or other criteria
          final isExpense = move.type == 'entry';
          // Check if it's posted (not draft)
          final isPosted = move.state == 'posted';
          return isTodayMove && isExpense && isPosted;
        })
        .fold(0.0, (sum, move) => sum + _toDouble(move.amountTotal));
  }

  /// Calculate total sales (all time)
  static double calculateTotalSales(List<OrderModel> salesOrders) {
    return salesOrders
        .where((order) => order.state == 'sale' || order.state == 'done')
        .fold(0.0, (sum, order) => sum + _toDouble(order.amountTotal));
  }

  /// Calculate total purchases (all time)
  static double calculateTotalPurchases(List<AccountMoveModel> accountMove) {
    return accountMove
        .where((move) => move.type == 'in_invoice' && move.state == 'posted')
        .fold(0.0, (sum, move) => sum + _toDouble(move.amountTotal));
  }

  /// Calculate total expenses (all time)
  static double calculateTotalExpenses(List<AccountMoveModel> accountMove) {
    return accountMove
        .where((move) => move.type == 'entry' && move.state == 'posted')
        .fold(0.0, (sum, move) => sum + _toDouble(move.amountTotal));
  }

  /// Format currency value
  static String formatCurrency(double value, {String symbol = '\$'}) {
    if (value >= 1000000) {
      return '$symbol${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '$symbol${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${value.toStringAsFixed(0)}';
    }
  }
}
