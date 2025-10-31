// في ملف pricelist_module.dart - تحديث

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';

class PricelistModule {
  PricelistModule._();

  /// 🔹 جلب جميع لوائح الأسعار مع عناصرها وحفظها محلياً
  static searchReadPricelists<T>({OnResponse? onResponse}) async {
    try {
      await Api.callKW(
        model: "product.pricelist",
        method: "search_read",
        args: [],
        kwargs: {
          "domain": [
            ["active", "=", true],
          ],
          "fields": [
            "id",
            "name",
            "currency_id",
            "active",
            "country_group_ids",
            "item_ids",
            "display_name",
          ],
        },
        onResponse: (response) async {
          List<PricelistModel> pricelists = [];

          for (var element in response) {
            var pricelist = PricelistModel.fromJson(element);

            // تحميل عناصر قائمة الأسعار
            if (pricelist.itemIds != null && pricelist.itemIds!.isNotEmpty) {
              await _loadPricelistItems(
                itemIds: pricelist.itemIds!,
                onItemsLoaded: (items) {
                  pricelist.items = items;
                },
              );
            }

            pricelists.add(pricelist);
          }

          // حفظ قوائم الأسعار في SharedPreferences
          await PrefUtils.setPriceLists(pricelists.obs);

          if (kDebugMode) {
            print("✅ Pricelists loaded and saved: ${pricelists.length}");
            int totalItems = pricelists.fold(
              0,
              (sum, p) => sum + (p.items?.length ?? 0),
            );
            print("   Total pricelist items: $totalItems");
          }

          onResponse?.call(pricelists);
        },
        onError: (error, data) {
          if (kDebugMode) {
            print("❌ Error getting pricelists: $error");
          }
          handleApiError(error);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error getting pricelists: $e");
      }
    }
  }

  static Future<void> _loadPricelistItems({
    required List<int> itemIds,
    required Function(List<PricelistItem>) onItemsLoaded,
  }) async {
    try {
      await Api.callKW(
        model: "product.pricelist.item",
        method: "read",
        args: [itemIds],
        kwargs: {
          "fields": [
            "id",
            "product_tmpl_id",
            "name",
            "price",
            "min_quantity",
            "date_start",
            "date_end",
            "base",
            "price_discount",
            "applied_on",
            "compute_price",
          ],
        },
        onResponse: (response) {
          List<PricelistItem> items = [];
          for (var element in response) {
            items.add(PricelistItem.fromJson(element));
          }
          onItemsLoaded(items);
        },
        onError: (error, data) {
          if (kDebugMode) {
            print("❌ Error loading pricelist items: $error");
          }
          onItemsLoaded([]);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading pricelist items: $e");
      }
      onItemsLoaded([]);
    }
  }

  /// 🔹 تحميل قوائم الأسعار من SharedPreferences
  static Future<List<PricelistModel>> loadPricelistsFromLocal() async {
    try {
      final pricelists = await PrefUtils.getPriceLists();

      if (kDebugMode) {
        print("✅ Pricelists loaded from local: ${pricelists.length}");
        int totalItems = pricelists.fold(
          0,
          (sum, p) => sum + (p.items?.length ?? 0),
        );
        print("   Total pricelist items: $totalItems");
      }

      return pricelists.toList();
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error loading pricelists from local: $e");
      }
      return [];
    }
  }

  /// 🔹 تحديث قائمة أسعار محلياً
  static Future<void> updateLocalPricelist(PricelistModel pricelist) async {
    await PrefUtils.updatePriceList(pricelist);
  }

  /// 🔹 إعادة تحميل قوائم الأسعار من السيرفر
  static Future<void> refreshPricelists({OnResponse? onResponse}) async {
    await searchReadPricelists(onResponse: onResponse);
  }

  static readPricelists({
    required List<int> ids,
    required OnResponse<List<PricelistModel>> onResponse,
  }) async {
    try {
      await Api.callKW(
        model: "product.pricelist",
        method: "read",
        args: [ids],
        kwargs: {
          "fields": [
            "id",
            "name",
            "currency_id",
            "active",
            "country_group_ids",
            "item_ids",
            "display_name",
          ],
        },
        onResponse: (response) async {
          List<PricelistModel> pricelists = [];

          for (var element in response) {
            var pricelist = PricelistModel.fromJson(element);

            if (pricelist.itemIds != null && pricelist.itemIds!.isNotEmpty) {
              await _loadPricelistItems(
                itemIds: pricelist.itemIds!,
                onItemsLoaded: (items) {
                  pricelist.items = items;
                },
              );
            }

            pricelists.add(pricelist);
          }

          onResponse(pricelists);
        },
        onError: (error, data) {
          handleApiError(error);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("❌ Error reading pricelists: $e");
      }
    }
  }

  static createPricelist({
    required Map<String, dynamic>? maps,
    required OnResponse<PricelistModel> onResponse,
  }) {
    Api.create(
      model: "product.pricelist",
      values: maps!,
      onResponse: (responseId) {
        readPricelists(
          ids: [responseId],
          onResponse: (responsePricelists) async {
            final created = responsePricelists.first;

            // إضافة للقائمة المحلية
            PrefUtils.listesPrix.add(created);
            await PrefUtils.setPriceLists(PrefUtils.listesPrix);

            Get.back(result: created);
            onResponse(created);
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        if (kDebugMode) {
          print('❌ Error creating pricelist: $error');
        }
      },
    );
  }

  static updatePricelist({
    required Map<String, dynamic>? maps,
    required int id,
    required OnResponse onResponse,
  }) {
    Api.write(
      model: "product.pricelist",
      ids: [id],
      values: maps!,
      onResponse: (response) {
        readPricelists(
          ids: [id],
          onResponse: (updatedPricelists) async {
            final updated = updatedPricelists.first;

            // تحديث القائمة المحلية
            await PrefUtils.updatePriceList(updated);

            onResponse(updated);
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        if (kDebugMode) {
          print('❌ Error updating pricelist: $error');
        }
      },
    );
  }

  static deletePricelist({
    required int id,
    required OnResponse onResponse,
    required BuildContext context,
  }) {
    Api.unlink(
      model: "product.pricelist",
      ids: [id],
      onResponse: (response) async {
        if (response) {
          // حذف من القائمة المحلية
          PrefUtils.listesPrix.removeWhere((p) => p.id == id);
          await PrefUtils.setPriceLists(PrefUtils.listesPrix);

          onResponse(response);
        }
      },
      onError: (String error, Map<String, dynamic> data) {
        String errorMessage = error;
        if (data.containsKey('error') &&
            data['error']['data'] != null &&
            data['error']['data']['message'] != null) {
          errorMessage = data['error']['data']['message'];
        }

        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Error"),
              content: Text(errorMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );

        if (kDebugMode) {
          print('❌ Error deleting pricelist: $errorMessage');
        }
      },
    );
  }
}
