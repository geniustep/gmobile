import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_module.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class StockBackorderConfirmationModule {
  StockBackorderConfirmationModule._();

  static getViews({required int pickingId, required OnResponse onResponse}) {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: "get_views",
      args: [],
      kwargs: {
        "context": {
          "default_show_transfers": false,
          "default_pick_ids": [
            [4, pickingId],
          ],
        },
        "views": [
          [1235, "form"],
        ],
        "options": {
          "action_id": false,
          "embedded_action_id": false,
          "embedded_parent_res_id": pickingId,
          "load_filters": false,
          "toolbar": false,
        },
      },
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static onchange({required int pickingId, required OnResponse onResponse}) {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: "onchange",
      args: [
        [],
        {},
        [],
        {
          "pick_ids": {"fields": {}},
          "show_transfers": {},
          "backorder_confirmation_line_ids": {
            "fields": {
              "picking_id": {
                "fields": {"display_name": {}},
              },
              "to_backorder": {},
            },
            "limit": 40,
            "order": "",
          },
        },
      ],
      kwargs: {
        "context": {
          "active_model": "stock.picking",
          "active_id": pickingId,
          "active_ids": [pickingId],
          "default_company_id": 1,
          "button_validate_picking_ids": [pickingId],
          "default_show_transfers": false,
          "default_pick_ids": [
            [4, pickingId],
          ],
        },
      },
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static process({
    required int confirmationId,
    required int pickingId,
    required OnResponse onResponse,
  }) {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: "process",
      args: [
        [confirmationId],
      ],
      kwargs: {
        "context": {
          "active_model": "stock.picking",
          "active_id": pickingId,
          "active_ids": [pickingId],
          "default_company_id": 1,
          "button_validate_picking_ids": [pickingId],
          "default_show_transfers": false,
          "default_pick_ids": [
            [4, pickingId],
          ],
        },
      },
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static Future<void> completeBackorderFlow({
    required int pickingId,
    required bool createBackorder,
    required OnResponse onResponse,
  }) async {
    getViews(
      pickingId: pickingId,
      onResponse: (getViewsResponse) {
        onchange(
          pickingId: pickingId,
          onResponse: (onchangeResponse) {
            if (onchangeResponse != null && onchangeResponse is Map) {
              final value = onchangeResponse['value'];
              if (value != null &&
                  value['backorder_confirmation_line_ids'] != null) {
                final lines = value['backorder_confirmation_line_ids'] as List;
                if (lines.isNotEmpty &&
                    lines[0] is List &&
                    lines[0].length > 2) {
                  final lineData = lines[0][2];
                  if (lineData is Map && lineData['picking_id'] != null) {
                    final pickingData = lineData['picking_id'];
                    dynamic confirmationPickingId;

                    if (pickingData is Map && pickingData['id'] != null) {
                      confirmationPickingId = pickingData['id'];
                    } else if (pickingData is int) {
                      confirmationPickingId = pickingData;
                    }

                    if (confirmationPickingId != null) {
                      Api.callKW(
                        model: "stock.backorder.confirmation",
                        method: "create",
                        args: [
                          {
                            "pick_ids": [
                              [4, confirmationPickingId],
                            ],
                            "show_transfers": false,
                            "backorder_confirmation_line_ids": [
                              [
                                0,
                                0,
                                {
                                  "picking_id": confirmationPickingId,
                                  "to_backorder": createBackorder,
                                },
                              ],
                            ],
                          },
                        ],
                        onResponse: (createResponse) {
                          if (createResponse != null && createResponse is int) {
                            if (createBackorder) {
                              process(
                                confirmationId: createResponse,
                                pickingId: pickingId,
                                onResponse: (processResponse) async {
                                  // ✅ تحديث البيانات بعد النجاح
                                  await _refreshPickingData(pickingId);
                                  onResponse(processResponse);
                                },
                              );
                            } else {
                              processCancelBackorder(
                                confirmationId: createResponse,
                                pickingId: pickingId,
                                onResponse: (processResponse) async {
                                  // ✅ تحديث البيانات بعد النجاح
                                  await _refreshPickingData(pickingId);
                                  onResponse(processResponse);
                                },
                              );
                            }
                          }
                        },
                        onError: (error, data) {
                          handleApiError(error);
                        },
                      );
                    }
                  }
                }
              }
            }
          },
        );
      },
    );
  }

  // ✅ دالة تحديث البيانات في SharedPreferences
  static Future<void> _refreshPickingData(int pickingId) async {
    try {
      // 1️⃣ تحديث stock.picking من السيرفر
      await StockPickingModule.webReadStockPicking(
        ids: [pickingId],
        showGlobalLoading: false,
        onResponse: (updatedPickings) async {
          if (updatedPickings.isNotEmpty) {
            final updatedPicking = updatedPickings.first;

            // 2️⃣ تحديث في PrefUtils
            final index = PrefUtils.stockPicking.indexWhere(
              (p) => p.id == pickingId,
            );

            if (index != -1) {
              PrefUtils.stockPicking[index] = updatedPicking;
            } else {
              PrefUtils.stockPicking.add(updatedPicking);
            }

            // 3️⃣ حفظ في SharedPreferences
            await PrefUtils.setStockPicking(PrefUtils.stockPicking);

            // 4️⃣ تحديث الـ Observable
            PrefUtils.stockPicking.refresh();

            print('✅ Stock Picking updated in cache: ${updatedPicking.name}');
            print('   State: ${updatedPicking.state}');
            print('   Date Done: ${updatedPicking.dateDone}');
          }
        },
      );
    } catch (e) {
      print('❌ Error refreshing picking data: $e');
    }
  }

  static Future<void> processCancelBackorder({
    required int confirmationId,
    required int pickingId,
    required OnResponse onResponse,
  }) async {
    Api.callKW(
      model: "stock.backorder.confirmation",
      method: "process_cancel_backorder",
      args: [
        [confirmationId],
      ],
      kwargs: {
        "context": {
          "active_model": "stock.picking",
          "active_id": pickingId,
          "active_ids": [pickingId],
          "default_company_id": 1,
          "button_validate_picking_ids": [pickingId],
          "default_show_transfers": false,
          "default_pick_ids": [
            [4, pickingId],
          ],
        },
      },
      onResponse: (response) {
        if (kDebugMode) {
          print('✅ process_cancel_backorder response: $response');
        }
        onResponse(response);
      },
      onError: (error, data) {
        if (kDebugMode) {
          print('❌ process_cancel_backorder error: $error');
        }
        handleApiError(error);
      },
    );
  }
}
