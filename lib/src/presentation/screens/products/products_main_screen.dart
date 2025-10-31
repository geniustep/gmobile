import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
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

class ProductsController extends GetxController {
  final RxString searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;

  final RxBool isSearching = false.obs;
  final RxBool showAllProducts = false.obs;
  final RxBool isGridView = true.obs;
  final RxInt gridColumns = 2.obs;
  final RxBool showOnlyAvailable = true.obs;
  final RxBool isLoading = false.obs;

  TabController? tabController;
  TickerProvider? _vsync;
  final RxList<String> categories = <String>[].obs;
  final RxList<String> visibleCategories = <String>[].obs;

  Timer? _debounceTimer;
  Map<String, int> _categoryCountCache = {};

  void _log(String message) {
    if (kDebugMode) {
      print('[ProductsController] $message');
    }
  }

  void _logError(String message, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [ProductsController] $message');
      print('Error: $error');
      if (stackTrace != null) {
        print('Stack: $stackTrace');
      }
    }
  }

  void initializeController(TickerProvider vsync) {
    try {
      _log('Initializing controller');
      _vsync = vsync;

      if (PrefUtils.products.isEmpty) {
        _log('No products available in PrefUtils');
        isLoading.value = false;
        return;
      }

      products.assignAll(List<ProductModel>.from(PrefUtils.products));
      _log('Loaded ${products.length} products');

      _initializeCategories();
      _createTabController();
      _applyDefaultFilter();
    } catch (e, stackTrace) {
      _logError('Error in initializeController', e, stackTrace);
      isLoading.value = false;
      Get.snackbar(
        'Initialization Error',
        'Failed to load products: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _createTabController() {
    try {
      tabController?.removeListener(_onTabChanged);
      tabController?.dispose();

      if (visibleCategories.isNotEmpty && _vsync != null) {
        tabController = TabController(
          length: visibleCategories.length,
          vsync: _vsync!,
        );
        tabController!.addListener(_onTabChanged);
        _log('TabController created with ${visibleCategories.length} tabs');
      } else {
        tabController = null;
        _log('No visible categories, TabController set to null');
      }
    } catch (e, stackTrace) {
      _logError('Error creating TabController', e, stackTrace);
      tabController = null;
    }
  }

  void _initializeCategories() {
    try {
      _log('Initializing categories');
      final categorySet = <String>{};

      for (final product in products) {
        try {
          final category = _getCategoryName(product);
          categorySet.add(category);
        } catch (e) {
          _logError('Error getting category for product ${product.id}', e);
        }
      }

      categories.assignAll(categorySet.toList()..sort());
      _log('Found ${categories.length} categories');

      _rebuildVisibleCategories();
    } catch (e, stackTrace) {
      _logError('Error in _initializeCategories', e, stackTrace);
      categories.clear();
      visibleCategories.clear();
    }
  }

  void _rebuildVisibleCategories() {
    try {
      _log('Rebuilding visible categories');
      final availableCategories = categories.where((category) {
        return products.any((product) {
          try {
            final matches = _getCategoryName(product) == category;
            final stockOk =
                !showOnlyAvailable.value ||
                (_parseDouble(product.qty_available) > 0);
            return matches && stockOk;
          } catch (e) {
            _logError(
              'Error checking category match for product ${product.id}',
              e,
            );
            return false;
          }
        });
      }).toList();

      final hadCategories = visibleCategories.isNotEmpty;
      visibleCategories.assignAll(availableCategories);
      _log('Visible categories: ${visibleCategories.length}');

      _rebuildCategoryCountCache();

      if (hadCategories != visibleCategories.isNotEmpty ||
          tabController?.length != visibleCategories.length) {
        _createTabController();
      }
    } catch (e, stackTrace) {
      _logError('Error in _rebuildVisibleCategories', e, stackTrace);
      visibleCategories.clear();
    }
  }

  void _rebuildCategoryCountCache() {
    try {
      _categoryCountCache.clear();
      for (final category in visibleCategories) {
        try {
          _categoryCountCache[category] = products.where((product) {
            final matches = _getCategoryName(product) == category;
            final stockOk =
                !showOnlyAvailable.value ||
                (_parseDouble(product.qty_available) > 0);
            return matches && stockOk;
          }).length;
        } catch (e) {
          _logError('Error counting category $category', e);
          _categoryCountCache[category] = 0;
        }
      }
    } catch (e, stackTrace) {
      _logError('Error in _rebuildCategoryCountCache', e, stackTrace);
    }
  }

  String _getCategoryName(ProductModel product) {
    try {
      if (product.categ_id == null || product.categ_id == false) {
        return "Uncategorized";
      }

      if (product.categ_id is List && (product.categ_id as List).length > 1) {
        return (product.categ_id as List)[1]?.toString() ?? "Uncategorized";
      } else if (product.categ_id is Map) {
        return product.categ_id['display_name']?.toString() ?? "Uncategorized";
      }
    } catch (e) {
      _logError('Error getting category name for product ${product.id}', e);
    }
    return "Uncategorized";
  }

  double _parseDouble(dynamic value) {
    try {
      if (value == null || value == false) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
    } catch (e) {
      _logError('Error parsing double from: $value', e);
    }
    return 0.0;
  }

  void _applyDefaultFilter() {
    try {
      _log('Applying default filter');
      if (showAllProducts.value) {
        filteredProducts.assignAll(
          showOnlyAvailable.value
              ? products
                    .where((p) => _parseDouble(p.qty_available) > 0)
                    .toList()
              : products.toList(),
        );
      } else {
        if (visibleCategories.isNotEmpty && tabController != null) {
          final currentIndex = tabController!.index.clamp(
            0,
            visibleCategories.length - 1,
          );
          _filterByCategory(visibleCategories[currentIndex]);
        } else {
          filteredProducts.clear();
        }
      }
      _log('Filtered products: ${filteredProducts.length}');
    } catch (e, stackTrace) {
      _logError('Error in _applyDefaultFilter', e, stackTrace);
      filteredProducts.clear();
    }
  }

  void _filterByCategory(String category) {
    try {
      _log('Filtering by category: $category');
      var list = products.where((product) {
        return _getCategoryName(product) == category;
      }).toList();

      if (showOnlyAvailable.value) {
        list = list.where((p) => _parseDouble(p.qty_available) > 0).toList();
      }

      filteredProducts.assignAll(list);
      _log(
        'Filtered ${filteredProducts.length} products for category $category',
      );
    } catch (e, stackTrace) {
      _logError('Error in _filterByCategory', e, stackTrace);
      filteredProducts.clear();
    }
  }

  void _searchProducts(String query) {
    try {
      _log('Searching for: $query');
      if (query.isEmpty) {
        isSearching.value = false;
        if (!showAllProducts.value &&
            visibleCategories.isNotEmpty &&
            tabController != null) {
          final currentIndex = tabController!.index.clamp(
            0,
            visibleCategories.length - 1,
          );
          _filterByCategory(visibleCategories[currentIndex]);
        } else {
          _applyDefaultFilter();
        }
        return;
      }

      isSearching.value = true;
      final lowerQuery = query.toLowerCase();

      var list = products.where((product) {
        try {
          final nameMatch = (product.name ?? '').toLowerCase().contains(
            lowerQuery,
          );
          final codeMatch = (product.default_code?.toString() ?? '')
              .toLowerCase()
              .contains(lowerQuery);
          final barcodeMatch = (product.barcode is String)
              ? (product.barcode as String).toLowerCase().contains(lowerQuery)
              : false;

          return nameMatch || codeMatch || barcodeMatch;
        } catch (e) {
          _logError('Error searching product ${product.id}', e);
          return false;
        }
      }).toList();

      if (showOnlyAvailable.value) {
        list = list.where((p) => _parseDouble(p.qty_available) > 0).toList();
      }

      filteredProducts.assignAll(list);
      _log('Search results: ${filteredProducts.length} products');
    } catch (e, stackTrace) {
      _logError('Error in _searchProducts', e, stackTrace);
      filteredProducts.clear();
    }
  }

  void onSearchChanged(String value) {
    try {
      searchQuery.value = value;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        _searchProducts(value);
      });
    } catch (e, stackTrace) {
      _logError('Error in onSearchChanged', e, stackTrace);
    }
  }

  void clearSearch() {
    try {
      _log('Clearing search');
      searchController.clear();
      searchQuery.value = '';
      isSearching.value = false;
      _applyDefaultFilter();
    } catch (e, stackTrace) {
      _logError('Error in clearSearch', e, stackTrace);
    }
  }

  Future<void> scanBarcode() async {
    try {
      _log('Starting barcode scan');
      final String? barcode = await Get.to(() => const BarcodeScannerPage());

      if (barcode != null && barcode.isNotEmpty) {
        _log('Barcode scanned: $barcode');
        searchController.text = barcode;
        searchQuery.value = barcode;
        isSearching.value = true;
        _searchProducts(barcode);
      } else {
        _log('Barcode scan cancelled or empty');
      }
    } catch (e, stackTrace) {
      _logError('Error in scanBarcode', e, stackTrace);
      Get.snackbar(
        "Scan Error",
        "Failed to scan barcode: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  void toggleShowAllProducts(bool value) {
    try {
      _log('Toggling show all products: $value');
      showAllProducts.value = value;
      _rebuildVisibleCategories();
      _applyDefaultFilter();
    } catch (e, stackTrace) {
      _logError('Error in toggleShowAllProducts', e, stackTrace);
    }
  }

  void toggleShowOnlyAvailable(bool value) {
    try {
      _log('Toggling show only available: $value');
      showOnlyAvailable.value = value;
      _rebuildVisibleCategories();
      _applyDefaultFilter();
    } catch (e, stackTrace) {
      _logError('Error in toggleShowOnlyAvailable', e, stackTrace);
    }
  }

  void toggleViewMode() {
    try {
      isGridView.value = !isGridView.value;
      _log('View mode: ${isGridView.value ? "Grid" : "List"}');
    } catch (e, stackTrace) {
      _logError('Error in toggleViewMode', e, stackTrace);
    }
  }

  void updateGridColumns(int columns) {
    try {
      gridColumns.value = columns;
      _log('Grid columns updated to: $columns');
    } catch (e, stackTrace) {
      _logError('Error in updateGridColumns', e, stackTrace);
    }
  }

  void _onTabChanged() {
    try {
      if (!isSearching.value &&
          !showAllProducts.value &&
          visibleCategories.isNotEmpty &&
          tabController != null) {
        final currentIndex = tabController!.index.clamp(
          0,
          visibleCategories.length - 1,
        );
        _log('Tab changed to index: $currentIndex');
        _filterByCategory(visibleCategories[currentIndex]);
      }
    } catch (e, stackTrace) {
      _logError('Error in _onTabChanged', e, stackTrace);
    }
  }

  Future<void> handleAddProduct() async {
    try {
      _log('Navigating to add product');
      final dynamic result = await Get.toNamed(AppRoutes.addProduct);

      if (result != null && result is ProductModel) {
        _log('New product added: ${result.name}');
        products.add(result);
        _initializeCategories();
        _applyDefaultFilter();

        Get.snackbar(
          "Success",
          "Product added successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primaryContainer,
          colorText: Get.theme.colorScheme.onPrimaryContainer,
        );
      }
    } catch (e, stackTrace) {
      _logError('Error in handleAddProduct', e, stackTrace);
      Get.snackbar(
        "Error",
        "Failed to add product: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  void refreshProducts() {
    try {
      _log('Refreshing products');
      isLoading.value = true;

      products.assignAll(List<ProductModel>.from(PrefUtils.products));
      _initializeCategories();
      _applyDefaultFilter();

      isLoading.value = false;
      _log('Products refreshed successfully');
    } catch (e, stackTrace) {
      _logError('Error in refreshProducts', e, stackTrace);
      isLoading.value = false;

      Get.snackbar(
        "Refresh Error",
        "Failed to refresh products: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  int getCategoryCount(String category) {
    try {
      return _categoryCountCache[category] ?? 0;
    } catch (e) {
      _logError('Error getting category count for $category', e);
      return 0;
    }
  }

  int get allCount {
    try {
      return showOnlyAvailable.value
          ? products.where((p) => _parseDouble(p.qty_available) > 0).length
          : products.length;
    } catch (e) {
      _logError('Error calculating allCount', e);
      return 0;
    }
  }

  int get availableCount {
    try {
      return products.where((p) => _parseDouble(p.qty_available) > 0).length;
    } catch (e) {
      _logError('Error calculating availableCount', e);
      return 0;
    }
  }

  bool get shouldShowTabs {
    try {
      return !isSearching.value &&
          !showAllProducts.value &&
          visibleCategories.isNotEmpty &&
          tabController != null;
    } catch (e) {
      _logError('Error in shouldShowTabs', e);
      return false;
    }
  }

  @override
  void dispose() {
    try {
      _log('Disposing controller');
      _debounceTimer?.cancel();
      tabController?.removeListener(_onTabChanged);
      tabController?.dispose();
      searchController.dispose();
      super.dispose();
    } catch (e, stackTrace) {
      _logError('Error in dispose', e, stackTrace);
      super.dispose();
    }
  }
}
