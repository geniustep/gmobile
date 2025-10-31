import 'package:json_annotation/json_annotation.dart';

part 'account_journal_model.g.dart';

@JsonSerializable()
class AccountJournalModel {
  @JsonKey(name: "id")
  dynamic id;
  @JsonKey(name: "name")
  dynamic name;
  @JsonKey(name: "active")
  dynamic active;
  @JsonKey(name: "type")
  dynamic type;
  @JsonKey(name: "company_id")
  dynamic companyId;
  @JsonKey(name: "company_partner_id")
  dynamic companyPartnerId;
  @JsonKey(name: "bank_account_id")
  dynamic bankAccountId;
  @JsonKey(name: "bank_id")
  dynamic bankId;
  @JsonKey(name: "bank_statements_source")
  dynamic bankStatementsSource;
  @JsonKey(name: "code")
  dynamic code;
  @JsonKey(name: "sequence_number_next")
  dynamic sequence_number_next;
  @JsonKey(name: "sequence_id")
  dynamic sequence_id;
  @JsonKey(name: "refund_sequence")
  dynamic refund_sequence;
  @JsonKey(name: "refund_sequence_number_next")
  dynamic refund_sequence_number_next;
  @JsonKey(name: "refund_sequence_id")
  dynamic refund_sequence_id;
  @JsonKey(name: "default_debit_account_id")
  dynamic default_debit_account_id;
  @JsonKey(name: "default_credit_account_id")
  dynamic default_credit_account_id;
  @JsonKey(name: "currency_id")
  dynamic currency_id;
  @JsonKey(name: "invoice_reference_type")
  dynamic invoice_reference_type;
  @JsonKey(name: "invoice_reference_model")
  dynamic invoice_reference_model;
  @JsonKey(name: "alias_id")
  dynamic alias_id;
  @JsonKey(name: "alias_name")
  dynamic alias_name;
  @JsonKey(name: "alias_domain")
  dynamic alias_domain;
  @JsonKey(name: "profit_account_id")
  dynamic profit_account_id;
  @JsonKey(name: "loss_account_id")
  dynamic loss_account_id;
  @JsonKey(name: "post_at")
  dynamic post_at;
  @JsonKey(name: "type_control_ids")
  dynamic type_control_ids;
  @JsonKey(name: "account_control_ids")
  dynamic account_control_ids;
  @JsonKey(name: "restrict_mode_hash_table")
  dynamic restrict_mode_hash_table;
  @JsonKey(name: "inbound_payment_method_ids")
  dynamic inbound_payment_method_ids;
  @JsonKey(name: "outbound_payment_method_ids")
  dynamic outbound_payment_method_ids;
  @JsonKey(name: "message_follower_ids")
  dynamic message_follower_ids;
  @JsonKey(name: "activity_ids")
  dynamic activity_ids;
  @JsonKey(name: "message_ids")
  dynamic message_ids;
  @JsonKey(name: "message_attachment_count")
  dynamic message_attachment_count;
  @JsonKey(name: "display_name")
  dynamic displayName;
  @JsonKey(name: "inbound_payment_method_line_ids")
  dynamic inboundPaymentMethodLineIds;
  @JsonKey(name: "outbound_payment_method_line_ids")
  dynamic outboundPaymentMethodLineIds;

  AccountJournalModel({
    this.id,
    this.name,
    this.active,
    this.type,
    this.companyId,
    this.companyPartnerId,
    this.bankAccountId,
    this.bankId,
    this.bankStatementsSource,
    this.code,
    this.sequence_number_next,
    this.sequence_id,
    this.refund_sequence,
    this.refund_sequence_number_next,
    this.refund_sequence_id,
    this.default_debit_account_id,
    this.default_credit_account_id,
    this.currency_id,
    this.invoice_reference_type,
    this.invoice_reference_model,
    this.alias_id,
    this.alias_name,
    this.alias_domain,
    this.profit_account_id,
    this.loss_account_id,
    this.post_at,
    this.type_control_ids,
    this.account_control_ids,
    this.restrict_mode_hash_table,
    this.inbound_payment_method_ids,
    this.outbound_payment_method_ids,
    this.message_follower_ids,
    this.activity_ids,
    this.message_ids,
    this.message_attachment_count,
    this.displayName,
    this.inboundPaymentMethodLineIds,
    this.outboundPaymentMethodLineIds,
  });

  factory AccountJournalModel.fromJson(Map<String, dynamic> json) =>
      _$AccountJournalModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountJournalModelToJson(this);
}
