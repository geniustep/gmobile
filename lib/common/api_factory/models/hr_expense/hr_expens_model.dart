import 'package:json_annotation/json_annotation.dart';

part 'hr_expens_model.g.dart';

@JsonSerializable()
class HrExpenseModel {
  @JsonKey(name: "name")
  dynamic name;
  @JsonKey(name: "date")
  dynamic date;
  @JsonKey(name: "employee_id")
  dynamic employeeId;
  @JsonKey(name: "product_id")
  dynamic productId;
  @JsonKey(name: "product_uom_id")
  dynamic productUomId;
  @JsonKey(name: "product_uom_category_id")
  dynamic productUomCategoryId;
  @JsonKey(name: "unit_amount")
  dynamic unitAmount;
  @JsonKey(name: "quantity")
  dynamic quantity;
  @JsonKey(name: "tax_ids")
  dynamic taxIds;
  @JsonKey(name: "untaxed_amount")
  dynamic untaxedAmount;
  @JsonKey(name: "total_amount")
  dynamic totalAmount;
  @JsonKey(name: "company_currency_id")
  dynamic companyCurrencyId;
  @JsonKey(name: "total_amount_company")
  dynamic totalAmountCompany;
  @JsonKey(name: "company_id")
  dynamic companyId;
  @JsonKey(name: "currency_id")
  dynamic currencyId;
  @JsonKey(name: "analytic_account_id")
  dynamic analyticAccountId;
  @JsonKey(name: "analytic_tag_ids")
  dynamic analyticTagIds;
  @JsonKey(name: "account_id")
  dynamic accountId;
  @JsonKey(name: "description")
  dynamic description;
  @JsonKey(name: "payment_mode")
  dynamic paymentMode;
  @JsonKey(name: "attachment_number")
  dynamic attachmentNumber;
  @JsonKey(name: "state")
  dynamic state;
  @JsonKey(name: "sheet_id")
  dynamic sheetId;
  @JsonKey(name: "reference")
  dynamic reference;
  @JsonKey(name: "is_refused")
  dynamic isRefused;
  @JsonKey(name: "is_editable")
  dynamic isEditable;
  @JsonKey(name: "is_ref_editable")
  dynamic isRefEditable;
  @JsonKey(name: "sale_order_id")
  dynamic saleOrderId;
  @JsonKey(name: "can_be_reinvoiced")
  dynamic canBeReinvoiced;
  @JsonKey(name: "activity_ids")
  dynamic activityIds;
  @JsonKey(name: "activity_state")
  dynamic activityState;
  @JsonKey(name: "activity_user_id")
  dynamic activitUserId;
  @JsonKey(name: "activity_type_id")
  dynamic activityTypeId;
  @JsonKey(name: "activity_date_deadline")
  dynamic activityDateDeadline;
  @JsonKey(name: "activity_summary")
  dynamic activitySummary;
  @JsonKey(name: "activity_exception_decoration")
  dynamic activityExceptionDecoration;
  @JsonKey(name: "activity_exception_icon")
  dynamic activityExceptionIcon;
  @JsonKey(name: "message_is_follower")
  dynamic messageIsFollower;
  @JsonKey(name: "message_follower_ids")
  dynamic messageFollowerIds;
  @JsonKey(name: "message_partner_ids")
  dynamic messagePartnerIds;
  @JsonKey(name: "message_channel_ids")
  dynamic messageChannelIds;
  @JsonKey(name: "message_ids")
  dynamic messageIds;
  @JsonKey(name: "message_unread")
  dynamic messageUnread;
  @JsonKey(name: "message_unread_counter")
  dynamic messageUnreadCounter;
  @JsonKey(name: "message_needaction")
  dynamic messageNeedaction;
  @JsonKey(name: "message_needaction_counter")
  dynamic messageNeedactionCounter;
  @JsonKey(name: "message_has_error")
  dynamic messageHasError;
  @JsonKey(name: "message_has_error_counter")
  dynamic messageHasErrorCounter;
  @JsonKey(name: "message_attachment_count")
  dynamic messageAttachmentCount;
  @JsonKey(name: "message_main_attachment_id")
  dynamic messageMainAttachmentId;
  @JsonKey(name: "website_message_ids")
  dynamic websiteMessageIds;
  @JsonKey(name: "message_has_sms_error")
  dynamic messageHasSmsError;
  @JsonKey(name: "id")
  dynamic id;
  @JsonKey(name: "display_name")
  dynamic displayName;
  @JsonKey(name: "create_uid")
  dynamic createUid;
  @JsonKey(name: "create_date")
  dynamic createDate;
  @JsonKey(name: "write_uid")
  dynamic writeUid;
  @JsonKey(name: "write_date")
  dynamic writeDate;
  @JsonKey(name: "__last_update")
  dynamic lastUpdate;

  HrExpenseModel({
    this.name,
    this.date,
    this.employeeId,
    this.productId,
    this.productUomId,
    this.productUomCategoryId,
    this.unitAmount,
    this.quantity,
    this.taxIds,
    this.untaxedAmount,
    this.totalAmount,
    this.companyCurrencyId,
    this.totalAmountCompany,
    this.companyId,
    this.currencyId,
    this.analyticAccountId,
    this.analyticTagIds,
    this.accountId,
    this.description,
    this.paymentMode,
    this.attachmentNumber,
    this.state,
    this.sheetId,
    this.reference,
    this.isRefused,
    this.isEditable,
    this.isRefEditable,
    this.saleOrderId,
    this.canBeReinvoiced,
    this.activityIds,
    this.activityState,
    this.activitUserId,
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
    this.id,
    this.displayName,
    this.createUid,
    this.createDate,
    this.writeUid,
    this.writeDate,
    this.lastUpdate,
  });
  factory HrExpenseModel.fromJson(Map<String, dynamic> json) =>
      _$HrExpenseModelFromJson(json);

  // تحويل من كائن HrExpenseModel إلى Map
  Map<String, dynamic> toJson() => _$HrExpenseModelToJson(this);
}
