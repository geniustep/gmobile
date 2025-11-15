import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/controllers/expense_controller.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';

class ExpenseBodySection extends StatefulWidget {
  const ExpenseBodySection({super.key});

  @override
  State<ExpenseBodySection> createState() => _ExpenseBodySectionState();
}

class _ExpenseBodySectionState extends State<ExpenseBodySection> {
  final ExpenseController expenseController = Get.put(ExpenseController());
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController expenseDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitAmountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Dropdown values
  dynamic selectedProductId;

  List<Map<String, dynamic>> productItems = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    expenseDateController.text = DateTime.now().toString().split(' ')[0];
    quantityController.text = '1';
  }

  void _loadData() {
    // Load products from PrefUtils
    if (PrefUtils.products.isNotEmpty) {
      productItems = PrefUtils.products.map((product) {
        final id = product.id;
        final name = product.name ?? 'Unknown Product';
        return {'id': id, 'name': name};
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const SizedBox(height: 20),

            // Expense Name
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Expense Description',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter expense description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Product Selection (Category)
            DropdownButtonFormField<dynamic>(
              value: selectedProductId,
              decoration: const InputDecoration(
                labelText: 'Product/Category',
                border: OutlineInputBorder(),
              ),
              items: productItems.map((product) {
                return DropdownMenuItem(
                  value: product['id'],
                  child: Text(product['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProductId = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a product/category';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Expense Date
            TextFormField(
              controller: expenseDateController,
              decoration: const InputDecoration(
                labelText: 'Expense Date',
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
                    expenseDateController.text = picked.toString().split(' ')[0];
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Unit Amount
            TextFormField(
              controller: unitAmountController,
              decoration: const InputDecoration(
                labelText: 'Unit Price',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter unit price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Quantity
            TextFormField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {});
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quantity';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter valid quantity';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Description/Notes
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Total Amount Display
            if (unitAmountController.text.isNotEmpty && quantityController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '\$${((double.tryParse(unitAmountController.text) ?? 0) * (double.tryParse(quantityController.text) ?? 1)).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Submit Button
            Obx(() {
              final VoidCallback? onPressed = expenseController.isCreating.value
                  ? null
                  : () {
                      _createExpense();
                    };
              return CustomElevatedButton(
                buttonName: expenseController.isCreating.value
                    ? "Submitting..."
                    : "Submit Expense",
                showToast: onPressed,
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _createExpense() async {
    if (_formKey.currentState!.validate()) {
      final expenseData = {
        'name': nameController.text,
        'product_id': selectedProductId,
        'date': expenseDateController.text,
        'unit_amount': double.parse(unitAmountController.text),
        'quantity': double.parse(quantityController.text),
        'description': descriptionController.text.isNotEmpty ? descriptionController.text : null,
      };

      final success = await expenseController.createExpense(
        expenseData: expenseData,
      );

      if (success) {
        SuccessToast.showSuccessToast(
          context,
          "Expense Created",
          "Expense has been created successfully",
        );

        // Clear form
        nameController.clear();
        unitAmountController.clear();
        quantityController.text = '1';
        descriptionController.clear();
        setState(() {
          selectedProductId = null;
        });
      }
    }
  }

  @override
  void dispose() {
    expenseDateController.dispose();
    nameController.dispose();
    quantityController.dispose();
    unitAmountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
