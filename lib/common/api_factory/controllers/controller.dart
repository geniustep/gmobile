import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_journal/account_journal_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_module.dart';
import 'package:gsloution_mobile/common/config/field_presets/presets_manager.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/api_factory/modules/settings_odoo_model.dart';
import 'package:gsloution_mobile/common/api_factory/modules/settings_odoo_module.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class Controller extends GetxController {
  var products = <ProductModel>[].obs;
  var partners = <PartnerModel>[].obs;
  var categoryProduct = <ProductCategoryModel>[].obs;
  var sales = <OrderModel>[].obs;
  var stockPicking = <StockPickingModel>[].obs;
  List<dynamic> listesPrix = [];
  List<dynamic> conditionsPaiement = [];

  var orderLine = <OrderLineModel>[].obs;
  var accountMove = <AccountMoveModel>[].obs;
  var accountJournal = <AccountJournalModel>[].obs;
  var settingsOdoo = ResConfigSettingModel().obs;

  // Settings Odooo
  Future<void> getSettingsOdooController({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    await SettingsOdooModule.onchangeSettingsOdoo(
      onResponse: (response) async {
        try {
          settingsOdoo.value = response;
          if (settingsOdoo.value != null &&
              settingsOdoo.value.default_invoice_policy != "delivery") {
            await SettingsOdooModule.deliverySettings(
              onResponse: (res) {
                onResponse?.call(true);
              },
              showGlobalLoading: showGlobalLoading!, // ✅ تمرير parameter
            );
          } else {
            onResponse?.call(true);
          }
        } catch (e) {
          print("Error obteniendo Partners: $e");
          handleApiError(e);
        }
      },
      showGlobalLoading: showGlobalLoading!, // ✅ تمرير parameter
    );
  }

  // Partners
  Future<void> getPartnersController({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    await PartnerModule.searchReadPartners(
      onResponse: (response) {
        try {
          partners.clear();
          partners.addAll(response);
          onResponse?.call(response);
        } catch (e) {
          print("Error obteniendo Partners: $e");
          handleApiError(e);
        }
      },
      showGlobalLoading:
          showGlobalLoading ?? true, // ✅ تمرير parameter مع قيمة افتراضية
    );
  }

  // Listes de prix
  Future<void> getListesPrixController({OnResponse? onResponse}) async {
    try {
      await PricelistModule.searchReadPricelists(
        onResponse: (response) {
          listesPrix = response;
          onResponse?.call(response);
        },
      );
    } catch (e) {
      print("Error obteniendo Listes de prix: $e");
      handleApiError(e);
    }
  }

  // Conditions de paiement
  Future<void> getConditionsPaiementController({OnResponse? onResponse}) async {
    try {
      await OrderModule.accountPaymentTerm(
        onResponse: (response) {
          conditionsPaiement = response;
          onResponse?.call(response);
        },
      );
    } catch (e) {
      print("Error obteniendo Conditions de paiement: $e");
      handleApiError(e);
    }
  }

  // products
  Future<void> getProductsController({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    await ProductModule.searchReadProducts(
      onResponse: (response) {
        try {
          products.clear();
          products.addAll(response);
          onResponse?.call(response);
        } catch (e) {
          print("Error obteniendo productos: $e");
          handleApiError(e);
        }
      },
      showGlobalLoading:
          showGlobalLoading ?? true, // ✅ تمرير parameter مع قيمة افتراضية
    );
  }

  // with preset
  Future<void> getNewProductsController({
    OnResponse? onResponse,
    bool? showGlobalLoading,
    FieldPreset preset = FieldPreset.basic, // ✅ جديد
  }) async {
    await ProductModule.searchReadProducts(
      onResponse: (response) {
        try {
          products.clear();
          products.addAll(response);
          onResponse?.call(response);
        } catch (e) {
          print("❌ Error processing products: $e");
          handleApiError(e);
        }
      },
      showGlobalLoading: showGlobalLoading ?? true,
    );
  }

  // category product

  Future<void> getCategoryProductsController({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    try {
      await ProductCategoryModule.searchReadProductsCategory(
        onResponse: (response) {
          categoryProduct.clear();
          categoryProduct.addAll(response);
          onResponse?.call(response);
        },
        showGlobalLoading: showGlobalLoading ?? true, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
      handleApiError(e);
    }
  }

  // sales order
  Future<void> getSalesController({
    OnResponse? onResponse,
    List? domain,
  }) async {
    await OrderModule.searchReadOrder(
      domain: domain ?? [],
      showGlobalLoading: false,
      onResponse: (response) {
        try {
          sales.addAll(response);
          onResponse?.call(response);
        } catch (e) {
          print("Error obteniendo sales: $e");
          handleApiError(e);
        }
      },
    );
  }

  // order line
  Future<void> getSalesLineController({
    OnResponse? onResponse,
    List<int>? ids,
  }) async {
    await OrderLineModule.readOrderLines(
      ids: ids!,
      onResponse: (response) {
        try {
          orderLine.addAll(response);
          onResponse?.call(response);
        } catch (e) {
          print("Error obteniendo: $e");
          handleApiError(e);
        }
      },
      // ✅ تمرير parameter مع قيمة افتراضية
    );
  }

  getSalesOrdersLineController({List<int>? ids, OnResponse? onResponse}) async {
    await OrderLineModule.readOrderLines(
      ids: ids!,
      onResponse: (response) {
        if (response.isNotEmpty) {
          orderLine.clear();
          orderLine.addAll(response);
          int key = orderLine.isNotEmpty ? orderLine[0].id as int : 0;
          onResponse?.call({key: orderLine});
          // onResponse!({key: orderLine});
        }
      },
    );
  }

  ////////////////////////////////////////
  /////////////** INVOICE **//////////////
  ////////////////////////////////////////
  // ACCONT MOVE

  getAccountMove({OnResponse? onResponse, bool? showGlobalLoading}) async {
    try {
      await AccountMoveModule.searchReadAccountMove(
        onResponse: (response) {
          accountMove.clear();
          accountMove.addAll(response);
          onResponse?.call(response);
        },
        showGlobalLoading: showGlobalLoading ?? true, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo: $e");
      handleApiError(e);
    }
  }

  // ════════════════════════════════════════════════════════════
  // 1. في controller.dart - إصلاح getAccountJournal
  // ════════════════════════════════════════════════════════════

  Future<void> getAccountJournal({
    OnResponse<List<AccountJournalModel>>? onResponse,
    List<dynamic>? domain,
    bool? showGlobalLoading,
  }) async {
    try {
      await AccountJournalModule.searchReadAccountJournal(
        domain: domain ?? [],
        showGlobalLoading: showGlobalLoading ?? false,
        onResponse: (response) {
          accountJournal.clear();
          accountJournal.addAll(response);

          print('✅ Account journals loaded: ${response.length}');

          // ✅ آمن - استخدام ?.call
          onResponse?.call(response);
        },
      );
    } catch (e) {
      print("❌ Error loading account journal: $e");
      handleApiError(e);
      // ✅ إرجاع list فارغة في حالة الخطأ
      onResponse?.call([]);
    }
  }

  Future<void> changeJournalDetails({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    await AccountJournalModule.changeJournalDetails(
      onResponse: (response) {
        onResponse?.call(response);
      },
      showGlobalLoading:
          showGlobalLoading ?? true, // ✅ تمرير parameter مع قيمة افتراضية
    );
  }

  // Stock Picking
  Future<void> getStockPickingController({
    OnResponse? onResponse,
    List? domain,
    bool? showGlobalLoading, // ✅ parameter جديد
  }) async {
    try {
      await StockPickingModule.searchStockPicking(
        domain: domain ?? [],
        onResponse: (response) {
          stockPicking.clear();
          stockPicking.addAll(response);
          onResponse?.call(stockPicking);
        },
        showGlobalLoading: showGlobalLoading ?? true, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo: $e");
      handleApiError(e);
    }
  }

  // تحديث أوامر التسليم تلقائياً
  Future<void> refreshStockPickingsForOrder({
    required String orderName,
    OnResponse? onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🔄 ========== REFRESHING STOCK PICKINGS FOR ORDER ==========');
        print('Order Name: $orderName');
        print('==========================================================\n');
      }

      await StockPickingModule.searchStockPicking(
        domain: [
          ["origin", "=", orderName],
        ],
        onResponse: (response) {
          // إضافة أوامر التسليم الجديدة فقط
          for (var picking in response) {
            if (!stockPicking.any((existing) => existing.id == picking.id)) {
              stockPicking.add(picking);
            }
          }

          if (kDebugMode) {
            print('✅ Stock pickings refreshed for order: $orderName');
            print('Total pickings: ${stockPicking.length}');
          }

          onResponse?.call(stockPicking);
        },
        showGlobalLoading: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR REFRESHING STOCK PICKINGS ==========');
        print('Error: $e');
        print('====================================================\n');
      }
      handleApiError(e);
    }
  }

  // تحديث حالة أمر تسليم محدد
  Future<void> updateStockPickingStatus({
    required int pickingId,
    required String newState,
    OnResponse? onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🔄 ========== UPDATING STOCK PICKING STATUS ==========');
        print('Picking ID: $pickingId');
        print('New State: $newState');
        print('====================================================\n');
      }

      // البحث عن أمر التسليم في القائمة المحلية
      final pickingIndex = stockPicking.indexWhere((p) => p.id == pickingId);

      if (pickingIndex != -1) {
        // تحديث الحالة محلياً
        stockPicking[pickingIndex].state = newState;
        stockPicking[pickingIndex].dateDone = DateTime.now().toIso8601String();

        if (kDebugMode) {
          print('✅ Stock picking status updated locally');
        }

        onResponse?.call(stockPicking[pickingIndex]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR UPDATING STOCK PICKING STATUS ==========');
        print('Error: $e');
        print('========================================================\n');
      }
      handleApiError(e);
    }
  }

  // تحديث كمية في StockMoveLine
  Future<void> updateStockMoveLineQty({
    required int lineId,
    required double newQty,
    OnResponse? onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🔄 ========== UPDATING STOCK MOVE LINE QTY ==========');
        print('Line ID: $lineId');
        print('New Qty: $newQty');
        print('==================================================\n');
      }

      await StockPickingModule.updateStockMoveLineQty(
        lineId: lineId,
        newQty: newQty,
        onResponse: (response) {
          // تحديث محلي
          final lineIndex = PrefUtils.stockMoveLines.indexWhere(
            (l) => l.id == lineId,
          );
          if (lineIndex != -1) {
            PrefUtils.stockMoveLines[lineIndex].quantity = newQty;
          }

          if (kDebugMode) {
            print('✅ Stock move line quantity updated locally');
          }

          onResponse?.call(response);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR UPDATING STOCK MOVE LINE QTY ==========');
        print('Error: $e');
        print('=======================================================\n');
      }
      handleApiError(e);
    }
  }

  // حذف StockMoveLine
  Future<void> deleteStockMoveLine({
    required int lineId,
    OnResponse? onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n🗑️ ========== DELETING STOCK MOVE LINE ==========');
        print('Line ID: $lineId');
        print('==============================================\n');
      }

      await StockPickingModule.deleteStockMoveLine(
        lineId: lineId,
        onResponse: (response) {
          // حذف محلي
          PrefUtils.stockMoveLines.removeWhere((l) => l.id == lineId);

          if (kDebugMode) {
            print('✅ Stock move line deleted locally');
          }

          onResponse?.call(response);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR DELETING STOCK MOVE LINE ==========');
        print('Error: $e');
        print('===================================================\n');
      }
      handleApiError(e);
    }
  }

  // التحقق من إمكانية النقل الفوري
  Future<void> checkImmediateTransfer({
    required int pickingId,
    OnResponse<bool>? onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n⚡ ========== CHECKING IMMEDIATE TRANSFER ==========');
        print('Picking ID: $pickingId');
        print('================================================\n');
      }

      await StockPickingModule.canImmediateTransfer(
        pickingId: pickingId,
        onResponse: (canTransfer) {
          if (kDebugMode) {
            print('📊 Can immediate transfer: $canTransfer');
          }
          onResponse?.call(canTransfer);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR CHECKING IMMEDIATE TRANSFER ==========');
        print('Error: $e');
        print('=====================================================\n');
      }
      onResponse?.call(false);
    }
  }

  // التحقق من إمكانية Backorder
  Future<void> checkBackorder({
    required int pickingId,
    OnResponse<bool>? onResponse,
  }) async {
    try {
      if (kDebugMode) {
        print('\n📋 ========== CHECKING BACKORDER ==========');
        print('Picking ID: $pickingId');
        print('========================================\n');
      }

      await StockPickingModule.canBackorder(
        pickingId: pickingId,
        onResponse: (canBackorder) {
          if (kDebugMode) {
            print('📊 Can backorder: $canBackorder');
          }
          onResponse?.call(canBackorder);
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('\n❌ ========== ERROR CHECKING BACKORDER ==========');
        print('Error: $e');
        print('============================================\n');
      }
      onResponse?.call(false);
    }
  }
}
