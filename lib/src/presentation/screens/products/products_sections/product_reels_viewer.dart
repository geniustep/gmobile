import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:intl/intl.dart';

/// Instagram Reels-style product viewer
/// Swipe vertically to navigate between products
class ProductReelsViewer extends StatefulWidget {
  final List<ProductModel> products;
  final int initialIndex;

  const ProductReelsViewer({
    super.key,
    required this.products,
    this.initialIndex = 0,
  });

  @override
  State<ProductReelsViewer> createState() => _ProductReelsViewerState();
}

class _ProductReelsViewerState extends State<ProductReelsViewer> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showDetails = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleDetails() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // PageView for products
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.products.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _ProductReelPage(
                product: widget.products[index],
                showDetails: _showDetails,
                onTap: _toggleDetails,
              );
            },
          ),

          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),

                  // Product counter
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.products.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // More options
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.white,
                      size: 28,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductReelPage extends StatelessWidget {
  final ProductModel product;
  final bool showDetails;
  final VoidCallback onTap;

  const _ProductReelPage({
    required this.product,
    required this.showDetails,
    required this.onTap,
  });

  Uint8List? _getImageBytes() {
    try {
      if (product.image_1920 == null || product.image_1920 == false) {
        return null;
      }

      if (product.image_1920 is String) {
        final imageString = product.image_1920 as String;
        if (imageString.isEmpty) return null;
        return base64Decode(imageString);
      }

      if (product.image_1920 is Uint8List) {
        return product.image_1920 as Uint8List;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null || value == false) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final imageBytes = _getImageBytes();
    final currencyFormat = NumberFormat.currency(
      symbol: 'MAD ',
      decimalDigits: 2,
    );
    final qtyAvailable = _parseDouble(product.qty_available);
    final salePrice = _parseDouble(product.list_price);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center, // Centers all children within the Stack
          children: [
            // Product Image
            Positioned(
              child: imageBytes != null
                  ? InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 3.0,
                      child: Image.memory(
                        imageBytes,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      ),
                    )
                  : _buildPlaceholder(),
            ),

            // Bottom gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: showDetails ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Name
                          Text(
                            product.name ?? 'Unknown Product',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 10),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 16),

                          // Info Cards Row
                          Row(
                            children: [
                              // Price Card
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.sell_rounded,
                                  label: 'Price',
                                  value: currencyFormat.format(salePrice),
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Stock Card
                              Expanded(
                                child: _buildInfoCard(
                                  icon: Icons.inventory_2_rounded,
                                  label: 'In Stock',
                                  value:
                                      '${qtyAvailable.toStringAsFixed(0)} ${product.uom_name ?? ""}',
                                  color: qtyAvailable > 0
                                      ? Colors.blue
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Additional Info Row
                          _buildQuickInfo(),

                          const SizedBox(height: 16),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.add_shopping_cart),
                                  label: const Text('Add to Cart'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 13,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              IconButton.filled(
                                onPressed: () {},
                                icon: Icon(
                                  product.is_favorite == true
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: product.is_favorite == true
                                      ? Colors.red
                                      : Colors.black,
                                  padding: const EdgeInsets.all(13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filled(
                                onPressed: () {},
                                icon: const Icon(Icons.share),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.all(13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Tap hint (when details are hidden)
            if (!showDetails)
              Positioned(
                bottom: 100,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tap to show details',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 120, color: Colors.grey),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 17),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Center(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo() {
    List<Widget> chips = [];

    // Product Code
    if (product.default_code != null &&
        product.default_code != false &&
        product.default_code.toString().isNotEmpty) {
      chips.add(
        _buildChip(icon: Icons.tag, text: product.default_code.toString()),
      );
    }

    // Category
    String categoryName = '';
    try {
      if (product.categ_id != null) {
        if (product.categ_id is List && (product.categ_id as List).length > 1) {
          categoryName = (product.categ_id as List)[1]?.toString() ?? '';
        } else if (product.categ_id is Map) {
          categoryName = product.categ_id['display_name']?.toString() ?? '';
        }
      }
    } catch (e) {
      categoryName = '';
    }

    if (categoryName.isNotEmpty) {
      // Get only last part if has /
      final parts = categoryName.split('/');
      final shortName = parts.isNotEmpty ? parts.last.trim() : categoryName;

      chips.add(_buildChip(icon: Icons.category, text: shortName));
    }

    // // Active status
    // chips.add(
    //   _buildChip(
    //     icon: product.active == true ? Icons.check_circle : Icons.cancel,
    //     text: product.active == true ? 'Active' : 'Inactive',
    //     color: product.active == true ? Colors.green : Colors.red,
    //   ),
    // );

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }

  Widget _buildChip({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color ?? Colors.white).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
