// lib/src/presentation/screens/sales/saleorder/create/widgets/product_lines/empty_products_view.dart

import 'package:flutter/material.dart';

class EmptyProductsView extends StatelessWidget {
  final VoidCallback? onAddProduct;
  const EmptyProductsView({
    Key? key,
    this.onAddProduct, // ← أضف
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            Text(
              'لا توجد منتجات',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على زر + لإضافة منتجات للطلب',
              style: TextStyle(fontSize: 15, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Icon(Icons.arrow_downward, size: 30, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
