import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Advanced search dialog for invoices
/// Provides comprehensive filtering options
class AdvancedInvoiceSearchDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;

  const AdvancedInvoiceSearchDialog({
    super.key,
    required this.onSearch,
  });

  @override
  State<AdvancedInvoiceSearchDialog> createState() =>
      _AdvancedInvoiceSearchDialogState();
}

class _AdvancedInvoiceSearchDialogState
    extends State<AdvancedInvoiceSearchDialog> {
  final TextEditingController invoiceNumberController = TextEditingController();
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController minAmountController = TextEditingController();
  final TextEditingController maxAmountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? selectedState;
  String? selectedPaymentState;

  final List<Map<String, String>> invoiceStates = [
    {'value': 'draft', 'label': 'مسودة'},
    {'value': 'posted', 'label': 'معتمدة'},
    {'value': 'cancel', 'label': 'ملغاة'},
  ];

  final List<Map<String, String>> paymentStates = [
    {'value': 'not_paid', 'label': 'غير مدفوعة'},
    {'value': 'in_payment', 'label': 'قيد الدفع'},
    {'value': 'paid', 'label': 'مدفوعة'},
    {'value': 'partial', 'label': 'مدفوعة جزئياً'},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'البحث المتقدم',
                    style: GoogleFonts.raleway(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D6571),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Invoice Number
              TextFormField(
                controller: invoiceNumberController,
                decoration: InputDecoration(
                  labelText: 'رقم الفاتورة',
                  prefixIcon: const Icon(Icons.receipt_long),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Customer Name
              TextFormField(
                controller: customerNameController,
                decoration: InputDecoration(
                  labelText: 'اسم العميل',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Invoice State
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: InputDecoration(
                  labelText: 'حالة الفاتورة',
                  prefixIcon: const Icon(Icons.bookmark),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('الكل'),
                  ),
                  ...invoiceStates.map((state) {
                    return DropdownMenuItem(
                      value: state['value'],
                      child: Text(state['label']!),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedState = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Payment State
              DropdownButtonFormField<String>(
                value: selectedPaymentState,
                decoration: InputDecoration(
                  labelText: 'حالة الدفع',
                  prefixIcon: const Icon(Icons.payment),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('الكل'),
                  ),
                  ...paymentStates.map((state) {
                    return DropdownMenuItem(
                      value: state['value'],
                      child: Text(state['label']!),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPaymentState = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Amount Range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'من مبلغ',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: maxAmountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'إلى مبلغ',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'من تاريخ',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          startDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'إلى تاريخ',
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          endDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('مسح الكل'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _performSearch,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('بحث'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      invoiceNumberController.clear();
      customerNameController.clear();
      minAmountController.clear();
      maxAmountController.clear();
      startDateController.clear();
      endDateController.clear();
      selectedState = null;
      selectedPaymentState = null;
    });
  }

  void _performSearch() {
    final filters = <String, dynamic>{};

    if (invoiceNumberController.text.isNotEmpty) {
      filters['invoice_number'] = invoiceNumberController.text;
    }

    if (customerNameController.text.isNotEmpty) {
      filters['customer_name'] = customerNameController.text;
    }

    if (selectedState != null) {
      filters['state'] = selectedState;
    }

    if (selectedPaymentState != null) {
      filters['payment_state'] = selectedPaymentState;
    }

    if (minAmountController.text.isNotEmpty) {
      filters['min_amount'] = double.tryParse(minAmountController.text);
    }

    if (maxAmountController.text.isNotEmpty) {
      filters['max_amount'] = double.tryParse(maxAmountController.text);
    }

    if (startDateController.text.isNotEmpty) {
      filters['start_date'] = startDateController.text;
    }

    if (endDateController.text.isNotEmpty) {
      filters['end_date'] = endDateController.text;
    }

    widget.onSearch(filters);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    invoiceNumberController.dispose();
    customerNameController.dispose();
    minAmountController.dispose();
    maxAmountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }
}
