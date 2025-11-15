import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move_line/account_move_line_model.dart';

class InvoicePdfService {
  static Future<File> generateInvoicePdf({
    required AccountMoveModel invoice,
    required List<AccountMoveLineModel> invoiceLines,
  }) async {
    final pdf = pw.Document();

    // Get partner name
    String partnerName = 'Unknown Partner';
    if (invoice.partnerId != null) {
      if (invoice.partnerId is List && (invoice.partnerId as List).length > 1) {
        partnerName = (invoice.partnerId as List)[1].toString();
      }
    }

    // Format dates
    final invoiceDate = invoice.invoiceDate != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(invoice.invoiceDate.toString()))
        : 'N/A';

    final dueDate = invoice.invoiceDateDue != null
        ? DateFormat('MMM dd, yyyy').format(DateTime.parse(invoice.invoiceDateDue.toString()))
        : 'N/A';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            _buildHeader(invoice, partnerName),
            pw.SizedBox(height: 30),

            // Invoice Info Section
            _buildInvoiceInfo(invoice, invoiceDate, dueDate),
            pw.SizedBox(height: 30),

            // Invoice Lines Table
            _buildInvoiceLinesTable(invoiceLines),
            pw.SizedBox(height: 30),

            // Totals Section
            _buildTotalsSection(invoice),
            pw.SizedBox(height: 40),

            // Payment Info
            _buildPaymentInfo(invoice),

            pw.Spacer(),

            // Footer
            _buildFooter(),
          ];
        },
      ),
    );

    // Save the PDF
    return _savePdf(pdf, invoice.name?.toString() ?? 'invoice');
  }

  static pw.Widget _buildHeader(AccountMoveModel invoice, String partnerName) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 32,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue900,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              invoice.name?.toString() ?? '',
              style: pw.TextStyle(
                fontSize: 16,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'Your Company Name',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Address Line 1',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.Text(
              'City, Country',
              style: const pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(
    AccountMoveModel invoice,
    String invoiceDate,
    String dueDate,
  ) {
    String partnerName = 'Unknown Partner';
    if (invoice.partnerId != null) {
      if (invoice.partnerId is List && (invoice.partnerId as List).length > 1) {
        partnerName = (invoice.partnerId as List)[1].toString();
      }
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Bill To:',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey800,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                partnerName,
                style: const pw.TextStyle(fontSize: 16),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _buildInfoRow('Invoice Date:', invoiceDate),
              pw.SizedBox(height: 4),
              _buildInfoRow('Due Date:', dueDate),
              if (invoice.ref != null && invoice.ref.toString().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 4),
                  child: _buildInfoRow('Reference:', invoice.ref.toString()),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Text(
          value,
          style: const pw.TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildInvoiceLinesTable(List<AccountMoveLineModel> lines) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        // Header Row
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue50),
          children: [
            _buildTableHeader('Product'),
            _buildTableHeader('Quantity'),
            _buildTableHeader('Unit Price'),
            _buildTableHeader('Discount'),
            _buildTableHeader('Subtotal'),
          ],
        ),
        // Data Rows
        ...lines.map((line) => _buildTableRow(line)).toList(),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.TableRow _buildTableRow(AccountMoveLineModel line) {
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
    final discount = line.discount?.toString() ?? '0';
    final subtotal = line.priceSubtotal?.toString() ?? '0.00';

    return pw.TableRow(
      children: [
        _buildTableCell(productName, pw.TextAlign.left),
        _buildTableCell(quantity, pw.TextAlign.center),
        _buildTableCell('\$$priceUnit', pw.TextAlign.right),
        _buildTableCell('$discount%', pw.TextAlign.center),
        _buildTableCell('\$$subtotal', pw.TextAlign.right),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, pw.TextAlign align) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 11),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotalsSection(AccountMoveModel invoice) {
    final untaxed = invoice.amountUntaxed?.toString() ?? '0.00';
    final tax = invoice.amountTax?.toString() ?? '0.00';
    final total = invoice.amountTotal?.toString() ?? '0.00';
    final residual = invoice.amountResidual?.toString() ?? '0.00';

    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 250,
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey300),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        ),
        child: pw.Column(
          children: [
            _buildTotalRow('Subtotal:', '\$$untaxed', false),
            pw.SizedBox(height: 8),
            _buildTotalRow('Tax:', '\$$tax', false),
            pw.Divider(height: 16, thickness: 2),
            _buildTotalRow('Total:', '\$$total', true),
            pw.SizedBox(height: 8),
            _buildTotalRow('Amount Due:', '\$$residual', true, PdfColors.red700),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, bool isBold, [PdfColor? color]) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isBold ? 14 : 12,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: color ?? (isBold ? PdfColors.grey900 : PdfColors.grey700),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: pw.FontWeight.bold,
            color: color ?? PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentInfo(AccountMoveModel invoice) {
    String paymentState = 'Not Paid';
    if (invoice.invoicePaymentState != null) {
      final state = invoice.invoicePaymentState.toString();
      paymentState = state == 'paid'
          ? 'Paid'
          : state == 'partial'
              ? 'Partially Paid'
              : 'Not Paid';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        children: [
          pw.Text(
            'Payment Status: ',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            paymentState,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 8),
        pw.Text(
          'Thank you for your business!',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Generated by Gmobile - Odoo Mobile App',
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey500,
          ),
        ),
      ],
    );
  }

  static Future<File> _savePdf(pw.Document pdf, String fileName) async {
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  static Future<void> openPdf(File file) async {
    await OpenFile.open(file.path);
  }
}
