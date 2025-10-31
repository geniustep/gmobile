import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/odoo_web_search_helper.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class StockPickingModule {
  StockPickingModule._();

  /// ✅ قراءة stock.picking محددة بـ IDs مع جميع التفاصيل
  static webReadStockPicking({
    required List<int> ids,
    required OnResponse onResponse,
    bool showGlobalLoading = true,
  }) async {
    // ✅ 1. بناء specification كامل
    final specification = {
      // ═══ الحقول الأساسية ═══
      "id": {},
      "name": {},
      "state": {},
      "priority": {},
      "picking_type_code": {},
      "return_count": {},
      "scheduled_date": {},
      "date_deadline": {},
      "date_done": {},
      "origin": {},
      "move_type": {},
      "note": {},
      "display_name": {},
      "is_locked": {},
      "has_scrap_move": {},
      "has_packages": {},
      "show_check_availability": {},
      "show_next_pickings": {},

      // ═══ Many2one Relations ═══
      "partner_id": SpecificationHelpers.many2oneBasic(),
      "picking_type_id": SpecificationHelpers.many2oneBasic(),
      "location_id": {
        "fields": {"id": {}},
      },
      "location_dest_id": {
        "fields": {"id": {}},
      },
      "backorder_id": {},
      "user_id": {},
      "group_id": SpecificationHelpers.many2oneBasic(),
      "sale_id": SpecificationHelpers.many2oneBasic(),
      "company_id": {
        "fields": {"id": {}},
      },

      // ═══ One2many: Stock Moves (الأهم!) ═══
      "move_ids_without_package": {
        "fields": {
          "id": {},
          "name": {},
          "state": {},
          "date": {},
          "date_deadline": {},
          "description_picking": {},
          "product_uom_qty": {},
          "quantity": {},
          "product_qty": {},
          "picked": {},
          "product_id": SpecificationHelpers.productBasic(),
          "location_id": SpecificationHelpers.locationBasic(),
          "location_dest_id": SpecificationHelpers.locationBasic(),
          "partner_id": {
            "fields": {"id": {}},
          },
          "product_uom": SpecificationHelpers.many2oneBasic(),
          "move_line_ids": {},
        },
      },
    };

    // ✅ 2. استدعاء web_read
    Api.webRead(
      model: "stock.picking",
      ids: ids,
      specification: specification,
      onResponse: (response) {
        if (response != null && response is List) {
          List<StockPickingModel> pickings = [];
          for (var element in response) {
            if (element is Map<String, dynamic>) {
              try {
                pickings.add(StockPickingModel.fromJson(element));
              } catch (e) {
                print("⚠️ Error parsing stock.picking: $e");
              }
            }
          }
          onResponse(pickings);
        } else {
          onResponse([]);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
      showGlobalLoading: showGlobalLoading,
    );
  }

  /// ✅ للاستخدام في Splash - جلب كل البيانات
  static loadAllForSplash({
    required OnResponse onResponse,
    Function(int current, int total)? onProgress,
  }) async {
    await WebSearchReadHelper.smartWebSearchReadAll<StockPickingModel>(
      model: "stock.picking",
      customSpecification: CommonSpecs.stockPickingComplete(),
      excludeFields: ['message_ids', 'activity_ids', 'message_follower_ids'],
      domain: [], // كل السجلات
      limit: 50,
      order: "scheduled_date DESC",
      fromJson: (data) => StockPickingModel.fromJson(data),
      onResponse: onResponse,
      onProgress: onProgress, // ← للـ progress bar
      showGlobalLoading: false,
      useCache: true,
    );
  }

  static readStockPicking({
    required List<int> ids,
    required OnResponse<List<StockPickingModel>> onResponse,
  }) {
    List<String> fields = [
      "id",
      "is_locked",
      "show_check_availability",

      "show_lots_text",
      "immediate_transfer",
      "show_operations",
      "show_reserved",
      "move_line_exist",
      "has_packages",
      "state",
      "picking_type_entire_packs",
      "has_scrap_move",
      "has_tracking",
      "name",
      "partner_id",
      "picking_type_id",
      "location_id",
      "location_dest_id",
      "backorder_id",
      "scheduled_date",
      "date_done",
      "origin",
      "owner_id",
      "move_line_nosuggest_ids",
      "package_level_ids_details",
      "move_line_ids_without_package",
      "move_ids_without_package",
      "package_level_ids",
      "picking_type_code",
      "move_type",
      "priority",
      "user_id",
      "group_id",
      "company_id",
      "note",
      "display_name",
    ];
    Api.read(
      model: "stock.picking",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<StockPickingModel> stockPicking = [];
        for (var element in response) {
          stockPicking.add(StockPickingModel.fromJson(element));
        }
        onResponse(stockPicking);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchStockPickingPartnersId({
    int offset = 0,
    List<dynamic>? domain,
    required OnResponse<dynamic> onResponse,
  }) {
    List<String> fields = [
      "name",
      "location_id",
      "location_dest_id",
      "partner_id",
      "user_id",
      "date",
      "scheduled_date",
      "origin",
      "group_id",
      "backorder_id",
      "state",
      "priority",
      "picking_type_id",
      "company_id",
    ];
    Api.searchRead(
      model: "stock.picking",
      domain: domain!,
      offset: offset,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          onResponse(response["records"]);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchStockPicking({
    OnResponse? onResponse,
    List? domain,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    List<String> fields = [
      "name",
      "location_id",
      "location_dest_id",
      "partner_id",
      "user_id",
      "date",
      "scheduled_date",
      "origin",
      "group_id",
      "backorder_id",
      "state",
      "priority",
      "picking_type_id",
      "company_id",
      "move_ids_without_package",
      "return_count",
      "picking_type_code",
      "json_popover",
      "date_deadline",
      "products_availability_state",
      "products_availability",
      "picking_properties",
      "move_type",
      "show_next_pickings",
      "sale_id",
      "note",
      "display_name",
    ];

    try {
      await Module.getRecordsController<StockPickingModel>(
        model: "stock.picking",
        fields: fields,
        domain: domain!,
        fromJson: (data) => StockPickingModel.fromJson(data),
        onResponse: (response) {
          onResponse!(response);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
    }
  }

  static confirmStockPicking({
    required List<int> args,
    required OnResponse onResponse,
  }) {
    Api.callKW(
      model: "stock.picking",
      method: "button_validate",
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static ConfirmStockPicking({
    Map<String, dynamic>? context,
    required List<int> args,
    required OnResponse onResponse,
  }) {
    Api.callKW(
      model: "stock.picking",
      method: "button_validate",
      args: [args],
      context: context,
      onResponse: (response) {
        onResponse(response);
        print(response);
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  // إنشاء Backorder Confirmation Record
  static createBackorderConfirmation({
    required List<int> pickingIds,
    required OnResponse<dynamic> onResponse,
  }) {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: "create",
      args: [
        {
          "pick_ids": [
            [6, 0, pickingIds],
          ], // many2many
          "show_transfers": false,
        },
      ],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // تحديث Backorder Confirmation
  static updateBackorderConfirmation({
    required int confirmationId,
    required List<List<dynamic>> lineUpdates,
    required OnResponse<dynamic> onResponse,
  }) {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: "write",
      args: [
        [confirmationId],
        {"backorder_confirmation_line_ids": lineUpdates},
      ],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // تنفيذ Backorder Confirmation
  static StockBackorderConfirmation({
    required String method,
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: method,
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // جلب StockMoveLine لأمر تسليم محدد
  static getStockMoveLines({
    required int pickingId,
    required OnResponse<List<dynamic>> onResponse,
  }) {
    List<dynamic> domain = [];
    if (pickingId > 0) {
      domain = [
        ["picking_id", "=", pickingId],
      ];
    }

    Api.searchRead(
      model: "stock.move.line",
      domain: domain,
      fields: [
        "id",
        "product_id",
        "product_uom_id",
        "location_id",
        "location_dest_id",
        "state",
        "lot_id",
        "lot_name",
        "reference",
        "origin",
        "display_name",
      ],
      onResponse: (response) {
        if (response != null) {
          // التحقق من نوع البيانات
          if (response is Map && response.containsKey("records")) {
            onResponse(response["records"]);
          } else if (response is List) {
            onResponse(response);
          } else {
            onResponse([]);
          }
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // تحديث كمية في StockMoveLine
  static updateStockMoveLineQty({
    required int lineId,
    required double newQty,
    required OnResponse onResponse,
  }) {
    Api.write(
      model: "stock.move.line",
      ids: [lineId],
      values: {"qty_done": newQty},
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // تحديث كميات متعددة في StockMove
  static updateStockMoveQuantities({
    required List<Map<String, dynamic>> moveUpdates,
    required OnResponse onResponse,
  }) {
    if (moveUpdates.isEmpty) {
      onResponse(true);
      return;
    }

    // تحديث كل move بشكل منفصل
    int completed = 0;
    int total = moveUpdates.length;
    List<dynamic> results = [];

    for (var update in moveUpdates) {
      Api.write(
        model: "stock.move",
        ids: [update['id']],
        values: {
          "product_uom_qty": update['product_uom_qty'],
          "quantity": update['quantity'],
          "picked": update['picked'],
        },
        onResponse: (response) {
          results.add(response);
          completed++;

          if (completed == total) {
            onResponse(results);
          }
        },
        onError: (error, data) {
          completed++;
          if (completed == total) {
            onResponse(results);
          }
        },
      );
    }
  }

  // حذف StockMoveLine
  static deleteStockMoveLine({
    required int lineId,
    required OnResponse onResponse,
  }) {
    Api.unlink(
      model: "stock.move.line",
      ids: [lineId],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  // التحقق من إمكانية النقل الفوري (بديل في Odoo 18)
  static canImmediateTransfer({
    required int pickingId,
    required OnResponse<bool> onResponse,
  }) {
    // في Odoo 18، نستخدم منطق بديل
    // يمكن النقل الفوري إذا كان state = 'assigned'
    Api.read(
      model: "stock.picking",
      ids: [pickingId],
      fields: ["state"],
      onResponse: (response) {
        if (response != null && response is List && response.isNotEmpty) {
          String state = response[0]["state"] ?? "";
          bool canTransfer = state == "assigned";
          onResponse(canTransfer);
        } else {
          onResponse(false);
        }
      },
      onError: (error, data) {
        onResponse(false);
      },
    );
  }

  // التحقق من إمكانية Backorder (بديل في Odoo 18)
  static canBackorder({
    required int pickingId,
    required OnResponse<bool> onResponse,
  }) {
    // في Odoo 18، نستخدم منطق بديل
    // يمكن الباك أوردر إذا كان state = 'assigned' أو 'confirmed'
    Api.read(
      model: "stock.picking",
      ids: [pickingId],
      fields: ["state"],
      onResponse: (response) {
        if (response != null && response is List && response.isNotEmpty) {
          String state = response[0]["state"] ?? "";
          bool canBackorder = state == "assigned" || state == "confirmed";
          onResponse(canBackorder);
        } else {
          onResponse(false);
        }
      },
      onError: (error, data) {
        onResponse(false);
      },
    );
  }

  // جلب تفاصيل stock.move
  static getStockMoveDetails({
    required List<int> moveIds,
    required OnResponse<List<dynamic>> onResponse,
  }) {
    List<String> fields = [
      "id",
      "name",
      "state",
      "product_id",
      "product_uom_qty",
      "quantity",
      "picked",
      "location_id",
      "location_dest_id",
      "partner_id",
      "picking_id",
      "date",
      "date_deadline",
      "description_picking",
      "product_uom",
      "move_line_ids",
    ];

    Api.searchRead(
      model: "stock.move",
      domain: [
        ["id", "in", moveIds],
      ],
      fields: fields,
      onResponse: (response) {
        if (response != null && response is List) {
          onResponse(response);
        } else {
          onResponse([]);
        }
      },
      onError: (error, data) {
        handleApiError(error);
        onResponse([]);
      },
    );
  }

  // تحديث الكميات باستخدام web_save
  static webSaveStockPicking({
    required int pickingId,
    required List<Map<String, dynamic>> moveUpdates,
    required OnResponse onResponse,
  }) {
    // بناء move_ids_without_package للتحديث
    final List<List<dynamic>> moveIds = [];

    for (var update in moveUpdates) {
      moveIds.add([
        1, // write operation
        update['id'],
        {'quantity': update['quantity']},
      ]);
    }

    Api.callKW(
      model: "stock.picking",
      method: "web_save",
      args: [
        [pickingId],
        {"move_ids_without_package": moveIds},
      ],
      kwargs: {
        "specification": {"move_ids_without_package": {}},
      },
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
