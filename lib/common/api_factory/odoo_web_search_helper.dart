import 'dart:async';
import 'package:gsloution_mobile/common/config/import.dart';

/// ملف مساعد لإدارة استدعاءات web_search_read و web_read في Odoo
/// يوفر دوال عامة لبناء وتنفيذ web operations مع specifications معقدة
class WebSearchReadHelper {
  WebSearchReadHelper._();

  // ✅ Cache للـ specifications لتجنب استدعاءات fields_get المتكررة
  static final Map<String, Map<String, dynamic>> _specificationCache = {};

  /// ═══════════════════════════════════════════════════════════════════════
  /// 🔍 WEB_SEARCH_READ - دوال البحث
  /// ═══════════════════════════════════════════════════════════════════════

  /// 🎯 الدالة الأساسية: webSearchReadController
  /// دالة عامة لتنفيذ web_search_read مع specification مخصص (صفحة واحدة)
  static Future<void> webSearchReadController<T>({
    required String model,
    required Map<String, dynamic> specification,
    List domain = const [],
    int limit = 50,
    int offset = 0,
    String? order,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final Completer<List<T>> completer = Completer();

      Api.callKW(
        method: 'web_search_read',
        model: model,
        args: [],
        kwargs: {
          "domain": domain,
          "specification": specification,
          "limit": limit,
          "offset": offset,
          if (order != null) "order": order,
          "context": {
            "lang": "fr_FR",
            "tz": "Africa/Casablanca",
            "uid": 2,
            "allowed_company_ids": [1],
            ...?additionalContext,
          },
        },
        onResponse: (response) {
          if (response != null && response['records'] != null) {
            List<T> fetchedRecords = [];
            for (var record in response['records']) {
              if (record is Map<String, dynamic> && fromJson != null) {
                try {
                  fetchedRecords.add(fromJson(record));
                } catch (e) {
                  print("⚠️ Error parsing record: $e");
                }
              }
            }
            completer.complete(fetchedRecords);
          } else {
            completer.complete([]);
          }
        },
        onError: (error, data) {
          print("❌ Error in web_search_read: $error");
          completer.completeError(error);
        },
        showGlobalLoading: showGlobalLoading,
      );

      final records = await completer.future;
      if (onResponse != null) onResponse(records);
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  /// 🧠 smartWebSearchRead - نسخة ذكية (صفحة واحدة + cache)
  static Future<void> smartWebSearchRead<T>({
    required String model,
    Map<String, dynamic>? customSpecification,
    List<String> excludeFields = const [],
    List domain = const [],
    int limit = 50,
    int offset = 0,
    String? order,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    bool useCache = true,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      Map<String, dynamic> baseSpec = {};
      String cacheKey = "$model-${excludeFields.join(',')}";

      if (useCache && _specificationCache.containsKey(cacheKey)) {
        baseSpec = Map<String, dynamic>.from(_specificationCache[cacheKey]!);
      } else {
        baseSpec = await buildBasicSpecification(
          model: model,
          excludeFields: excludeFields,
        );
        if (useCache)
          _specificationCache[cacheKey] = Map<String, dynamic>.from(baseSpec);
      }

      if (customSpecification != null) {
        customSpecification.forEach((key, value) => baseSpec[key] = value);
      }

      await webSearchReadController<T>(
        model: model,
        specification: baseSpec,
        domain: domain,
        limit: limit,
        offset: offset,
        order: order,
        fromJson: fromJson,
        onResponse: onResponse,
        showGlobalLoading: showGlobalLoading,
        additionalContext: additionalContext,
      );
    } catch (e) {
      print("❌ Error in smartWebSearchRead: $e");
    }
  }

  /// 🔄 smartWebSearchReadAll - جلب كل السجلات مع pagination
  static Future<void> smartWebSearchReadAll<T>({
    required String model,
    Map<String, dynamic>? customSpecification,
    List<String> excludeFields = const [],
    List domain = const [],
    int limit = 50,
    String? order,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    Function(int current, int total)? onProgress,
    bool? showGlobalLoading,
    bool useCache = true,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      Map<String, dynamic> baseSpec = {};
      String cacheKey = "$model-${excludeFields.join(',')}";

      if (useCache && _specificationCache.containsKey(cacheKey)) {
        baseSpec = Map<String, dynamic>.from(_specificationCache[cacheKey]!);
      } else {
        baseSpec = await buildBasicSpecification(
          model: model,
          excludeFields: excludeFields,
        );
        if (useCache)
          _specificationCache[cacheKey] = Map<String, dynamic>.from(baseSpec);
      }

      if (customSpecification != null) {
        customSpecification.forEach((key, value) => baseSpec[key] = value);
      }

      int offset = 0;
      bool hasMore = true;
      List<T> allRecords = [];
      int totalEstimate = 0;

      while (hasMore) {
        final Completer<List<T>> completer = Completer();

        Api.callKW(
          method: 'web_search_read',
          model: model,
          args: [],
          kwargs: {
            "domain": domain,
            "specification": baseSpec,
            "limit": limit,
            "offset": offset,
            if (order != null) "order": order,
            "context": {
              "lang": "fr_FR",
              "tz": "Africa/Casablanca",
              "uid": 2,
              "allowed_company_ids": [1],
              ...?additionalContext,
            },
          },
          onResponse: (response) {
            if (response != null && response['records'] != null) {
              List<T> fetchedRecords = [];
              if (response['length'] != null)
                totalEstimate = response['length'];

              for (var record in response['records']) {
                if (record is Map<String, dynamic> && fromJson != null) {
                  try {
                    fetchedRecords.add(fromJson(record));
                  } catch (e) {
                    print("⚠️ Error parsing: $e");
                  }
                }
              }
              completer.complete(fetchedRecords);
            } else {
              completer.complete([]);
            }
          },
          onError: (error, data) {
            print("❌ Error at offset $offset: $error");
            completer.completeError(error);
          },
          showGlobalLoading:
              showGlobalLoading != null && showGlobalLoading && offset == 0,
        );

        final fetchedRecords = await completer.future;
        allRecords.addAll(fetchedRecords);

        if (onProgress != null) {
          int estimatedTotal = totalEstimate > 0
              ? totalEstimate
              : (fetchedRecords.length == limit
                    ? allRecords.length + limit
                    : allRecords.length);
          onProgress(allRecords.length, estimatedTotal);
        }

        hasMore = fetchedRecords.length == limit;
        offset += limit;
      }

      if (onResponse != null) onResponse(allRecords);
    } catch (e) {
      print("❌ Error in smartWebSearchReadAll: $e");
      if (onResponse != null) onResponse([]);
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// 📖 WEB_READ - دوال القراءة بـ IDs
  /// ═══════════════════════════════════════════════════════════════════════

  /// 📖 webReadController - قراءة IDs محددة مع specification
  static Future<void> webReadController<T>({
    required String model,
    required List<int> ids,
    required Map<String, dynamic> specification,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      final Completer<List<T>> completer = Completer();

      Api.callKW(
        method: 'web_read',
        model: model,
        args: [ids],
        kwargs: {
          "specification": specification,
          "context": {
            "lang": "fr_FR",
            "tz": "Africa/Casablanca",
            "uid": 2,
            "allowed_company_ids": [1],
            ...?additionalContext,
          },
        },
        onResponse: (response) {
          if (response != null && response is List) {
            List<T> fetchedRecords = [];
            for (var record in response) {
              if (record is Map<String, dynamic> && fromJson != null) {
                try {
                  fetchedRecords.add(fromJson(record));
                } catch (e) {
                  print("⚠️ Error parsing: $e");
                }
              }
            }
            completer.complete(fetchedRecords);
          } else {
            completer.complete([]);
          }
        },
        onError: (error, data) {
          print("❌ Error in web_read: $error");
          completer.completeError(error);
        },
        showGlobalLoading: showGlobalLoading,
      );

      final records = await completer.future;
      if (onResponse != null) onResponse(records);
    } catch (e) {
      print("❌ Error: $e");
    }
  }

  /// 🧠 smartWebRead - نسخة ذكية لقراءة IDs
  static Future<void> smartWebRead<T>({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? customSpecification,
    List<String> excludeFields = const [],
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    bool? showGlobalLoading,
    bool useCache = true,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      Map<String, dynamic> baseSpec = {};
      String cacheKey = "$model-${excludeFields.join(',')}";

      if (useCache && _specificationCache.containsKey(cacheKey)) {
        baseSpec = Map<String, dynamic>.from(_specificationCache[cacheKey]!);
      } else {
        baseSpec = await buildBasicSpecification(
          model: model,
          excludeFields: excludeFields,
        );
        if (useCache)
          _specificationCache[cacheKey] = Map<String, dynamic>.from(baseSpec);
      }

      if (customSpecification != null) {
        customSpecification.forEach((key, value) => baseSpec[key] = value);
      }

      await webReadController<T>(
        model: model,
        ids: ids,
        specification: baseSpec,
        fromJson: fromJson,
        onResponse: onResponse,
        showGlobalLoading: showGlobalLoading,
        additionalContext: additionalContext,
      );
    } catch (e) {
      print("❌ Error in smartWebRead: $e");
    }
  }

  /// 🔄 smartWebReadAll - قراءة IDs كثيرة مع batches
  static Future<void> smartWebReadAll<T>({
    required String model,
    required List<int> ids,
    Map<String, dynamic>? customSpecification,
    List<String> excludeFields = const [],
    int batchSize = 50,
    T Function(Map<String, dynamic>)? fromJson,
    OnResponse? onResponse,
    Function(int current, int total)? onProgress,
    bool? showGlobalLoading,
    bool useCache = true,
    Map<String, dynamic>? additionalContext,
  }) async {
    try {
      Map<String, dynamic> baseSpec = {};
      String cacheKey = "$model-${excludeFields.join(',')}";

      if (useCache && _specificationCache.containsKey(cacheKey)) {
        baseSpec = Map<String, dynamic>.from(_specificationCache[cacheKey]!);
      } else {
        baseSpec = await buildBasicSpecification(
          model: model,
          excludeFields: excludeFields,
        );
        if (useCache)
          _specificationCache[cacheKey] = Map<String, dynamic>.from(baseSpec);
      }

      if (customSpecification != null) {
        customSpecification.forEach((key, value) => baseSpec[key] = value);
      }

      List<T> allRecords = [];
      int totalIds = ids.length;
      int processedIds = 0;

      for (int i = 0; i < ids.length; i += batchSize) {
        int end = (i + batchSize < ids.length) ? i + batchSize : ids.length;
        List<int> batchIds = ids.sublist(i, end);

        final Completer<List<T>> completer = Completer();

        Api.callKW(
          method: 'web_read',
          model: model,
          args: [batchIds],
          kwargs: {
            "specification": baseSpec,
            "context": {
              "lang": "fr_FR",
              "tz": "Africa/Casablanca",
              "uid": 2,
              "allowed_company_ids": [1],
              ...?additionalContext,
            },
          },
          onResponse: (response) {
            if (response != null && response is List) {
              List<T> batchRecords = [];
              for (var record in response) {
                if (record is Map<String, dynamic> && fromJson != null) {
                  try {
                    batchRecords.add(fromJson(record));
                  } catch (e) {
                    print("⚠️ Error: $e");
                  }
                }
              }
              completer.complete(batchRecords);
            } else {
              completer.complete([]);
            }
          },
          onError: (error, data) {
            print("❌ Error in batch: $error");
            completer.completeError(error);
          },
          showGlobalLoading:
              showGlobalLoading != null && showGlobalLoading && i == 0,
        );

        final batchRecords = await completer.future;
        allRecords.addAll(batchRecords);
        processedIds += batchIds.length;

        if (onProgress != null) onProgress(processedIds, totalIds);
      }

      if (onResponse != null) onResponse(allRecords);
    } catch (e) {
      print("❌ Error in smartWebReadAll: $e");
      if (onResponse != null) onResponse([]);
    }
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// 🏗️ دوال مساعدة
  /// ═══════════════════════════════════════════════════════════════════════

  static Future<Map<String, dynamic>> buildBasicSpecification({
    required String model,
    List<String> excludeFields = const [],
    bool includeMany2one = true,
  }) async {
    final Completer<Map<String, dynamic>> completer = Completer();

    Api.callKW(
      method: 'fields_get',
      model: model,
      args: [],
      kwargs: {
        "attributes": ["type", "relation"],
      },
      onResponse: (response) {
        if (response is Map<String, dynamic>) {
          Map<String, dynamic> specification = {};
          response.forEach((fieldName, fieldInfo) {
            if (excludeFields.contains(fieldName)) return;
            String fieldType = fieldInfo['type'] ?? '';
            if (!['many2one', 'one2many', 'many2many'].contains(fieldType)) {
              specification[fieldName] = {};
            } else if (fieldType == 'many2one' && includeMany2one) {
              specification[fieldName] = {
                "fields": {"id": {}, "display_name": {}},
              };
            }
          });
          completer.complete(specification);
        } else {
          completer.complete({});
        }
      },
      onError: (error, data) {
        print("❌ Error in fields_get: $error");
        completer.completeError(error);
      },
    );
    return completer.future;
  }

  static Map<String, dynamic> buildSpecification(
    Map<String, dynamic> fieldsConfig,
  ) {
    Map<String, dynamic> spec = {};
    fieldsConfig.forEach((fieldName, config) {
      if (config is Map && config.containsKey('fields')) {
        spec[fieldName] = {"fields": buildSpecification(config['fields'])};
      } else {
        spec[fieldName] = {};
      }
    });
    return spec;
  }

  static void clearCache() {
    _specificationCache.clear();
    print("✅ Cache cleared");
  }

  static void clearCacheForModel(String model) {
    _specificationCache.removeWhere((key, value) => key.startsWith(model));
    print("✅ Cache cleared for $model");
  }

  static void printCacheStatus() {
    print("📊 Cache: ${_specificationCache.length} models");
    _specificationCache.forEach((key, value) {
      print("   - $key: ${value.keys.length} fields");
    });
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// 🎨 SpecificationHelpers
/// ═══════════════════════════════════════════════════════════════════════
class SpecificationHelpers {
  SpecificationHelpers._();

  static Map<String, dynamic> many2oneBasic() {
    return {
      "fields": {"id": {}, "display_name": {}},
    };
  }

  static Map<String, dynamic> many2oneWithDetails({
    List<String> additionalFields = const [],
  }) {
    Map<String, dynamic> fields = {"id": {}, "display_name": {}};
    for (var field in additionalFields) fields[field] = {};
    return {"fields": fields};
  }

  static Map<String, dynamic> partnerComplete() {
    return {
      "fields": {
        "id": {},
        "display_name": {},
        "name": {},
        "email": {},
        "phone": {},
        "mobile": {},
        "street": {},
        "city": {},
        "country_id": many2oneBasic(),
      },
    };
  }

  static Map<String, dynamic> productBasic() {
    return {
      "fields": {
        "id": {},
        "display_name": {},
        "default_code": {},
        "barcode": {},
        "list_price": {},
        "standard_price": {},
      },
    };
  }

  static Map<String, dynamic> locationBasic() {
    return {
      "fields": {"id": {}, "display_name": {}, "complete_name": {}},
    };
  }
}

/// ═══════════════════════════════════════════════════════════════════════
/// 📦 CommonSpecs
/// ═══════════════════════════════════════════════════════════════════════
class CommonSpecs {
  CommonSpecs._();

  /// stock.picking كامل
  static Map<String, dynamic> stockPickingComplete() {
    return {
      "move_ids_without_package": {
        "fields": {
          "id": {},
          "name": {},
          "state": {},
          "company_id": {},
          "picking_type_id": {},
          "partner_id": {},
          "product_id": SpecificationHelpers.productBasic(),
          "product_uom_qty": {},
          "quantity": {},
          "picked": {},
          "scrapped": {},
          "picking_code": {},
          "show_details_visible": {},
          "additional": {},
          "move_lines_count": {},
          "is_locked": {},
          "product_uom_category_id": {},
          "is_storable": {},
          "has_tracking": {},
          "is_quantity_done_editable": {},
          "show_quant": {},
          "location_id": SpecificationHelpers.locationBasic(),
          "location_dest_id": SpecificationHelpers.locationBasic(),
          "date": {},
          "date_deadline": {},
          "product_uom": SpecificationHelpers.many2oneBasic(),
          "move_line_ids": {},
          "description_picking": {},
        },
      },
    };
  }

  /// sale.order مع order lines
  static Map<String, dynamic> saleOrderComplete() {
    return {
      "order_line": {
        "fields": {
          "id": {},
          "product_id": SpecificationHelpers.productBasic(),
          "product_uom_qty": {},
          "qty_delivered": {},
          "price_unit": {},
          "discount": {},
          "price_subtotal": {},
          "price_total": {},
        },
      },
    };
  }

  /// sale.order مع pickings و moves
  static Map<String, dynamic> saleOrderWithPickings() {
    return {
      "order_line": {
        "fields": {
          "id": {},
          "product_id": SpecificationHelpers.productBasic(),
          "product_uom_qty": {},
          "price_unit": {},
          "price_subtotal": {},
        },
      },
      "picking_ids": {
        "fields": {
          "id": {},
          "name": {},
          "state": {},
          "picking_type_code": {},
          "move_ids_without_package": {
            "fields": {
              "id": {},
              "product_id": SpecificationHelpers.productBasic(),
              "product_uom_qty": {},
              "quantity": {},
              "state": {},
            },
          },
        },
      },
    };
  }

  /// purchase.order
  static Map<String, dynamic> purchaseOrderComplete() {
    return {
      "order_line": {
        "fields": {
          "id": {},
          "product_id": SpecificationHelpers.productBasic(),
          "product_qty": {},
          "qty_received": {},
          "price_unit": {},
          "price_subtotal": {},
        },
      },
    };
  }

  /// invoice
  static Map<String, dynamic> invoiceComplete() {
    return {
      "invoice_line_ids": {
        "fields": {
          "id": {},
          "product_id": SpecificationHelpers.productBasic(),
          "quantity": {},
          "price_unit": {},
          "discount": {},
          "price_subtotal": {},
        },
      },
    };
  }
}
