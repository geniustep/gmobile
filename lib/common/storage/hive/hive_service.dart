// ════════════════════════════════════════════════════════════
// HiveService - إدارة مركزية لجميع Hive Boxes
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/product_entity.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/partner_entity.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/sale_order_entity.dart';

class HiveService {
  HiveService._();

  static final HiveService instance = HiveService._();

  // ════════════════════════════════════════════════════════════
  // Box Names
  // ════════════════════════════════════════════════════════════
  static const String _productsBox = 'products';
  static const String _partnersBox = 'partners';
  static const String _salesBox = 'sales';
  static const String _categoriesBox = 'categories';
  static const String _priceListsBox = 'priceLists';
  static const String _stockPickingBox = 'stockPicking';
  static const String _accountMoveBox = 'accountMove';
  static const String _warehousesBox = 'warehouses';
  static const String _cacheBox = 'cache';
  static const String _metadataBox = 'metadata'; // للتخزين التوقيت وغيره

  // ════════════════════════════════════════════════════════════
  // Boxes
  // ════════════════════════════════════════════════════════════
  late Box<ProductEntity> productsBox;
  late Box<PartnerEntity> partnersBox;
  late Box<SaleOrderEntity> salesBox;
  late Box<dynamic> categoriesBox; // Generic box للبيانات البسيطة
  late Box<dynamic> priceListsBox;
  late Box<dynamic> stockPickingBox;
  late Box<dynamic> accountMoveBox;
  late Box<dynamic> warehousesBox;
  late Box<dynamic> cacheBox;
  late Box<dynamic> metadataBox;

  bool _isInitialized = false;

  // ════════════════════════════════════════════════════════════
  // Initialization
  // ════════════════════════════════════════════════════════════
  Future<void> init() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ HiveService already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🔧 Initializing HiveService...');
      }

      // Initialize Hive
      await Hive.initFlutter();

      // Register Adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ProductEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PartnerEntityAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(SaleOrderEntityAdapter());
      }

      // Open Boxes
      productsBox = await Hive.openBox<ProductEntity>(_productsBox);
      partnersBox = await Hive.openBox<PartnerEntity>(_partnersBox);
      salesBox = await Hive.openBox<SaleOrderEntity>(_salesBox);
      categoriesBox = await Hive.openBox(_categoriesBox);
      priceListsBox = await Hive.openBox(_priceListsBox);
      stockPickingBox = await Hive.openBox(_stockPickingBox);
      accountMoveBox = await Hive.openBox(_accountMoveBox);
      warehousesBox = await Hive.openBox(_warehousesBox);
      cacheBox = await Hive.openBox(_cacheBox);
      metadataBox = await Hive.openBox(_metadataBox);

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ HiveService initialized successfully');
        print('   Products: ${productsBox.length} items');
        print('   Partners: ${partnersBox.length} items');
        print('   Sales: ${salesBox.length} items');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing HiveService: $e');
      }
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Products Methods
  // ════════════════════════════════════════════════════════════

  /// حفظ منتجات متعددة
  Future<void> saveProducts(List<ProductEntity> products) async {
    await _ensureInitialized();

    final batch = <int, ProductEntity>{};
    for (var product in products) {
      batch[product.id] = product;
    }

    await productsBox.putAll(batch);
    await _updateLastSync('products');

    if (kDebugMode) {
      print('✅ Saved ${products.length} products to Hive');
    }
  }

  /// جلب جميع المنتجات (مع pagination اختياري)
  Future<List<ProductEntity>> getProducts({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    await _ensureInitialized();

    var products = productsBox.values.toList();

    // البحث
    if (searchQuery != null && searchQuery.isNotEmpty) {
      products = products
          .where((p) => p.matchesSearch(searchQuery))
          .toList();
    }

    // Pagination
    if (offset != null && offset > 0) {
      products = products.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      products = products.take(limit).toList();
    }

    return products;
  }

  /// جلب منتج بالـ ID
  Future<ProductEntity?> getProductById(int id) async {
    await _ensureInitialized();
    return productsBox.get(id);
  }

  /// حذف جميع المنتجات
  Future<void> clearProducts() async {
    await _ensureInitialized();
    await productsBox.clear();
    if (kDebugMode) {
      print('🗑️ Cleared all products');
    }
  }

  /// عدد المنتجات
  int get productsCount => productsBox.length;

  // ════════════════════════════════════════════════════════════
  // Partners Methods
  // ════════════════════════════════════════════════════════════

  Future<void> savePartners(List<PartnerEntity> partners) async {
    await _ensureInitialized();

    final batch = <int, PartnerEntity>{};
    for (var partner in partners) {
      batch[partner.id] = partner;
    }

    await partnersBox.putAll(batch);
    await _updateLastSync('partners');

    if (kDebugMode) {
      print('✅ Saved ${partners.length} partners to Hive');
    }
  }

  Future<List<PartnerEntity>> getPartners({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    await _ensureInitialized();

    var partners = partnersBox.values.toList();

    if (searchQuery != null && searchQuery.isNotEmpty) {
      partners = partners
          .where((p) => p.matchesSearch(searchQuery))
          .toList();
    }

    if (offset != null && offset > 0) {
      partners = partners.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      partners = partners.take(limit).toList();
    }

    return partners;
  }

  Future<PartnerEntity?> getPartnerById(int id) async {
    await _ensureInitialized();
    return partnersBox.get(id);
  }

  Future<void> clearPartners() async {
    await _ensureInitialized();
    await partnersBox.clear();
  }

  int get partnersCount => partnersBox.length;

  // ════════════════════════════════════════════════════════════
  // Sales Methods
  // ════════════════════════════════════════════════════════════

  Future<void> saveSales(List<SaleOrderEntity> sales) async {
    await _ensureInitialized();

    final batch = <int, SaleOrderEntity>{};
    for (var sale in sales) {
      batch[sale.id] = sale;
    }

    await salesBox.putAll(batch);
    await _updateLastSync('sales');

    if (kDebugMode) {
      print('✅ Saved ${sales.length} sales to Hive');
    }
  }

  Future<List<SaleOrderEntity>> getSales({
    int? limit,
    int? offset,
  }) async {
    await _ensureInitialized();

    var sales = salesBox.values.toList();

    if (offset != null && offset > 0) {
      sales = sales.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      sales = sales.take(limit).toList();
    }

    return sales;
  }

  Future<SaleOrderEntity?> getSaleById(int id) async {
    await _ensureInitialized();
    return salesBox.get(id);
  }

  Future<void> clearSales() async {
    await _ensureInitialized();
    await salesBox.clear();
  }

  int get salesCount => salesBox.length;

  // ════════════════════════════════════════════════════════════
  // Generic Methods للبيانات الأخرى (categories, priceLists, etc.)
  // ════════════════════════════════════════════════════════════

  Future<void> saveGenericData(String boxName, String key, dynamic data) async {
    await _ensureInitialized();

    Box box;
    switch (boxName) {
      case 'categories':
        box = categoriesBox;
        break;
      case 'priceLists':
        box = priceListsBox;
        break;
      case 'stockPicking':
        box = stockPickingBox;
        break;
      case 'accountMove':
        box = accountMoveBox;
        break;
      case 'warehouses':
        box = warehousesBox;
        break;
      case 'cache':
        box = cacheBox;
        break;
      default:
        throw Exception('Unknown box: $boxName');
    }

    await box.put(key, data);
    await _updateLastSync(boxName);
  }

  Future<dynamic> getGenericData(String boxName, String key) async {
    await _ensureInitialized();

    Box box;
    switch (boxName) {
      case 'categories':
        box = categoriesBox;
        break;
      case 'priceLists':
        box = priceListsBox;
        break;
      case 'stockPicking':
        box = stockPickingBox;
        break;
      case 'accountMove':
        box = accountMoveBox;
        break;
      case 'warehouses':
        box = warehousesBox;
        break;
      case 'cache':
        box = cacheBox;
        break;
      default:
        throw Exception('Unknown box: $boxName');
    }

    return box.get(key);
  }

  /// مسح box معين
  Future<void> clearBox(String boxName) async {
    await _ensureInitialized();

    Box box;
    switch (boxName) {
      case 'categories':
        box = categoriesBox;
        break;
      case 'priceLists':
        box = priceListsBox;
        break;
      case 'stockPicking':
        box = stockPickingBox;
        break;
      case 'accountMove':
        box = accountMoveBox;
        break;
      case 'warehouses':
        box = warehousesBox;
        break;
      case 'cache':
        box = cacheBox;
        break;
      default:
        throw Exception('Unknown box: $boxName');
    }

    await box.clear();
    if (kDebugMode) {
      print('🗑️ Cleared box: $boxName');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Account Moves Methods
  // ════════════════════════════════════════════════════════════

  Future<void> saveAccountMoves(List<dynamic> accountMoves) async {
    await _ensureInitialized();
    
    final batch = <String, dynamic>{};
    for (var accountMove in accountMoves) {
      final id = accountMove['id'] ?? accountMove.id;
      if (id != null) {
        batch[id.toString()] = accountMove;
      }
    }
    
    await accountMoveBox.putAll(batch);
    await _updateLastSync('accountMove');
    
    if (kDebugMode) {
      print('✅ Saved ${accountMoves.length} account moves to Hive');
    }
  }

  Future<List<dynamic>> getAccountMoves({int? limit, int? offset}) async {
    await _ensureInitialized();
    
    var accountMoves = accountMoveBox.values.toList();
    
    if (offset != null && offset > 0) {
      accountMoves = accountMoves.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      accountMoves = accountMoves.take(limit).toList();
    }
    
    return accountMoves;
  }

  Future<void> clearAccountMoves() async {
    await _ensureInitialized();
    await accountMoveBox.clear();
  }

  int get accountMovesCount => accountMoveBox.length;

  // ════════════════════════════════════════════════════════════
  // Stock Picking Methods
  // ════════════════════════════════════════════════════════════

  Future<void> saveStockPicking(List<dynamic> stockPickingList) async {
    await _ensureInitialized();
    
    final batch = <String, dynamic>{};
    for (var picking in stockPickingList) {
      final id = picking['id'] ?? picking.id;
      if (id != null) {
        batch[id.toString()] = picking;
      }
    }
    
    await stockPickingBox.putAll(batch);
    await _updateLastSync('stockPicking');
    
    if (kDebugMode) {
      print('✅ Saved ${stockPickingList.length} stock pickings to Hive');
    }
  }

  Future<List<dynamic>> getStockPicking({int? limit, int? offset}) async {
    await _ensureInitialized();
    
    var stockPickingList = stockPickingBox.values.toList();
    
    if (offset != null && offset > 0) {
      stockPickingList = stockPickingList.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      stockPickingList = stockPickingList.take(limit).toList();
    }
    
    return stockPickingList;
  }

  Future<void> clearStockPicking() async {
    await _ensureInitialized();
    await stockPickingBox.clear();
  }

  int get stockPickingCount => stockPickingBox.length;

  // ════════════════════════════════════════════════════════════
  // Warehouses Methods
  // ════════════════════════════════════════════════════════════

  Future<void> saveWarehouses(List<dynamic> warehouses) async {
    await _ensureInitialized();
    
    final batch = <String, dynamic>{};
    for (var warehouse in warehouses) {
      final id = warehouse['id'] ?? warehouse.id;
      if (id != null) {
        batch[id.toString()] = warehouse;
      }
    }
    
    await warehousesBox.putAll(batch);
    await _updateLastSync('warehouses');
    
    if (kDebugMode) {
      print('✅ Saved ${warehouses.length} warehouses to Hive');
    }
  }

  Future<List<dynamic>> getWarehouses({int? limit, int? offset}) async {
    await _ensureInitialized();
    
    var warehousesList = warehousesBox.values.toList();
    
    if (offset != null && offset > 0) {
      warehousesList = warehousesList.skip(offset).toList();
    }
    if (limit != null && limit > 0) {
      warehousesList = warehousesList.take(limit).toList();
    }
    
    return warehousesList;
  }

  Future<void> clearWarehouses() async {
    await _ensureInitialized();
    await warehousesBox.clear();
  }

  int get warehousesCount => warehousesBox.length;

  // ════════════════════════════════════════════════════════════
  // Metadata & Sync Tracking
  // ════════════════════════════════════════════════════════════

  Future<void> _updateLastSync(String key) async {
    await metadataBox.put('lastSync_$key', DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSync(String key) async {
    await _ensureInitialized();
    final value = metadataBox.get('lastSync_$key');
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  /// التحقق من صلاحية الـ Cache
  Future<bool> isCacheValid(String key, Duration validity) async {
    final lastSync = await getLastSync(key);
    if (lastSync == null) return false;
    return DateTime.now().difference(lastSync) < validity;
  }

  // ════════════════════════════════════════════════════════════
  // Utility Methods
  // ════════════════════════════════════════════════════════════

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await init();
    }
  }

  /// مسح كل البيانات
  Future<void> clearAll() async {
    await _ensureInitialized();

    await productsBox.clear();
    await partnersBox.clear();
    await salesBox.clear();
    await categoriesBox.clear();
    await priceListsBox.clear();
    await stockPickingBox.clear();
    await accountMoveBox.clear();
    await warehousesBox.clear();
    await cacheBox.clear();
    await metadataBox.clear();

    if (kDebugMode) {
      print('🗑️ Cleared all Hive data');
    }
  }

  /// إغلاق جميع الـ Boxes
  Future<void> close() async {
    if (!_isInitialized) return;

    await Hive.close();
    _isInitialized = false;

    if (kDebugMode) {
      print('🔒 HiveService closed');
    }
  }

  /// معلومات عن حجم البيانات
  Map<String, int> getStorageInfo() {
    return {
      'products': productsBox.length,
      'partners': partnersBox.length,
      'sales': salesBox.length,
      'categories': categoriesBox.length,
      'priceLists': priceListsBox.length,
      'stockPicking': stockPickingBox.length,
      'accountMove': accountMoveBox.length,
      'warehouses': warehousesBox.length,
    };
  }
}
