// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_tax_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountTaxModel _$AccountTaxModelFromJson(Map<String, dynamic> json) =>
    AccountTaxModel(
      amount: json['amount'],
      active: json['active'],
      amountType: json['amount_type'],
      analytic: json['analytic'],
      displayName: json['display_name'],
      id: json['id'],
      name: json['name'],
      description: json['description'],
      cashBasisBaseAccountId: json['cash_basis_base_account_id'],
      cashBasisTransitionAccountId: json['cash_basis_transition_account_id'],
      childrenTaxIds: json['children_tax_ids'],
      companyId: json['company_id'],
      countryId: json['country_id'],
      hideTaxExigibility: json['hide_tax_exigibility'],
      includeBaseAmount: json['include_base_amount'],
      invoiceRepartitionLineIds: json['invoice_repartition_line_ids'],
      priceInclude: json['price_include'],
      refundRepartitionLineIds: json['refund_repartition_line_ids'],
      sequence: json['sequence'],
      taxExigibility: json['tax_exigibility'],
      taxGroupId: json['tax_group_id'],
      typeTaxUse: json['type_tax_use'],
    );

Map<String, dynamic> _$AccountTaxModelToJson(AccountTaxModel instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'active': instance.active,
      'amount_type': instance.amountType,
      'analytic': instance.analytic,
      'display_name': instance.displayName,
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'cash_basis_base_account_id': instance.cashBasisBaseAccountId,
      'cash_basis_transition_account_id': instance.cashBasisTransitionAccountId,
      'children_tax_ids': instance.childrenTaxIds,
      'company_id': instance.companyId,
      'country_id': instance.countryId,
      'hide_tax_exigibility': instance.hideTaxExigibility,
      'include_base_amount': instance.includeBaseAmount,
      'invoice_repartition_line_ids': instance.invoiceRepartitionLineIds,
      'price_include': instance.priceInclude,
      'refund_repartition_line_ids': instance.refundRepartitionLineIds,
      'sequence': instance.sequence,
      'tax_exigibility': instance.taxExigibility,
      'tax_group_id': instance.taxGroupId,
      'type_tax_use': instance.typeTaxUse,
    };
