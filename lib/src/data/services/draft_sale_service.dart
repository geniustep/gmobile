import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DraftSaleService {
  static const String _draftKey = 'draft_sales';
  static const String _activeDraftKey = 'active_draft_id';
  static const String _draftLengthKey = 'draft_length';
  static int draftLength = 0;
  static DraftSaleService? _instance;

  static DraftSaleService get instance {
    _instance ??= DraftSaleService._();
    return _instance!;
  }

  DraftSaleService._();

  Future<Map<String, dynamic>?> getDraft(String draftId) async {
    final drafts = await getAllDrafts();
    try {
      return drafts.firstWhere((d) => d['id'] == draftId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? draftsJson = prefs.getString(_draftKey);

    if (draftsJson == null || draftsJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = jsonDecode(draftsJson);
      return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> setActiveDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeDraftKey, draftId);
  }

  Future<String?> getActiveDraftId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeDraftKey);
  }

  Future<void> clearActiveDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeDraftKey);
  }

  Future<Map<String, dynamic>?> getActiveDraft() async {
    final draftId = await getActiveDraftId();
    if (draftId == null) return null;
    return await getDraft(draftId);
  }

  // دالة مساعدة لتحديث عدد الـ drafts
  Future<void> _updateDraftLength(SharedPreferences prefs, int length) async {
    draftLength = length;
    await prefs.setInt(_draftLengthKey, length);
  }

  // دالة لجلب عدد الـ drafts من SharedPreferences
  Future<int> getDraftLength() async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic savedLength = prefs.getInt(_draftLengthKey);

    if (savedLength != null) {
      draftLength = savedLength;
      return draftLength;
    }

    // إذا لم تكن القيمة محفوظة، نحسبها من البيانات الفعلية
    final drafts = await getAllDrafts();
    draftLength = drafts.length;
    await _updateDraftLength(prefs, draftLength);

    return draftLength;
  }

  // دالة تحديث عدد الـ drafts يدوياً
  Future<void> refreshDraftLength() async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();
    await _updateDraftLength(prefs, drafts.length);
  }

  // ✅ إضافة StreamController للبث المباشر
  static final StreamController<int> _draftCountController =
      StreamController<int>.broadcast();

  // دالة للحصول على الـ stream
  static Stream<int> get draftCountStream => _draftCountController.stream;

  // ✅ تحديث جميع دوال الحفظ والحذف لإرسال التحديثات
  Future<String> saveDraft(Map<String, dynamic> draftData) async {
    final prefs = await SharedPreferences.getInstance();

    final String draftId =
        draftData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    draftData['id'] = draftId;
    draftData['lastModified'] = DateTime.now().toIso8601String();

    // ✅ التحقق من وجود بيانات الأسعار المزدوجة وتحديثها إذا لزم الأمر
    _updateDraftPrices(draftData);

    final drafts = await getAllDrafts();
    final index = drafts.indexWhere((d) => d['id'] == draftId);

    if (index != -1) {
      drafts[index] = draftData;
    } else {
      drafts.add(draftData);
    }

    await prefs.setString(_draftKey, jsonEncode(drafts));

    // ✅ تحديث الـ stream مع العدد الجديد
    final newLength = drafts.length;
    await _updateDraftLength(prefs, newLength);
    _draftCountController.add(newLength);

    return draftId;
  }

  // ✅ دالة جديدة لتحديث بيانات الأسعار في المسودة
  void _updateDraftPrices(Map<String, dynamic> draftData) {
    if (draftData['products'] != null && draftData['products'] is List) {
      final List<dynamic> products = draftData['products'];

      for (var product in products) {
        if (product is Map<String, dynamic>) {
          // إذا كان هناك سعر قديم (priceUnit) ولكن لا يوجد displayPrice
          if (product.containsKey('price') &&
              !product.containsKey('displayPrice')) {
            // نسخ السعر القديم إلى displayPrice
            product['displayPrice'] = product['price'];

            // إذا كان هناك فرق في الأسعار، نحتاج لتحديث serverPrice
            if (product.containsKey('hasPriceDifference') &&
                product['hasPriceDifference'] == true) {
              // في هذه الحالة، نحتاج للحفاظ على serverPrice منفصلاً
              // إذا لم يكن موجوداً، نستخدم نفس السعر مؤقتاً
              if (!product.containsKey('serverPrice')) {
                product['serverPrice'] = product['price'];
              }
            } else {
              // لا يوجد فرق، فكل الأسعار متساوية
              product['serverPrice'] = product['price'];
              product['displayPrice'] = product['price'];
            }
          }

          // ✅ إضافة حقل لتتبع وجود فرق في الأسعار
          final displayPrice = product['displayPrice'] ?? product['price'];
          final serverPrice = product['serverPrice'] ?? product['price'];
          product['hasPriceDifference'] = displayPrice != serverPrice;

          // ✅ تسجيل في الـ debug إذا كان هناك فرق
          if (displayPrice != serverPrice) {
            print(
              '💰 Draft Service: Price difference detected for product ${product['productName']}',
            );
            print('   Display: $displayPrice, Server: $serverPrice');
          }
        }
      }
    }
  }

  // ✅ دالة مساعدة لتحضير بيانات المنتج مع الأسعار المزدوجة
  Map<String, dynamic> prepareProductData({
    required int productId,
    required String productName,
    required double quantity,
    required double displayPrice,
    required double serverPrice,
    required double discount,
    required double listPrice,
  }) {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': serverPrice, // الحفاظ على التوافق مع الإصدارات القديمة
      'displayPrice': displayPrice, // السعر المعروض
      'serverPrice': serverPrice, // السعر المرسل
      'discount': discount,
      'listPrice': listPrice,
      'hasPriceDifference': displayPrice != serverPrice,
    };
  }

  Future<void> deleteDraft(String draftId) async {
    final prefs = await SharedPreferences.getInstance();
    final drafts = await getAllDrafts();

    drafts.removeWhere((d) => d['id'] == draftId);
    await prefs.setString(_draftKey, jsonEncode(drafts));

    // ✅ تحديث الـ stream مع العدد الجديد
    final newLength = drafts.length;
    await _updateDraftLength(prefs, newLength);
    _draftCountController.add(newLength);

    final activeDraftId = await getActiveDraftId();
    if (activeDraftId == draftId) {
      await clearActiveDraft();
    }
  }

  Future<void> clearAllDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_draftKey);
    await prefs.remove(_activeDraftKey);

    // ✅ تحديث الـ stream مع العدد الجديد
    await _updateDraftLength(prefs, 0);
    _draftCountController.add(0);
  }

  // ✅ دالة جديدة لتحميل المسودة مع معالجة الأسعار المزدوجة
  Future<Map<String, dynamic>?> loadDraftWithPriceSupport(
    String draftId,
  ) async {
    final draft = await getDraft(draftId);
    if (draft == null) return null;

    // معالجة بيانات المنتجات لضمان دعم الأسعار المزدوجة
    if (draft['products'] != null && draft['products'] is List) {
      final List<dynamic> products = draft['products'];
      final List<dynamic> updatedProducts = [];

      for (var product in products) {
        if (product is Map<String, dynamic>) {
          final updatedProduct = Map<String, dynamic>.from(product);

          // ✅ ضمان وجود جميع حقول الأسعار
          if (!updatedProduct.containsKey('displayPrice')) {
            updatedProduct['displayPrice'] = updatedProduct['price'] ?? 0.0;
          }

          if (!updatedProduct.containsKey('serverPrice')) {
            updatedProduct['serverPrice'] = updatedProduct['price'] ?? 0.0;
          }

          if (!updatedProduct.containsKey('hasPriceDifference')) {
            final displayPrice = updatedProduct['displayPrice'] ?? 0.0;
            final serverPrice = updatedProduct['serverPrice'] ?? 0.0;
            updatedProduct['hasPriceDifference'] = displayPrice != serverPrice;
          }

          updatedProducts.add(updatedProduct);
        }
      }

      draft['products'] = updatedProducts;
    }

    return draft;
  }

  // ✅ دالة للحصول على ملخص الأسعار من المسودة
  Map<String, dynamic> getDraftPriceSummary(Map<String, dynamic> draft) {
    if (draft['products'] == null || draft['products'] is! List) {
      return {
        'displayTotal': 0.0,
        'serverTotal': 0.0,
        'priceDifference': 0.0,
        'productsWithDifference': 0,
        'hasPriceDifference': false,
      };
    }

    double displayTotal = 0.0;
    double serverTotal = 0.0;
    int productsWithDifference = 0;

    final List<dynamic> products = draft['products'];

    for (var product in products) {
      if (product is Map<String, dynamic>) {
        final quantity = (product['quantity'] ?? 1.0).toDouble();
        final displayPrice =
            (product['displayPrice'] ?? product['price'] ?? 0.0).toDouble();
        final serverPrice = (product['serverPrice'] ?? product['price'] ?? 0.0)
            .toDouble();

        displayTotal += displayPrice * quantity;
        serverTotal += serverPrice * quantity;

        if (displayPrice != serverPrice) {
          productsWithDifference++;
        }
      }
    }

    return {
      'displayTotal': displayTotal,
      'serverTotal': serverTotal,
      'priceDifference': displayTotal - serverTotal,
      'productsWithDifference': productsWithDifference,
      'hasPriceDifference': productsWithDifference > 0,
    };
  }

  // ✅ دالة لإرسال تحديث يدوي
  static void notifyDraftCountChanged(int newCount) {
    _draftCountController.add(newCount);
  }

  // ✅ تنظيف الـ stream عند التدمير
  static void dispose() {
    _draftCountController.close();
  }
}
