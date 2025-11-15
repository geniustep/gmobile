// ════════════════════════════════════════════════════════════
// StorageService - الحل الهجين بين SharedPreferences و Hive
// ════════════════════════════════════════════════════════════
//
// ✅ SharedPreferences: للبيانات الصغيرة السريعة
//    - token, isLoggedIn, user, lat, long
//
// ✅ Hive: للبيانات الكبيرة عالية الأداء
//    - products, partners, sales, categories, etc.
//
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/product_entity.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/partner_entity.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/sale_order_entity.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/user/user_model.dart';
import 'dart:convert';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  late SharedPreferences _prefs;
  final HiveService _hive = HiveService.instance;

  bool _isInitialized = false;

  // ════════════════════════════════════════════════════════════
  // Reactive State (للتوافق مع الكود القديم)
  // ════════════════════════════════════════════════════════════
  var products = <ProductModel>[].obs;
  var partners = <PartnerModel>[].obs;
  var sales = <OrderModel>[].obs;

  // ════════════════════════════════════════════════════════════
  // Initialization
  // ════════════════════════════════════════════════════════════
  Future<void> init() async {
    if (_isInitialized) {
      if (kDebugMode) {
        print('⚠️ StorageService already initialized');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('🚀 Initializing StorageService...');
      }

      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();

      // Initialize Hive
      await _hive.init();

      _isInitialized = true;

      if (kDebugMode) {
        print('✅ StorageService initialized successfully');
        _printStorageInfo();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error initializing StorageService: $e');
      }
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════
  // SharedPreferences Methods (بيانات صغيرة)
  // ════════════════════════════════════════════════════════════

  // ─────── Token ───────
  Future<void> setToken(String token) async {
    await _prefs.setString('token', token);
  }

  Future<String> getToken() async {
    return _prefs.getString('token') ?? '';
  }

  // ─────── IsLoggedIn ───────
  Future<void> setIsLoggedIn(bool value) async {
    await _prefs.setBool('isLoggedIn', value);
  }

  Future<bool> getIsLoggedIn() async {
    return _prefs.getBool('isLoggedIn') ?? false;
  }

  // ─────── User ───────
  Future<void> setUser(UserModel user) async {
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final userString = _prefs.getString('user');
    if (userString == null || userString.isEmpty) return null;

    try {
      final userJson = jsonDecode(userString);
      return UserModel.fromJson(userJson);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error parsing user: $e');
      }
      return null;
    }
  }

  // ─────── Location ───────
  Future<void> setLatitude(double lat) async {
    await _prefs.setDouble('lat', lat);
  }

  double getLatitude() {
    return _prefs.getDouble('lat') ?? 0.0;
  }

  Future<void> setLongitude(double long) async {
    await _prefs.setDouble('long', long);
  }

  double getLongitude() {
    return _prefs.getDouble('long') ?? 0.0;
  }

  // ════════════════════════════════════════════════════════════
  // Hive Methods (بيانات كبيرة)
  // ════════════════════════════════════════════════════════════

  // ─────── Products ───────
  Future<void> setProducts(List<ProductModel> productModels) async {
    // تحويل ProductModel إلى ProductEntity
    final entities = productModels
        .map((model) => ProductEntity.fromModel(model))
        .toList();

    // حفظ في Hive
    await _hive.saveProducts(entities);

    // تحديث الـ Reactive State
    products.value = productModels;

    if (kDebugMode) {
      print('✅ Saved ${entities.length} products (SharedPreferences → Hive)');
    }
  }

  Future<List<ProductModel>> getProducts({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    // جلب من Hive
    final entities = await _hive.getProducts(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
    );

    // تحويل ProductEntity إلى ProductModel
    final models = entities.map((entity) => entity.toModel()).toList();

    // تحديث الـ Reactive State (فقط إذا لم يكن هناك pagination)
    if (limit == null && offset == null && searchQuery == null) {
      products.value = models;
    }

    return models;
  }

  Future<void> clearProducts() async {
    await _hive.clearProducts();
    products.clear();
  }

  int get productsCount => _hive.productsCount;

  // ─────── Partners ───────
  Future<void> setPartners(List<PartnerModel> partnerModels) async {
    final entities = partnerModels
        .map((model) => PartnerEntity.fromModel(model))
        .toList();

    await _hive.savePartners(entities);
    partners.value = partnerModels;

    if (kDebugMode) {
      print('✅ Saved ${entities.length} partners (SharedPreferences → Hive)');
    }
  }

  Future<List<PartnerModel>> getPartners({
    int? limit,
    int? offset,
    String? searchQuery,
  }) async {
    final entities = await _hive.getPartners(
      limit: limit,
      offset: offset,
      searchQuery: searchQuery,
    );

    final models = entities.map((entity) => entity.toModel()).toList();

    if (limit == null && offset == null && searchQuery == null) {
      partners.value = models;
    }

    return models;
  }

  Future<void> updatePartner(PartnerModel partner) async {
    final entity = PartnerEntity.fromModel(partner);
    await _hive.partnersBox.put(entity.id, entity);

    // تحديث في الـ Reactive State
    final index = partners.indexWhere((p) => p.id == partner.id);
    if (index != -1) {
      partners[index] = partner;
    } else {
      partners.add(partner);
    }
  }

  Future<void> clearPartners() async {
    await _hive.clearPartners();
    partners.clear();
  }

  int get partnersCount => _hive.partnersCount;

  // ─────── Sales ───────
  Future<void> setSales(List<OrderModel> saleModels) async {
    final entities = saleModels
        .map((model) => SaleOrderEntity.fromModel(model))
        .toList();

    await _hive.saveSales(entities);
    sales.value = saleModels;

    if (kDebugMode) {
      print('✅ Saved ${entities.length} sales (SharedPreferences → Hive)');
    }
  }

  Future<List<OrderModel>> getSales({
    int? limit,
    int? offset,
  }) async {
    final entities = await _hive.getSales(
      limit: limit,
      offset: offset,
    );

    final models = entities.map((entity) => entity.toModel()).toList();

    if (limit == null && offset == null) {
      sales.value = models;
    }

    return models;
  }

  Future<void> clearSales() async {
    await _hive.clearSales();
    sales.clear();
  }

  int get salesCount => _hive.salesCount;

  // ─────── Generic Data (categories, priceLists, etc.) ───────
  Future<void> saveGenericData(String key, dynamic data) async {
    // نحفظ البيانات العامة كـ JSON string في Hive box عام
    String boxName;
    if (key == 'categoryProduct') {
      boxName = 'categories';
    } else if (key == 'priceLists') {
      boxName = 'priceLists';
    } else if (key == 'stockPicking') {
      boxName = 'stockPicking';
    } else if (key == 'stockMoveLines') {
      boxName = 'stockPicking'; // نفس الـ box
    } else if (key == 'accountMove') {
      boxName = 'accountMove';
    } else if (key == 'paymentTerms') {
      boxName = 'categories'; // نفس الـ box للبيانات الصغيرة
    } else {
      boxName = 'categories'; // default
    }

    await _hive.saveGenericData(boxName, key, jsonEncode(data));
  }

  Future<dynamic> getGenericData(String key) async {
    String boxName;
    if (key == 'categoryProduct') {
      boxName = 'categories';
    } else if (key == 'priceLists') {
      boxName = 'priceLists';
    } else if (key == 'stockPicking') {
      boxName = 'stockPicking';
    } else if (key == 'stockMoveLines') {
      boxName = 'stockPicking';
    } else if (key == 'accountMove') {
      boxName = 'accountMove';
    } else if (key == 'paymentTerms') {
      boxName = 'categories';
    } else {
      boxName = 'categories';
    }

    final data = await _hive.getGenericData(boxName, key);
    if (data == null) return null;

    try {
      return jsonDecode(data);
    } catch (e) {
      return data; // إذا لم تكن JSON
    }
  }

  // ════════════════════════════════════════════════════════════
  // Cache Validity Methods
  // ════════════════════════════════════════════════════════════

  Future<bool> isCacheValid(String key, Duration validity) async {
    return await _hive.isCacheValid(key, validity);
  }

  Future<DateTime?> getLastSync(String key) async {
    return await _hive.getLastSync(key);
  }

  // ════════════════════════════════════════════════════════════
  // Clear All Data
  // ════════════════════════════════════════════════════════════

  Future<void> clearAll() async {
    // مسح SharedPreferences (ما عدا البيانات المهمة)
    await _prefs.clear();

    // مسح Hive
    await _hive.clearAll();

    // مسح Reactive State
    products.clear();
    partners.clear();
    sales.clear();

    if (kDebugMode) {
      print('🗑️ Cleared all data (SharedPreferences + Hive)');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Utility Methods
  // ════════════════════════════════════════════════════════════

  void _printStorageInfo() {
    print('📊 Storage Info:');
    print('   SharedPreferences:');
    print('     - token: ${_prefs.containsKey('token')}');
    print('     - isLoggedIn: ${_prefs.containsKey('isLoggedIn')}');
    print('     - user: ${_prefs.containsKey('user')}');
    print('   Hive:');
    final info = _hive.getStorageInfo();
    info.forEach((key, value) {
      print('     - $key: $value items');
    });
  }

  Map<String, dynamic> getStorageInfo() {
    return {
      'sharedPreferences': {
        'token': _prefs.containsKey('token'),
        'isLoggedIn': _prefs.containsKey('isLoggedIn'),
        'user': _prefs.containsKey('user'),
      },
      'hive': _hive.getStorageInfo(),
    };
  }

  Future<void> close() async {
    await _hive.close();
    _isInitialized = false;
  }
}
