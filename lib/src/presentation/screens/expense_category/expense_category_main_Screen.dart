import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_category/expense_category_sections/expense_category_list_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';

class ExpenseCategoryMainScreen extends StatefulWidget {
  const ExpenseCategoryMainScreen({super.key});

  @override
  State<ExpenseCategoryMainScreen> createState() =>
      _ExpenseCategoryMainScreenState();
}

class _ExpenseCategoryMainScreenState extends State<ExpenseCategoryMainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _categoryNameController = TextEditingController();
  final _controller = Get.find<Controller>();

  bool _isLoading = false;
  bool _isCreating = false;
  ProductCategoryModel? _selectedParentCategory;

  // تصفية الفئات التي لها علاقة بالمصاريف
  List<ProductCategoryModel> get _expenseCategories {
    return PrefUtils.categoryProduct.where((category) {
      // الفئات التي لها property_account_expense_categ_id
      return category.propertyAccountExpenseCategId != null &&
          category.propertyAccountExpenseCategId != false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _controller.getCategoryProductsController(
        showGlobalLoading: false,
        onResponse: (categories) {
          setState(() {
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        showWarning('فشل تحميل فئات المصاريف: $e');
      }
    }
  }

  Future<void> _createExpenseCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final categoryName = _categoryNameController.text.trim();

    if (categoryName.isEmpty) {
      showWarning('يرجى إدخال اسم الفئة');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      Map<String, dynamic> categoryData = {
        'name': categoryName,
      };

      // إذا كان هناك فئة رئيسية محددة، نضيفها كـ parent
      if (_selectedParentCategory != null) {
        categoryData['parent_id'] = _selectedParentCategory!.id;
      }

      // ملاحظة: في Odoo، يجب تعيين property_account_expense_categ_id
      // لكن هذا يتطلب معرفة حساب المصروفات المناسب
      // يمكن إضافة هذا لاحقاً من إعدادات Odoo

      ProductCategoryModule.CreateProductCategory(
        maps: categoryData,
        onResponse: (categoryId) async {
          setState(() {
            _isCreating = false;
          });

          // تحديث قائمة الفئات
          await _loadCategories();

          // مسح الحقول
          _categoryNameController.clear();
          _selectedParentCategory = null;

          if (mounted) {
            SuccessToast.showSuccessToast(
              context,
              "تم الإنشاء بنجاح",
              "تم إنشاء فئة المصروف بنجاح",
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      if (mounted) {
        showWarning('فشل إنشاء فئة المصروف: $e');
      }
    }
  }

  String _getCategoryDisplayName(ProductCategoryModel category) {
    if (category.displayName != null && category.displayName != false) {
      return category.displayName.toString();
    }
    if (category.name != null && category.name != false) {
      return category.name.toString();
    }
    return 'غير محدد';
  }

  String _getParentCategoryName(ProductCategoryModel category) {
    if (category.parentId == null || category.parentId == false) {
      return 'فئة رئيسية';
    }

    if (category.parentId is List && (category.parentId as List).length > 1) {
      return (category.parentId as List)[1]?.toString() ?? 'فئة رئيسية';
    }

    // البحث عن الفئة الرئيسية في القائمة
    if (category.parentId is int) {
      final parentId = category.parentId as int;
      final parent = PrefUtils.categoryProduct.firstWhereOrNull(
        (cat) => cat.id == parentId,
      );
      if (parent != null) {
        return _getCategoryDisplayName(parent);
      }
    }

    return 'فئة رئيسية';
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(
          navigateName: "Expense Category",
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Parent Category Dropdown
              Obx(() {
                final allCategories = PrefUtils.categoryProduct;
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
              // Create Button
              _isCreating
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : CustomElevatedButton(
                      buttonName: "إنشاء فئة مصروف",
                      showToast: _createExpenseCategory,
                    ),
              const SizedBox(height: 40),
              // Categories List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "فئات المصاريف",
                    style: GoogleFonts.raleway(
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _isLoading ? null : _loadCategories,
                    tooltip: 'تحديث',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Categories List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Obx(() {
                        final expenseCategories = _expenseCategories;

                        if (expenseCategories.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد فئات مصاريف',
                                  style: GoogleFonts.raleway(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'فئات المصاريف هي الفئات التي لها حساب مصروفات',
                                  style: GoogleFonts.nunito(
                                    textStyle: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _loadCategories,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('تحديث'),
                                ),
                              ],
                            ),
                          );
                        }

                        return ExpenseCategoryListSection(
                          isSmallScreen: isSmallScreen,
                          categoryList: expenseCategories,
                        );
                      }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
