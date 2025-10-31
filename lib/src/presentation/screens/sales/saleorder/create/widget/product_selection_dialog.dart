// lib/src/presentation/screens/sales/saleorder/create/widget/product_selection_dialog.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/build_image_helper.dart';

class ProductSelectionDialog extends StatefulWidget {
  final List<ProductModel> products;
  final Set<int> selectedProductIds;
  final Function(ProductModel) onProductSelected;
  final List<PricelistModel>? priceLists;
  final dynamic selectedPriceListId;

  const ProductSelectionDialog({
    Key? key,
    required this.products,
    required this.selectedProductIds,
    required this.onProductSelected,
    this.priceLists,
    this.selectedPriceListId,
  }) : super(key: key);

  @override
  State<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends State<ProductSelectionDialog> {
  List<ProductModel> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showAllProducts = false; // خيار إظهار الكل

  @override
  void initState() {
    super.initState();
    _filterProductsByStock();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProductsByStock() {
    setState(() {
      if (_showAllProducts) {
        _filteredProducts = widget.products;
      } else {
        // عرض المنتجات الموجودة في المخزون فقط
        _filteredProducts = widget.products.where((product) {
          final qtyAvailable = product.qty_available?.toDouble() ?? 0.0;
          return qtyAvailable > 0;
        }).toList();
      }
    });
  }

  void _filterProducts(String query) {
    setState(() {
      final baseProducts = _showAllProducts
          ? widget.products
          : widget.products.where((product) {
              final qtyAvailable = product.qty_available?.toDouble() ?? 0.0;
              return qtyAvailable > 0;
            }).toList();

      if (query.isEmpty) {
        _filteredProducts = baseProducts;
      } else {
        _filteredProducts = baseProducts.where((product) {
          return product.name.toLowerCase().contains(query.toLowerCase()) ||
              (product.barcode?.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildSearchBar(),
          _buildStockToggle(),
          _buildProductCount(),
          Expanded(child: _buildProductsList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'اختر منتج',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن منتج أو باركود...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterProducts('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _filterProducts,
      ),
    );
  }

  Widget _buildStockToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            _showAllProducts ? Icons.inventory_2 : Icons.inventory,
            color: _showAllProducts ? Colors.blue : Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _showAllProducts ? 'عرض الكل' : 'المخزون المتاح',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _showAllProducts ? Colors.blue : Colors.green,
            ),
          ),
          const Spacer(),
          Switch(
            value: _showAllProducts,
            onChanged: (value) {
              setState(() {
                _showAllProducts = value;
                _filterProductsByStock();
              });
            },
            activeColor: Colors.blue,
            inactiveThumbColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildProductCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'النتائج: ${_filteredProducts.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (widget.selectedProductIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'محدد: ${widget.selectedProductIds.length}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمة أخرى',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredProducts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        final isSelected = widget.selectedProductIds.contains(product.id);

        return _buildProductItem(product, isSelected);
      },
    );
  }

  Widget _buildProductItem(ProductModel product, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          widget.onProductSelected(product);
          // ✅ استخدام Navigator بدلاً من Get.back لتجنب مشاكل التنقل
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pop();
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildProductImage(product),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.barcode != null &&
                        product.barcode != false) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.qr_code,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product.barcode!.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    _buildPriceSection(product),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailingIcon(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductImage(ProductModel product) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BuildImageHelper.buildImage(
        product.image_512 ?? product.image_1920,
        width: 60,
        height: 60,
      ),
    );
  }

  Widget _buildTrailingIcon(bool isSelected) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.green,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    }

    return Icon(
      Icons.add_circle_outline,
      color: Theme.of(context).primaryColor,
      size: 28,
    );
  }

  // ============= Helper Methods =============

  Color _getStockColor(ProductModel product) {
    final qtyAvailable = product.qty_available?.toDouble() ?? 0.0;
    if (qtyAvailable > 10) return Colors.green;
    if (qtyAvailable > 0) return Colors.orange;
    return Colors.red;
  }

  String _getStockText(ProductModel product) {
    final qtyAvailable = product.qty_available?.toDouble() ?? 0.0;
    if (qtyAvailable > 0) {
      return qtyAvailable.toStringAsFixed(0);
    }
    return 'غير متوفر';
  }

  // ============= Price Calculation =============

  /// حساب السعر مع قائمة الأسعار
  Map<String, dynamic> _calculateProductPrice(ProductModel product) {
    final basePrice = product.lst_price?.toDouble() ?? 0.0;

    // إذا لم تكن هناك قائمة أسعار، إرجاع السعر الأساسي
    if (widget.priceLists == null ||
        widget.priceLists!.isEmpty ||
        widget.selectedPriceListId == null) {
      return {
        'finalPrice': basePrice,
        'originalPrice': basePrice,
        'discount': 0.0,
        'hasDiscount': false,
        'isMarkup': false,
      };
    }

    // البحث عن قائمة الأسعار المحددة
    final priceList = widget.priceLists!.firstWhereOrNull(
      (p) => p.id == widget.selectedPriceListId,
    );

    if (priceList == null ||
        priceList.items == null ||
        priceList.items!.isEmpty) {
      return {
        'finalPrice': basePrice,
        'originalPrice': basePrice,
        'discount': 0.0,
        'hasDiscount': false,
        'isMarkup': false,
      };
    }

    // البحث عن القاعدة المناسبة مباشرة
    final matchingRule = _findMatchingRuleForProduct(product, priceList.items!);

    if (matchingRule != null) {
      // حساب السعر النهائي مباشرة
      final result = _calculatePriceForProduct(product, matchingRule);

      return {
        'finalPrice': result['finalPrice'],
        'originalPrice': basePrice,
        'discount': result['discount'],
        'hasDiscount': result['hasAppliedRule'],
        'isMarkup': result['isMarkup'],
      };
    }

    return {
      'finalPrice': basePrice,
      'originalPrice': basePrice,
      'discount': 0.0,
      'hasDiscount': false,
      'isMarkup': false,
    };
  }

  /// البحث عن القاعدة المناسبة للمنتج
  PricelistItem? _findMatchingRuleForProduct(
    ProductModel product,
    List<PricelistItem> rules,
  ) {
    for (var rule in rules) {
      // التحقق من مطابقة المنتج
      final productMatch = _matchesProduct(product, rule);

      // التحقق من مطابقة الكمية (نستخدم 1 ككمية افتراضية)
      final quantityMatch = 1.0 >= (rule.minQuantity ?? 0);

      if (productMatch && quantityMatch) {
        return rule;
      }
    }
    return null;
  }

  /// حساب السعر للمنتج مع القاعدة
  Map<String, dynamic> _calculatePriceForProduct(
    ProductModel product,
    PricelistItem rule,
  ) {
    final basePrice = product.lst_price?.toDouble() ?? 0.0;
    final ruleValue = _extractNumericValue(rule.price);
    final isNegative = _isNegativeValue(rule.price);

    if (ruleValue == null) {
      return {
        'finalPrice': basePrice,
        'discount': 0.0,
        'isMarkup': false,
        'hasAppliedRule': false,
      };
    }

    double finalPrice = basePrice;
    double discount = 0.0;
    bool isMarkup = false;

    switch (rule.computePrice) {
      case 'fixed':
        finalPrice = ruleValue;
        discount = _calculateDiscountPercentage(basePrice, finalPrice);
        break;

      case 'percentage':
        if (isNegative) {
          finalPrice = basePrice * (1 + ruleValue / 100);
          isMarkup = true;
        } else {
          discount = ruleValue;
          finalPrice = basePrice * (1 - ruleValue / 100);
        }
        break;

      case 'formula':
        if (isNegative) {
          finalPrice = basePrice * (1 + ruleValue / 100);
          isMarkup = true;
        } else {
          discount = ruleValue;
          finalPrice = basePrice * (1 - ruleValue / 100);
        }
        break;

      default:
        return {
          'finalPrice': basePrice,
          'discount': 0.0,
          'isMarkup': false,
          'hasAppliedRule': false,
        };
    }

    return {
      'finalPrice': finalPrice,
      'discount': discount,
      'isMarkup': isMarkup,
      'hasAppliedRule': true,
    };
  }

  /// التحقق من مطابقة المنتج
  bool _matchesProduct(ProductModel product, PricelistItem rule) {
    if (rule.productTmplId == null ||
        rule.productTmplId == false ||
        rule.productTmplId == 0) {
      return true;
    }
    return product.product_tmpl_id == rule.productTmplId;
  }

  /// استخراج القيمة الرقمية من النص
  double? _extractNumericValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String && value.isNotEmpty) {
      final match = RegExp(r'-?(\d+\.?\d*)').firstMatch(value);
      if (match != null) {
        return double.tryParse(match.group(1)!);
      }
    }

    return null;
  }

  /// التحقق من كون القيمة سالبة
  bool _isNegativeValue(dynamic value) {
    if (value is num) {
      return value < 0;
    }

    if (value is String) {
      return value.contains('-');
    }

    return false;
  }

  /// حساب نسبة الخصم
  double _calculateDiscountPercentage(double originalPrice, double finalPrice) {
    if (originalPrice == 0) return 0.0;
    return ((originalPrice - finalPrice) / originalPrice * 100).clamp(0, 100);
  }

  // ============= UI Components =============

  /// بناء قسم السعر مع قائمة الأسعار
  Widget _buildPriceSection(ProductModel product) {
    final priceData = _calculateProductPrice(product);
    final finalPrice = priceData['finalPrice'] as double;
    final originalPrice = priceData['originalPrice'] as double;
    final hasDiscount = priceData['hasDiscount'] as bool;
    final isMarkup = priceData['isMarkup'] as bool;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // السعر النهائي
        Row(
          children: [
            Text(
              '${finalPrice.toStringAsFixed(2)} Dh',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: _getStockColor(product).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStockColor(product).withOpacity(0.3),
                ),
              ),
              child: Text(
                'المخزون: ${_getStockText(product)}',
                style: TextStyle(
                  fontSize: 10,
                  color: _getStockColor(product),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        // ✅ عرض السعر الأصلي والخصم فقط إذا كان هناك خصم (وليس زيادة)
        if (hasDiscount && finalPrice != originalPrice && !isMarkup) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              // السعر الأصلي
              Text(
                '${originalPrice.toStringAsFixed(2)} Dh',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 8),
              // مؤشر الخصم
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Text(
                  '-${((originalPrice - finalPrice) / originalPrice * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// Helper function لعرض الـ Dialog
void showProductSelectionDialog({
  BuildContext? context,
  required List<ProductModel> products,
  required Set<int> selectedProductIds,
  required Function(ProductModel) onProductSelected,
  List<PricelistModel>? priceLists,
  dynamic selectedPriceListId,
}) {
  Get.bottomSheet(
    ProductSelectionDialog(
      products: products,
      selectedProductIds: selectedProductIds,
      onProductSelected: onProductSelected,
      priceLists: priceLists,
      selectedPriceListId: selectedPriceListId,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
