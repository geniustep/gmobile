// ════════════════════════════════════════════════════════════
// HivePartners - إدارة العملاء في Hive
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/partner_entity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HivePartners {
  HivePartners._();

  static final RxList<PartnerModel> partners = <PartnerModel>[].obs;

  /// حفظ العملاء في Hive
  static Future<void> setPartners(RxList<PartnerModel> partnerList) async {
    partners.value = partnerList;
    
    // حفظ في Hive
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      final entities = partnerList.map((p) => PartnerEntity.fromModel(p)).toList();
      await HiveService.instance.savePartners(entities);
      
      if (kDebugMode) {
        print('✅ Saved ${partnerList.length} partners to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving partners to Hive: $e');
      }
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.partners, jsonEncode(partnerList.toList()));
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error saving partners to SharedPreferences: $fallbackError');
        }
      }
    }
  }

  /// جلب العملاء من Hive
  static Future<RxList<PartnerModel>> getPartners() async {
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      // جلب من Hive
      final entities = await HiveService.instance.getPartners();
      final partnerList = entities.map((e) => e.toModel()).toList();
      partners.value = partnerList;
      
      if (kDebugMode) {
        print('✅ Loaded ${partnerList.length} partners from Hive');
      }
      
      return partners;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading partners from Hive: $e');
        print('🔄 Falling back to SharedPreferences...');
      }
      
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        var partnersString = prefs.getString(PrefKeys.partners);
        if (partnersString == null || partnersString.isEmpty) {
          partners.value = <PartnerModel>[].obs;
          return partners;
        }
        List<dynamic> decoded = jsonDecode(partnersString);
        partners.value = RxList(decoded.map((e) => PartnerModel.fromJson(e)).toList());
        return partners;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error loading partners from SharedPreferences: $fallbackError');
        }
        partners.value = <PartnerModel>[].obs;
        return partners;
      }
    }
  }

  /// تحديث عميل محدد
  static Future<void> updatePartner(PartnerModel updatedPartner) async {
    RxList<PartnerModel> currentPartners = await getPartners();
    int index = currentPartners.indexWhere(
      (partner) => partner.id == updatedPartner.id,
    );
    if (index != -1) {
      currentPartners[index] = updatedPartner;
    } else {
      currentPartners.add(updatedPartner);
    }
    await setPartners(currentPartners);
  }

  /// مسح جميع العملاء
  static Future<void> clearPartners() async {
    try {
      await HiveService.instance.init();
      await HiveService.instance.clearPartners();
      partners.clear();
      
      if (kDebugMode) {
        print('✅ Cleared all partners from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing partners: $e');
      }
    }
  }

  /// عدد العملاء
  static int get partnersCount {
    try {
      return HiveService.instance.partnersCount;
    } catch (e) {
      return partners.length;
    }
  }
}

