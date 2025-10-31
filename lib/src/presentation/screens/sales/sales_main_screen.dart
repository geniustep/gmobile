import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/create_new_order_form.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/salesSections/horizontal_sales_table_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_app_bar_badge.dart';
import 'package:gsloution_mobile/src/presentation/widgets/drawer/dashboard_drawer.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/services/order_persistence_tracker.dart';

class SalesMainScreen extends StatefulWidget {
  const SalesMainScreen({super.key});

  @override
  State<SalesMainScreen> createState() => _SalesMainScreenState();
}

class _SalesMainScreenState extends State<SalesMainScreen> {
  final controller = SidebarXController(selectedIndex: 1, extended: true);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final RxList<OrderModel> sales = PrefUtils.sales;
  final RxList<OrderModel> filteredSales = <OrderModel>[].obs;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    // ✅ لا نحتاج لتحميل البيانات - sales هو PrefUtils.sales مباشرة
    _applyDefaultFilter();

    // ✅ مراقبة تغييرات PrefUtils.sales مباشرة
    ever(sales, (List<OrderModel> newSales) {
      _applyDefaultFilter();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ لا نحتاج لإعادة تحميل البيانات - PrefUtils.sales محدث تلقائياً

    // ✅ تم تحديث التبعيات
  }

  @override
  void didUpdateWidget(SalesMainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ لا نحتاج لإعادة تحميل البيانات - PrefUtils.sales محدث تلقائياً
  }

  void _applyDefaultFilter() {
    isAdmin = PrefUtils.user.value.isAdmin ?? false;

    // ✅ تم تطبيق الفلتر بنجاح

    // ✅ البيانات مفلترة مسبقاً من السيرفر، فقط الترتيب
    List<OrderModel> sortedSales = List<OrderModel>.from(sales);

    // ✅ ترتيب مثل Odoo: date_order desc, id desc
    sortedSales.sort((a, b) {
      // أولاً: الترتيب حسب date_order (تنازلي)
      final dateA = _parseDate(a.dateOrder);
      final dateB = _parseDate(b.dateOrder);

      if (dateA != null && dateB != null) {
        final dateCompare = dateB.compareTo(dateA);
        if (dateCompare != 0) {
          return dateCompare; // إذا كانت التواريخ مختلفة
        }
      } else if (dateA == null && dateB != null) {
        return 1; // dateA null يذهب للأخير
      } else if (dateA != null && dateB == null) {
        return -1; // dateB null يذهب للأخير
      }

      // ثانياً: إذا تساوت التواريخ، رتب حسب ID (تنازلي)
      return (b.id ?? 0).compareTo(a.id ?? 0);
    });

    filteredSales.assignAll(sortedSales);

    // ✅ تم ترتيب الطلبات بنجاح

    filteredSales.refresh();
    OrderPersistenceTracker.logSalesMainScreenState('After Odoo-style sort');
  }

  // ✅ دالة مساعدة لتحليل التاريخ
  DateTime? _parseDate(dynamic date) {
    if (date == null || date == false || date == '') return null;

    try {
      if (date is DateTime) return date;
      if (date is String) return DateTime.parse(date.trim());
      if (date is List && date.isNotEmpty && date[0] is String) {
        return DateTime.parse(date[0]);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Could not parse date: $date');
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ لا نحتاج لإعادة تحميل البيانات في كل build
    // البيانات محدثة تلقائياً من PrefUtils

    // ✅ تم بناء الشاشة

    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _key,
      backgroundColor: AppColors.background,
      endDrawer: Drawer(
        child: DashboardDrawer(routeName: "Trading", controller: controller),
      ),
      appBar: isSmallScreen
          ? AppBar(
              elevation: 0,
              backgroundColor: AppColors.cardBackground,
              automaticallyImplyLeading: true,
              centerTitle: true,
              surfaceTintColor: Colors.transparent,
              shadowColor: FunctionalColors.shadow,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Sales",
                    style: GoogleFonts.raleway(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  if (isAdmin) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "Admin",
                        style: GoogleFonts.raleway(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(
                  Icons.keyboard_arrow_left,
                  size: 30,
                  color: FunctionalColors.iconPrimary,
                ),
              ),
              actions: [
                DraftAppBarBadge(
                  showOnlyWhenHasDrafts: true,
                  iconColor: FunctionalColors.iconPrimary,
                  badgeColor: Colors.orange,
                ),
                IconButton(
                  onPressed: () {
                    if (!Platform.isAndroid && !Platform.isIOS) {
                      controller.setExtended(true);
                    }
                    if (_key.currentState != null) {
                      _key.currentState?.openEndDrawer();
                    }
                  },
                  icon: Icon(
                    Icons.menu,
                    size: 28,
                    color: FunctionalColors.iconPrimary,
                  ),
                ),
              ],
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.background, AppColors.surfaceLight],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Flexible(
              fit: FlexFit.loose,
              child: HorizontalSalesTableSection(sales: filteredSales),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () async {
          await Get.to(() => const CreateNewOrder());
        },
        label: Text(
          "Create Order",
          style: GoogleFonts.raleway(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
        icon: const Icon(
          Icons.add_circle_outline_rounded,
          color: Colors.white,
          size: 22,
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
    );
  }

  @override
  void dispose() {
    // ✅ تم إصلاح الخطأ - إزالة استدعاء dispose() على ScaffoldState
    // ✅ إذا كان لديك أي عناصر تحتاج للتخلص منها، أضفها هنا
    // controller.dispose(); // إذا كان الـ controller يحتاج للتخلص منه

    super.dispose(); // ✅ دائمًا استدع super.dispose() في النهاية
  }
}
