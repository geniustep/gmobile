import 'package:json_annotation/json_annotation.dart';

part 'account_move_model.g.dart';

@JsonSerializable()
class AccountMoveModel {
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'date')
  dynamic date;
  @JsonKey(name: 'ref')
  dynamic ref;
  @JsonKey(name: 'narration')
  dynamic narration;
  @JsonKey(name: 'state')
  dynamic state;
  @JsonKey(name: 'type')
  dynamic type;
  @JsonKey(name: 'type_name')
  dynamic typeName;
  @JsonKey(name: 'to_check')
  dynamic toCheck;
  @JsonKey(name: 'journal_id')
  dynamic journalId;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'company_currency_id')
  dynamic companyCurrencyId;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'line_ids')
  dynamic lineIds;
  @JsonKey(name: 'partner_id')
  dynamic partnerId;
  @JsonKey(name: 'commercial_partner_id')
  dynamic commercialPartnerId;
  @JsonKey(name: 'amount_untaxed')
  dynamic amountUntaxed;
  @JsonKey(name: 'amount_tax')
  dynamic amountTax;
  @JsonKey(name: 'amount_total')
  dynamic amountTotal;
  @JsonKey(name: 'amount_residual')
  dynamic amountResidual;
  @JsonKey(name: 'amount_untaxed_signed')
  dynamic amountUntaxedSigned;
  @JsonKey(name: 'amount_tax_signed')
  dynamic amountTaxSigned;
  @JsonKey(name: 'amount_total_signed')
  dynamic amountTotalSigned;
  @JsonKey(name: 'amount_residual_signed')
  dynamic amountResidualSigned;
  @JsonKey(name: 'amount_by_group')
  dynamic amountByGroup;
  @JsonKey(name: 'tax_cash_basis_rec_id')
  dynamic taxCashBasisRecId;
  @JsonKey(name: 'auto_post')
  dynamic autoPost;
  @JsonKey(name: 'reversed_entry_id')
  dynamic reversedEntryId;
  @JsonKey(name: 'reversal_move_id')
  dynamic reversalMoveId;
  @JsonKey(name: 'fiscal_position_id')
  dynamic fiscalPositionId;
  @JsonKey(name: 'invoice_user_id')
  dynamic invoiceUserId;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'invoice_payment_state')
  dynamic invoicePaymentState;
  @JsonKey(name: 'invoice_date')
  dynamic invoiceDate;
  @JsonKey(name: 'invoice_date_due')
  dynamic invoiceDateDue;
  @JsonKey(name: 'invoice_payment_ref')
  dynamic invoicePaymentRef;
  @JsonKey(name: 'invoice_sent')
  dynamic invoiceSent;
  @JsonKey(name: 'invoice_origin')
  dynamic invoiceOrigin;
  @JsonKey(name: 'invoice_payment_term_id')
  dynamic invoicePaymentTermId;
  @JsonKey(name: 'invoice_line_ids')
  dynamic invoiceLineIds;
  @JsonKey(name: 'invoice_partner_bank_id')
  dynamic invoicePartnerBankId;
  @JsonKey(name: 'invoice_incoterm_id')
  dynamic invoiceIncotermId;
  @JsonKey(name: 'invoice_outstanding_credits_debits_widget')
  dynamic invoiceOutstandingCreditsDebitsWidget;
  @JsonKey(name: 'invoice_payments_widget')
  dynamic invoicePaymentsWidget;
  @JsonKey(name: 'invoice_has_outstanding')
  dynamic invoiceHasOutstanding;
  @JsonKey(name: 'invoice_vendor_bill_id')
  dynamic invoiceVendorBillId;
  @JsonKey(name: 'invoice_source_email')
  dynamic invoiceSourceEmail;
  @JsonKey(name: 'invoice_partner_display_name')
  dynamic invoicePartnerDisplayName;
  @JsonKey(name: 'invoice_partner_icon')
  dynamic invoicePartnerIcon;
  @JsonKey(name: 'invoice_cash_rounding_id')
  dynamic invoiceCashRoundingId;
  @JsonKey(name: 'invoice_sequence_number_next')
  dynamic invoiceSequenceNumberNext;
  @JsonKey(name: 'invoice_sequence_number_next_prefix')
  dynamic invoiceSequenceNumberNextPrefix;
  @JsonKey(name: 'invoice_filter_type_domain')
  dynamic invoiceFilterTypeDomain;
  @JsonKey(name: 'bank_partner_id')
  dynamic bankPartnerId;
  @JsonKey(name: 'invoice_has_matching_suspense_amount')
  dynamic invoiceHasMatchingSuspenseAmount;
  @JsonKey(name: 'tax_lock_date_message')
  dynamic taxLockDateMessage;
  @JsonKey(name: 'has_reconciled_entries')
  dynamic hasReconciledEntries;
  @JsonKey(name: 'restrict_mode_hash_table')
  dynamic restrictModeHashTable;
  @JsonKey(name: 'secure_sequence_number')
  dynamic secureSequenceNumber;
  @JsonKey(name: 'inalterable_hash')
  dynamic inalterableHash;
  @JsonKey(name: 'string_to_hash')
  dynamic stringToHash;
  @JsonKey(name: 'transaction_ids')
  dynamic transactionIds;
  @JsonKey(name: 'authorized_transaction_ids')
  dynamic authorizedTransactionIds;
  @JsonKey(name: 'purchase_vendor_bill_id')
  dynamic purchaseVendorBillId;
  @JsonKey(name: 'purchase_id')
  dynamic purchaseId;
  @JsonKey(name: 'stock_move_id')
  dynamic stockMoveId;
  @JsonKey(name: 'stock_valuation_layer_ids')
  dynamic stockValuationLayerIds;
  @JsonKey(name: 'pos_order_ids')
  dynamic posOrderIds;
  @JsonKey(name: 'team_id')
  dynamic teamId;
  @JsonKey(name: 'partner_shipping_id')
  dynamic partnerShippingId;
  @JsonKey(name: 'timesheet_ids')
  dynamic timesheetIds;
  @JsonKey(name: 'timesheet_count')
  dynamic timesheetCount;
  @JsonKey(name: 'campaign_id')
  dynamic campaignId;
  @JsonKey(name: 'source_id')
  dynamic sourceId;
  @JsonKey(name: 'medium_id')
  dynamic mediumId;
  @JsonKey(name: 'activity_ids')
  dynamic activityIds;
  @JsonKey(name: 'activity_state')
  dynamic activityState;
  @JsonKey(name: 'activity_user_id')
  dynamic activityUserId;
  @JsonKey(name: 'activity_type_id')
  dynamic activityTypeId;
  @JsonKey(name: 'activity_date_deadline')
  dynamic activityDateDeadline;
  @JsonKey(name: 'activity_summary')
  dynamic activitySummary;
  @JsonKey(name: 'activity_exception_decoration')
  dynamic activityExceptionDecoration;
  @JsonKey(name: 'activity_exception_icon')
  dynamic activityExceptionIcon;
  @JsonKey(name: 'message_is_follower')
  dynamic messageIsFollower;
  @JsonKey(name: 'message_follower_ids')
  dynamic messageFollowerIds;
  @JsonKey(name: 'message_partner_ids')
  dynamic messagePartnerIds;
  @JsonKey(name: 'message_channel_ids')
  dynamic messageChannelIds;
  @JsonKey(name: 'message_ids')
  dynamic messageIds;
  @JsonKey(name: 'message_unread')
  dynamic messageUnread;
  @JsonKey(name: 'message_unread_counter')
  dynamic messageUnreadCounter;
  @JsonKey(name: 'message_needaction')
  dynamic messageNeedaction;
  @JsonKey(name: 'message_needaction_counter')
  dynamic messageNeedactionCounter;
  @JsonKey(name: 'message_has_error')
  dynamic messageHasError;
  @JsonKey(name: 'message_has_error_counter')
  dynamic messageHasErrorCounter;
  @JsonKey(name: 'message_attachment_count')
  dynamic messageAttachmentCount;
  @JsonKey(name: 'message_main_attachment_id')
  dynamic messageMainAttachmentId;
  @JsonKey(name: 'website_message_ids')
  dynamic websiteMessageIds;
  @JsonKey(name: 'message_has_sms_error')
  dynamic messageHasSmsError;
  @JsonKey(name: 'access_url')
  dynamic accessUrl;
  @JsonKey(name: 'access_token')
  dynamic accessToken;
  @JsonKey(name: 'access_warning')
  dynamic accessWarning;
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'display_name')
  dynamic displayName;
  @JsonKey(name: 'create_uid')
  dynamic createUid;
  @JsonKey(name: 'create_date')
  dynamic createDate;
  @JsonKey(name: 'write_uid')
  dynamic writeUid;
  @JsonKey(name: 'write_date')
  dynamic writeDate;
  @JsonKey(name: '__last_update')
  dynamic lastUpdate;

  AccountMoveModel({
    this.name,
    this.date,
    this.ref,
    this.narration,
    this.state,
    this.type,
    this.typeName,
    this.toCheck,
    this.journalId,
    this.companyId,
    this.companyCurrencyId,
    this.currencyId,
    this.lineIds,
    this.partnerId,
    this.commercialPartnerId,
    this.amountUntaxed,
    this.amountTax,
    this.amountTotal,
    this.amountResidual,
    this.amountUntaxedSigned,
    this.amountTaxSigned,
    this.amountTotalSigned,
    this.amountResidualSigned,
    this.amountByGroup,
    this.taxCashBasisRecId,
    this.autoPost,
    this.reversedEntryId,
    this.reversalMoveId,
    this.fiscalPositionId,
    this.invoiceUserId,
    this.userId,
    this.invoicePaymentState,
    this.invoiceDate,
    this.invoiceDateDue,
    this.invoicePaymentRef,
    this.invoiceSent,
    this.invoiceOrigin,
    this.invoicePaymentTermId,
    this.invoiceLineIds,
    this.invoicePartnerBankId,
    this.invoiceIncotermId,
    this.invoiceOutstandingCreditsDebitsWidget,
    this.invoicePaymentsWidget,
    this.invoiceHasOutstanding,
    this.invoiceVendorBillId,
    this.invoiceSourceEmail,
    this.invoicePartnerDisplayName,
    this.invoicePartnerIcon,
    this.invoiceCashRoundingId,
    this.invoiceSequenceNumberNext,
    this.invoiceSequenceNumberNextPrefix,
    this.invoiceFilterTypeDomain,
    this.bankPartnerId,
    this.invoiceHasMatchingSuspenseAmount,
    this.taxLockDateMessage,
    this.hasReconciledEntries,
    this.restrictModeHashTable,
    this.secureSequenceNumber,
    this.inalterableHash,
    this.stringToHash,
    this.transactionIds,
    this.authorizedTransactionIds,
    this.purchaseVendorBillId,
    this.purchaseId,
    this.stockMoveId,
    this.stockValuationLayerIds,
    this.posOrderIds,
    this.teamId,
    this.partnerShippingId,
    this.timesheetIds,
    this.timesheetCount,
    this.campaignId,
    this.sourceId,
    this.mediumId,
    this.activityIds,
    this.activityState,
    this.activityUserId,
    this.activityTypeId,
    this.activityDateDeadline,
    this.activitySummary,
    this.activityExceptionDecoration,
    this.activityExceptionIcon,
    this.messageIsFollower,
    this.messageFollowerIds,
    this.messagePartnerIds,
    this.messageChannelIds,
    this.messageIds,
    this.messageUnread,
    this.messageUnreadCounter,
    this.messageNeedaction,
    this.messageNeedactionCounter,
    this.messageHasError,
    this.messageHasErrorCounter,
    this.messageAttachmentCount,
    this.messageMainAttachmentId,
    this.websiteMessageIds,
    this.messageHasSmsError,
    this.accessUrl,
    this.accessToken,
    this.accessWarning,
    this.id,
    this.displayName,
    this.createUid,
    this.createDate,
    this.writeUid,
    this.writeDate,
    this.lastUpdate,
  });

  factory AccountMoveModel.fromJson(Map<String, dynamic> json) =>
      _$AccountMoveModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountMoveModelToJson(this);
}

@JsonSerializable()
class SalesAdvancePaymentInvoice {
  @JsonKey(name: "id")
  dynamic id;
  @JsonKey(name: "count")
  dynamic count;
  @JsonKey(name: "advance_payment_method")
  dynamic advancePaymentMethod;
  @JsonKey(name: "has_down_payments")
  dynamic hasDownPayments;
  @JsonKey(name: "deduct_down_payments")
  dynamic deductDownPayments;
  @JsonKey(name: "product_id")
  dynamic productId;
  @JsonKey(name: "currency_id")
  dynamic currencyId;
  @JsonKey(name: "fixed_amount")
  dynamic fixedAmount;
  @JsonKey(name: "amount")
  dynamic amount;
  @JsonKey(name: "deposit_account_id")
  dynamic depositAccountId;
  @JsonKey(name: "deposit_taxes_id")
  dynamic depositTaxesId;
  @JsonKey(name: "display_name")
  dynamic displayName;

  SalesAdvancePaymentInvoice({
    this.id,
    this.count,
    this.advancePaymentMethod,
    this.hasDownPayments,
    this.deductDownPayments,
    this.productId,
    this.currencyId,
    this.fixedAmount,
    this.amount,
    this.depositAccountId,
    this.depositTaxesId,
    this.displayName,
  });

  factory SalesAdvancePaymentInvoice.fromJson(Map<String, dynamic> json) =>
      _$SalesAdvancePaymentInvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$SalesAdvancePaymentInvoiceToJson(this);
}
