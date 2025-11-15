import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/src/presentation/screens/expense_category/expense_category_sections/expense_category_update_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/delete_toast.dart';

class ExpenseCategoryListSection extends StatefulWidget {
  final dynamic isSmallScreen;
  final List<ProductCategoryModel> categoryList;

  const ExpenseCategoryListSection({
    super.key,
    required this.isSmallScreen,
    required this.categoryList,
  });

  @override
  State<ExpenseCategoryListSection> createState() =>
      _ExpenseCategoryListSectionState();
}

class _ExpenseCategoryListSectionState
    extends State<ExpenseCategoryListSection> {
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

    if (category.parentId is int) {
      final parentId = category.parentId as int;
      final parent = widget.categoryList.firstWhereOrNull(
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
    if (widget.categoryList.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/other/empty_product.png",
                width: 350,
              ),
              Text(
                "No Expense Category Found",
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: RefreshIndicator(
          onRefresh: () async {
            // يمكن إضافة refresh logic هنا
          },
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget.categoryList.length,
            itemBuilder: (context, index) {
              final category = widget.categoryList[index];
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.shade100,
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    title: Text(
                      _getCategoryDisplayName(category),
                      style: GoogleFonts.raleway(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: const Color(0xFF444444),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                              padding: const EdgeInsets.only(top: 4),
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.blue.shade50.withOpacity(0.3),
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
                              buildModalBottomSheet(context, category);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red.shade50.withOpacity(0.3),
                          ),
                          child: IconButton(
                            onPressed: () {
                              _deleteCategory(context, category, index);
                            },
                            icon: SvgPicture.asset(
                              "assets/icons/icon_svg/delete_icon.svg",
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFE2E4E7)),
                ],
              );
            },
          ),
        ),
      );
    }
  }

  void _deleteCategory(
    BuildContext context,
    ProductCategoryModel category,
    int index,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف فئة المصروف'),
        content: Text(
          'هل أنت متأكد من حذف "${_getCategoryDisplayName(category)}"؟',
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
                _getCategoryDisplayName(category),
              );
              Navigator.pop(context);
              // يمكن إزالة من القائمة مؤقتاً
              // widget.categoryList.removeAt(index);
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

  void buildModalBottomSheet(BuildContext context, ProductCategoryModel category) {
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
          height: MediaQuery.of(context).size.height * 0.8,
          child: ExpenseCategoryUpdateSection(category: category),
        );
      },
    );
  }
}
