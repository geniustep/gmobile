import 'package:gsloution_mobile/common/api_factory/odoo_web_search_helper.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class OrderModule {
  OrderModule._();
  static searchReadOrder({
    OnResponse? onResponse,
    List? domain,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    List<String> fields = [
      'amount_total',
      'state',
      'activity_ids',
      'order_line',
      'invoice_count',
      'delivery_count',
      'pricelist_id',
      'payment_term_id',
      'amount_tax',
      'amount_untaxed',
      'user_id',
      'picking_ids',
    ];

    try {
      await Module.getRecordsController<OrderModel>(
        model: "sale.order",
        fields: fields,
        domain: domain ?? [],
        fromJson: (data) => OrderModel.fromJson(data),
        onResponse: (response) {
          onResponse!(response);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
    }
  }

  static readOrders({
    required List<int> ids,
    required OnResponse<List<OrderModel>> onResponse,
  }) {
    List<String> fields = [
      "id",
      "authorized_transaction_ids",
      "state",
      "picking_ids",
      "delivery_count",
      "expense_count",
      "invoice_count",
      "name",
      "partner_id",
      "partner_invoice_id",
      "partner_shipping_id",
      "sale_order_template_id",
      "validity_date",
      "date_order",
      "pricelist_id",
      "currency_id",
      "payment_term_id",
      "order_line",
      "note",
      "amount_untaxed",
      "amount_tax",
      "amount_total",
      "sale_order_option_ids",
      "user_id",
      "team_id",
      "company_id",
      "require_signature",
      "require_payment",
      "reference",
      "client_order_ref",
      "fiscal_position_id",
      "invoice_status",
      "warehouse_id",
      "incoterm",
      "picking_policy",
      "commitment_date",
      "expected_date",
      "effective_date",
      "origin",
      "campaign_id",
      "medium_id",
      "source_id",
      "signed_by",
      "signed_on",
      "signature",
      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
      "display_name",
    ];
    Api.read(
      model: "sale.order",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          List<OrderModel> partners = [];
          for (var element in response) {
            partners.add(OrderModel.fromJson(element));
          }
          onResponse(partners);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static Future<void> webReadOrder({
    required List<int> ids,
    required OnResponse<List<OrderModel>> onResponse,
  }) async {
    await WebSearchReadHelper.smartWebRead(
      model: "sale.order",
      ids: ids,
      fromJson: (data) => OrderModel.fromJson(data),
      onResponse: (respone) {
        if (respone != null) {
          onResponse(respone);
        }
      },
    );
  }

  static cancelMethod({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "sale.order",
      method: "action_cancel",
      args: [args],
      kwargs: {
        "context": {
          "params": {
            "action": "sales",
            "actionStack": [
              {"action": "sales"},
            ],
          },
          "lang": "fr_FR",
          "tz": "Africa/Casablanca",
          "uid": 2,
          "allowed_company_ids": [1],
        },
      },
      onResponse: (response) {
        if (response != null) {
          print("First response: $response");
          try {
            // تحليل الحقول مباشرة من الاستجابة
            final resModel = response['res_model'];
            final context = response['context'];

            if (resModel != "sale.order.cancel" || context == null) {
              throw Exception("Unexpected res_model or missing context");
            }

            // إعداد kwargs للاستدعاء الثاني بناءً على الاستجابة
            final kwargsForSecondCall = {
              "context": {
                ...context, // استخدم الـ context المقدم من الاستجابة
                "params": {
                  "action": "sales",
                  "actionStack": [
                    {"action": "sales"},
                  ],
                },
                "lang": "fr_FR",
                "tz": "Africa/Casablanca",
                "uid": 2,
                "allowed_company_ids": [1],
                "active_model": "sale.order",
                "active_id": args.first,
                "active_ids": args,
              },
            };

            // الاستدعاء الثاني
            Api.callKW(
              model: "sale.order.cancel",
              method: "action_cancel",
              args: [1],
              kwargs: kwargsForSecondCall,
              onResponse: (resCancel) {
                if (resCancel != null) {
                  onResponse(true);
                } else {
                  onResponse(false);
                }
              },
              onError: (error, data) {
                handleApiError(error);
                onResponse(false);
              },
            );
          } catch (e) {
            print("Error parsing first response: $e");
            onResponse(false);
          }
        } else {
          print("No response from first call");
          onResponse(false);
        }
      },
      onError: (error, data) {
        handleApiError(error);
        onResponse(false);
      },
    );
  }

  static Draft_method({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "sale.order",
      method: "action_draft",
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static pricelist({required OnResponse<dynamic> onResponse}) {
    Api.callKW(
      model: "product.pricelist",
      method: "name_search",
      args: [],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static accountPaymentTerm({required OnResponse<dynamic> onResponse}) {
    Api.callKW(
      model: "account.payment.term",
      method: "name_search",
      args: [],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static saleOrderTemplate({required OnResponse<dynamic> onResponse}) {
    Api.callKW(
      model: "sale.order.template",
      method: "name_search",
      args: [],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static printSaleOrders({
    List<int>? args,
    dynamic id,
    required OnResponse<dynamic> onResponse,
  }) {
    Map<String, dynamic> context = {};
    context["params"] = {"action_id": 417};
    context["active_model"] = "sale.order";
    context["active_id"] = 7;
    context["active_ids"] = [7];

    Api.callKW(
      model: "sale.order",
      method: "",
      args: [args],
      context: context,
      onResponse: (response) {
        print(response);
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static printSaleOrder({
    List<int>? args,
    dynamic id,
    required OnResponse<dynamic> onResponse,
  }) {
    Map<String, dynamic> context = {
      "lang": "fr_FR",
      "tz": "Africa/Casablanca",
      "uid": 2,
      "allowed_company_ids": [1],
      "active_id": 7, // يجب تعيين هذا القيمة بناءً على سياق الاستخدام
      "active_ids": [7], // وكذلك هذه القيمة
      "active_model": "sale.order",
    };

    Api.printPdfReport(
      model: "ir.actions.report",
      method: "render_qweb_pdf",
      args: [417],
      kwargs: {"context": context},
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static yourFunctionToDownloadReport({
    required OnResponse<dynamic> onResponse,
  }) async {
    try {
      await Api.downloadPdfReport(
        reportName: "sale.report_saleorder",
        ids: [7],
        model: 'sale.order',
      );
      // الكود هنا سيتم تنفيذه بعد نجاح تحميل التقرير
      print("تم تحميل التقرير بنجاح.");
    } catch (e) {
      // التعامل مع أي أخطاء قد تحدث أثناء تحميل التقرير
      print("حدث خطأ أثناء تحميل التقرير: $e");
    }
  }

  static createSaleOrder({
    required Map<String, dynamic>? maps,
    bool? showGlobalLoading,
    required OnResponse onResponse,
  }) async {
    Map<String, dynamic> newMap = Map.from(maps!);
    await Module.createModule(
      showGlobalLoading: showGlobalLoading,
      model: "sale.order",
      maps: newMap,
      onResponse: (response) {
        onResponse(response);
      },
    );
  }

  static updateSaleOrder({
    required Map<String, dynamic>? maps,
    required List<int> ids,
    required OnResponse onResponse,
  }) async {
    Map<String, dynamic> newMap = Map.from(maps!);
    await Module.writeModule(
      model: "sale.order",
      ids: ids,
      values: newMap,
      onResponse: (response) {
        onResponse(response);
      },
    );
  }

  static confirmOrder({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "sale.order",
      method: "action_confirm",
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
