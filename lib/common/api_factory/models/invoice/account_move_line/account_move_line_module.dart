import 'package:gsloution_mobile/common/config/import.dart';

class AccountMoveLineModule {
  AccountMoveLineModule._();
  static readAccountMoveLine({
    required List<int> ids,
    required OnResponse<List<AccountMoveLineModel>> onResponse,
    Map<String, dynamic>? context,
  }) {
    List<String> fields = [
      'move_id',
      'move_name',
      'date',
      'ref',
      'parent_state',
      'journal_id',
      'company_id',
      'company_currency_id',
      'country_id',
      'account_id',
      'account_internal_type',
      'account_root_id',
      'sequence',
      'name',
      'quantity',
      'price_unit',
      'discount',
      'debit',
      'credit',
      'balance',
      'amount_currency',
      'price_subtotal',
      'price_total',
      'reconciled',
      'blocked',
      'date_maturity',
      'currency_id',
      'partner_id',
      'product_uom_id',
      'product_id',
      'reconcile_model_id',
      'payment_id',
      'statement_line_id',
      'statement_id',
      'tax_ids',
      'tax_line_id',
      'tax_group_id',
      'tax_base_amount',
      'tax_exigible',
      'tax_repartition_line_id',
      'tag_ids',
      'tax_audit',
      'amount_residual',
      'amount_residual_currency',
      'full_reconcile_id',
      'matched_debit_ids',
      'matched_credit_ids',
      'analytic_line_ids',
      'analytic_account_id',
      'analytic_tag_ids',
      'recompute_tax_line',
      'display_type',
      'is_rounding_line',
      'exclude_from_invoice_tab',
      'always_set_currency_id',
      'expense_id',
      'purchase_line_id',
      'is_anglo_saxon_line',
      'sale_line_ids',
      'id',
      'display_name',
      'create_uid',
      'create_date',
      'write_uid',
      'write_date',
      '__last_update',
    ];
    Api.read(
      model: "account.move.line",
      ids: ids,
      fields: fields,
      // kwargs: context,
      onResponse: (response) {
        List<AccountMoveLineModel> accountMoveLine = [];
        for (var element in response) {
          accountMoveLine.add(
            AccountMoveLineModel.fromJson(element as Map<String, dynamic>),
          );
        }
        onResponse(accountMoveLine);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadAccountMoveLine({
    int offset = 0,
    required List domain,
    required OnResponse<Map<int, List<AccountMoveLineModel>>> onResponse,
  }) {
    List<String> fields = [
      'move_id',
      'move_name',
      'date',
      'ref',
      'parent_state',
      'journal_id',
      'company_id',
      'company_currency_id',
      'country_id',
      'account_id',
      'account_internal_type',
      'account_root_id',
      'sequence',
      'name',
      'quantity',
      'price_unit',
      'discount',
      'debit',
      'credit',
      'balance',
      'amount_currency',
      'price_subtotal',
      'price_total',
      'reconciled',
      'blocked',
      'date_maturity',
      'currency_id',
      'partner_id',
      'product_uom_id',
      'product_id',
      'reconcile_model_id',
      'payment_id',
      'statement_line_id',
      'statement_id',
      'tax_ids',
      'tax_line_id',
      'tax_group_id',
      'tax_base_amount',
      'tax_exigible',
      'tax_repartition_line_id',
      'tag_ids',
      'tax_audit',
      'amount_residual',
      'amount_residual_currency',
      'full_reconcile_id',
      'matched_debit_ids',
      'matched_credit_ids',
      'analytic_line_ids',
      'analytic_account_id',
      'analytic_tag_ids',
      'recompute_tax_line',
      'display_type',
      'is_rounding_line',
      'exclude_from_invoice_tab',
      'always_set_currency_id',
      'expense_id',
      'purchase_line_id',
      'is_anglo_saxon_line',
      'sale_line_ids',
      'id',
      'display_name',
      'create_uid',
      'create_date',
      'write_uid',
      'write_date',
      '__last_update',
    ];
    const int limit = 0;
    List<AccountMoveLineModel> account = [];
    Api.searchRead(
      model: "account.move.line",
      domain: domain,
      limit: limit,
      offset: offset,
      fields: fields,
      onResponse: (response) {
        if (response != null) {
          for (var element in response["records"]) {
            account.add(AccountMoveLineModel.fromJson(element));
          }
          onResponse({response["length"]: account});
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadAccountMoveLineBalance({
    required List domain,
    required OnResponse<Map<int, List<AccountMoveLineModel>>> onResponse,
  }) {
    List<dynamic> fields = [
      'move_id',
      'move_name',
      'date',
      'ref',
      'parent_state',
      'journal_id',
      'company_id',
      'company_currency_id',
      'country_id',
      'account_id',
      'account_internal_type',
      'account_root_id',
      'sequence',
      'name',
      'quantity',
      'price_unit',
      'discount',
      'debit',
      'credit',
      'balance',
      'amount_currency',
      'price_subtotal',
      'price_total',
      'reconciled',
      'blocked',
      'date_maturity',
      'currency_id',
      'partner_id',
      'product_uom_id',
      'product_id',
      'reconcile_model_id',
      'payment_id',
      'statement_line_id',
      'statement_id',
      'tax_ids',
      'tax_line_id',
      'tax_group_id',
      'tax_base_amount',
      'tax_exigible',
      'tax_repartition_line_id',
      'tag_ids',
      'tax_audit',
      'amount_residual',
      'amount_residual_currency',
      'full_reconcile_id',
      'matched_debit_ids',
      'matched_credit_ids',
      'analytic_line_ids',
      'analytic_account_id',
      'analytic_tag_ids',
      'recompute_tax_line',
      'display_type',
      'is_rounding_line',
      'exclude_from_invoice_tab',
      'always_set_currency_id',
      'expense_id',
      'purchase_line_id',
      'is_anglo_saxon_line',
      'sale_line_ids',
      'id',
      'display_name',
      'create_uid',
      'create_date',
      'write_uid',
      'write_date',
      '__last_update',
    ];

    List<dynamic> newdomaine = [
      [
        "display_type",
        "not in",
        ["line_section", "line_note"],
      ],
      "&",
      "&",
      ["move_id.state", "=", "posted"],
      "&",
      "&",
      ["full_reconcile_id", "=", false],
      ["balance", "!=", 0],
      ["account_id.reconcile", "=", true],
      "|",
      ["account_id.internal_type", "=", "payable"],
      ["account_id.internal_type", "=", "receivable"],
    ];
    List<AccountMoveLineModel> account = [];
    var groupby = ["partner_id"];
    var kwargs = {"domain": newdomaine, "fields": fields, "groupby": groupby};
    Api.callKW(
      kwargs: kwargs,
      model: "account.move.line",
      method: "web_read_group",
      args: [],
      onResponse: (response) {
        try {
          if (response != null) {
            for (var element in response["groups"]) {
              account.add(AccountMoveLineModel.fromJson(element));
            }
            onResponse({response["length"]: account});
          }
        } catch (e) {
          print(e);
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }
}
