// lib/src/presentation/screens/inventory/stock_picking_main_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/inventory/horizontal_stock_picking_table_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/drawer/dashboard_drawer.dart';
import 'package:sidebarx/sidebarx.dart';

class StockPickingMainScreen extends StatefulWidget {
  const StockPickingMainScreen({super.key});

  @override
  State<StockPickingMainScreen> createState() => _StockPickingMainScreenState();
}

class _StockPickingMainScreenState extends State<StockPickingMainScreen> {
  final controller = SidebarXController(selectedIndex: 2, extended: true);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final RxList<StockPickingModel> stockPickings = PrefUtils.stockPicking;
  final RxList<StockPickingModel> filteredStockPickings =
      <StockPickingModel>[].obs;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _applyDefaultFilter();

    ever(stockPickings, (_) => _applyDefaultFilter());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // تحديث البيانات عند العودة للشاشة
    // ✅ تحديث البيانات عند العودة للشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  void _applyDefaultFilter() {
    isAdmin = PrefUtils.user.value.isAdmin ?? false;
    if (isAdmin) {
      filteredStockPickings.assignAll(stockPickings);
    } else {
      filteredStockPickings.assignAll(stockPickings);
    }
  }

  void _refreshData() {
    // ✅ إعادة تطبيق الفلاتر على البيانات المحدثة
    stockPickings.refresh();
    _applyDefaultFilter();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      key: _key,
      backgroundColor: AppColors.background,
      endDrawer: Drawer(
        child: DashboardDrawer(routeName: "Inventory", controller: controller),
      ),
      appBar: isSmallScreen
          ? AppBar(
              elevation: 0,
              backgroundColor: AppColors.cardBackground,
              automaticallyImplyLeading: true,
              centerTitle: true,
              surfaceTintColor: Colors.transparent,
              shadowColor: FunctionalColors.shadow,
              title: Text(
                "Transferts",
                style: GoogleFonts.raleway(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
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
                IconButton(
                  onPressed: _refreshData,
                  icon: Icon(Icons.refresh, color: AppColors.textPrimary),
                  tooltip: 'تحديث البيانات',
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
              child: HorizontalStockPickingTableSection(
                stockPickings: filteredStockPickings,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
