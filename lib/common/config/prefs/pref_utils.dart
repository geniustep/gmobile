import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_move_line/stock_move_line_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_warehouse/stock_warehouse_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/config/hive/hive_products.dart';
import 'package:gsloution_mobile/common/config/hive/hive_partners.dart';
import 'package:gsloution_mobile/common/config/hive/hive_sales.dart';
import 'package:gsloution_mobile/common/config/hive/hive_account_moves.dart';
import 'package:gsloution_mobile/common/config/hive/hive_stock_picking.dart';
import 'package:gsloution_mobile/common/config/hive/hive_warehouses.dart';
import 'package:gsloution_mobile/common/utils/security_helper.dart';
import 'package:gsloution_mobile/src/authentication/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils();

  static SharedPreferences? preferences;
  static double latitude = 0;
  static double longitude = 0;
  // استخدام المتغيرات من الملفات الجديدة
  static RxList<ProductModel> get products => HiveProducts.products;
  static var categoryProduct = <ProductCategoryModel>[].obs;
  static RxList<PartnerModel> get partners => HivePartners.partners;
  static var user = UserModel().obs;
  static RxList<OrderModel> get sales => HiveSales.sales;
  static var orderLine = <OrderLineModel>[].obs;
  static RxList<AccountMoveModel> get accountMove => HiveAccountMoves.accountMoves;
  static var listesPrix = <PricelistModel>[].obs;
  static RxList<StockPickingModel> get stockPicking => HiveStockPicking.stockPicking;
  static var stockMoveLines = <StockMoveLineModel>[].obs;
  static RxList<StockWarehouseModel> get warehouses => HiveWarehouses.warehouses;
  static List<dynamic> conditionsPaiement = [];

  static Future<void> initPreferences() async {
    preferences ??= await SharedPreferences.getInstance();
  }

  static Future<void> clearPrefs() async {
    await initPreferences();
    await preferences!.clear();
  }

  static Future<void> setToken(String token) async {
    await initPreferences();
    // Encrypt token before saving
    await SecurityHelper.saveEncryptedToken(PrefKeys.token, token);
    // Also save unencrypted for backward compatibility (remove in future)
    await preferences!.setString(PrefKeys.token, token);
  }

  static Future<String> getToken() async {
    await initPreferences();
    // Try to get encrypted token first
    final encryptedToken = await SecurityHelper.getEncryptedToken(PrefKeys.token);
    if (encryptedToken != null && encryptedToken.isNotEmpty) {
      return encryptedToken;
    }
    // Fallback to unencrypted token
    return preferences!.getString(PrefKeys.token) ?? "";
  }

  static Future<void> setIsLoggedIn(bool isLoggedIn) async {
    await initPreferences();
    await preferences!.setBool(PrefKeys.isLoggedIn, isLoggedIn);
  }

  static Future<bool> getIsLoggedIn() async {
    await initPreferences();
    return preferences!.getBool(PrefKeys.isLoggedIn) ?? false;
  }

  // Location

  static Future<void> setLatitude(double lat) async {
    latitude = lat;
    await preferences!.setDouble(PrefKeys.lat, latitude);
  }

  static double getLatitude() {
    if (preferences!.containsKey(PrefKeys.lat)) {
      return preferences!.getDouble(PrefKeys.lat)!;
    }
    return 0;
  }

  static Future<void> setLongitude(double long) async {
    longitude = long;
    await preferences!.setDouble(PrefKeys.long, longitude);
  }

  static double getLongitude() {
    if (preferences!.containsKey(PrefKeys.long)) {
      return preferences!.getDouble(PrefKeys.long)!;
    }
    return 0;
  }

  // Users
  static Future<void> setUser(String userData) async {
    await initPreferences();
    await preferences!.setString(PrefKeys.user, userData);
  }

  static Future<UserModel> getUser() async {
    await initPreferences();
    Map<String, dynamic> getUser = jsonDecode(
      preferences!.getString(PrefKeys.user) ?? "{}",
    );
    user.value = UserModel.fromJson(getUser);
    return user.value;
  }

  // Partners - باستخدام HivePartners
  static Future<void> setPartners(RxList<PartnerModel> partner) async {
    await HivePartners.setPartners(partner);
  }

  static Future<RxList<PartnerModel>> getPartners() async {
    return await HivePartners.getPartners();
  }

  static Future<void> updatePartner(PartnerModel updatedPartner) async {
    await HivePartners.updatePartner(updatedPartner);
  }

  // Products - باستخدام HiveProducts
  static Future<void> setProducts(RxList<ProductModel> product) async {
    await HiveProducts.setProducts(product);
  }

  static Future<RxList<ProductModel>> getProducts() async {
    return await HiveProducts.getProducts();
  }

  // Category Product
  static Future<void> setCatgProducts(
    RxList<ProductCategoryModel> productCtgy,
  ) async {
    await initPreferences();
    categoryProduct = productCtgy;
    preferences!.setString(
      PrefKeys.categoryProduct,
      jsonEncode(productCtgy.toList()),
    );
  }

  static Future<RxList<ProductCategoryModel>> getCatgProducts() async {
    await initPreferences();
    var productsString = preferences!.getString(PrefKeys.categoryProduct);
    if (productsString == null || productsString.isEmpty) {
      return <ProductCategoryModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(productsString);
    return RxList(
      decoded.map((e) => ProductCategoryModel.fromJson(e)).toList(),
    );
  }

  // Sales - باستخدام HiveSales
  static Future<void> setSales(RxList<OrderModel> saleS) async {
    await HiveSales.setSales(saleS);
  }

  static Future<RxList<OrderModel>> getSales() async {
    return await HiveSales.getSales();
  }

  static Future<void> saveSales(RxList<OrderModel> saleS) async {
    await HiveSales.saveSales(saleS);
  }

  // salesLine
  static Future<void> setSalesLine(RxList<OrderLineModel> salesLine) async {
    await initPreferences();
    orderLine = salesLine;
    preferences!.setString(PrefKeys.salesLine, jsonEncode(salesLine.toList()));
  }

  static Future<RxList<OrderLineModel>> getSalesLine() async {
    await initPreferences();
    var salesString = preferences!.getString(PrefKeys.salesLine);
    if (salesString == null || salesString.isEmpty) {
      return <OrderLineModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(salesString);
    return RxList(decoded.map((e) => OrderLineModel.fromJson(e)).toList());
  }

  // =======================
  // Payment Terms (Conditions de paiement)
  // =======================

  static Future<void> setPaymentTerms(List<dynamic> paymentTerms) async {
    await initPreferences();
    conditionsPaiement = paymentTerms;
    preferences!.setString(PrefKeys.paymentTerms, jsonEncode(paymentTerms));
  }

  static Future<List<dynamic>> getPaymentTerms() async {
    await initPreferences();
    var termsString = preferences!.getString(PrefKeys.paymentTerms);
    if (termsString == null || termsString.isEmpty) {
      return [];
    }
    return jsonDecode(termsString);
  }

  // =======================
  // Price Lists (Listes de prix)
  // =======================
  // في ملف pref_utils.dart - تحديث دوال Price Lists

  static Future<void> setPriceLists(RxList<PricelistModel> priceLists) async {
    await initPreferences();
    listesPrix.assignAll(priceLists);

    // تحويل إلى JSON مع حفظ جميع البيانات بما في ذلك items
    List<Map<String, dynamic>> priceListsJson = priceLists.map((pricelist) {
      Map<String, dynamic> json = pricelist.toJson();

      // التأكد من حفظ items
      if (pricelist.items != null) {
        json['items'] = pricelist.items!.map((item) => item.toJson()).toList();
      }

      return json;
    }).toList();

    await preferences!.setString(
      PrefKeys.priceLists,
      jsonEncode(priceListsJson),
    );

    if (kDebugMode) {
      print('✅ Price lists saved to SharedPreferences: ${priceLists.length}');
    }
  }

  static Future<RxList<PricelistModel>> getPriceLists() async {
    await initPreferences();
    var listsString = preferences!.getString(PrefKeys.priceLists);

    if (listsString == null || listsString.isEmpty) {
      return <PricelistModel>[].obs;
    }

    try {
      List<dynamic> decoded = jsonDecode(listsString);
      List<PricelistModel> pricelists = decoded.map((json) {
        PricelistModel pricelist = PricelistModel.fromJson(json);

        // استرجاع items من JSON
        if (json['items'] != null && json['items'] is List) {
          pricelist.items = (json['items'] as List)
              .map((itemJson) => PricelistItem.fromJson(itemJson))
              .toList();
        }

        return pricelist;
      }).toList();

      if (kDebugMode) {
        print(
          '✅ Price lists loaded from SharedPreferences: ${pricelists.length}',
        );
        int totalItems = pricelists.fold(
          0,
          (sum, p) => sum + (p.items?.length ?? 0),
        );
        print('   Total pricelist items: $totalItems');
      }

      return RxList(pricelists);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading price lists from SharedPreferences: $e');
      }
      return <PricelistModel>[].obs;
    }
  }

  static Future<void> updatePriceList(PricelistModel updatedPriceList) async {
    RxList<PricelistModel> currentPriceLists = await getPriceLists();

    int index = currentPriceLists.indexWhere(
      (priceList) => priceList.id == updatedPriceList.id,
    );

    if (index != -1) {
      currentPriceLists[index] = updatedPriceList;
    } else {
      currentPriceLists.add(updatedPriceList);
    }

    await setPriceLists(currentPriceLists);
  }

  static Future<void> savePriceLists(RxList<PricelistModel> priceLists) async {
    await setPriceLists(priceLists);
  }

  ////////// Stock ////
  // StockPicking - باستخدام HiveStockPicking
  static Future<void> setStockPicking(RxList<StockPickingModel> stock) async {
    await HiveStockPicking.setStockPicking(stock);
  }

  static Future<RxList<StockPickingModel>> getStockPicking() async {
    return await HiveStockPicking.getStockPicking();
  }

  static Future<void> saveStockPicking(RxList<StockPickingModel> stock) async {
    await HiveStockPicking.saveStockPicking(stock);
  }

  // StockMoveLines
  static Future<void> setStockMoveLines(
    RxList<StockMoveLineModel> lines,
  ) async {
    await initPreferences();
    stockMoveLines = lines;
    preferences!.setString(PrefKeys.stockMoveLines, jsonEncode(lines.toList()));
  }

  static Future<RxList<StockMoveLineModel>> getStockMoveLines() async {
    await initPreferences();
    var lines = preferences!.getString(PrefKeys.stockMoveLines);
    if (lines == null || lines.isEmpty) {
      return <StockMoveLineModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(lines);
    return RxList(decoded.map((e) => StockMoveLineModel.fromJson(e)).toList());
  }

  static Future<void> saveStockMoveLines(
    RxList<StockMoveLineModel> lines,
  ) async {
    await initPreferences();
    stockMoveLines.assignAll(lines);
    await preferences!.setString(
      PrefKeys.stockMoveLines,
      jsonEncode(lines.toList()),
    );
  }

  ////// ***** Invoice ****** //////
  /// Account Move - باستخدام HiveAccountMoves
  static Future<void> setAccountMove(RxList<AccountMoveModel> account) async {
    await HiveAccountMoves.setAccountMoves(account);
  }

  static Future<RxList<AccountMoveModel>> getAccountMove() async {
    return await HiveAccountMoves.getAccountMoves();
  }

  ////////// Warehouses - باستخدام HiveWarehouses ////
  static Future<void> setWarehouses(RxList<StockWarehouseModel> warehouseList) async {
    await HiveWarehouses.setWarehouses(warehouseList);
  }

  static Future<RxList<StockWarehouseModel>> getWarehouses() async {
    return await HiveWarehouses.getWarehouses();
  }
}
