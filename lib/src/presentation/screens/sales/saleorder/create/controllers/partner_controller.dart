// lib/src/presentation/screens/sales/saleorder/create/controllers/partner_controller.dart

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class PartnerController extends GetxController {
  // ============= State =============

  final Rxn<PartnerModel> selectedPartner = Rxn<PartnerModel>();
  final Rxn<PricelistModel> selectedPriceList = Rxn<PricelistModel>();
  final RxnInt selectedPaymentTermId = RxnInt();
  final RxList<PricelistModel> partnerPriceLists = <PricelistModel>[].obs;
  final RxList<PartnerModel> partners = <PartnerModel>[].obs;
  final RxList<PricelistModel> allPriceLists = <PricelistModel>[].obs;
  final RxList<dynamic> paymentTerms = <dynamic>[].obs;
  final Rxn<DateTime> deliveryDate = Rxn<DateTime>();
  final RxBool showDeliveryDate = false.obs;

  // Admin flag
  final bool isAdmin = PrefUtils.user.value.isAdmin ?? false;

  // ============= Lifecycle =============

  @override
  void onInit() {
    super.onInit();
  }

  // ============= Initialization =============

  void initialize({PartnerModel? preSelectedPartner}) {
    partners.value = preSelectedPartner != null
        ? [preSelectedPartner]
        : PrefUtils.partners.toList();

    allPriceLists.value = PrefUtils.listesPrix.toList();
    paymentTerms.value = PrefUtils.conditionsPaiement;

    if (preSelectedPartner != null) {
      selectPartner(preSelectedPartner.id);
    }
  }

  // ============= Partner Management =============

  void selectPartner(int partnerId) {
    try {
      // ✅ التحقق من وجود الشركاء
      if (partners.isEmpty) {
        partners.value = PrefUtils.partners.toList();
      }

      // ✅ التحقق من وجود قوائم الأسعار
      if (allPriceLists.isEmpty) {
        allPriceLists.value = PrefUtils.listesPrix.toList();
      }

      final partner = partners.firstWhere((p) => p.id == partnerId);
      selectedPartner.value = partner;

      // تحميل قوائم الأسعار الخاصة بالشريك
      _loadPartnerPriceLists(partner);

      if (kDebugMode) {
        print('✅ Partner selected: ${partner.name}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error selecting partner: $e');
        print('   Available partners: ${partners.length}');
        print('   Partner IDs: ${partners.map((p) => p.id).toList()}');
      }
    }
  }

  void _loadPartnerPriceLists(PartnerModel partner) {
    try {
      if (kDebugMode) {
        print('\n💰 Loading price lists for partner: ${partner.name}');
        print(
          '   Property product pricelist: ${partner.propertyProductPricelist}',
        );
        print('   Is Admin: $isAdmin');
      }

      // ✅ التحقق من وجود قوائم أسعار متاحة
      if (allPriceLists.isEmpty) {
        if (kDebugMode) {
          print('   ⚠️ No price lists available - hiding section');
        }
        partnerPriceLists.clear(); // إفراغ القائمة
        selectedPriceList.value = null; // إلغاء التحديد
        update(); // ✅ تحديث GetBuilder
        return; // إنهاء الدالة مبكراً
      }

      // ✅ فحص إذا كانت الشركة تستخدم قوائم الأسعار
      if (!_shouldUsePriceLists(partner)) {
        if (kDebugMode) {
          print('   ⚠️ Company does not use price lists - skipping');
        }
        partnerPriceLists.clear();
        selectedPriceList.value = null;
        update(); // ✅ تحديث GetBuilder
        return;
      }

      // إذا كان المستخدم Admin، يحصل على جميع القوائم
      if (isAdmin) {
        partnerPriceLists.value = allPriceLists.toList();

        if (kDebugMode) {
          print(
            '   ✅ Admin: All price lists available (${partnerPriceLists.length})',
          );
        }

        _selectDefaultPriceList(partner);
        update(); // ✅ تحديث GetBuilder
        return;
      }

      // للمستخدمين العاديين: تحديد قائمة الأسعار من بيانات الشريك
      if (partner.propertyProductPricelist != null) {
        dynamic pricelistId;

        // معالجة property_product_pricelist
        if (partner.propertyProductPricelist is List) {
          final list = partner.propertyProductPricelist as List;
          if (list.isNotEmpty) {
            pricelistId = list[0] is int ? list[0] : null;
          }
        } else if (partner.propertyProductPricelist is int) {
          pricelistId = partner.propertyProductPricelist as int;
        }

        if (pricelistId != null) {
          // البحث عن قائمة الأسعار المحددة
          final partnerPriceList = allPriceLists.firstWhereOrNull(
            (p) => p.id == pricelistId,
          );

          if (partnerPriceList != null) {
            partnerPriceLists.value = [partnerPriceList];

            if (kDebugMode) {
              print('   ✅ Partner price list loaded: ID $pricelistId');
              print('   ✅ Price list: ${partnerPriceList.name}');
              print('   ✅ Items: ${partnerPriceList.items?.length ?? 0}');
            }

            selectPriceList(partnerPriceList.id);
            update(); // ✅ تحديث GetBuilder
          } else {
            // ✅ إذا لم توجد القائمة المحددة، إخفاء القسم
            if (kDebugMode) {
              print('   ⚠️ Partner price list not found - hiding section');
            }
            partnerPriceLists.clear();
            selectedPriceList.value = null;
            update(); // ✅ تحديث GetBuilder
          }
        } else {
          if (kDebugMode) {
            print('   ⚠️ No valid price list ID found - hiding section');
          }
          partnerPriceLists.clear();
          selectedPriceList.value = null;
          update(); // ✅ تحديث GetBuilder
        }
      } else {
        if (kDebugMode) {
          print('   ⚠️ No property_product_pricelist found - hiding section');
        }
        partnerPriceLists.clear();
        selectedPriceList.value = null;
        update(); // ✅ تحديث GetBuilder
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading partner price lists: $e');
      }
      // ✅ في حالة الخطأ، إخفاء القسم
      partnerPriceLists.clear();
      selectedPriceList.value = null;
    }
  }

  void _selectDefaultPriceList(PartnerModel partner) {
    if (partnerPriceLists.isEmpty) return;

    // محاولة العثور على قائمة الأسعار الخاصة بالشريك
    dynamic defaultPriceListId;

    if (partner.propertyProductPricelist != null) {
      if (partner.propertyProductPricelist is List) {
        final list = partner.propertyProductPricelist as List;
        if (list.isNotEmpty) {
          defaultPriceListId = list[0] is int ? list[0] : null;
        }
      } else if (partner.propertyProductPricelist is int) {
        defaultPriceListId = partner.propertyProductPricelist as int;
      }
    }

    // تحديد قائمة الأسعار
    if (defaultPriceListId != null) {
      final priceList = partnerPriceLists.firstWhereOrNull(
        (p) => p.id == defaultPriceListId,
      );
      if (priceList != null) {
        selectPriceList(priceList.id);
        return;
      }
    }

    // إذا لم يتم العثور على قائمة محددة، اختر الأولى
    selectPriceList(partnerPriceLists.first.id);
  }

  // ============= Price List Management =============

  void selectPriceList(dynamic priceListId) {
    if (priceListId == null) {
      selectedPriceList.value = null;
      if (kDebugMode) {
        print('   Price list cleared');
      }
      return;
    }

    try {
      final priceList = allPriceLists.firstWhere((p) => p.id == priceListId);
      selectedPriceList.value = priceList;

      if (kDebugMode) {
        print('\n💰 Price list selected:');
        print('   Name: ${priceList.name}');
        print('   ID: $priceListId');
        print('   Items: ${priceList.items?.length ?? 0}');

        // طباعة بعض الأمثلة على القواعد
        if (priceList.items != null && priceList.items!.isNotEmpty) {
          print('   Sample rules:');
          for (
            var i = 0;
            i < (priceList.items!.length > 3 ? 3 : priceList.items!.length);
            i++
          ) {
            final item = priceList.items![i];
            print(
              '     Rule ${i + 1}: Product ${item.productTmplId}, '
              'Min Qty: ${item.minQuantity}, '
              'Fixed Price: ${item.price}, '
              'Discount: ${item.priceDiscount}%',
            );
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error selecting price list: $e');
      }
    }
  }

  // ============= Payment Terms Management =============

  void selectPaymentTerm(dynamic paymentTermId) {
    selectedPaymentTermId.value = paymentTermId;
    if (kDebugMode) {
      print('💳 Payment term selected: $paymentTermId');
    }
  }

  // ============= Delivery Date Management =============

  void toggleDeliveryDate(bool show) {
    showDeliveryDate.value = show;
    if (!show) {
      deliveryDate.value = null;
    }
    if (kDebugMode) {
      print('📅 Delivery date ${show ? "enabled" : "disabled"}');
    }
  }

  void setDeliveryDate(DateTime? date) {
    deliveryDate.value = date;
    if (kDebugMode) {
      print('📅 Delivery date set: ${date?.toIso8601String() ?? "null"}');
    }
  }

  // ============= Validation =============

  bool validateFormData() {
    if (kDebugMode) {
      print('\n🔍 Validating form data...');
    }

    if (selectedPartner.value == null) {
      if (kDebugMode) {
        print('❌ No partner selected');
      }
      return false;
    }

    if (kDebugMode) {
      print('✅ Form data validated');
      print('   Partner: ${selectedPartner.value!.name}');
      print('   Price List: ${selectedPriceList.value?.name ?? "None"}');
      print('   Payment Term: ${selectedPaymentTermId.value ?? "None"}');
      print(
        '   Delivery Date: ${deliveryDate.value?.toIso8601String() ?? "None"}',
      );
    }

    return true;
  }

  // ============= Data Retrieval =============

  Map<String, dynamic> getFormData() {
    final data = <String, dynamic>{
      'partner_id': selectedPartner.value?.id,
      'pricelist_id': selectedPriceList.value?.id,
      'payment_term_id': selectedPaymentTermId.value,
    };

    if (showDeliveryDate.value && deliveryDate.value != null) {
      data['commitment_date'] = deliveryDate.value;
    }

    if (kDebugMode) {
      print('\n📋 Form data:');
      data.forEach((key, value) {
        print('   $key: $value');
      });
    }

    return data;
  }

  void loadFromDraft({
    dynamic partnerId,
    dynamic priceListId,
    dynamic paymentTermId,
  }) {
    if (kDebugMode) {
      print('\n📥 Loading partner data from draft...');
      print('   Partner ID: $partnerId');
      print('   Price List ID: $priceListId');
      print('   Payment Term ID: $paymentTermId');
    }

    if (partnerId != null) {
      selectPartner(partnerId);
    }

    if (priceListId != null) {
      selectPriceList(priceListId);
    }

    if (paymentTermId != null) {
      selectPaymentTerm(paymentTermId);
    }

    if (kDebugMode) {
      print('✅ Partner data loaded from draft');
    }
  }

  // ============= Reset =============

  void reset() {
    if (kDebugMode) {
      print('\n🔄 Resetting PartnerController...');
    }

    selectedPartner.value = null;
    selectedPriceList.value = null;
    selectedPaymentTermId.value = null;
    partnerPriceLists.clear();
    deliveryDate.value = null;
    showDeliveryDate.value = false;

    if (kDebugMode) {
      print('✅ PartnerController reset');
    }
  }

  // ============= Getters =============

  bool get hasPartner => selectedPartner.value != null;
  dynamic get partnerId => selectedPartner.value?.id;
  String? get partnerName => selectedPartner.value?.name;
  dynamic get priceListId => selectedPriceList.value?.id;
  dynamic get paymentTermId => selectedPaymentTermId.value;

  // ✅ إضافة getter جديد للتحقق من وجود قوائم أسعار
  bool get hasPriceLists => partnerPriceLists.isNotEmpty;

  // ============= Price List Configuration =============

  /// التحقق من إذا كانت الشركة تستخدم قوائم الأسعار
  bool _shouldUsePriceLists(PartnerModel partner) {
    // ✅ يمكن إضافة منطق للتحقق من إعدادات الشركة
    // مثلاً: التحقق من حقل في بيانات الشركة أو إعدادات النظام

    // للآن، نتحقق من وجود property_product_pricelist
    if (partner.propertyProductPricelist == null) {
      if (kDebugMode) {
        print('   ⚠️ No property_product_pricelist found');
      }
      return false;
    }

    // ✅ يمكن إضافة المزيد من الشروط هنا
    // مثلاً: التحقق من إعدادات الشركة
    return true;
  }

  /// التحقق من إذا كان يجب إرسال pricelist_id للخادم
  bool get shouldSendPriceListId {
    return selectedPriceList.value != null && hasPriceLists;
  }
}
