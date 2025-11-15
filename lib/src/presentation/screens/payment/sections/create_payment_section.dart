import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/controllers/payment_controller.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/date_picker_section/date_picker.dart';
import 'package:gsloution_mobile/src/presentation/widgets/text_field/dropdown_form_field_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/text_field/text_field_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';

class CreatePaymentSection extends StatefulWidget {
  const CreatePaymentSection({super.key});

  @override
  State<CreatePaymentSection> createState() => _CreatePaymentSectionState();
}

class _CreatePaymentSectionState extends State<CreatePaymentSection> {
  final PaymentController paymentController = Get.find<PaymentController>();
  final InvoiceController invoiceController = Get.put(InvoiceController());
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController paymentDateController = TextEditingController();

  // Dropdown values
  String selectedPaymentType = 'inbound';
  String selectedPartnerType = 'customer';
  dynamic selectedPartnerId;
  dynamic selectedJournalId;
  dynamic selectedInvoiceId;

  List<Map<String, dynamic>> partnerItems = [];
  List<Map<String, dynamic>> journalItems = [];
  List<Map<String, dynamic>> invoiceItems = [];
  bool isLoadingInvoices = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadInvoices();
    paymentDateController.text = DateTime.now().toString().split(' ')[0];
  }

  void _loadData() {
    // Load partners from PrefUtils
    if (PrefUtils.partners.isNotEmpty) {
      partnerItems = PrefUtils.partners.map((partner) {
        final id = partner.id;
        final name = partner.name ?? 'Unknown Partner';
        return {'id': id, 'name': name};
      }).toList();
    }

    // Load journals from PrefUtils
    if (PrefUtils.accountJournal.isNotEmpty) {
      journalItems = PrefUtils.accountJournal.map((journal) {
        final id = journal.id;
        final name = journal.name ?? 'Unknown Journal';
        return {'id': id, 'name': name};
      }).toList();
    }
  }

  Future<void> _loadInvoices() async {
    setState(() {
      isLoadingInvoices = true;
    });

    // Get unpaid/partial invoices
    await invoiceController.loadInvoices();

    final unpaidInvoices = invoiceController.invoices
        .where((invoice) =>
          invoice.invoicePaymentState == 'not_paid' ||
          invoice.invoicePaymentState == 'partial')
        .toList();

    setState(() {
      invoiceItems = unpaidInvoices.map((invoice) {
        final id = invoice.id;
        final name = invoice.name ?? 'Invoice';
        final amount = invoice.amountResidual ?? invoice.amountTotal ?? 0;
        return {'id': id, 'name': '$name (\$$amount due)', 'amount': amount};
      }).toList();
      isLoadingInvoices = false;
    });
  }

  void _onInvoiceSelected(dynamic invoiceId) {
    final selectedInvoice = invoiceItems.firstWhere(
      (inv) => inv['id'] == invoiceId,
      orElse: () => {},
    );

    if (selectedInvoice.isNotEmpty) {
      setState(() {
        selectedInvoiceId = invoiceId;
        amountController.text = selectedInvoice['amount'].toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(navigateName: "Create Payment"),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Payment Type
              DropdownButtonFormField<String>(
                value: selectedPaymentType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'inbound', child: Text('Receive Payment')),
                  DropdownMenuItem(value: 'outbound', child: Text('Send Payment')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPaymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Partner Type
              DropdownButtonFormField<String>(
                value: selectedPartnerType,
                decoration: const InputDecoration(
                  labelText: 'Partner Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'customer', child: Text('Customer')),
                  DropdownMenuItem(value: 'supplier', child: Text('Supplier')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPartnerType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Partner Selection
              DropdownButtonFormField<dynamic>(
                value: selectedPartnerId,
                decoration: const InputDecoration(
                  labelText: 'Customer/Supplier',
                  border: OutlineInputBorder(),
                ),
                items: partnerItems.map((partner) {
                  return DropdownMenuItem(
                    value: partner['id'],
                    child: Text(partner['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPartnerId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a customer/supplier';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Invoice Selection (optional - link payment to invoice)
              if (!isLoadingInvoices && invoiceItems.isNotEmpty)
                Column(
                  children: [
                    DropdownButtonFormField<dynamic>(
                      value: selectedInvoiceId,
                      decoration: const InputDecoration(
                        labelText: 'Link to Invoice (Optional)',
                        border: OutlineInputBorder(),
                        helperText: 'Select invoice to pay',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No Invoice'),
                        ),
                        ...invoiceItems.map((invoice) {
                          return DropdownMenuItem(
                            value: invoice['id'],
                            child: Text(invoice['name']),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _onInvoiceSelected(value);
                        } else {
                          setState(() {
                            selectedInvoiceId = null;
                            amountController.clear();
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),

              // Amount
              TextFormField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Payment Date
              TextFormField(
                controller: paymentDateController,
                decoration: const InputDecoration(
                  labelText: 'Payment Date',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      paymentDateController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Journal
              DropdownButtonFormField<dynamic>(
                value: selectedJournalId,
                decoration: const InputDecoration(
                  labelText: 'Journal',
                  border: OutlineInputBorder(),
                ),
                items: journalItems.map((journal) {
                  return DropdownMenuItem(
                    value: journal['id'],
                    child: Text(journal['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedJournalId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a journal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Memo
              TextFormField(
                controller: memoController,
                decoration: const InputDecoration(
                  labelText: 'Memo',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Submit Button
              Obx(() => CustomElevatedButton(
                buttonName: paymentController.isCreating.value
                    ? "Creating..."
                    : "Create Payment",
                showToast: paymentController.isCreating.value
                    ? null
                    : () {
                        _createPayment();
                      },
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPayment() async {
    if (_formKey.currentState!.validate()) {
      final paymentData = {
        'payment_type': selectedPaymentType,
        'partner_type': selectedPartnerType,
        'partner_id': selectedPartnerId,
        'amount': double.parse(amountController.text),
        'payment_date': paymentDateController.text,
        'journal_id': selectedJournalId,
        'communication': memoController.text,
      };

      // Add invoice IDs if selected
      if (selectedInvoiceId != null) {
        paymentData['invoice_ids'] = [[6, 0, [selectedInvoiceId]]];
      }

      final success = await paymentController.createPayment(
        paymentData: paymentData,
      );

      if (success) {
        SuccessToast.showSuccessToast(
          context,
          "Payment Created",
          selectedInvoiceId != null
              ? "Payment linked to invoice successfully"
              : "Payment has been created successfully",
        );
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    memoController.dispose();
    paymentDateController.dispose();
    super.dispose();
  }
}
