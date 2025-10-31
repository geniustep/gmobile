import 'package:json_annotation/json_annotation.dart';

part 'account_move_line_model.g.dart';

@JsonSerializable()
class AccountMoveLineModel {
  @JsonKey(name: 'move_id')
  dynamic moveId;
  @JsonKey(name: 'move_name')
  dynamic moveName;
  @JsonKey(name: 'date')
  dynamic date;
  @JsonKey(name: 'ref')
  dynamic ref;
  @JsonKey(name: 'parent_state')
  dynamic parentState;
  @JsonKey(name: 'journal_id')
  dynamic journalId;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'company_currency_id')
  dynamic companyCurrencyId;
  @JsonKey(name: 'country_id')
  dynamic countryId;
  @JsonKey(name: 'account_id')
  dynamic accountId;
  @JsonKey(name: 'account_internal_type')
  dynamic accountInternalType;
  @JsonKey(name: 'account_root_id')
  dynamic accountRootId;
  @JsonKey(name: 'sequence')
  dynamic sequence;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'quantity')
  dynamic quantity;
  @JsonKey(name: 'price_unit')
  dynamic priceUnit;
  @JsonKey(name: 'discount')
  dynamic discount;
  @JsonKey(name: 'debit')
  dynamic debit;
  @JsonKey(name: 'credit')
  dynamic credit;
  @JsonKey(name: 'balance')
  dynamic balance;
  @JsonKey(name: 'amount_currency')
  dynamic amountCurrency;
  @JsonKey(name: 'price_subtotal')
  dynamic priceSubtotal;
  @JsonKey(name: 'price_total')
  dynamic priceTotal;
  @JsonKey(name: 'reconciled')
  dynamic reconciled;
  @JsonKey(name: 'blocked')
  dynamic blocked;
  @JsonKey(name: 'date_maturity')
  dynamic dateMaturity;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'partner_id')
  dynamic partnerId;
  @JsonKey(name: 'product_uom_id')
  dynamic productUomId;
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'reconcile_model_id')
  dynamic reconcileModelId;
  @JsonKey(name: 'payment_id')
  dynamic paymentId;
  @JsonKey(name: 'statement_line_id')
  dynamic statementLineId;
  @JsonKey(name: 'statement_id')
  dynamic statementId;
  @JsonKey(name: 'tax_ids')
  dynamic taxIds;
  @JsonKey(name: 'tax_line_id')
  dynamic taxLineId;
  @JsonKey(name: 'tax_group_id')
  dynamic taxGroupId;
  @JsonKey(name: 'tax_base_amount')
  dynamic taxBaseAmount;
  @JsonKey(name: 'tax_exigible')
  dynamic taxExigible;
  @JsonKey(name: 'tax_repartition_line_id')
  dynamic taxRepartitionLineId;
  @JsonKey(name: 'tag_ids')
  dynamic tagIds;
  @JsonKey(name: 'tax_audit')
  dynamic taxAudit;
  @JsonKey(name: 'amount_residual')
  dynamic amountResidual;
  @JsonKey(name: 'amount_residual_currency')
  dynamic amountResidualCurrency;
  @JsonKey(name: 'full_reconcile_id')
  dynamic fullReconcileId;
  @JsonKey(name: 'matched_debit_ids')
  dynamic matchedDebitIds;
  @JsonKey(name: 'matched_credit_ids')
  dynamic matchedCreditIds;
  @JsonKey(name: 'analytic_line_ids')
  dynamic analyticLineIds;
  @JsonKey(name: 'analytic_account_id')
  dynamic analyticAccountId;
  @JsonKey(name: 'analytic_tag_ids')
  dynamic analyticTagIds;
  @JsonKey(name: 'recompute_tax_line')
  dynamic recomputeTaxLine;
  @JsonKey(name: 'display_type')
  dynamic displayType;
  @JsonKey(name: 'is_rounding_line')
  dynamic isRoundingLine;
  @JsonKey(name: 'exclude_from_invoice_tab')
  dynamic excludeFromInvoiceTab;
  @JsonKey(name: 'always_set_currency_id')
  dynamic alwaysSetCurrencyId;
  @JsonKey(name: 'expense_id')
  dynamic expenseId;
  @JsonKey(name: 'purchase_line_id')
  dynamic purchaseLineId;
  @JsonKey(name: 'is_anglo_saxon_line')
  dynamic isAngloSaxonLine;
  @JsonKey(name: 'sale_line_ids')
  dynamic saleLineIds;
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

  AccountMoveLineModel({
    this.moveId,
    this.moveName,
    this.date,
    this.ref,
    this.parentState,
    this.journalId,
    this.companyId,
    this.companyCurrencyId,
    this.countryId,
    this.accountId,
    this.accountInternalType,
    this.accountRootId,
    this.sequence,
    this.name,
    this.quantity,
    this.priceUnit,
    this.discount,
    this.debit,
    this.credit,
    this.balance,
    this.amountCurrency,
    this.priceSubtotal,
    this.priceTotal,
    this.reconciled,
    this.blocked,
    this.dateMaturity,
    this.currencyId,
    this.partnerId,
    this.productUomId,
    this.productId,
    this.reconcileModelId,
    this.paymentId,
    this.statementLineId,
    this.statementId,
    this.taxIds,
    this.taxLineId,
    this.taxGroupId,
    this.taxBaseAmount,
    this.taxExigible,
    this.taxRepartitionLineId,
    this.tagIds,
    this.taxAudit,
    this.amountResidual,
    this.amountResidualCurrency,
    this.fullReconcileId,
    this.matchedDebitIds,
    this.matchedCreditIds,
    this.analyticLineIds,
    this.analyticAccountId,
    this.analyticTagIds,
    this.recomputeTaxLine,
    this.displayType,
    this.isRoundingLine,
    this.excludeFromInvoiceTab,
    this.alwaysSetCurrencyId,
    this.expenseId,
    this.purchaseLineId,
    this.isAngloSaxonLine,
    this.saleLineIds,
    this.id,
    this.displayName,
    this.createUid,
    this.createDate,
    this.writeUid,
    this.writeDate,
    this.lastUpdate,
  });

  factory AccountMoveLineModel.fromJson(Map<String, dynamic> json) =>
      _$AccountMoveLineModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountMoveLineModelToJson(this);
}
