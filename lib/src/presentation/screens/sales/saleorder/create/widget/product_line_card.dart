// lib/src/presentation/screens/sales/saleorder/create/widget/product_line_card.dart

import 'package:flutter/material.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/build_image_helper.dart';

class ProductLineCard extends StatelessWidget {
  final int index;
  final ProductLine line;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onQuantityTap;

  const ProductLineCard({
    Key? key,
    required this.index,
    required this.line,
    required this.onEdit,
    required this.onDelete,
    this.onQuantityTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final product = line.productModel;
    if (product == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة المنتج
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: BuildImageHelper.buildImage(
                  product.image_512,
                  width: 70,
                  height: 70,
                ),
              ),

              const SizedBox(width: 12),

              // معلومات المنتج
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // اسم المنتج
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // الكمية والسعر والخصم
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildChip(
                          icon: Icons.shopping_cart,
                          label: 'الكمية: ${line.quantity}',
                          color: Colors.blue,
                        ),
                        _buildChip(
                          icon: Icons.attach_money,
                          label: '${line.priceUnit.toStringAsFixed(2)} Dh',
                          color: Colors.green,
                        ),
                        if (line.hasDiscount)
                          _buildChip(
                            icon: Icons.discount,
                            label:
                                '-${line.discountPercentage.toStringAsFixed(1)}%',
                            color: Colors.red,
                          ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // سعر القائمة (إذا كان هناك خصم)
                    if (line.hasDiscount)
                      Text(
                        'سعر القائمة: ${line.listPrice.toStringAsFixed(2)} Dh',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
              ),

              // الإجمالي والأزرار
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // الإجمالي
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${line.getTotalPrice().toStringAsFixed(2)} Dh',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // التوفير (إذا كان هناك خصم)
                  if (line.getSavings() > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.savings, size: 14, color: Colors.red[700]),
                          const SizedBox(width: 4),
                          Text(
                            '${line.getSavings().toStringAsFixed(2)} Dh',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // أزرار التحكم
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة الكمية (إذا كان هناك callback)
                      if (onQuantityTap != null) ...[
                        _buildIconButton(
                          icon: Icons.shopping_cart,
                          color: Colors.orange,
                          onPressed: onQuantityTap!,
                          tooltip: 'تغيير الكمية',
                        ),
                        const SizedBox(width: 8),
                      ],
                      _buildIconButton(
                        icon: Icons.edit,
                        color: Colors.blue,
                        onPressed: onEdit,
                        tooltip: 'تعديل',
                      ),
                      const SizedBox(width: 8),
                      _buildIconButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        onPressed: onDelete,
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: color),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }
}
