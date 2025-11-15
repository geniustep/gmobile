import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/hr_expense/hr_expens_model.dart';
import 'package:gsloution_mobile/common/controllers/expense_controller.dart';
import 'package:intl/intl.dart';

class ExpenseApprovalSection extends StatefulWidget {
  const ExpenseApprovalSection({super.key});

  @override
  State<ExpenseApprovalSection> createState() => _ExpenseApprovalSectionState();
}

class _ExpenseApprovalSectionState extends State<ExpenseApprovalSection> {
  final ExpenseController controller = Get.find<ExpenseController>();
  List<HrExpenseModel> pendingExpenses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingExpenses();
  }

  Future<void> _loadPendingExpenses() async {
    setState(() {
      isLoading = true;
    });

    await controller.loadExpenses();

    setState(() {
      // Filter expenses that need approval (reported state)
      pendingExpenses = controller.expenses
          .where((expense) => expense.state == 'reported')
          .toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expense Approvals',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPendingExpenses,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : pendingExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: Colors.green.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No pending approvals',
                          style: GoogleFonts.raleway(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: pendingExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = pendingExpenses[index];
                      return _buildExpenseCard(expense);
                    },
                  ),
      ),
    );
  }

  Widget _buildExpenseCard(HrExpenseModel expense) {
    String employeeName = 'Unknown Employee';
    if (expense.employeeId != null) {
      if (expense.employeeId is List && (expense.employeeId as List).length > 1) {
        employeeName = (expense.employeeId as List)[1].toString();
      }
    }

    String productName = 'Unknown Product';
    if (expense.productId != null) {
      if (expense.productId is List && (expense.productId as List).length > 1) {
        productName = (expense.productId as List)[1].toString();
      }
    }

    final expenseDate = expense.date != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(expense.date.toString()))
        : 'No date';

    final amount = expense.totalAmount?.toString() ?? '0.00';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.name?.toString() ?? 'Expense',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF5D6571),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Awaiting Approval',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$$amount',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildDetailRow(Icons.person, 'Employee', employeeName),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.inventory_2, 'Product', productName),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.calendar_today, 'Date', expenseDate),
                if (expense.description != null && expense.description.toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildDetailRow(Icons.notes, 'Notes', expense.description.toString()),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _rejectExpense(expense),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveExpense(expense),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF5D6571),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _approveExpense(HrExpenseModel expense) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700),
            const SizedBox(width: 12),
            const Text('Approve Expense'),
          ],
        ),
        content: Text(
          'Are you sure you want to approve this expense for ${expense.totalAmount ?? 0}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Note: In production, you would call an approval API
      Get.snackbar(
        'Success',
        'Expense approved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _loadPendingExpenses(); // Reload list
    }
  }

  Future<void> _rejectExpense(HrExpenseModel expense) async {
    final TextEditingController reasonController = TextEditingController();

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red.shade700),
            const SizedBox(width: 12),
            const Text('Reject Expense'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject this expense?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
                hintText: 'Enter reason for rejection',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Note: In production, you would call a rejection API with the reason
      Get.snackbar(
        'Rejected',
        'Expense has been rejected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      _loadPendingExpenses(); // Reload list
    }

    reasonController.dispose();
  }
}
