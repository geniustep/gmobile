import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/product_line.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/build_image_helper.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/widget/sales_quantity_selector.dart';

class ProductLineEditor extends StatefulWidget {
  final ProductLine line;
  final GlobalKey<FormBuilderState> formKey;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final Function(double)? onQuantityChanged;
  final Function(double)? onDiscountChanged;
  final Function(double)? onPriceChanged;

  const ProductLineEditor({
    super.key,
    required this.line,
    required this.formKey,
    required this.onSave,
    required this.onCancel,
    this.onQuantityChanged,
    this.onDiscountChanged,
    this.onPriceChanged,
  });

  @override
  State<ProductLineEditor> createState() => _ProductLineEditorState();
}

class _ProductLineEditorState extends State<ProductLineEditor> {
  final bool isAdmin = PrefUtils.user.value.isAdmin ?? false;

  // ✅ Debounce timers لتقليل التحديثات
  Timer? _quantityDebounce;
  Timer? _priceDebounce;
  Timer? _discountDebounce;

  // متغيرات لتجنب الحلقات اللانهائية
  bool _isUpdatingQuantity = false;
  bool _isUpdatingPrice = false;
  bool _isUpdatingDiscount = false;

  @override
  void initState() {
    super.initState();

    // تهيئة الحقول بالقيم الحالية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.line.quantityController.text = widget.line.quantity
          .toStringAsFixed(0);
      widget.line.priceController.text = widget.line.priceUnit.toStringAsFixed(
        2,
      );
      widget.line.discountController.text = widget.line.discountPercentage
          .toStringAsFixed(1);
    });
  }

  @override
  void dispose() {
    // ✅ إلغاء timers
    _quantityDebounce?.cancel();
    _priceDebounce?.cancel();
    _discountDebounce?.cancel();
    super.dispose();
  }

  // ✅ دالة debounce للكمية
  void _onQuantityChanged(String? value) {
    _quantityDebounce?.cancel();

    if (value == null || value.isEmpty) return;

    _quantityDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _isUpdatingQuantity) return;

      final qty = double.tryParse(value);
      if (qty != null && qty > 0) {
        _isUpdatingQuantity = true;

        widget.line.updateQuantity(qty);
        widget.onQuantityChanged?.call(qty);

        if (mounted) {
          setState(() {
            _isUpdatingQuantity = false;
          });
        }
      }
    });
  }

  // ✅ دالة debounce للسعر
  void _onPriceChanged(String? value) {
    _priceDebounce?.cancel();

    if (value == null || value.isEmpty) return;

    _priceDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _isUpdatingPrice) return;

      final price = double.tryParse(value);
      if (price != null && price >= 0) {
        _isUpdatingPrice = true;

        widget.line.updatePrice(price);
        widget.onPriceChanged?.call(price);

        if (mounted) {
          setState(() {
            _isUpdatingPrice = false;
          });
        }
      }
    });
  }

  // ✅ دالة debounce للخصم
  void _onDiscountChanged(String? value) {
    _discountDebounce?.cancel();

    if (value == null || value.isEmpty) return;

    _discountDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _isUpdatingDiscount) return;

      final discount = double.tryParse(value);
      if (discount != null && discount >= 0 && discount <= 100) {
        _isUpdatingDiscount = true;

        widget.line.updateDiscount(discount);
        widget.onDiscountChanged?.call(discount);

        if (mounted) {
          setState(() {
            _isUpdatingDiscount = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FormBuilder(
        key: widget.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildProductInfo(),
            const SizedBox(height: 16),
            _buildQuantityField(),
            const SizedBox(height: 16),
            _buildPriceAndDiscountFields(),
            const SizedBox(height: 16),
            _buildPriceBreakdown(),
            const SizedBox(height: 16),
            _buildTotalCard(),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ... باقي الدوال (نفس الكود مع استبدال onChanged)

  Widget _buildQuantityField() {
    return Row(
      children: [
        Expanded(
          child: FormBuilderTextField(
            name: 'quantity',
            controller: widget.line.quantityController,
            decoration: InputDecoration(
              labelText: 'الكمية',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.shopping_cart),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'الكمية مطلوبة'),
              FormBuilderValidators.numeric(
                errorText: 'يجب أن يكون رقماً صحيحاً',
              ),
              FormBuilderValidators.min(1, errorText: 'يجب أن يكون أكبر من 0'),
            ]),
            // ✅ استخدام debounce بدلاً من onChanged مباشرة
            onChanged: _onQuantityChanged,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.touch_app, color: Colors.orange),
            onPressed: _showQuantitySelector,
            tooltip: 'اختيار الكمية',
          ),
        ),
      ],
    );
  }

  Future<void> _showQuantitySelector() async {
    final quantity = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          SalesQuantitySelector(productName: widget.line.productName),
    );  

    if (quantity != null) {
      widget.line.updateQuantity(quantity.toDouble());
      widget.onQuantityChanged?.call(quantity.toDouble());
      widget.line.quantityController.text = quantity.toString();

      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget _buildPriceAndDiscountFields() {
    return Row(
      children: [
        // حقل السعر
        Expanded(
          child: FormBuilderTextField(
            name: 'price',
            controller: widget.line.priceController,
            enabled: isAdmin,
            decoration: InputDecoration(
              labelText: 'السعر',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.attach_money),
              suffixText: 'Dh',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'السعر مطلوب'),
              FormBuilderValidators.numeric(errorText: 'يجب أن يكون رقماً'),
              FormBuilderValidators.min(0, errorText: 'يجب أن يكون موجباً'),
            ]),
            // ✅ استخدام debounce
            onChanged: _onPriceChanged,
          ),
        ),
        const SizedBox(width: 8),
        // حقل الخصم
        Expanded(
          child: FormBuilderTextField(
            name: 'discount',
            controller: widget.line.discountController,
            enabled: isAdmin,
            decoration: InputDecoration(
              labelText: 'الخصم',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              prefixIcon: const Icon(Icons.percent),
              suffixText: '%',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.numeric(errorText: 'يجب أن يكون رقماً'),
              FormBuilderValidators.min(0, errorText: 'يجب أن يكون موجباً'),
              FormBuilderValidators.max(
                100,
                errorText: 'يجب أن يكون أقل من 100',
              ),
            ]),
            // ✅ استخدام debounce
            onChanged: _onDiscountChanged,
          ),
        ),
      ],
    );
  }

  // ... باقي الدوال بدون تغيير

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'تعديل المنتج',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'وضع التعديل',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Row(
      children: [
        BuildImageHelper.buildImage(
          widget.line.productModel?.image_1920,
          width: 60,
          height: 60,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.line.productName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.line.productModel?.default_code != null)
                Text(
                  'الرمز: ${widget.line.productModel!.default_code}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildPriceRow('السعر الأصلي:', widget.line.listPrice),
          if (widget.line.hasDiscount) ...[
            const Divider(),
            _buildPriceRow(
              'الخصم (${widget.line.discountPercentage.toStringAsFixed(1)}%):',
              -(widget.line.listPrice - widget.line.priceUnit),
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: color ?? Colors.grey[700]),
        ),
        Text(
          '${value.toStringAsFixed(2)} Dh',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'الإجمالي:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${widget.line.getTotalPrice().toStringAsFixed(2)} Dh',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
            label: const Text('إلغاء'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onSave,
            icon: const Icon(Icons.check),
            label: const Text('حفظ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
