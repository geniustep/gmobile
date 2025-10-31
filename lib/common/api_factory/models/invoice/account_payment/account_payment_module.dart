import 'package:gsloution_mobile/common/config/import.dart';

class AccountPaymentModule {
  AccountPaymentModule._();

  static readAccountPayment(
      {required List<int> ids,
      required OnResponse<List<AccountPaymentModel>> onResponse}) {
    List<String> fields = [
      "state",
      "move_line_ids",
      "reconciled_invoices_count",
      "has_invoices",
      "move_reconciled",
      "id",
      "name",
      "invoice_ids",
      "payment_type",
      "partner_type",
      "partner_id",
      "company_id",
      "amount",
      "journal_id",
      "destination_journal_id",
      "hide_payment_method",
      "payment_method_id",
      "payment_method_code",
      "payment_token_id",
      "partner_bank_account_id",
      "show_partner_bank_account",
      "require_partner_bank_account",
      "payment_transaction_id",
      "currency_id",
      "payment_date",
      "communication",
      "payment_difference",
      "payment_difference_handling",
      "writeoff_account_id",
      "writeoff_label",
      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
    ];
    Api.read(
      model: "account.payment",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<AccountPaymentModel> accountPayment = [];
        for (var element in response) {
          accountPayment.add(
              AccountPaymentModel.fromJson(element as Map<String, dynamic>));
        }
        onResponse(accountPayment);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadAccountPayment(
      {int offset = 0,
      required List domain,
      required OnResponse<Map<int, List<AccountPaymentModel>>> onResponse}) {
    List<String> fields = [
      "state",
      "move_line_ids",
      "reconciled_invoices_count",
      "has_invoices",
      "move_reconciled",
      "id",
      "name",
      "invoice_ids",
      "payment_type",
      "partner_type",
      "partner_id",
      "company_id",
      "amount",
      "journal_id",
      "destination_journal_id",
      "hide_payment_method",
      "payment_method_id",
      "payment_method_code",
      "payment_token_id",
      "partner_bank_account_id",
      "show_partner_bank_account",
      "require_partner_bank_account",
      "payment_transaction_id",
      "currency_id",
      "payment_date",
      "communication",
      "payment_difference",
      "payment_difference_handling",
      "writeoff_account_id",
      "writeoff_label",
      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
    ];
    const int LIMIT = 40;
    List<AccountPaymentModel> accountPayment = [];
    Api.searchRead(
        model: "account.payment",
        domain: domain,
        limit: LIMIT,
        offset: offset,
        fields: fields,
        onResponse: (response) {
          if (response != null) {
            for (var element in response["records"]) {
              accountPayment.add(AccountPaymentModel.fromJson(
                  element as Map<String, dynamic>));
            }
            onResponse({response["length"]: accountPayment});
          }
        },
        onError: (error, data) {
          handleApiError(error);
        });
  }

  static createAccountPayments(
      {required Map<String, dynamic>? maps,
      Map<String, dynamic>? context,
      required OnResponse onResponse}) {
    Api.callKW(
      model: "account.payment",
      method: "create",
      args: [maps],
      context: context,
      onResponse: (response) {
        Api.callKW(
          model: "account.payment",
          method: "post",
          args: [response],
          onResponse: (responsePost) {
            if (responsePost) {
              onResponse(responsePost);
            }
          },
          onError: (String error, Map<String, dynamic> data) {
            print('error');
          },
        );
      },
      onError: (String error, Map<String, dynamic> data) {
        print('error');
      },
    );
  }
}
