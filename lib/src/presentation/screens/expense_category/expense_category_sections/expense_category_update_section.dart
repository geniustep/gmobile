import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';

class ExpenseCategoryUpdateSection extends StatefulWidget {
  final ProductCategoryModel category;

  const ExpenseCategoryUpdateSection({
    super.key,
    required this.category,
  });

  @override
  State<ExpenseCategoryUpdateSection> createState() =>
      _ExpenseCategoryUpdateSectionState();
}

class _ExpenseCategoryUpdateSectionState
    extends State<ExpenseCategoryUpdateSection> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  ProductCategoryModel? _selectedParentCategory;
  bool _isUpdating = false;

  String _getCategoryDisplayName(ProductCategoryModel category) {
    if (category.displayName != null && category.displayName != false) {
      return category.displayName.toString();
    }
    if (category.name != null && category.name != false) {
      return category.name.toString();
    }
    return 'غير محدد';
  }

  @override
  void initState() {
    super.initState();
    _categoryNameController.text = _getCategoryDisplayName(widget.category);
    
    // تحديد الفئة الرئيسية الحالية
    if (widget.category.parentId != null && widget.category.parentId != false) {
      if (widget.category.parentId is int) {
        final parentId = widget.category.parentId as int;
        _selectedParentCategory = PrefUtils.categoryProduct.firstWhereOrNull(
          (cat) => cat.id == parentId,
        );
      }
    }
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryName = _categoryNameController.text.trim();

    if (categoryName.isEmpty) {
      showWarning('يرجى إدخال اسم الفئة');
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      Map<String, dynamic> categoryData = {
        'name': categoryName,
      };

      // تحديث الفئة الرئيسية
      if (_selectedParentCategory != null) {
        categoryData['parent_id'] = _selectedParentCategory!.id;
      } else {
        // إزالة الفئة الرئيسية
        categoryData['parent_id'] = false;
      }

      // تحديث الفئة في Odoo
      final categoryId = widget.category.id is int
          ? widget.category.id as int
          : int.tryParse(widget.category.id.toString()) ?? 0;

      Api.write(
        model: "product.category",
        ids: [categoryId],
        values: categoryData,
        onResponse: (response) {
          setState(() {
            _isUpdating = false;
          });

          if (mounted) {
            SuccessToast.showSuccessToast(
              context,
              "تم التحديث بنجاح",
              "تم تحديث فئة المصروف بنجاح",
            );
            Navigator.of(context).pop();
          }
        },
        onError: (error, data) {
          setState(() {
            _isUpdating = false;
          });
          if (mounted) {
            showWarning('فشل تحديث فئة المصروف: $error');
          }
        },
      );
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        showWarning('فشل تحديث فئة المصروف: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "تحديث فئة المصروف",
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
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Parent Category Dropdown
                Obx(() {
                  final allCategories = PrefUtils.categoryProduct
                      .where((cat) => cat.id != widget.category.id)
                      .toList();
                  return DropdownButtonFormField<ProductCategoryModel?>(
                    decoration: InputDecoration(
                      labelText: "الفئة الرئيسية (اختياري)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    value: _selectedParentCategory,
                    items: [
                      const DropdownMenuItem<ProductCategoryModel?>(
                        value: null,
                        child: Text('بدون فئة رئيسية'),
                      ),
                      ...allCategories.map((category) {
                        return DropdownMenuItem<ProductCategoryModel?>(
                          value: category,
                          child: Text(_getCategoryDisplayName(category)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedParentCategory = value;
                      });
                    },
                  );
                }),
                const SizedBox(height: 20),
                // Category Name Field
                TextFormField(
                  controller: _categoryNameController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    labelText: "اسم فئة المصروف",
                    labelStyle: GoogleFonts.raleway(
                      color: const Color(0xFF444444),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "أدخل اسم فئة المصروف",
                    hintStyle: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E4E7),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0xFFE2E4E7),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم فئة المصروف';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: _isUpdating
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : CustomElevatedButton(
                          buttonName: "تحديث",
                          showToast: _updateCategory,
                        ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
