import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move_line/account_move_line_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move_line/account_move_line_module.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/common/services/pdf/invoice_pdf_service.dart';
import 'package:intl/intl.dart';

class InvoiceDetailSection extends StatefulWidget {
  const InvoiceDetailSection({super.key});

  @override
  State<InvoiceDetailSection> createState() => _InvoiceDetailSectionState();
}

class _InvoiceDetailSectionState extends State<InvoiceDetailSection> {
  final InvoiceController controller = Get.find<InvoiceController>();
  late AccountMoveModel invoice;
  List<AccountMoveLineModel> invoiceLines = [];
  bool isLoadingLines = false;

  @override
  void initState() {
    super.initState();
    invoice = Get.arguments['invoice'];
    _loadInvoiceLines();
  }

  Future<void> _loadInvoiceLines() async {
    if (invoice.invoiceLineIds == null) return;

    setState(() {
      isLoadingLines = true;
    });

    List<int> lineIds = [];
    if (invoice.invoiceLineIds is List) {
      lineIds = (invoice.invoiceLineIds as List).map((e) => e as int).toList();
    }

    if (lineIds.isNotEmpty) {
      AccountMoveLineModule.readAccountMoveLine(
        ids: lineIds,
        onResponse: (lines) {
          setState(() {
            invoiceLines = lines;
            isLoadingLines = false;
          });
        },
      );
    } else {
      setState(() {
        isLoadingLines = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          invoice.name?.toString() ?? 'Invoice Details',
          style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (invoice.state == 'draft')
            IconButton(
              icon: const Icon(Icons.check_circle_outline),
              tooltip: 'Confirm Invoice',
              onPressed: () => _confirmInvoice(),
            ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate PDF',
            onPressed: () => _generatePDF(),
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

            // Partner & Date Info
            _buildPartnerInfoCard(),
            const SizedBox(height: 20),

            // Amounts Card
            _buildAmountsCard(),
            const SizedBox(height: 20),

            // Invoice Lines
            _buildInvoiceLinesSection(),
            const SizedBox(height: 20),

            // Payment Info
            _buildPaymentInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final state = invoice.state?.toString() ?? 'draft';
    final paymentState = invoice.invoicePaymentState?.toString() ?? 'not_paid';

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
                Text(
                  invoice.name?.toString() ?? 'Invoice',
                  style: GoogleFonts.raleway(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D6571),
                  ),
                ),
                _buildStateChip(state),
              ],
            ),
            const SizedBox(height: 12),
            _buildPaymentStateChip(paymentState),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerInfoCard() {
    String partnerName = 'Unknown Partner';
    if (invoice.partnerId != null) {
      if (invoice.partnerId is List && (invoice.partnerId as List).length > 1) {
        partnerName = (invoice.partnerId as List)[1].toString();
      }
    }

    final invoiceDate = invoice.invoiceDate != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(invoice.invoiceDate.toString()))
        : 'No date';

    final dueDate = invoice.invoiceDateDue != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(invoice.invoiceDateDue.toString()))
        : 'No due date';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Information',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow('Customer', partnerName),
            const SizedBox(height: 12),
            _buildDetailRow('Invoice Date', invoiceDate),
            const SizedBox(height: 12),
            _buildDetailRow('Due Date', dueDate),
            const SizedBox(height: 12),
            if (invoice.ref != null && invoice.ref.toString().isNotEmpty)
              _buildDetailRow('Reference', invoice.ref.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountsCard() {
    final untaxed = invoice.amountUntaxed?.toString() ?? '0.00';
    final tax = invoice.amountTax?.toString() ?? '0.00';
    final total = invoice.amountTotal?.toString() ?? '0.00';
    final residual = invoice.amountResidual?.toString() ?? '0.00';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amounts',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildAmountRow('Untaxed Amount', untaxed, false),
            const SizedBox(height: 8),
            _buildAmountRow('Tax', tax, false),
            const Divider(height: 16),
            _buildAmountRow('Total', total, true),
            const SizedBox(height: 8),
            _buildAmountRow('Amount Due', residual, true, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceLinesSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Lines',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            if (isLoadingLines)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (invoiceLines.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Center(
                  child: Text('No invoice lines'),
                ),
              )
            else
              ...invoiceLines.map((line) => _buildInvoiceLineItem(line)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceLineItem(AccountMoveLineModel line) {
    String productName = 'Product';
    if (line.productId != null) {
      if (line.productId is List && (line.productId as List).length > 1) {
        productName = (line.productId as List)[1].toString();
      }
    } else if (line.name != null) {
      productName = line.name.toString();
    }

    final quantity = line.quantity?.toString() ?? '0';
    final priceUnit = line.priceUnit?.toString() ?? '0.00';
    final priceSubtotal = line.priceSubtotal?.toString() ?? '0.00';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            productName,
            style: GoogleFonts.raleway(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5D6571),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: $quantity × \$$priceUnit',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                '\$$priceSubtotal',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          if (line.discount != null && line.discount != 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Discount: ${line.discount}%',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Information',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Divider(height: 24),
            _buildDetailRow(
              'Payment State',
              controller.getPaymentStateLabel(invoice.invoicePaymentState?.toString()),
            ),
            if (invoice.invoicePaymentRef != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildDetailRow('Payment Reference', invoice.invoicePaymentRef.toString()),
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

  Widget _buildAmountRow(String label, String value, bool isBold, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: color ?? (isBold ? const Color(0xFF5D6571) : Colors.grey.shade600),
          ),
        ),
        Text(
          '\$$value',
          style: GoogleFonts.raleway(
            fontSize: isBold ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color ?? (isBold ? Colors.blue : const Color(0xFF5D6571)),
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
      case 'cancel':
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
        controller.getInvoiceStateLabel(state).toUpperCase(),
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPaymentStateChip(String paymentState) {
    Color color;
    switch (paymentState) {
      case 'paid':
        color = Colors.green;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      case 'not_paid':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paymentState == 'paid'
                ? Icons.check_circle
                : paymentState == 'partial'
                    ? Icons.schedule
                    : Icons.error_outline,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            controller.getPaymentStateLabel(paymentState),
            style: GoogleFonts.nunito(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmInvoice() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Invoice'),
        content: const Text('Are you sure you want to confirm this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await controller.confirmInvoice(invoice.id as int);
      if (success) {
        Get.back(); // Go back to list
      }
    }
  }

  Future<void> _generatePDF() async {
    try {
      Get.snackbar(
        'PDF Generation',
        'Generating PDF...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      final file = await InvoicePdfService.generateInvoicePdf(
        invoice: invoice,
        invoiceLines: invoiceLines,
      );

      Get.snackbar(
        'Success',
        'PDF generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        mainButton: TextButton(
          onPressed: () => InvoicePdfService.openPdf(file),
          child: const Text('Open', style: TextStyle(color: Colors.white)),
        ),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
