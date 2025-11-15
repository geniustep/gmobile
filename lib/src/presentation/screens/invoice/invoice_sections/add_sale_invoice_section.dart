import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';

class AddSaleInvoiceSection extends StatefulWidget {
  const AddSaleInvoiceSection({super.key});

  @override
  State<AddSaleInvoiceSection> createState() => _AddSaleInvoiceSectionState();
}

class _AddSaleInvoiceSectionState extends State<AddSaleInvoiceSection> {
  final InvoiceController invoiceController = Get.put(InvoiceController());
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  // Dropdown values
  dynamic selectedPartnerId;
  dynamic selectedJournalId;
  String selectedInvoiceType = 'out_invoice';

  List<Map<String, dynamic>> partnerItems = [];
  List<Map<String, dynamic>> journalItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    invoiceDateController.text = DateTime.now().toString().split(' ')[0];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(navigateName: "Add Sale Invoice"),
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 20),

              // Invoice Type
              DropdownButtonFormField<String>(
                value: selectedInvoiceType,
                decoration: const InputDecoration(
                  labelText: 'Invoice Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'out_invoice', child: Text('Customer Invoice')),
                  DropdownMenuItem(value: 'out_refund', child: Text('Customer Credit Note')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedInvoiceType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Customer Selection
              DropdownButtonFormField<dynamic>(
                value: selectedPartnerId,
                decoration: const InputDecoration(
                  labelText: 'Customer',
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
                    return 'Please select a customer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Invoice Date
              TextFormField(
                controller: invoiceDateController,
                decoration: const InputDecoration(
                  labelText: 'Invoice Date',
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
                      invoiceDateController.text = picked.toString().split(' ')[0];
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Due Date
              TextFormField(
                controller: dueDateController,
                decoration: const InputDecoration(
                  labelText: 'Due Date',
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
                      dueDateController.text = picked.toString().split(' ')[0];
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
              ),
              const SizedBox(height: 20),

              // Reference
              TextFormField(
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              Obx(() => CustomElevatedButton(
                buttonName: invoiceController.isCreating.value
                    ? "Creating..."
                    : "Create Invoice",
                showToast: invoiceController.isCreating.value
                    ? null
                    : () {
                        _createInvoice();
                      },
              )),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createInvoice() async {
    if (_formKey.currentState!.validate()) {
      final invoiceData = {
        'partner_id': selectedPartnerId,
        'invoice_date': invoiceDateController.text,
        'invoice_date_due': dueDateController.text.isNotEmpty ? dueDateController.text : null,
        'journal_id': selectedJournalId,
        'ref': referenceController.text.isNotEmpty ? referenceController.text : null,
        'type': selectedInvoiceType,
      };

      final success = await invoiceController.createInvoice(
        invoiceData: invoiceData,
      );

      if (success) {
        SuccessToast.showSuccessToast(
          context,
          "Invoice Created",
          "Sale Invoice has been created successfully",
        );
        Get.back();
      }
    }
  }

  @override
  void dispose() {
    invoiceDateController.dispose();
    dueDateController.dispose();
    referenceController.dispose();
    super.dispose();
  }
}
