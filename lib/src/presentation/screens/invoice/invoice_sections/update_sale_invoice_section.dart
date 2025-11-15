import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';
import 'package:intl/intl.dart';

class UpdateSaleInvoiceSection extends StatefulWidget {
  final AccountMoveModel invoice;

  const UpdateSaleInvoiceSection({
    super.key,
    required this.invoice,
  });

  @override
  State<UpdateSaleInvoiceSection> createState() =>
      _UpdateSaleInvoiceSectionState();
}

class _UpdateSaleInvoiceSectionState extends State<UpdateSaleInvoiceSection> {
  final _formKey = GlobalKey<FormState>();
  final InvoiceController invoiceController = Get.find<InvoiceController>();

  // Form Controllers
  final TextEditingController invoiceDateController = TextEditingController();
  final TextEditingController dueDateController = TextEditingController();
  final TextEditingController referenceController = TextEditingController();

  // Dropdown values
  dynamic selectedPartnerId;
  dynamic selectedJournalId;
  String? selectedPaymentState;
  bool _isUpdating = false;

  List<Map<String, dynamic>> partnerItems = [];
  List<Map<String, dynamic>> journalItems = [];

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
      return '';
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

  @override
  void initState() {
    super.initState();
    _loadData();
    _initializeFields();
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

  void _initializeFields() {
    // Initialize partner
    if (widget.invoice.partnerId != null && widget.invoice.partnerId != false) {
      if (widget.invoice.partnerId is int) {
        selectedPartnerId = widget.invoice.partnerId;
      } else if (widget.invoice.partnerId is List &&
          (widget.invoice.partnerId as List).isNotEmpty) {
        selectedPartnerId = (widget.invoice.partnerId as List)[0];
      }
    }

    // Initialize journal
    if (widget.invoice.journalId != null && widget.invoice.journalId != false) {
      if (widget.invoice.journalId is int) {
        selectedJournalId = widget.invoice.journalId;
      } else if (widget.invoice.journalId is List &&
          (widget.invoice.journalId as List).isNotEmpty) {
        selectedJournalId = (widget.invoice.journalId as List)[0];
      }
    }

    // Initialize dates
    invoiceDateController.text = _formatDate(
      widget.invoice.invoiceDate ?? widget.invoice.date,
    );
    dueDateController.text = _formatDate(widget.invoice.invoiceDateDue);

    // Initialize reference
    if (widget.invoice.ref != null && widget.invoice.ref != false) {
      referenceController.text = widget.invoice.ref.toString();
    }

    // Initialize payment state
    if (widget.invoice.invoicePaymentState != null &&
        widget.invoice.invoicePaymentState != false) {
      selectedPaymentState = widget.invoice.invoicePaymentState.toString();
    }
  }

  @override
  void dispose() {
    invoiceDateController.dispose();
    dueDateController.dispose();
    referenceController.dispose();
    super.dispose();
  }

  Future<void> _updateInvoice() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final invoiceId = widget.invoice.id is int
          ? widget.invoice.id as int
          : int.tryParse(widget.invoice.id.toString()) ?? 0;

      Map<String, dynamic> updateData = {};

      if (selectedPartnerId != null) {
        updateData['partner_id'] = selectedPartnerId;
      }

      if (selectedJournalId != null) {
        updateData['journal_id'] = selectedJournalId;
      }

      if (invoiceDateController.text.isNotEmpty) {
        updateData['invoice_date'] = invoiceDateController.text;
      }

      if (dueDateController.text.isNotEmpty) {
        updateData['invoice_date_due'] = dueDateController.text;
      }

      if (referenceController.text.isNotEmpty) {
        updateData['ref'] = referenceController.text;
      }

      Api.write(
        model: "account.move",
        ids: [invoiceId],
        values: updateData,
        onResponse: (response) {
          setState(() {
            _isUpdating = false;
          });

          invoiceController.refresh();

          if (mounted) {
            SuccessToast.showSuccessToast(
              context,
              "تم التحديث بنجاح",
              "تم تحديث الفاتورة بنجاح",
            );
            Navigator.of(context).pop();
          }
        },
        onError: (error, data) {
          setState(() {
            _isUpdating = false;
          });
          if (mounted) {
            showWarning('فشل تحديث الفاتورة: $error');
          }
        },
      );
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        showWarning('فشل تحديث الفاتورة: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "تحديث الفاتورة",
                  style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Color(0xFF444444),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 26,
                  color: Color(0xFF444444),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
        Divider(
          color: Colors.grey.shade300,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
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
                  ),
                  const SizedBox(height: 20),
                  // Company (Read-only)
                  TextFormField(
                    initialValue: _getCompanyName(widget.invoice),
                    decoration: const InputDecoration(
                      labelText: 'Company',
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
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
                        initialDate: invoiceDateController.text.isNotEmpty
                            ? DateTime.parse(invoiceDateController.text)
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          invoiceDateController.text =
                              picked.toString().split(' ')[0];
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
                        initialDate: dueDateController.text.isNotEmpty
                            ? DateTime.parse(dueDateController.text)
                            : DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          dueDateController.text =
                              picked.toString().split(' ')[0];
                        });
                      }
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
                  // Payment State (Read-only display)
                  TextFormField(
                    initialValue: invoiceController
                        .getPaymentStateLabel(selectedPaymentState),
                    decoration: const InputDecoration(
                      labelText: 'Payment Status',
                      border: OutlineInputBorder(),
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Update Button
                  _isUpdating
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : CustomElevatedButton(
                          buttonName: "تحديث الفاتورة",
                          showToast: _updateInvoice,
                        ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
