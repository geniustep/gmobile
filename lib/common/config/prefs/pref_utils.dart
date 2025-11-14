import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_move_line/stock_move_line_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/utils/security_helper.dart';
import 'package:gsloution_mobile/src/authentication/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils();

  static SharedPreferences? preferences;
  static double latitude = 0;
  static double longitude = 0;
  static var products = <ProductModel>[].obs;
  static var categoryProduct = <ProductCategoryModel>[].obs;
  static var partners = <PartnerModel>[].obs;
  static var user = UserModel().obs;
  static var sales = <OrderModel>[].obs;
  static var orderLine = <OrderLineModel>[].obs;
  static var accountMove = <AccountMoveModel>[].obs;
  static var listesPrix = <PricelistModel>[].obs;
  static var stockPicking = <StockPickingModel>[].obs;
  static var stockMoveLines = <StockMoveLineModel>[].obs;
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

  static setLatitude(double lat) async {
    latitude = lat;
    return await preferences!.setDouble(PrefKeys.lat, latitude);
  }

  static double getLatitude() {
    if (preferences!.containsKey(PrefKeys.lat)) {
      return preferences!.getDouble(PrefKeys.lat)!;
    }
    return 0;
  }

  static setLongitude(double long) async {
    longitude = long;
    return await preferences!.setDouble(PrefKeys.long, longitude);
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

  // Partners
  static Future<void> setPartners(RxList<PartnerModel> partner) async {
    await initPreferences();
    partners = partner;
    preferences!.setString(PrefKeys.partners, jsonEncode(partner.toList()));
  }

  static Future<RxList<PartnerModel>> getPartners() async {
    await initPreferences();
    var partnersString = preferences!.getString(PrefKeys.partners);
    if (partnersString == null || partnersString.isEmpty) {
      return <PartnerModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(partnersString);
    return RxList(decoded.map((e) => PartnerModel.fromJson(e)).toList());
  }

  static Future<void> updatePartner(PartnerModel updatedPartner) async {
    RxList<PartnerModel> currentPartners = await getPartners();
    int index = currentPartners.indexWhere(
      (partner) => partner.id == updatedPartner.id,
    );
    if (index != -1) {
      currentPartners[index] = updatedPartner;
    } else {
      currentPartners.add(updatedPartner);
    }
    await setPartners(currentPartners);
  }

  // Products
  static Future<void> setProducts(RxList<ProductModel> product) async {
    await initPreferences();
    products = product;
    preferences!.setString(PrefKeys.products, jsonEncode(product.toList()));
  }

  static Future<RxList<ProductModel>> getProducts() async {
    await initPreferences();
    var productsString = preferences!.getString(PrefKeys.products);
    if (productsString == null || productsString.isEmpty) {
      return <ProductModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(productsString);
    return RxList(decoded.map((e) => ProductModel.fromJson(e)).toList());
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

  // sales
  static Future<void> setSales(RxList<OrderModel> saleS) async {
    await initPreferences();
    sales = saleS;
    preferences!.setString(PrefKeys.sales, jsonEncode(saleS.toList()));
  }

  static Future<RxList<OrderModel>> getSales() async {
    await initPreferences();
    var salesString = preferences!.getString(PrefKeys.sales);
    if (salesString == null || salesString.isEmpty) {
      return <OrderModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(salesString);
    return RxList(decoded.map((e) => OrderModel.fromJson(e)).toList());
  }

  static Future<void> saveSales(RxList<OrderModel> saleS) async {
    await initPreferences();
    sales = saleS; // ← تحديث المتغير الثابت في PrefUtils

    // ✅ تحسين الأداء: ضغط البيانات قبل الحفظ
    try {
      final jsonString = jsonEncode(saleS.toList());
      await preferences!.setString(PrefKeys.sales, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving sales: $e');
      }
    }
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
  // StockPicking
  static Future<void> setStockPicking(RxList<StockPickingModel> stock) async {
    await initPreferences();
    stockPicking = stock;
    preferences!.setString(PrefKeys.stockPicking, jsonEncode(stock.toList()));
  }

  static Future<RxList<StockPickingModel>> getStockPicking() async {
    await initPreferences();
    var stock = preferences!.getString(PrefKeys.stockPicking);
    if (stock == null || stock.isEmpty) {
      return <StockPickingModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(stock);
    return RxList(decoded.map((e) => StockPickingModel.fromJson(e)).toList());
  }

  static Future<void> saveStockPicking(RxList<StockPickingModel> stock) async {
    await initPreferences();
    stockPicking.assignAll(stock); // ← تحديث المتغير الثابت في PrefUtils
    await preferences!.setString(
      PrefKeys.stockPicking,
      jsonEncode(stock.toList()),
    );
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
  /// Account Move

  static Future<void> setAccountMove(RxList<AccountMoveModel> account) async {
    await initPreferences();
    accountMove = account;
    preferences!.setString(PrefKeys.accountMove, jsonEncode(account.toList()));
  }

  static Future<RxList<AccountMoveModel>> getAccountMove() async {
    await initPreferences();
    var accountMoveString = preferences!.getString(PrefKeys.accountMove);
    if (accountMoveString == null || accountMoveString.isEmpty) {
      return <AccountMoveModel>[].obs;
    }
    List<dynamic> decoded = jsonDecode(accountMoveString);
    return RxList(decoded.map((e) => AccountMoveModel.fromJson(e)).toList());
  }
}
