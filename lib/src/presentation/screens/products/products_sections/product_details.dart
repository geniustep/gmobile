import 'package:flutter/material.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/build_image.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_app_bar_badge.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ProductDetails extends StatelessWidget {
  final ProductModel product;

  const ProductDetails({super.key, required this.product});

  void _log(String message) {
    if (kDebugMode) {
      print('[ProductDetails] $message');
    }
  }

  void _logError(String message, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [ProductDetails] $message');
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack: $stackTrace');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(
      symbol: 'MAD ',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(colorScheme, context),
              _buildProductHeader(colorScheme, currencyFormat),
              _buildPriceSection(colorScheme, currencyFormat),
              _buildStockSection(colorScheme),
              if (_isAdmin) _buildQuickActions(colorScheme),
              _buildDetailsSection(colorScheme),
              _buildSalesInfo(colorScheme),
              if (_hasSellers) _buildSupplierInfo(colorScheme, currencyFormat),
              _buildAdditionalInfo(colorScheme),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(colorScheme, currencyFormat),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(product.name ?? 'Product Details'),
      actions: [
        DraftAppBarBadge(
          showOnlyWhenHasDrafts: true,
          iconColor: FunctionalColors.iconPrimary,
          badgeColor: Colors.orange,
        ),
        IconButton(
          icon: Icon(
            product.is_favorite == true
                ? Icons.favorite
                : Icons.favorite_border,
            color: product.is_favorite == true ? Colors.red : null,
          ),
          onPressed: () {
            _log('Favorite button pressed');
          },
        ),
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            _log('Edit button pressed');
          },
        ),
      ],
    );
  }

  bool get _isAdmin {
    try {
      return PrefUtils.user.value.isAdmin == true;
    } catch (e) {
      return false;
    }
  }

  bool get _hasSellers {
    try {
      return product.seller_ids != null &&
          product.seller_ids is List &&
          (product.seller_ids as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ✅ دالة جديدة لتحويل الصورة من String إلى Uint8List
  Uint8List? _getImageBytes() {
    try {
      if (product.image_1920 == null || product.image_1920 == false) {
        return null;
      }

      // إذا كانت String (base64)
      if (product.image_1920 is String) {
        final imageString = product.image_1920 as String;
        if (imageString.isEmpty) {
          return null;
        }

        try {
          return base64Decode(imageString);
        } catch (e) {
          _logError('Error decoding base64 image', e);
          return null;
        }
      }

      // إذا كانت Uint8List بالفعل
      if (product.image_1920 is Uint8List) {
        return product.image_1920 as Uint8List;
      }

      return null;
    } catch (e, stackTrace) {
      _logError('Error getting image bytes', e, stackTrace);
      return null;
    }
  }

  Widget _buildProductImage(ColorScheme colorScheme, BuildContext context) {
    try {
      _log('Building product image');

      final imageBytes = _getImageBytes();
      bool isChampsValid(dynamic champs) {
        return champs != null && champs != false && champs != "";
      }

      return InkWell(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (_) {
              final String imageToShow = kReleaseMode
                  ? (isChampsValid(product.image_1920)
                        ? product.image_1920
                        : "assets/images/other/empty_product.png")
                  : "assets/images/other/empty_product.png";

              return ImageTap(imageToShow);
            },
          );
        },
        child: Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant.withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: imageBytes != null
              ? Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    _logError('Error loading image', error, stackTrace);
                    return _buildErrorIcon(colorScheme);
                  },
                )
              : _buildErrorIcon(colorScheme),
        ),
      );
    } catch (e, stackTrace) {
      _logError('Error in _buildProductImage', e, stackTrace);
      return Container(
        width: double.infinity,
        height: 300,
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        child: _buildErrorIcon(colorScheme),
      );
    }
  }

  Widget _buildErrorIcon(ColorScheme colorScheme) {
    return Icon(
      Icons.inventory_2_outlined,
      size: 100,
      color: colorScheme.outline,
    );
  }

  Widget _buildProductHeader(
    ColorScheme colorScheme,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name ?? 'Unknown Product',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_hasValidCode)
                Flexible(
                  child: Text(
                    'Code: ${product.default_code}',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: product.active == true
                      ? colorScheme.primaryContainer
                      : colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product.active == true ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: product.active == true
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (_hasValidBarcode) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: colorScheme.primary),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Barcode: ${product.barcode}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _buildCategoryChip(colorScheme),
        ],
      ),
    );
  }

  bool get _hasValidCode {
    return product.default_code != null &&
        product.default_code != false &&
        product.default_code.toString() != "false" &&
        product.default_code.toString().isNotEmpty;
  }

  bool get _hasValidBarcode {
    return product.barcode != null &&
        product.barcode != false &&
        product.barcode.toString() != "false" &&
        product.barcode.toString().isNotEmpty;
  }

  Widget _buildCategoryChip(ColorScheme colorScheme) {
    String categoryName = 'Uncategorized';

    try {
      if (product.categ_id != null) {
        if (product.categ_id is List && (product.categ_id as List).length > 1) {
          categoryName =
              (product.categ_id as List)[1]?.toString() ?? 'Uncategorized';
        } else if (product.categ_id is Map) {
          categoryName =
              product.categ_id['display_name']?.toString() ?? 'Uncategorized';
        }
      }
    } catch (e) {
      categoryName = 'Uncategorized';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.category,
            size: 14,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              categoryName,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(
    ColorScheme colorScheme,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceCard(
              colorScheme: colorScheme,
              title: 'Sale Price',
              price: _parseDouble(product.list_price),
              icon: Icons.sell,
              color: colorScheme.primary,
              currencyFormat: currencyFormat,
            ),
          ),
          const SizedBox(width: 12),
          if (_isAdmin)
            Expanded(
              child: _buildPriceCard(
                colorScheme: colorScheme,
                title: 'Cost Price',
                price: _parseDouble(product.standard_price),
                icon: Icons.shopping_cart,
                color: colorScheme.tertiary,
                currencyFormat: currencyFormat,
              ),
            ),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null || value == false) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Widget _buildPriceCard({
    required ColorScheme colorScheme,
    required String title,
    required double price,
    required IconData icon,
    required Color color,
    required NumberFormat currencyFormat,
  }) {
    final salePrice = _parseDouble(product.list_price);
    final costPrice = _parseDouble(product.standard_price);
    final profit = salePrice - costPrice;
    final margin = salePrice > 0 ? ((profit / salePrice) * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(price),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (title == 'Sale Price' && margin > 0 && _isAdmin) ...[
            const SizedBox(height: 4),
            Text(
              'Margin: ${margin.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockSection(ColorScheme colorScheme) {
    final qtyAvailable = _parseDouble(product.qty_available);
    final virtualAvailable = _parseDouble(product.virtual_available);
    final isInStock = qtyAvailable > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Stock Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStockCard(
                  colorScheme: colorScheme,
                  title: 'On Hand',
                  quantity: qtyAvailable,
                  icon: Icons.warehouse,
                  color: isInStock ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStockCard(
                  colorScheme: colorScheme,
                  title: 'Forecasted',
                  quantity: virtualAvailable,
                  icon: Icons.trending_up,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          if (product.uom_name != null &&
              product.uom_name != false &&
              product.uom_name.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Unit: ${product.uom_name}',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockCard({
    required ColorScheme colorScheme,
    required String title,
    required double quantity,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            quantity.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              colorScheme: colorScheme,
              icon: Icons.point_of_sale,
              label: 'Sell',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              colorScheme: colorScheme,
              icon: Icons.add_shopping_cart,
              label: 'Purchase',
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              colorScheme: colorScheme,
              icon: Icons.inventory_2,
              label: 'Adjust Stock',
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: colorScheme.onPrimaryContainer, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            colorScheme: colorScheme,
            label: 'Product Type',
            value: _getProductType(),
            icon: Icons.category,
          ),
          if (product.categ_id != null)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Category',
              value: _getCategoryName(),
              icon: Icons.folder,
            ),
          if (product.sale_ok != null)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Can be Sold',
              value: product.sale_ok == true ? 'Yes' : 'No',
              icon: Icons.sell,
            ),
          if (product.purchase_ok != null)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Can be Purchased',
              value: product.purchase_ok == true ? 'Yes' : 'No',
              icon: Icons.shopping_cart,
            ),
          if (product.invoice_policy != null && product.invoice_policy != false)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Invoice Policy',
              value: _getInvoicePolicy(),
              icon: Icons.receipt,
            ),
          if (product.tracking != null &&
              product.tracking != false &&
              product.tracking.toString() != 'none')
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Tracking',
              value: product.tracking.toString(),
              icon: Icons.track_changes,
            ),
          if (_parseDouble(product.weight) > 0)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Weight',
              value:
                  '${_parseDouble(product.weight)} ${product.weight_uom_name ?? "kg"}',
              icon: Icons.fitness_center,
            ),
          if (_parseDouble(product.volume) > 0)
            _buildDetailRow(
              colorScheme: colorScheme,
              label: 'Volume',
              value:
                  '${_parseDouble(product.volume)} ${product.volume_uom_name ?? "m³"}',
              icon: Icons.square_foot,
            ),
        ],
      ),
    );
  }

  String _getProductType() {
    try {
      switch (product.type?.toString()) {
        case 'consu':
          return 'Consumable';
        case 'service':
          return 'Service';
        case 'product':
          return 'Storable Product';
        default:
          return product.type?.toString() ?? 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getCategoryName() {
    try {
      if (product.categ_id != null) {
        if (product.categ_id is List && (product.categ_id as List).length > 1) {
          String fullName =
              (product.categ_id as List)[1]?.toString() ?? 'Uncategorized';
          List<String> parts = fullName.split('/');
          return parts.last.trim();
        } else if (product.categ_id is Map) {
          return product.categ_id['display_name']?.toString() ??
              'Uncategorized';
        }
      }
    } catch (e) {
      return 'Uncategorized';
    }
    return 'Uncategorized';
  }

  String _getInvoicePolicy() {
    try {
      switch (product.invoice_policy?.toString()) {
        case 'delivery':
          return 'Delivered quantities';
        case 'order':
          return 'Ordered quantities';
        default:
          return product.invoice_policy?.toString() ?? 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  Widget _buildDetailRow({
    required ColorScheme colorScheme,
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesInfo(ColorScheme colorScheme) {
    final salesCount = _parseDouble(product.sales_count);
    final purchasedQty = _parseDouble(product.purchased_product_qty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isAdmin ? 'Sales & Purchase Statistics' : 'Sales Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  colorScheme: colorScheme,
                  title: 'Total Sales',
                  value: salesCount.toStringAsFixed(0),
                  icon: Icons.shopping_bag,
                  color: Colors.green,
                ),
              ),
              if (_isAdmin) const SizedBox(width: 12),
              if (_isAdmin)
                Expanded(
                  child: _buildStatCard(
                    colorScheme: colorScheme,
                    title: 'Purchased Qty',
                    value: purchasedQty.toStringAsFixed(0),
                    icon: Icons.shopping_cart,
                    color: Colors.blue,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required ColorScheme colorScheme,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierInfo(
    ColorScheme colorScheme,
    NumberFormat currencyFormat,
  ) {
    if (!_hasSellers) return const SizedBox.shrink();

    final sellers = product.seller_ids as List;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Suppliers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...sellers.map(
            (seller) => _buildSupplierCard(
              colorScheme: colorScheme,
              seller: seller,
              currencyFormat: currencyFormat,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierCard({
    required ColorScheme colorScheme,
    required dynamic seller,
    required NumberFormat currencyFormat,
  }) {
    String supplierName = 'Unknown Supplier';
    double price = 0.0;
    double minQty = 1.0;
    int delay = 0;

    try {
      if (seller is Map) {
        supplierName =
            seller['partner_id']?['display_name']?.toString() ??
            'Unknown Supplier';
        price = _parseDouble(seller['price']);
        minQty = _parseDouble(seller['min_qty']);
        delay = (seller['delay'] ?? 0) is int
            ? seller['delay']
            : int.tryParse(seller['delay'].toString()) ?? 0;
      }
    } catch (e) {
      // Keep default values
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                radius: 20,
                child: Icon(
                  Icons.business,
                  color: colorScheme.onPrimaryContainer,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplierName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      currencyFormat.format(price),
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildSupplierDetail(
                colorScheme: colorScheme,
                icon: Icons.shopping_basket,
                label: 'Min Qty: ${minQty.toStringAsFixed(0)}',
              ),
              const SizedBox(width: 16),
              _buildSupplierDetail(
                colorScheme: colorScheme,
                icon: Icons.access_time,
                label: 'Lead Time: $delay days',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierDetail({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (_hasResponsible)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.person,
              label: 'Responsible',
              value: _getResponsibleName(),
            ),
          if (product.write_date != null && product.write_date != false)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.calendar_today,
              label: 'Last Updated',
              value: _formatDate(product.write_date.toString()),
            ),
          if (product.product_variant_count != null)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.description,
              label: 'Product Variants',
              value: product.product_variant_count.toString(),
            ),
          if (product.sale_delay != null && product.sale_delay != false)
            _buildInfoRow(
              colorScheme: colorScheme,
              icon: Icons.local_shipping,
              label: 'Customer Lead Time',
              value: '${product.sale_delay} days',
            ),
        ],
      ),
    );
  }

  bool get _hasResponsible {
    try {
      return product.responsible_id != null &&
          product.responsible_id != false &&
          (product.responsible_id is List
              ? (product.responsible_id as List).length > 1
              : true);
    } catch (e) {
      return false;
    }
  }

  String _getResponsibleName() {
    try {
      if (product.responsible_id is List &&
          (product.responsible_id as List).length > 1) {
        return (product.responsible_id as List)[1]?.toString() ??
            'Not assigned';
      } else if (product.responsible_id is Map) {
        return product.responsible_id['display_name']?.toString() ??
            'Not assigned';
      }
    } catch (e) {
      return 'Not assigned';
    }
    return 'Not assigned';
  }

  Widget _buildInfoRow({
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildBottomBar(ColorScheme colorScheme, NumberFormat currencyFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sale Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    currencyFormat.format(_parseDouble(product.list_price)),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
