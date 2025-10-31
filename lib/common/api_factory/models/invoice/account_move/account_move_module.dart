import 'package:gsloution_mobile/common/api_factory/api_end_points.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class AccountMoveModule {
  AccountMoveModule._();
  static readInvoice({
    required List<int> ids,
    required OnResponse<List<AccountMoveModel>> onResponse,
  }) {
    List<String> fields = [
      'name',
      'date',
      'ref',
      'narration',
      'state',
      'type',
      'type_name',
      'to_check',
      'journal_id',
      'company_id',
      'company_currency_id',
      'currency_id',
      'line_ids',
      'partner_id',
      'commercial_partner_id',
      'amount_untaxed',
      'amount_tax',
      'amount_total',
      'amount_residual',
      'amount_untaxed_signed',
      'amount_tax_signed',
      'amount_total_signed',
      'amount_residual_signed',
      'amount_by_group',
      'tax_cash_basis_rec_id',
      'auto_post',
      'reversed_entry_id',
      'reversal_move_id',
      'fiscal_position_id',
      'invoice_user_id',
      'user_id',
      'invoice_payment_state',
      'invoice_date',
      'invoice_date_due',
      'invoice_payment_ref',
      'invoice_sent',
      'invoice_origin',
      'invoice_payment_term_id',
      'invoice_line_ids',
      'invoice_partner_bank_id',
      'invoice_incoterm_id',
      'invoice_outstanding_credits_debits_widget',
      'invoice_payments_widget',
      'invoice_has_outstanding',
      'invoice_vendor_bill_id',
      'invoice_source_email',
      'invoice_partner_display_name',
      'invoice_partner_icon',
      'invoice_cash_rounding_id',
      'invoice_sequence_number_next',
      'invoice_sequence_number_next_prefix',
      'invoice_filter_type_domain',
      'bank_partner_id',
      'invoice_has_matching_suspense_amount',
      'tax_lock_date_message',
      'has_reconciled_entries',
      'restrict_mode_hash_table',
      'secure_sequence_number',
      'inalterable_hash',
      'string_to_hash',
      'transaction_ids',
      'authorized_transaction_ids',
      'purchase_vendor_bill_id',
      'purchase_id',
      'stock_move_id',
      'stock_valuation_layer_ids',
      'pos_order_ids',
      'team_id',
      'partner_shipping_id',
      'timesheet_ids',
      'timesheet_count',
      'campaign_id',
      'source_id',
      'medium_id',
      'activity_ids',
      'activity_state',
      'activity_user_id',
      'activity_type_id',
      'activity_date_deadline',
      'activity_summary',
      'activity_exception_decoration',
      'activity_exception_icon',
      'message_is_follower',
      'message_follower_ids',
      'message_partner_ids',
      'message_channel_ids',
      'message_ids',
      'message_unread',
      'message_unread_counter',
      'message_needaction',
      'message_needaction_counter',
      'message_has_error',
      'message_has_error_counter',
      'message_attachment_count',
      'message_main_attachment_id',
      'website_message_ids',
      'message_has_sms_error',
      'access_url',
      'access_token',
      'access_warning',
      'id',
      'display_name',
      'create_uid',
      'create_date',
      'write_uid',
      'write_date',
      '__last_update',
    ];
    Api.read(
      model: "account.move",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<AccountMoveModel> invoices = [];
        for (var element in response) {
          invoices.add(
            AccountMoveModel.fromJson(element as Map<String, dynamic>),
          );
        }
        onResponse(invoices);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadAccountMove({
    required OnResponse onResponse,
    dynamic domain,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    List<String> fields = [];
    domain = [];
    try {
      await Module.getRecordsController<AccountMoveModel>(
        model: "account.move",
        fields: fields,
        domain: domain,
        fromJson: (data) => AccountMoveModel.fromJson(data),
        onResponse: (response) {
          print("Productos obtenidos: ${response.length}");
          onResponse(response);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo invoice: $e");
      handleApiError(e);
    }
  }

  static searchInvoicePartnersId({
    int offset = 0,
    List<dynamic>? domain,
    required OnResponse<dynamic> onResponse,
  }) {
    List<String> fields = ["partner_id"];
    Api.searchRead(
      model: "account.move",
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

  static loadViewInvoice({
    required List<int> args,
    required OnResponse onResponse,
    Map<String, dynamic>? context,
    Map<String, dynamic>? kwargs,
  }) {
    Api.callKW(
      model: "account.move",
      method: "load_views",
      kwargs: kwargs,
      args: args,
      context: context,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static createSaleAdvancePaymentInv({
    required Map<String, dynamic>? maps,
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<SalesAdvancePaymentInvoice>>> onResponse,
  }) {
    Map<String, dynamic> newMap = Map.from(maps!);
    Api.create(
      model: "sale.advance.payment.inv",
      values: newMap,
      onResponse: (response) {
        // onResponse(response);
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static confirmInvoice({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "account.move",
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

  static cancelMethod({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "account.move",
      method: "action_cancel",
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static draftMethod({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "account.move",
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

  static createInvoiceCall({
    required List<int> args,
    required int id,
    required OnResponse<dynamic> onResponse,
  }) {
    Map<String, dynamic> context = {};
    context["params"] = {
      "action": 289,
      "cids": 1,
      "id": id,
      "menu_id": 170,
      "model": "sale.order",
      "view_type": "form",
    };
    context["create"] = false;
    context["active_model"] = "sale.order";
    context["active_id"] = id;
    context["active_ids"] = [id];
    context["open_invoices"] = true;

    Api.callKW(
      model: "sale.advance.payment.inv",
      method: "create_invoices",
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

  static createInvoiceSales({
    required Map<String, dynamic>? maps,
    Map<String, dynamic>? kwargs,
    required OnResponse onResponse,
    required List<int> args,
  }) {
    Api.callKW(
      model: "sale.advance.payment.inv",
      method: "create",
      args: [maps],
      kwargs: {"context": kwargs},
      onResponse: (response) {
        onResponse(response);
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static comptabliseInvoiceSales({
    required List<int> args,
    required OnResponse<bool> onResponse,
  }) {
    Api.callKW(
      model: "account.move",
      method: "action_post",
      args: [args],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static createInvoicePurchase({
    Map<String, dynamic>? kwargs,
    required OnResponse onResponse,
    required List<int> args,
  }) {
    Api.callKW(
      model: "purchase.order",
      method: "action_view_invoice",
      args: [args],
      kwargs: {
        "context": {
          "lang": "fr_FR",
          "tz": "Africa/Casablanca",
          "uid": 2,
          "allowed_company_ids": [1],
        },
      },
      onResponse: (response) {
        onResponse(response);
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static confirmInvoicePurchase({
    Map<String, dynamic>? kwargs,
    required OnResponse onResponse,
    required String method,
    required List<int> args,
  }) {
    var model = "purchase.order";
    var params = {
      "model": model,
      "method": method,
      "args": args,
      "kwargs": kwargs ?? {},
    };
    Api.request(
      method: HttpMethod.post,
      path: ApiEndPoints.getCallKWEndPoint(model, method),
      params: Api.createPayload(params),
      onResponse: (response) {
        try {
          onResponse(response);
        } catch (e) {
          print(e);
        }
      },
      onError: (error, data) {
        print('error');
      },
    );
  }

  static createInvoicePurchaseCall({
    required Map<String, dynamic> invoiceData,
    // required int id,
    required OnResponse<dynamic> onResponse,
  }) {
    List<dynamic> args = [invoiceData];

    Api.callKW(
      model: "account.move",
      method: "create",
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
