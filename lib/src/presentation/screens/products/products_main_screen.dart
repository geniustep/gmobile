import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/controllers/products_controllers.dart';
import 'package:gsloution_mobile/common/widgets/barcodeScannerPage.dart';
import 'package:gsloution_mobile/src/presentation/screens/products/products_sections/product-list_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_app_bar_badge.dart';
import 'package:gsloution_mobile/src/presentation/widgets/drawer/dashboard_drawer.dart';
import 'package:gsloution_mobile/src/presentation/widgets/floating_aciton_button/custom_floating_action_button.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:sidebarx/sidebarx.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ProductsMainScreen extends StatefulWidget {
  const ProductsMainScreen({super.key});

  @override
  State<ProductsMainScreen> createState() => _ProductsMainScreenState();
}

class _ProductsMainScreenState extends State<ProductsMainScreen>
    with TickerProviderStateMixin {
  late final ProductsController _controller;
  final SidebarXController _sidebarController = SidebarXController(
    selectedIndex: 1,
    extended: true,
  );
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    try {
      _controller = Get.put(ProductsController());
      _controller.initializeController(this);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error initializing ProductsController: $e');
        print('Stack: $stackTrace');
      }
      Get.snackbar(
        'Initialization Error',
        'Failed to initialize products screen',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    try {
      Get.delete<ProductsController>();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error disposing ProductsController: $e');
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Products'),
          actions: [
            DraftAppBarBadge(
              showOnlyWhenHasDrafts: true,
              iconColor: FunctionalColors.iconPrimary,
              badgeColor: Colors.orange,
            ),
            IconButton(
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
              icon: Icon(Icons.list),
            ),
          ],
        ),
        key: _scaffoldKey,
        endDrawer: DashboardDrawer(
          routeName: "Products",
          controller: _sidebarController,
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            _buildFilterSection(colorScheme),
            _buildSearchBar(colorScheme),
            _buildCategoryTabs(colorScheme),
            _buildProductList(),
          ],
        ),
        floatingActionButton: CustomFloatingActionButton(
          buttonName: "Add Product",
          routeName: AppRoutes.addProduct,
          onTap: _controller.handleAddProduct,
        ),
      ),
    );
  }

  Widget _buildFilterSection(ColorScheme colorScheme) {
    return Obx(() {
      try {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
              _buildFilterChip(
                label: "Show All",
                count: _controller.allCount,
                isSelected: _controller.showAllProducts.value,
                onSelected: () => _controller.toggleShowAllProducts(
                  !_controller.showAllProducts.value,
                ),
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 12),
              _buildFilterChip(
                label: "Available Only",
                count: _controller.availableCount,
                isSelected: _controller.showOnlyAvailable.value,
                onSelected: () => _controller.toggleShowOnlyAvailable(
                  !_controller.showOnlyAvailable.value,
                ),
                colorScheme: colorScheme,
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _controller.isGridView.value
                      ? Icons.view_list
                      : Icons.grid_view,
                  color: colorScheme.primary,
                ),
                tooltip: _controller.isGridView.value
                    ? "Switch to List View"
                    : "Switch to Grid View",
                onPressed: _controller.toggleViewMode,
              ),
              if (_controller.isGridView.value)
                PopupMenuButton<int>(
                  icon: Icon(Icons.view_column, color: colorScheme.primary),
                  tooltip: "Grid Columns",
                  onSelected: _controller.updateGridColumns,
                  itemBuilder: (context) => [
                    if (_controller.gridColumns.value != 1)
                      PopupMenuItem(
                        value: 1,
                        child: Row(
                          children: [
                            Icon(
                              Icons.view_agenda,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text("1 Column"),
                          ],
                        ),
                      ),
                    if (_controller.gridColumns.value != 2)
                      PopupMenuItem(
                        value: 2,
                        child: Row(
                          children: [
                            Icon(
                              Icons.view_module,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text("2 Columns"),
                          ],
                        ),
                      ),
                  ],
                ),
            ],
          ),
        );
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ Error building filter section: $e');
          print('Stack: $stackTrace');
        }
        return const SizedBox.shrink();
      }
    });
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onSelected,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller.searchController,
              onChanged: _controller.onSearchChanged,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                suffixIcon: Obx(
                  () => _controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.error),
                          onPressed: _controller.clearSearch,
                        )
                      : const SizedBox.shrink(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
                hintText: "Search by name, code, or barcode...",
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _controller.scanBarcode,
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.qr_code_scanner,
                  color: colorScheme.onPrimaryContainer,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ColorScheme colorScheme) {
    return Obx(() {
      try {
        if (_controller.shouldShowTabs && _controller.tabController != null) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              controller: _controller.tabController,
              isScrollable: true,
              indicatorColor: colorScheme.primary,
              indicatorWeight: 3,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: _controller.visibleCategories.map((category) {
                final count = _controller.getCategoryCount(category);
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(category, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('❌ Error building category tabs: $e');
          print('Stack: $stackTrace');
        }
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildProductList() {
    return Expanded(
      child: Obx(() {
        try {
          if (_controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            );
          }

          if (_controller.filteredProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.searchQuery.value.isNotEmpty
                        ? "No products match your search"
                        : "No products available",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 80.0),
            child: ProductListSection(
              isSmallScreen: MediaQuery.of(context).size.width < 600,
              productList: _controller.filteredProducts,
              isGridView: _controller.isGridView.value,
              gridColumns: _controller.gridColumns.value,
            ),
          );
        } catch (e, stackTrace) {
          if (kDebugMode) {
            print('❌ Error building product list: $e');
            print('Stack: $stackTrace');
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading products',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _controller.refreshProducts(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }
      }),
    );
  }
}
