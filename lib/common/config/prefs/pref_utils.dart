import 'dart:convert';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/src/authentication/models/user_model.dart';
import 'package:gsloution_mobile/src/home/model/res_partner_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtils {
  PrefUtils();

  static SharedPreferences? preferences;
  static var products = <ProductModel>[].obs;
  static var partners = <PartnerModel>[].obs;

  static Future<void> initPreferences() async {
    preferences ??= await SharedPreferences.getInstance();
  }

  static Future<void> setToken(String token) async {
    await initPreferences();
    await preferences!.setString(PrefKeys.token, token);
  }

  static Future<String> getToken() async {
    await initPreferences();
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

  static Future<void> setUser(String userData) async {
    await initPreferences();
    await preferences!.setString(PrefKeys.user, userData);
  }

  static Future<UserModel> getUser() async {
    await initPreferences();
    Map<String, dynamic> user =
        jsonDecode(preferences!.getString(PrefKeys.user) ?? "{}");
    return UserModel.fromJson(user);
  }

  static Future<void> clearPrefs() async {
    await initPreferences();
    await preferences!.clear();
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
}
