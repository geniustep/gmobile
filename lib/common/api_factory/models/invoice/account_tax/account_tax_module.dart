import 'package:gsloution_mobile/common/config/import.dart';

class AccountTaxModule {
  AccountTaxModule._();
  static readAccountTax(
      {required List<int> ids,
      required OnResponse<List<AccountTaxModel>> onResponse}) {
    List<String> fields = [
      "amount",
      "active",
      "amount_type",
      "analytic",
      "display_name",
      "id",
      "name",
      "description",
      "cash_basis_base_account_id",
      "cash_basis_transition_account_id",
      "children_tax_ids",
      "company_id",
      "country_id",
      "hide_tax_exigibility",
      "include_base_amount",
      "invoice_repartition_line_ids",
      "price_include",
      "refund_repartition_line_ids",
      "sequence",
      "tax_exigibility",
      "tax_group_id",
      "type_tax_use",
    ];
    Api.read(
      model: "account.tax",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<AccountTaxModel> accountTax = [];
        for (var element in response) {
          accountTax
              .add(AccountTaxModel.fromJson(element as Map<String, dynamic>));
        }
        onResponse(accountTax);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadAccountTax(
      {int offset = 0,
      required List domain,
      required OnResponse<Map<int, List<AccountTaxModel>>> onResponse}) {
    List<String> fields = [
      "amount",
      "active",
      "amount_type",
      "analytic",
      "display_name",
      "id",
      "name",
      "description",
      "cash_basis_base_account_id",
      "cash_basis_transition_account_id",
      "children_tax_ids",
      "company_id",
      "country_id",
      "hide_tax_exigibility",
      "include_base_amount",
      "invoice_repartition_line_ids",
      "price_include",
      "refund_repartition_line_ids",
      "sequence",
      "tax_exigibility",
      "tax_group_id",
      "type_tax_use",
    ];
    const int LIMIT = 40;
    List<AccountTaxModel> accountTax = [];
    Api.searchRead(
        model: "account.tax",
        domain: domain,
        limit: LIMIT,
        offset: offset,
        fields: fields,
        onResponse: (response) {
          if (response != null) {
            for (var element in response["records"]) {
              accountTax.add(
                  AccountTaxModel.fromJson(element as Map<String, dynamic>));
            }
            onResponse({response["length"]: accountTax});
          }
        },
        onError: (error, data) {
          handleApiError(error);
        });
  }
}
