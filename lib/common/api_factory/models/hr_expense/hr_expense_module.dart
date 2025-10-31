import 'package:gsloution_mobile/common/api_factory/models/hr_expense/hr_expens_model.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class HrExpenseModule {
  HrExpenseModule._();

  static readHrExpense({
    required List<int> ids,
    List<String>? fields,
    required OnResponse<List<HrExpenseModel>> onResponse,
  }) {
    List<String> fields = [
      "name",
      "date",
      "employee_id",
      "product_id",
      "product_uom_id",
      "product_uom_category_id",
      "unit_amount",
      "quantity",
      "tax_ids",
      "untaxed_amount",
      "total_amount",
      "company_currency_id",
      "total_amount_company",
      "company_id",
      "currency_id",
      "analytic_account_id",
      "analytic_tag_ids",
      "account_id",
      "description",
      "payment_mode",
      "attachment_number",
      "state",
      "sheet_id",
      "reference",
      "is_refused",
      "is_editable",
      "is_ref_editable",
      "sale_order_id",
      "can_be_reinvoiced",
      "activity_ids",
      "activity_state",
      "activity_user_id",
      "activity_type_id",
      "activity_date_deadline",
      "activity_summary",
      "activity_exception_decoration",
      "activity_exception_icon",
      "message_is_follower",
      "message_follower_ids",
      "message_partner_ids",
      "message_channel_ids",
      "message_ids",
      "message_unread",
      "message_unread_counter",
      "message_needaction",
      "message_needaction_counter",
      "message_has_error",
      "message_has_error_counter",
      "message_attachment_count",
      "message_main_attachment_id",
      "website_message_ids",
      "message_has_sms_error",
      "id",
      "display_name",
      "create_uid",
      "create_date",
      "write_uid",
      "write_date",
      "__last_update",
    ];
    Api.read(
      model: "hr.expense",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          List<HrExpenseModel> hrExpense = [];
          for (var element in response) {
            hrExpense.add(
              HrExpenseModel.fromJson(element as Map<String, dynamic>),
            );
          }
          onResponse(hrExpense);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadHrExpense({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<HrExpenseModel>>> onResponse,
    List? groupby,
    List<String>? fields,
  }) {
    List<String> fields = [
      "name",
      "date",
      "employee_id",
      "product_id",
      "product_uom_id",
      "product_uom_category_id",
      "unit_amount",
      "quantity",
      "tax_ids",
      "untaxed_amount",
      "total_amount",
      "company_currency_id",
      "total_amount_company",
      "company_id",
      "currency_id",
      "analytic_account_id",
      "analytic_tag_ids",
      "account_id",
      "description",
      "payment_mode",
      "attachment_number",
      "state",
      "sheet_id",
      "reference",
      "is_refused",
      "is_editable",
      "is_ref_editable",
      "sale_order_id",
      "can_be_reinvoiced",
      "activity_ids",
      "activity_state",
      "activity_user_id",
      "activity_type_id",
      "activity_date_deadline",
      "activity_summary",
      "activity_exception_decoration",
      "activity_exception_icon",
      "message_is_follower",
      "message_follower_ids",
      "message_partner_ids",
      "message_channel_ids",
      "message_ids",
      "message_unread",
      "message_unread_counter",
      "message_needaction",
      "message_needaction_counter",
      "message_has_error",
      "message_has_error_counter",
      "message_attachment_count",
      "message_main_attachment_id",
      "website_message_ids",
      "message_has_sms_error",
      "id",
      "display_name",
      "create_uid",
      "create_date",
      "write_uid",
      "write_date",
      "__last_update",
    ];
    const int LIMIT = 80;
    List<HrExpenseModel> hrExpense = [];
    Api.searchRead(
      model: "hr.expense",
      domain: domain,
      limit: LIMIT,
      offset: offset,
      fields: fields,
      order: "id",
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            hrExpense.add(
              HrExpenseModel.fromJson(element as Map<String, dynamic>),
            );
          }
          onResponse({response["length"]: hrExpense});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static readHrExpenseSheet({
    required List<int> ids,
    List<String>? fields,
    required OnResponse<List<HrExpenseModel>> onResponse,
  }) {
    List<String> fields = [
      "name",
      "employee_id",
      "total_amount",
      "company_id",
      "currency_id",
      "payment_mode",
      "attachment_number",
      "state",
      "id",
      "display_name",
    ];
    Api.read(
      model: "hr.expense.sheet",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          List<HrExpenseModel> hrExpense = [];
          for (var element in response) {
            hrExpense.add(
              HrExpenseModel.fromJson(element as Map<String, dynamic>),
            );
          }
          onResponse(hrExpense);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadHrExpenseSheet({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<HrExpenseModel>>> onResponse,
    List? groupby,
    List<String>? fields,
  }) {
    List<String> fields = [
      "name",
      "employee_id",
      "total_amount",
      "company_id",
      "currency_id",
      "payment_mode",
      "attachment_number",
      "state",
      "id",
      "display_name",
    ];
    const int limit = 80;
    List<HrExpenseModel> hrExpense = [];
    Api.searchRead(
      model: "hr.expense.sheet",
      domain: domain,
      limit: limit,
      offset: offset,
      fields: fields,
      order: "id",
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            hrExpense.add(
              HrExpenseModel.fromJson(element as Map<String, dynamic>),
            );
          }
          onResponse({response["length"]: hrExpense});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static createHrExpense({
    required Map<String, dynamic>? maps,
    int offset = 0,
    required OnResponse onResponse,
  }) {
    Map<String, dynamic>? newMaps = {};
    // _formKey.currentState!.fields['bank_journal_id'];
    maps!.forEach((key, value) {
      if (key != 'bank_journal_id') {
        newMaps[key] = value;
      }
    });

    Api.create(
      model: "hr.expense",
      values: newMaps,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }

  static submitExpenses({
    required List<int> args,
    required OnResponse onResponse,
    required int idBank,
  }) {
    Api.callKW(
      model: "hr.expense",
      method: "action_submit_expenses",
      args: args,
      onResponse: (response) {
        if (response != null) {
          writeByCashSheet(
            args: [response['res_id']],
            idBank: idBank,
            onResponse: (r) {
              onResponse(r);
              submitSheet(
                args: [response['res_id']],
                onResponse: (resSheet) {
                  approveExpense(
                    args: [response['res_id']],
                    onResponse: (resApprove) {
                      comptabiliseExpense(
                        args: [response['res_id']],
                        onResponse: (resComtabilite) {
                          if (resComtabilite != null) {
                            onResponse(response);
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static writeByCashSheet({
    required List<int> args,
    required OnResponse onResponse,
    required int idBank,
  }) {
    Api.callKW(
      model: "hr.expense.sheet",
      method: "write",
      args: [
        args,
        {"bank_journal_id": idBank},
      ],
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static submitSheet({
    required List<int> args,
    required OnResponse onResponse,
  }) {
    Api.callKW(
      model: "hr.expense.sheet",
      method: "action_submit_sheet",
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static approveExpense({
    required List<int> args,
    required OnResponse onResponse,
  }) {
    Api.callKW(
      model: "hr.expense.sheet",
      method: "approve_expense_sheets",
      args: args,
      onResponse: (response) {
        onResponse(response);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static comptabiliseExpense({
    required List<int> args,
    required OnResponse onResponse,
  }) {
    Api.callKW(
      model: "hr.expense.sheet",
      method: "action_sheet_move_create",
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
