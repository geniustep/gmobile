// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountPaymentModel _$AccountPaymentModelFromJson(Map<String, dynamic> json) =>
    AccountPaymentModel(
      state: json['state'],
      moveLineIds: json['move_line_ids'],
      reconciledInvoicesCount: json['reconciled_invoices_count'],
      hasInvoices: json['has_invoices'],
      moveReconciled: json['move_reconciled'],
      id: json['id'],
      name: json['name'],
      invoiceIds: json['invoice_ids'],
      paymentType: json['payment_type'],
      partnerType: json['partner_type'],
      partnerId: json['partner_id'],
      companyId: json['company_id'],
      amount: json['amount'],
      journalId: json['journal_id'],
      destinationJournalId: json['destination_journal_id'],
      hidePaymentMethod: json['hide_payment_method'],
      paymentMethodId: json['payment_method_id'],
      paymentMethodCode: json['payment_method_code'],
      paymentTokenId: json['payment_token_id'],
      partnerBankAccountId: json['partner_bank_account_id'],
      showPartnerBankAccount: json['show_partner_bank_account'],
      requirePartnerBankAccount: json['require_partner_bank_account'],
      paymentTransactionId: json['payment_transaction_id'],
      currencyId: json['currency_id'],
      paymentDate: json['payment_date'],
      communication: json['communication'],
      paymentDifference: json['payment_difference'],
      paymentDifferenceHandling: json['payment_difference_handling'],
      writeoffAccountId: json['writeoff_account_id'],
      writeoffLabel: json['writeoff_label'],
      messageFollowerIds: json['message_follower_ids'],
      activityIds: json['activity_ids'],
      messageIds: json['message_ids'],
      messageAttachmentCount: json['message_attachment_count'],
    );

Map<String, dynamic> _$AccountPaymentModelToJson(
        AccountPaymentModel instance) =>
    <String, dynamic>{
      'state': instance.state,
      'move_line_ids': instance.moveLineIds,
      'reconciled_invoices_count': instance.reconciledInvoicesCount,
      'has_invoices': instance.hasInvoices,
      'move_reconciled': instance.moveReconciled,
      'id': instance.id,
      'name': instance.name,
      'invoice_ids': instance.invoiceIds,
      'payment_type': instance.paymentType,
      'partner_type': instance.partnerType,
      'partner_id': instance.partnerId,
      'company_id': instance.companyId,
      'amount': instance.amount,
      'journal_id': instance.journalId,
      'destination_journal_id': instance.destinationJournalId,
      'hide_payment_method': instance.hidePaymentMethod,
      'payment_method_id': instance.paymentMethodId,
      'payment_method_code': instance.paymentMethodCode,
      'payment_token_id': instance.paymentTokenId,
      'partner_bank_account_id': instance.partnerBankAccountId,
      'show_partner_bank_account': instance.showPartnerBankAccount,
      'require_partner_bank_account': instance.requirePartnerBankAccount,
      'payment_transaction_id': instance.paymentTransactionId,
      'currency_id': instance.currencyId,
      'payment_date': instance.paymentDate,
      'communication': instance.communication,
      'payment_difference': instance.paymentDifference,
      'payment_difference_handling': instance.paymentDifferenceHandling,
      'writeoff_account_id': instance.writeoffAccountId,
      'writeoff_label': instance.writeoffLabel,
      'message_follower_ids': instance.messageFollowerIds,
      'activity_ids': instance.activityIds,
      'message_ids': instance.messageIds,
      'message_attachment_count': instance.messageAttachmentCount,
    };
