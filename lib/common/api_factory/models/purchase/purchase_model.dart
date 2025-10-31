import 'package:json_annotation/json_annotation.dart';

part 'purchase_model.g.dart';

@JsonSerializable()
class PurchaseModel {
  @JsonKey(name: 'state')
  dynamic state;
  @JsonKey(name: 'invoice_count')
  dynamic invoiceCount;
  @JsonKey(name: 'invoice_ids')
  dynamic invoiceIds;
  @JsonKey(name: 'picking_count')
  dynamic pickingCount;
  @JsonKey(name: 'picking_ids')
  dynamic pickingIds;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'partner_id')
  dynamic partnerId;
  @JsonKey(name: 'partner_ref')
  dynamic partnerRef;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'is_shipped')
  dynamic isShipped;
  @JsonKey(name: 'date_order')
  dynamic dateOrder;
  @JsonKey(name: 'date_approve')
  dynamic dateApprove;
  @JsonKey(name: 'origin')
  dynamic origin;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'order_line')
  dynamic orderLine;
  @JsonKey(name: 'amount_untaxed')
  dynamic amountUntaxed;
  @JsonKey(name: 'amount_tax')
  dynamic amountTax;
  @JsonKey(name: 'amount_total')
  dynamic amountTotal;
  @JsonKey(name: 'notes')
  dynamic notes;
  @JsonKey(name: 'date_planned')
  dynamic datePlanned;
  @JsonKey(name: 'picking_type_id')
  dynamic pickingTypeId;
  @JsonKey(name: 'dest_address_id')
  dynamic destAddressId;
  @JsonKey(name: 'default_location_dest_id_usage')
  dynamic defaultLocationDestIdUsage;
  @JsonKey(name: 'incoterm_id')
  dynamic incotermId;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'invoice_status')
  dynamic invoiceStatus;
  @JsonKey(name: 'payment_term_id')
  dynamic paymentTermId;
  @JsonKey(name: 'fiscal_position_id')
  dynamic fiscalPositionId;
  @JsonKey(name: 'message_follower_ids')
  dynamic messageFollowerIds;
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
  @JsonKey(name: 'message_partner_ids')
  dynamic messagePartnerIds;
  @JsonKey(name: 'message_channel_ids')
  dynamic messageChannelIds;
  @JsonKey(name: 'message_ids')
  dynamic messageIds;
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'display_name')
  dynamic displayName;
  @JsonKey(name: 'product_id')
  dynamic productId;
  @JsonKey(name: 'currency_rate')
  dynamic currencyRate;
  @JsonKey(name: 'group_id')
  dynamic groupId;
  @JsonKey(name: 'activity_ids')
  dynamic activityIds;

  PurchaseModel({
    this.state,
    this.invoiceCount,
    this.invoiceIds,
    this.pickingCount,
    this.pickingIds,
    this.name,
    this.partnerId,
    this.partnerRef,
    this.currencyId,
    this.isShipped,
    this.dateOrder,
    this.dateApprove,
    this.origin,
    this.companyId,
    this.orderLine,
    this.amountUntaxed,
    this.amountTax,
    this.amountTotal,
    this.notes,
    this.datePlanned,
    this.pickingTypeId,
    this.destAddressId,
    this.defaultLocationDestIdUsage,
    this.incotermId,
    this.userId,
    this.invoiceStatus,
    this.paymentTermId,
    this.fiscalPositionId,
    this.messageFollowerIds,
    this.activityState,
    this.activityUserId,
    this.activityTypeId,
    this.activityDateDeadline,
    this.activitySummary,
    this.activityExceptionDecoration,
    this.activityExceptionIcon,
    this.messageIsFollower,
    this.messagePartnerIds,
    this.messageChannelIds,
    this.messageIds,
    this.id,
    this.displayName,
    this.productId,
    this.currencyRate,
    this.groupId,
    this.activityIds,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$PurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseModelToJson(this);
}
