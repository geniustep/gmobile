import 'package:json_annotation/json_annotation.dart';

part 'account_tax_model.g.dart';

@JsonSerializable()
class AccountTaxModel {
  @JsonKey(name: "amount")
  dynamic amount;
  @JsonKey(name: "active")
  dynamic active;
  @JsonKey(name: "amount_type")
  dynamic amountType;
  @JsonKey(name: "analytic")
  dynamic analytic;
  @JsonKey(name: "display_name")
  dynamic displayName;
  @JsonKey(name: "id")
  dynamic id;
  @JsonKey(name: "name")
  dynamic name;
  @JsonKey(name: "description")
  dynamic description;
  @JsonKey(name: "cash_basis_base_account_id")
  dynamic cashBasisBaseAccountId;
  @JsonKey(name: "cash_basis_transition_account_id")
  dynamic cashBasisTransitionAccountId;
  @JsonKey(name: "children_tax_ids")
  dynamic childrenTaxIds;
  @JsonKey(name: "company_id")
  dynamic companyId;
  @JsonKey(name: "country_id")
  dynamic countryId;
  @JsonKey(name: "hide_tax_exigibility")
  dynamic hideTaxExigibility;
  @JsonKey(name: "include_base_amount")
  dynamic includeBaseAmount;
  @JsonKey(name: "invoice_repartition_line_ids")
  dynamic invoiceRepartitionLineIds;
  @JsonKey(name: "price_include")
  dynamic priceInclude;
  @JsonKey(name: "refund_repartition_line_ids")
  dynamic refundRepartitionLineIds;
  @JsonKey(name: "sequence")
  dynamic sequence;
  @JsonKey(name: "tax_exigibility")
  dynamic taxExigibility;
  @JsonKey(name: "tax_group_id")
  dynamic taxGroupId;
  @JsonKey(name: "type_tax_use")
  dynamic typeTaxUse;

  AccountTaxModel({
    this.amount,
    this.active,
    this.amountType,
    this.analytic,
    this.displayName,
    this.id,
    this.name,
    this.description,
    this.cashBasisBaseAccountId,
    this.cashBasisTransitionAccountId,
    this.childrenTaxIds,
    this.companyId,
    this.countryId,
    this.hideTaxExigibility,
    this.includeBaseAmount,
    this.invoiceRepartitionLineIds,
    this.priceInclude,
    this.refundRepartitionLineIds,
    this.sequence,
    this.taxExigibility,
    this.taxGroupId,
    this.typeTaxUse,
  });

  factory AccountTaxModel.fromJson(Map<String, dynamic> json) =>
      _$AccountTaxModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountTaxModelToJson(this);
}
