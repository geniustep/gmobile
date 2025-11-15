import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/src/presentation/screens/invoice/invoice_sections/update_sale_invoice_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/invoice/sections/invoice_detail_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/delete_toast.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:intl/intl.dart';

class SaleInvoiceListSection extends StatefulWidget {
  const SaleInvoiceListSection({
    super.key,
  });

  @override
  State<SaleInvoiceListSection> createState() => _SaleInvoiceListSectionState();
}

class _SaleInvoiceListSectionState extends State<SaleInvoiceListSection> {
  final InvoiceController invoiceController = Get.find<InvoiceController>();

  String _getPartnerName(AccountMoveModel invoice) {
    if (invoice.partnerId == null || invoice.partnerId == false) {
      return 'Unknown Partner';
    }

    if (invoice.partnerId is List && (invoice.partnerId as List).length > 1) {
      return (invoice.partnerId as List)[1]?.toString() ?? 'Unknown Partner';
    }

    if (invoice.invoicePartnerDisplayName != null &&
        invoice.invoicePartnerDisplayName != false) {
      return invoice.invoicePartnerDisplayName.toString();
    }

    return 'Unknown Partner';
  }

  String _getPartnerPhone(AccountMoveModel invoice) {
    // يمكن إضافة منطق لجلب رقم الهاتف من partner_id
    return 'N/A';
  }

  String _getCompanyName(AccountMoveModel invoice) {
    if (invoice.companyId == null || invoice.companyId == false) {
      return 'N/A';
    }

    if (invoice.companyId is List && (invoice.companyId as List).length > 1) {
      return (invoice.companyId as List)[1]?.toString() ?? 'N/A';
    }

    return 'N/A';
  }

  String _formatDate(dynamic date) {
    if (date == null || date == false) {
      return 'N/A';
    }

    try {
      if (date is String) {
        final parsedDate = DateTime.parse(date);
        return DateFormat('yyyy-MM-dd').format(parsedDate);
      }
      return date.toString();
    } catch (e) {
      return date.toString();
    }
  }

  Color _getPaymentStatusColor(String? paymentState) {
    switch (paymentState) {
      case 'paid':
        return const Color(0xFF4CAF50); // Green
      case 'partial':
        return const Color(0xFFFF9800); // Orange
      case 'not_paid':
        return const Color(0xFFF44336); // Red
      case 'in_payment':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  String _getPaymentStatusLabel(String? paymentState) {
    return invoiceController.getPaymentStateLabel(paymentState);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (invoiceController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (invoiceController.filteredInvoices.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No Invoices Found",
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => invoiceController.refresh(),
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => invoiceController.refresh(),
        child: ListView.builder(
          itemCount: invoiceController.filteredInvoices.length,
          itemBuilder: (context, index) {
            final invoice = invoiceController.filteredInvoices[index];
            final partnerName = _getPartnerName(invoice);
            final partnerPhone = _getPartnerPhone(invoice);
            final companyName = _getCompanyName(invoice);
            final invoiceDate = _formatDate(invoice.invoiceDate ?? invoice.date);
            final paymentState = invoice.invoicePaymentState?.toString();
            final paymentStatusColor = _getPaymentStatusColor(paymentState);
            final paymentStatusLabel = _getPaymentStatusLabel(paymentState);

            return GestureDetector(
              onTap: () {
                Get.toNamed(
                  AppRoutes.invoiceDetail,
                  arguments: {'invoice': invoice},
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              partnerName,
                              style: GoogleFonts.raleway(
                                color: const Color(0xFF5D6571),
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: paymentStatusColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              paymentStatusLabel,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone_android_sharp,
                            size: 20,
                            color: Color(0xFFA0A0A3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            partnerPhone,
                            style: GoogleFonts.nunito(
                              color: const Color(0xFFA0A0A3),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range_outlined,
                            size: 20,
                            color: Color(0xFFA0A0A3),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            invoiceDate,
                            style: GoogleFonts.nunito(
                              color: const Color(0xFFA0A0A3),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (invoice.amountTotal != null &&
                          invoice.amountTotal != false) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.attach_money,
                              size: 20,
                              color: Color(0xFFA0A0A3),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Total: ${invoice.amountTotal}',
                              style: GoogleFonts.nunito(
                                color: const Color(0xFF5D6571),
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: SvgPicture.asset(
                                  "assets/icons/icon_svg/company_icon.svg",
                                  width: 18,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                companyName,
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFF5D6571),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.blue.shade50.withOpacity(0.5),
                                ),
                                child: IconButton(
                                  icon: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: SvgPicture.asset(
                                      "assets/icons/icon_svg/edit_icon.svg",
                                      color: Colors.blue,
                                    ),
                                  ),
                                  onPressed: () {
                                    buildModalBottomSheet(context, invoice);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.red.shade50.withOpacity(0.5),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    _deleteInvoice(context, invoice, index);
                                  },
                                  icon: SvgPicture.asset(
                                    "assets/icons/icon_svg/delete_icon.svg",
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  void _deleteInvoice(
    BuildContext context,
    AccountMoveModel invoice,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف الفاتورة'),
        content: Text(
          'هل أنت متأكد من حذف الفاتورة "${invoice.name ?? 'N/A'}"؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // TODO: إضافة منطق حذف من Odoo
              DeleteToast.showDeleteToast(
                context,
                _getPartnerName(invoice),
              );
              Navigator.pop(context);
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void buildModalBottomSheet(BuildContext context, AccountMoveModel invoice) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: UpdateSaleInvoiceSection(invoice: invoice),
        );
      },
    );
  }
}
