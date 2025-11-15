import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_payment/account_payment_model.dart';
import 'package:gsloution_mobile/common/controllers/payment_controller.dart';
import 'package:intl/intl.dart';

class PaymentDetailSection extends StatelessWidget {
  const PaymentDetailSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountPaymentModel payment = Get.arguments['payment'];
    final PaymentController controller = Get.find<PaymentController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          payment.name?.toString() ?? 'Payment Details',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(payment, controller),
            const SizedBox(height: 20),

            // Details Card
            _buildDetailsCard(payment),
            const SizedBox(height: 20),

            // Journal Information
            _buildJournalCard(payment),
            const SizedBox(height: 20),

            // Additional Information
            _buildAdditionalInfoCard(payment),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(AccountPaymentModel payment, PaymentController controller) {
    final amount = payment.amount?.toString() ?? '0.00';
    final state = payment.state?.toString() ?? 'draft';
    final paymentType = payment.paymentType?.toString() ?? 'inbound';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                _buildStateChip(state),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  paymentType == 'inbound'
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 32,
                  color: paymentType == 'inbound' ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  '\$$amount',
                  style: GoogleFonts.raleway(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D6571),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              controller.getPaymentTypeLabel(paymentType),
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(AccountPaymentModel payment) {
    String partnerName = 'Unknown Partner';
    if (payment.partnerId != null) {
      if (payment.partnerId is List && (payment.partnerId as List).length > 1) {
        partnerName = (payment.partnerId as List)[1].toString();
      }
    }

    final paymentDate = payment.paymentDate != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(payment.paymentDate.toString()))
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
              'Payment Details',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Partner', partnerName),
            const SizedBox(height: 12),
            _buildDetailRow('Payment Date', paymentDate),
            const SizedBox(height: 12),
            _buildDetailRow('Reference', payment.name?.toString() ?? 'N/A'),
            const SizedBox(height: 12),
            if (payment.communication != null)
              _buildDetailRow('Memo', payment.communication.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalCard(AccountPaymentModel payment) {
    String journalName = 'Unknown Journal';
    if (payment.journalId != null) {
      if (payment.journalId is List && (payment.journalId as List).length > 1) {
        journalName = (payment.journalId as List)[1].toString();
      }
    }

    String paymentMethodName = 'Manual';
    if (payment.paymentMethodId != null) {
      if (payment.paymentMethodId is List && (payment.paymentMethodId as List).length > 1) {
        paymentMethodName = (payment.paymentMethodId as List)[1].toString();
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
              'Journal Information',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Journal', journalName),
            const SizedBox(height: 12),
            _buildDetailRow('Payment Method', paymentMethodName),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard(AccountPaymentModel payment) {
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
            if (payment.reconciledInvoicesCount != null)
              _buildDetailRow(
                'Reconciled Invoices',
                payment.reconciledInvoicesCount.toString(),
              ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Has Invoices',
              payment.hasInvoices == true ? 'Yes' : 'No',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'Move Reconciled',
              payment.moveReconciled == true ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

  Widget _buildStateChip(String state) {
    Color color;
    switch (state) {
      case 'draft':
        color = Colors.grey;
        break;
      case 'posted':
        color = Colors.blue;
        break;
      case 'reconciled':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        state.toUpperCase(),
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
