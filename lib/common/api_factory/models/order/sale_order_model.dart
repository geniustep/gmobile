import 'package:json_annotation/json_annotation.dart';

part 'sale_order_model.g.dart';

@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'authorized_transaction_ids')
  dynamic authorizedTransactionIds;
  @JsonKey(name: 'state')
  dynamic state;
  @JsonKey(name: 'picking_ids')
  dynamic pickingIds;
  @JsonKey(name: 'delivery_count')
  dynamic deliveryCount;
  @JsonKey(name: 'expense_count')
  dynamic expenseCount;
  @JsonKey(name: 'invoice_count')
  dynamic invoiceCount;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'partner_id')
  dynamic partnerId;
  @JsonKey(name: 'partner_invoice_id')
  dynamic partnerInvoiceId;
  @JsonKey(name: 'partner_shipping_id')
  dynamic partnerShippingId;
  @JsonKey(name: 'sale_order_template_id')
  dynamic saleOrderTemplateId;
  @JsonKey(name: 'validity_date')
  dynamic validityDate;
  @JsonKey(name: 'date_order')
  dynamic dateOrder;
  @JsonKey(name: 'write_date')
  dynamic writeDate;
  @JsonKey(name: 'pricelist_id')
  dynamic pricelistId;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'payment_term_id')
  dynamic paymentTermId;
  @JsonKey(name: 'order_line')
  dynamic orderLine;
  @JsonKey(name: 'note')
  dynamic note;
  @JsonKey(name: 'amount_untaxed')
  dynamic amountUntaxed;
  @JsonKey(name: 'amount_tax')
  dynamic amountTax;
  @JsonKey(name: 'amount_total')
  dynamic amountTotal;
  @JsonKey(name: 'margin')
  dynamic margin;
  @JsonKey(name: 'sale_order_option_ids')
  dynamic saleOrderOptionIds;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'team_id')
  dynamic teamId;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'require_signature')
  dynamic requireSignature;
  @JsonKey(name: 'require_payment')
  dynamic requirePayment;
  @JsonKey(name: 'reference')
  dynamic reference;
  @JsonKey(name: 'client_order_ref')
  dynamic clientOrderRef;
  @JsonKey(name: 'fiscal_position_id')
  dynamic fiscalPositionId;
  @JsonKey(name: 'analytic_account_id')
  dynamic analyticAccountId;
  @JsonKey(name: 'invoice_status')
  dynamic invoiceStatus;
  @JsonKey(name: 'warehouse_id')
  dynamic warehouseId;
  @JsonKey(name: 'incoterm')
  dynamic incoterm;
  @JsonKey(name: 'picking_policy')
  dynamic pickingPolicy;
  @JsonKey(name: 'commitment_date')
  dynamic commitmentDate;
  @JsonKey(name: 'expected_date')
  dynamic expectedDate;
  @JsonKey(name: 'effective_date')
  dynamic effectiveDate;
  @JsonKey(name: 'origin')
  dynamic origin;
  @JsonKey(name: 'campaign_id')
  dynamic campaignId;
  @JsonKey(name: 'medium_id')
  dynamic mediumId;
  @JsonKey(name: 'source_id')
  dynamic sourceId;
  @JsonKey(name: 'signed_by')
  dynamic signedBy;
  @JsonKey(name: 'signed_on')
  dynamic signedOn;
  @JsonKey(name: 'signature')
  dynamic signature;
  @JsonKey(name: '__last_update')
  dynamic lastUpdate;
  @JsonKey(name: 'message_follower_ids')
  dynamic messageFollowerIds;
  @JsonKey(name: 'activity_ids')
  dynamic activityIds;
  @JsonKey(name: 'message_ids')
  dynamic messageIds;
  @JsonKey(name: 'message_attachment_count')
  dynamic messageAttachmentCount;
  @JsonKey(name: 'display_name')
  dynamic displayName;
  @JsonKey(name: 'move_ids')
  dynamic moveIds;

  OrderModel({
    this.id,
    this.authorizedTransactionIds,
    this.state,
    this.pickingIds,
    this.deliveryCount,
    this.expenseCount,
    this.invoiceCount,
    this.name,
    this.partnerId,
    this.partnerInvoiceId,
    this.partnerShippingId,
    this.saleOrderTemplateId,
    this.validityDate,
    this.dateOrder,
    this.pricelistId,
    this.currencyId,
    this.paymentTermId,
    this.orderLine,
    this.note,
    this.amountUntaxed,
    this.amountTax,
    this.amountTotal,
    this.margin,
    this.saleOrderOptionIds,
    this.userId,
    this.teamId,
    this.companyId,
    this.requireSignature,
    this.requirePayment,
    this.reference,
    this.clientOrderRef,
    this.fiscalPositionId,
    this.analyticAccountId,
    this.invoiceStatus,
    this.warehouseId,
    this.incoterm,
    this.pickingPolicy,
    this.commitmentDate,
    this.expectedDate,
    this.effectiveDate,
    this.origin,
    this.campaignId,
    this.mediumId,
    this.sourceId,
    this.signedBy,
    this.signedOn,
    this.signature,
    this.messageFollowerIds,
    this.activityIds,
    this.messageIds,
    this.messageAttachmentCount,
    this.displayName,
    this.lastUpdate,
    this.moveIds,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}
