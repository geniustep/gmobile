import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:gsloution_mobile/src/presentation/widgets/button/custom_elevated_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/success_toast.dart';

class CategoryMainScreen extends StatefulWidget {
  const CategoryMainScreen({Key? key}) : super(key: key);

  @override
  State<CategoryMainScreen> createState() => _CategoryMainScreenState();
}

class _CategoryMainScreenState extends State<CategoryMainScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subCategoryController = TextEditingController();
  final _mainCategoryController = TextEditingController();
  final _controller = Get.find<Controller>();

  bool _isLoading = false;
  bool _isCreating = false;
  ProductCategoryModel? _selectedParentCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _subCategoryController.dispose();
    _mainCategoryController.dispose();
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
        showWarning('فشل تحميل الفئات: $e');
      }
    }
  }

  Future<void> _createCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final mainCategoryName = _mainCategoryController.text.trim();
    final subCategoryName = _subCategoryController.text.trim();

    if (mainCategoryName.isEmpty && subCategoryName.isEmpty) {
      showWarning('يرجى إدخال اسم الفئة الرئيسية أو الفرعية');
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      // إذا كان هناك فئة فرعية، ننشئها أولاً كفئة رئيسية
      // ثم ننشئ الفئة الرئيسية كـ parent
      Map<String, dynamic> categoryData = {
        'name': subCategoryName.isNotEmpty ? subCategoryName : mainCategoryName,
      };

      // إذا كان هناك فئة رئيسية محددة، نضيفها كـ parent
      if (_selectedParentCategory != null) {
        categoryData['parent_id'] = _selectedParentCategory!.id;
      } else if (mainCategoryName.isNotEmpty && subCategoryName.isNotEmpty) {
        // إذا كان هناك اسم فئة رئيسية، نحاول العثور عليها أو إنشاؤها
        // للبساطة، سننشئ الفئة الفرعية فقط
      }

      ProductCategoryModule.CreateProductCategory(
        maps: categoryData,
        onResponse: (categoryId) async {
          setState(() {
            _isCreating = false;
          });

          // تحديث قائمة الفئات
          await _loadCategories();

          // مسح الحقول
          _subCategoryController.clear();
          _mainCategoryController.clear();
          _selectedParentCategory = null;

          if (mounted) {
            SuccessToast.showSuccessToast(
              context,
              "تم الإنشاء بنجاح",
              "تم إنشاء الفئة بنجاح",
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isCreating = false;
      });
      if (mounted) {
        showWarning('فشل إنشاء الفئة: $e');
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
    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: CustomAppBar(navigateName: "Category"),
      ),
      body: Container(
        color: Colors.white70,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Parent Category Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final categories = PrefUtils.categoryProduct;
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
                      ...categories.map((category) {
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
              ),
              const SizedBox(height: 20),
              // Sub-Category Field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextFormField(
                  controller: _subCategoryController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    labelText: "اسم الفئة",
                    labelStyle: GoogleFonts.raleway(
                      color: const Color(0xFF444444),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    hintText: "أدخل اسم الفئة",
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
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'يرجى إدخال اسم الفئة';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              // Create Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _isCreating
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : CustomElevatedButton(
                        buttonName: "إنشاء فئة",
                        showToast: _createCategory,
                      ),
              ),
              const SizedBox(height: 40),
              // Categories List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "فئات المنتجات",
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
              ),
              const SizedBox(height: 10),
              // Categories List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Obx(() {
                        final categories = PrefUtils.categoryProduct;

                        if (categories.isEmpty) {
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
                                  'لا توجد فئات',
                                  style: GoogleFonts.raleway(
                                    textStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
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

                        return RefreshIndicator(
                          onRefresh: _loadCategories,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: categories.length,
                            itemBuilder: (context, index) {
                              final category = categories[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.orange.shade100,
                                    child: Icon(
                                      Icons.category,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  title: Text(
                                    _getCategoryDisplayName(category),
                                    style: GoogleFonts.raleway(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 18,
                                      color: const Color(0xFF444444),
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getParentCategoryName(category),
                                          style: GoogleFonts.nunito(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        if (category.productCount != null &&
                                            category.productCount != false)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Text(
                                              'عدد المنتجات: ${category.productCount}',
                                              style: GoogleFonts.nunito(
                                                fontSize: 12,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  trailing:
                                      category.parentId != null &&
                                          category.parentId != false
                                      ? Icon(
                                          Icons.subdirectory_arrow_right,
                                          color: Colors.grey[400],
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
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
