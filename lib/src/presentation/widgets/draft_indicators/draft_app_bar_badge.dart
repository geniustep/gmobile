import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/src/data/services/draft_sale_service.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/create_new_order_form.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class DraftAppBarBadge extends StatefulWidget {
  final VoidCallback? onTap; // ✅ اختياري - للتحكم المخصص
  final String? targetRoute;
  final bool showOnlyWhenHasDrafts; // ✅ شرط الظهور فقط عند وجود مسودات
  final double? iconSize;
  final Color? iconColor;
  final Color? badgeColor;

  const DraftAppBarBadge({
    super.key,
    this.onTap,
    this.targetRoute,
    this.showOnlyWhenHasDrafts = false, // ✅ افتراضيًا يظهر دائمًا
    this.iconSize,
    this.iconColor,
    this.badgeColor = Colors.orange,
  });

  @override
  State<DraftAppBarBadge> createState() => _DraftAppBarBadgeState();
}

class _DraftAppBarBadgeState extends State<DraftAppBarBadge> {
  final DraftSaleService _draftService = DraftSaleService.instance;
  int _productsCount = 0;
  StreamSubscription<int>? _draftCountSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToDraftChanges();
    _loadInitialDraftCount();
  }

  void _startListeningToDraftChanges() {
    _draftCountSubscription = DraftSaleService.draftCountStream.listen((
      newCount,
    ) {
      if (mounted) {
        setState(() {
          _productsCount = newCount;
        });
      }
    });
  }

  Future<void> _loadInitialDraftCount() async {
    try {
      final initialCount = await _draftService.getDraftLength();
      if (mounted) {
        setState(() {
          _productsCount = initialCount;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _productsCount = 0;
        });
      }
    }
  }

  // ✅ دالة فتح المسودات - مستقلة تماماً
  Future<void> _openDrafts() async {
    if (widget.onTap != null) {
      // ✅ استخدام الدالة المخصصة إذا وجدت
      widget.onTap!();
      return;
    }

    // ✅ السلوك الافتراضي - التنقل لصفحة المسودات
    final result = await Get.toNamed(AppRoutes.draftSales);

    if (result != null && result is Map<String, dynamic>) {
      // ✅ المستخدم اختار مسودة - فتح إنشاء طلب جديد
      await Get.to(() => const CreateNewOrder());

      // ✅ تحديث العدد بعد العودة
      await _refreshDraftCount();
    } else {
      // ✅ تحديث العدد حتى إذا لم يتم اختيار مسودة
      await _refreshDraftCount();
    }
  }

  Future<void> _refreshDraftCount() async {
    try {
      final newCount = await _draftService.getDraftLength();
      if (mounted) {
        setState(() {
          _productsCount = newCount;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error refreshing draft count: $e');
      }
    }
  }

  @override
  void dispose() {
    _draftCountSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ شرط عدم الظهور إذا لم توجد مسودات والمطلوب ذلك
    if (widget.showOnlyWhenHasDrafts && _productsCount == 0) {
      return const SizedBox.shrink();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.shopping_cart_outlined,
            size: widget.iconSize,
            color: widget.iconColor,
          ),
          onPressed: _openDrafts,
          tooltip: 'المسودات ($_productsCount)',
        ),
        if (_productsCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: GestureDetector(
              onTap: _openDrafts,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.badgeColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  _productsCount > 9 ? '9+' : _productsCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
