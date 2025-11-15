import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Advanced filter dialog for expenses
/// Provides comprehensive filtering options
class AdvancedExpenseFilterDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onFilter;

  const AdvancedExpenseFilterDialog({
    super.key,
    required this.onFilter,
  });

  @override
  State<AdvancedExpenseFilterDialog> createState() =>
      _AdvancedExpenseFilterDialogState();
}

class _AdvancedExpenseFilterDialogState
    extends State<AdvancedExpenseFilterDialog> {
  final TextEditingController employeeNameController = TextEditingController();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController minAmountController = TextEditingController();
  final TextEditingController maxAmountController = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();

  String? selectedState;
  String? selectedCategory;

  final List<Map<String, String>> expenseStates = [
    {'value': 'draft', 'label': 'مسودة'},
    {'value': 'reported', 'label': 'معلقة'},
    {'value': 'approved', 'label': 'معتمدة'},
    {'value': 'done', 'label': 'مكتملة'},
    {'value': 'refused', 'label': 'مرفوضة'},
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
                    'تصفية المصاريف',
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

              // Employee Name
              TextFormField(
                controller: employeeNameController,
                decoration: InputDecoration(
                  labelText: 'اسم الموظف',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Product/Category Name
              TextFormField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'المنتج/الفئة',
                  prefixIcon: const Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Expense State
              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: InputDecoration(
                  labelText: 'حالة المصروف',
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
                  ...expenseStates.map((state) {
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

              // Quick Filters
              Text(
                'تصفية سريعة',
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF5D6571),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildQuickFilterChip('اليوم', Icons.today),
                  _buildQuickFilterChip('هذا الأسبوع', Icons.date_range),
                  _buildQuickFilterChip('هذا الشهر', Icons.calendar_month),
                  _buildQuickFilterChip('المعتمدة', Icons.check_circle),
                  _buildQuickFilterChip('المعلقة', Icons.pending),
                  _buildQuickFilterChip('المرفوضة', Icons.cancel),
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
                      onPressed: _performFilter,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('تطبيق'),
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

  Widget _buildQuickFilterChip(String label, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        _applyQuickFilter(label);
      },
    );
  }

  void _applyQuickFilter(String filter) {
    final now = DateTime.now();

    switch (filter) {
      case 'اليوم':
        startDateController.text = DateFormat('yyyy-MM-dd').format(now);
        endDateController.text = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 'هذا الأسبوع':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        startDateController.text = DateFormat('yyyy-MM-dd').format(startOfWeek);
        endDateController.text = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 'هذا الشهر':
        final startOfMonth = DateTime(now.year, now.month, 1);
        startDateController.text = DateFormat('yyyy-MM-dd').format(startOfMonth);
        endDateController.text = DateFormat('yyyy-MM-dd').format(now);
        break;
      case 'المعتمدة':
        setState(() {
          selectedState = 'approved';
        });
        break;
      case 'المعلقة':
        setState(() {
          selectedState = 'reported';
        });
        break;
      case 'المرفوضة':
        setState(() {
          selectedState = 'refused';
        });
        break;
    }
  }

  void _clearFilters() {
    setState(() {
      employeeNameController.clear();
      productNameController.clear();
      minAmountController.clear();
      maxAmountController.clear();
      startDateController.clear();
      endDateController.clear();
      selectedState = null;
      selectedCategory = null;
    });
  }

  void _performFilter() {
    final filters = <String, dynamic>{};

    if (employeeNameController.text.isNotEmpty) {
      filters['employee_name'] = employeeNameController.text;
    }

    if (productNameController.text.isNotEmpty) {
      filters['product_name'] = productNameController.text;
    }

    if (selectedState != null) {
      filters['state'] = selectedState;
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

    widget.onFilter(filters);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    employeeNameController.dispose();
    productNameController.dispose();
    minAmountController.dispose();
    maxAmountController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }
}
