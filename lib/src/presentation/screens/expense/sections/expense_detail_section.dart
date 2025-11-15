import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/hr_expense/hr_expens_model.dart';
import 'package:gsloution_mobile/common/controllers/expense_controller.dart';
import 'package:intl/intl.dart';

class ExpenseDetailSection extends StatefulWidget {
  const ExpenseDetailSection({super.key});

  @override
  State<ExpenseDetailSection> createState() => _ExpenseDetailSectionState();
}

class _ExpenseDetailSectionState extends State<ExpenseDetailSection> {
  final ExpenseController controller = Get.find<ExpenseController>();
  late HrExpenseModel expense;

  @override
  void initState() {
    super.initState();
    expense = Get.arguments['expense'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          expense.name?.toString() ?? 'Expense Details',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (expense.state == 'draft')
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Submit Expense',
              onPressed: () => _submitExpense(),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 20),

            // Employee & Date Info
            _buildEmployeeInfoCard(),
            const SizedBox(height: 20),

            // Product Info
            _buildProductInfoCard(),
            const SizedBox(height: 20),

            // Amount Breakdown
            _buildAmountCard(),
            const SizedBox(height: 20),

            // Additional Info
            _buildAdditionalInfoCard(),
            const SizedBox(height: 20),

            // Description
            if (expense.description != null && expense.description.toString().isNotEmpty)
              _buildDescriptionCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final state = expense.state?.toString() ?? 'draft';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    expense.name?.toString() ?? 'Expense',
                    style: GoogleFonts.raleway(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D6571),
                    ),
                  ),
                ),
                _buildStateChip(state),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  controller.getExpenseStateLabel(state),
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeInfoCard() {
    String employeeName = 'Unknown Employee';
    if (expense.employeeId != null) {
      if (expense.employeeId is List && (expense.employeeId as List).length > 1) {
        employeeName = (expense.employeeId as List)[1].toString();
      }
    }

    final expenseDate = expense.date != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(expense.date.toString()))
        : 'No date';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Employee Information',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Employee', employeeName, Icons.person),
            const SizedBox(height: 12),
            _buildDetailRow('Expense Date', expenseDate, Icons.calendar_today),
            const SizedBox(height: 12),
            if (expense.reference != null && expense.reference.toString().isNotEmpty)
              _buildDetailRow('Reference', expense.reference.toString(), Icons.tag),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    String productName = 'Unknown Product';
    if (expense.productId != null) {
      if (expense.productId is List && (expense.productId as List).length > 1) {
        productName = (expense.productId as List)[1].toString();
      }
    }

    String uomName = 'Unit';
    if (expense.productUomId != null) {
      if (expense.productUomId is List && (expense.productUomId as List).length > 1) {
        uomName = (expense.productUomId as List)[1].toString();
      }
    }

    final quantity = expense.quantity?.toString() ?? '0';
    final unitAmount = expense.unitAmount?.toString() ?? '0.00';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product Information',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Product', productName, Icons.inventory_2),
            const SizedBox(height: 12),
            _buildDetailRow('Quantity', '$quantity $uomName', Icons.format_list_numbered),
            const SizedBox(height: 12),
            _buildDetailRow('Unit Price', '\$$unitAmount', Icons.attach_money),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    final untaxed = expense.untaxedAmount?.toString() ?? '0.00';
    final total = expense.totalAmount?.toString() ?? '0.00';
    final totalCompany = expense.totalAmountCompany?.toString() ?? total;

    return Card(
      elevation: 2,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount Details',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
              ),
            ),
            const Divider(height: 24, color: Colors.blue),
            _buildAmountRow('Untaxed Amount', untaxed, false),
            const SizedBox(height: 8),
            const Divider(height: 16),
            _buildAmountRow('Total Amount', total, true),
            const SizedBox(height: 8),
            _buildAmountRow('Company Currency', totalCompany, false),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    String paymentMode = expense.paymentMode?.toString() ?? 'own_account';
    String companyName = 'Unknown Company';
    if (expense.companyId != null) {
      if (expense.companyId is List && (expense.companyId as List).length > 1) {
        companyName = (expense.companyId as List)[1].toString();
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Additional Information',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Payment Mode',
              paymentMode == 'own_account' ? 'Own Account' : 'Company Account',
              Icons.payment,
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Company', companyName, Icons.business),
            const SizedBox(height: 12),
            if (expense.attachmentNumber != null && expense.attachmentNumber != 0)
              _buildDetailRow(
                'Attachments',
                '${expense.attachmentNumber} file(s)',
                Icons.attach_file,
              ),
            if (expense.sheetId != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildDetailRow(
                  'Expense Report',
                  expense.sheetId is List
                      ? (expense.sheetId as List)[1].toString()
                      : expense.sheetId.toString(),
                  Icons.description,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notes, color: Colors.grey.shade700),
                const SizedBox(width: 8),
                Text(
                  'Description',
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              expense.description.toString(),
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5D6571),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.blue.shade900 : Colors.blue.shade700,
          ),
        ),
        Text(
          '\$$value',
          style: GoogleFonts.raleway(
            fontSize: isBold ? 24 : 16,
            fontWeight: FontWeight.bold,
            color: isBold ? Colors.blue.shade900 : Colors.blue.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildStateChip(String state) {
    Color color;
    IconData icon;

    switch (state) {
      case 'draft':
        color = Colors.grey;
        icon = Icons.edit;
        break;
      case 'reported':
        color = Colors.blue;
        icon = Icons.send;
        break;
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'done':
        color = Colors.teal;
        icon = Icons.done_all;
        break;
      case 'refused':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            controller.getExpenseStateLabel(state).toUpperCase(),
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitExpense() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Submit Expense'),
        content: const Text('Are you sure you want to submit this expense for approval?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Note: We need a bank journal ID for submission
      // This is a simplified version - in production, you'd select the journal
      Get.snackbar(
        'Info',
        'Please select a bank journal in the expense submission workflow',
        snackPosition: SnackPosition.BOTTOM,
      );
      // final success = await controller.submitExpense(expense.id as int, bankJournalId);
      // if (success) {
      //   Get.back(); // Go back to list
      // }
    }
  }
}
