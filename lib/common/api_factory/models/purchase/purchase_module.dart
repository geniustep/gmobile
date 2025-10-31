import 'package:gsloution_mobile/common/api_factory/models/purchase/purchase_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class PurchaseModule {
  PurchaseModule._();
  static readPurchase({
    required List<int> ids,
    required OnResponse<List<PurchaseModel>> onResponse,
  }) {
    List<String> fields = [
      "state",
      "invoice_count",
      "invoice_ids",
      "picking_count",
      "picking_ids",
      "name",
      "partner_id",
      "partner_ref",
      "currency_id",
      "is_shipped",
      "date_order",
      "date_approve",
      "origin",
      "company_id",
      "order_line",
      "amount_untaxed",
      "amount_tax",
      "amount_total",
      "notes",
      "date_planned",
      "picking_type_id",
      "dest_address_id",
      "default_location_dest_id_usage",
      "incoterm_id",
      "user_id",
      "invoice_status",
      "payment_term_id",
      "fiscal_position_id",
      "message_follower_ids",
      "activity_state",
      "activity_user_id",
      "activity_type_id",
      "activity_date_deadline",
      "activity_summary",
      "activity_exception_decoration",
      "activity_exception_icon",
      "message_is_follower",
      "message_partner_ids",
      "message_channel_ids",
      "message_ids",
      "id",
      "display_name",
      "product_id",
      "currency_rate",
      "group_id",
      "is_shipped",
      "activity_ids",
    ];
    Api.read(
      model: "purchase.order",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<PurchaseModel> purchase = [];
        for (var element in response) {
          purchase.add(PurchaseModel.fromJson(element));
        }
        onResponse(purchase);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadPurchase({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<PurchaseModel>>> onResponse,
    List? groupby,
  }) {
    List<String> fields = [
      "state",
      "invoice_count",
      "invoice_ids",
      "picking_count",
      "picking_ids",
      "name",
      "partner_id",
      "partner_ref",
      "currency_id",
      "is_shipped",
      "date_order",
      "date_approve",
      "origin",
      "company_id",
      "order_line",
      "amount_untaxed",
      "amount_tax",
      "amount_total",
      "notes",
      "date_planned",
      "picking_type_id",
      "dest_address_id",
      "default_location_dest_id_usage",
      "incoterm_id",
      "user_id",
      "invoice_status",
      "payment_term_id",
      "fiscal_position_id",
      "message_follower_ids",
      "activity_state",
      "activity_user_id",
      "activity_type_id",
      "activity_date_deadline",
      "activity_summary",
      "activity_exception_decoration",
      "activity_exception_icon",
      "message_is_follower",
      "message_partner_ids",
      "message_channel_ids",
      "message_ids",
      "id",
      "display_name",
      "product_id",
      "currency_rate",
      "group_id",
      "is_shipped",
      "activity_ids",
    ];
    const int LIMIT = 80;
    List<PurchaseModel> purchase = [];
    Api.searchRead(
      model: "purchase.order",
      domain: domain,
      limit: LIMIT,
      offset: offset,
      fields: fields,
      order: "id",
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            purchase.add(PurchaseModel.fromJson(element));
          }
          onResponse({response["length"]: purchase});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static addPurchae({
    required Map<String, dynamic>? maps,
    required OnResponse onResponse,
  }) async {
    Map<String, dynamic> newMap = Map.from(maps!);
    await Module.addModule(
      model: "purchase.order",
      maps: newMap,
      onResponse: (response) {
        onResponse(response);
      },
    );
  }

  static confirmPurchase({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "purchase.order",
      method: "button_confirm",
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
