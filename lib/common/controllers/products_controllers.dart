import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/barcodeScannerPage.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

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
