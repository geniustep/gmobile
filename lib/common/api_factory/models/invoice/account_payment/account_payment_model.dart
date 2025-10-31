import 'package:json_annotation/json_annotation.dart';

part 'account_payment_model.g.dart';

@JsonSerializable()
class AccountPaymentModel {
  @JsonKey(name: "state")
  dynamic state;
  @JsonKey(name: "move_line_ids")
  dynamic moveLineIds;
  @JsonKey(name: "reconciled_invoices_count")
  dynamic reconciledInvoicesCount;
  @JsonKey(name: "has_invoices")
  dynamic hasInvoices;
  @JsonKey(name: "move_reconciled")
  dynamic moveReconciled;
  @JsonKey(name: "id")
  dynamic id;
  @JsonKey(name: "name")
  dynamic name;
  @JsonKey(name: "invoice_ids")
  dynamic invoiceIds;
  @JsonKey(name: "payment_type")
  dynamic paymentType;
  @JsonKey(name: "partner_type")
  dynamic partnerType;
  @JsonKey(name: "partner_id")
  dynamic partnerId;
  @JsonKey(name: "company_id")
  dynamic companyId;
  @JsonKey(name: "amount")
  dynamic amount;
  @JsonKey(name: "journal_id")
  dynamic journalId;
  @JsonKey(name: "destination_journal_id")
  dynamic destinationJournalId;
  @JsonKey(name: "hide_payment_method")
  dynamic hidePaymentMethod;
  @JsonKey(name: "payment_method_id")
  dynamic paymentMethodId;
  @JsonKey(name: "payment_method_code")
  dynamic paymentMethodCode;
  @JsonKey(name: "payment_token_id")
  dynamic paymentTokenId;
  @JsonKey(name: "partner_bank_account_id")
  dynamic partnerBankAccountId;
  @JsonKey(name: "show_partner_bank_account")
  dynamic showPartnerBankAccount;
  @JsonKey(name: "require_partner_bank_account")
  dynamic requirePartnerBankAccount;
  @JsonKey(name: "payment_transaction_id")
  dynamic paymentTransactionId;
  @JsonKey(name: "currency_id")
  dynamic currencyId;
  @JsonKey(name: "payment_date")
  dynamic paymentDate;
  @JsonKey(name: "communication")
  dynamic communication;
  @JsonKey(name: "payment_difference")
  dynamic paymentDifference;
  @JsonKey(name: "payment_difference_handling")
  dynamic paymentDifferenceHandling;
  @JsonKey(name: "writeoff_account_id")
  dynamic writeoffAccountId;
  @JsonKey(name: "writeoff_label")
  dynamic writeoffLabel;
  @JsonKey(name: "message_follower_ids")
  dynamic messageFollowerIds;
  @JsonKey(name: "activity_ids")
  dynamic activityIds;
  @JsonKey(name: "message_ids")
  dynamic messageIds;
  @JsonKey(name: "message_attachment_count")
  dynamic messageAttachmentCount;

  AccountPaymentModel({
    this.state,
    this.moveLineIds,
    this.reconciledInvoicesCount,
    this.hasInvoices,
    this.moveReconciled,
    this.id,
    this.name,
    this.invoiceIds,
    this.paymentType,
    this.partnerType,
    this.partnerId,
    this.companyId,
    this.amount,
    this.journalId,
    this.destinationJournalId,
    this.hidePaymentMethod,
    this.paymentMethodId,
    this.paymentMethodCode,
    this.paymentTokenId,
    this.partnerBankAccountId,
    this.showPartnerBankAccount,
    this.requirePartnerBankAccount,
    this.paymentTransactionId,
    this.currencyId,
    this.paymentDate,
    this.communication,
    this.paymentDifference,
    this.paymentDifferenceHandling,
    this.writeoffAccountId,
    this.writeoffLabel,
    this.messageFollowerIds,
    this.activityIds,
    this.messageIds,
    this.messageAttachmentCount,
  });

  factory AccountPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$AccountPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPaymentModelToJson(this);
}
