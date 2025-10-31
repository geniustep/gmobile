import 'package:json_annotation/json_annotation.dart';

part 'partner_model.g.dart';

@JsonSerializable()
class PartnerModel {
  @JsonKey(name: 'id')
  dynamic id;
  @JsonKey(name: 'same_vat_partner_id')
  dynamic sameVatPartnerId;
  @JsonKey(name: 'partner_gid')
  dynamic partnerGid;
  @JsonKey(name: 'additional_info')
  dynamic additionalInfo;
  @JsonKey(name: 'sale_order_count')
  dynamic saleOrderCount;
  @JsonKey(name: 'total_invoiced')
  dynamic totalInvoiced;
  @JsonKey(name: 'payment_token_count')
  dynamic paymentTokenCount;
  @JsonKey(name: 'image_512')
  dynamic image_512;
  @JsonKey(name: 'image_256')
  dynamic image_256;
  @JsonKey(name: 'image_1920')
  dynamic image1920;
  @JsonKey(name: 'image_128')
  dynamic image_128;
  @JsonKey(name: '__last_update')
  dynamic sLastUpdate;
  @JsonKey(name: 'is_company')
  bool? isCompany;
  @JsonKey(name: 'commercial_partner_id')
  dynamic commercialPartnerId;
  @JsonKey(name: 'active')
  dynamic active;
  @JsonKey(name: 'company_type')
  dynamic companyType;
  @JsonKey(name: 'name')
  dynamic name;
  @JsonKey(name: 'parent_id')
  dynamic parentId;
  @JsonKey(name: 'company_name')
  dynamic companyName;
  @JsonKey(name: 'type')
  dynamic type;
  @JsonKey(name: 'street')
  dynamic street;
  @JsonKey(name: 'street2')
  dynamic street2;
  @JsonKey(name: 'city')
  dynamic city;
  @JsonKey(name: 'state_id')
  dynamic stateId;
  @JsonKey(name: 'zip')
  dynamic zip;
  @JsonKey(name: 'country_id')
  dynamic countryId;
  @JsonKey(name: 'vat')
  dynamic vat;
  @JsonKey(name: 'function')
  dynamic function;
  @JsonKey(name: 'phone')
  dynamic phone;
  @JsonKey(name: 'mobile')
  dynamic mobile;
  @JsonKey(name: 'phone_sanitized')
  dynamic phoneSanitized;
  @JsonKey(name: 'user_ids')
  dynamic userIds;
  @JsonKey(name: 'is_blacklisted')
  bool? isBlacklisted;
  @JsonKey(name: 'email')
  dynamic email;
  @JsonKey(name: 'website')
  dynamic website;
  @JsonKey(name: 'title')
  dynamic title;
  @JsonKey(name: 'active_lang_count')
  dynamic activeLangCount;
  @JsonKey(name: 'lang')
  dynamic lang;
  @JsonKey(name: 'categoryId')
  dynamic categoryId;
  @JsonKey(name: 'child_ids')
  dynamic childIds;
  @JsonKey(name: 'user_id')
  dynamic userId;
  @JsonKey(name: 'team_id')
  dynamic teamId;
  @JsonKey(name: 'property_payment_term_id')
  dynamic propertyPaymentTermId;
  @JsonKey(name: 'property_supplier_payment_term_id')
  dynamic propertySupplierPaymentTermId;
  @JsonKey(name: 'property_account_position_id')
  dynamic propertyAccountPositionId;
  @JsonKey(name: 'ref')
  dynamic ref;
  @JsonKey(name: 'company_id')
  dynamic companyId;
  @JsonKey(name: 'industry_id')
  dynamic industryId;
  @JsonKey(name: 'property_stock_customer')
  dynamic propertyStockCustomer;
  @JsonKey(name: 'property_stock_supplier')
  dynamic propertyStockSupplier;
  @JsonKey(name: 'bankIds')
  dynamic bankIds;
  @JsonKey(name: 'currency_id')
  dynamic currencyId;
  @JsonKey(name: 'property_account_receivable_id')
  dynamic propertyAccountReceivableId;
  @JsonKey(name: 'property_account_payable_id')
  dynamic propertyAccountPayableId;
  @JsonKey(name: 'comment')
  dynamic comment;
  @JsonKey(name: 'sale_warn')
  dynamic saleWarn;
  @JsonKey(name: 'sale_warn_msg')
  dynamic saleWarnMsg;
  @JsonKey(name: 'invoice_warn')
  dynamic invoiceWarn;
  @JsonKey(name: 'invoice_warn_msg')
  dynamic invoiceWarnMsg;
  @JsonKey(name: 'picking_warn')
  dynamic pickingWarn;
  @JsonKey(name: 'picking_warn_msg')
  dynamic pickingWarnMsg;
  @JsonKey(name: 'date_localization')
  dynamic dateLocalization;
  @JsonKey(name: 'partner_latitude')
  dynamic partnerLatitude;
  @JsonKey(name: 'partner_longitude')
  dynamic partnerLongitude;
  @JsonKey(name: 'secteur_to_partner')
  dynamic secteurToPartner;
  @JsonKey(name: 'employee_to_partner')
  dynamic employeeToPartner;
  @JsonKey(name: 'route_to_partners')
  dynamic routeToPartners;
  @JsonKey(name: 'centre_to_partner')
  dynamic centreToPartner;
  @JsonKey(name: 'city_to_partner')
  dynamic cityToPartner;
  @JsonKey(name: 'country_to_partner')
  dynamic countryToPartner;
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
  @JsonKey(name: 'customer_rank')
  dynamic customerRank;
  @JsonKey(name: 'property_product_pricelist')
  dynamic propertyProductPricelist;
  @JsonKey(name: 'credit')
  dynamic credit;
  @JsonKey(name: 'company_registry')
  dynamic companyRegistry;

  PartnerModel({
    this.id,
    this.sameVatPartnerId,
    this.partnerGid,
    this.additionalInfo,
    this.saleOrderCount,
    this.totalInvoiced,
    this.paymentTokenCount,
    this.image1920,
    this.image_128,
    this.image_512,
    this.image_256,
    this.sLastUpdate,
    this.isCompany,
    this.commercialPartnerId,
    this.active,
    this.companyType,
    this.name,
    this.parentId,
    this.companyName,
    this.type,
    this.street,
    this.street2,
    this.city,
    this.stateId,
    this.zip,
    this.countryId,
    this.vat,
    this.function,
    this.phone,
    this.mobile,
    this.phoneSanitized,
    this.userIds,
    this.isBlacklisted,
    this.email,
    this.website,
    this.title,
    this.activeLangCount,
    this.lang,
    this.categoryId,
    this.childIds,
    this.userId,
    this.teamId,
    this.propertyPaymentTermId,
    this.propertySupplierPaymentTermId,
    this.propertyAccountPositionId,
    this.ref,
    this.companyId,
    this.industryId,
    this.propertyStockCustomer,
    this.propertyStockSupplier,
    this.bankIds,
    this.currencyId,
    this.propertyAccountReceivableId,
    this.propertyAccountPayableId,
    this.comment,
    this.saleWarn,
    this.saleWarnMsg,
    this.invoiceWarn,
    this.invoiceWarnMsg,
    this.pickingWarn,
    this.pickingWarnMsg,
    this.dateLocalization,
    this.partnerLatitude,
    this.partnerLongitude,
    this.secteurToPartner,
    this.employeeToPartner,
    this.routeToPartners,
    this.centreToPartner,
    this.cityToPartner,
    this.countryToPartner,
    this.messageFollowerIds,
    this.activityIds,
    this.messageIds,
    this.messageAttachmentCount,
    this.displayName,
    this.customerRank,
    this.propertyProductPricelist,
    this.credit,
    this.companyRegistry,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) =>
      _$PartnerModelFromJson(json);

  Map<String, dynamic> toJson() => _$PartnerModelToJson(this);
}
