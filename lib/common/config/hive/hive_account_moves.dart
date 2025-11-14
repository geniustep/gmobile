// ════════════════════════════════════════════════════════════
// HiveAccountMoves - إدارة الحركات المحاسبية في Hive
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_keys.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HiveAccountMoves {
  HiveAccountMoves._();

  static final RxList<AccountMoveModel> accountMoves = <AccountMoveModel>[].obs;

  /// حفظ الحركات المحاسبية في Hive
  static Future<void> setAccountMoves(RxList<AccountMoveModel> accountMovesList) async {
    accountMoves.value = accountMovesList;
    
    // حفظ في Hive
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      final accountMovesJson = accountMovesList.map((a) => a.toJson()).toList();
      await HiveService.instance.saveAccountMoves(accountMovesJson);
      
      if (kDebugMode) {
        print('✅ Saved ${accountMovesList.length} account moves to Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving account moves to Hive: $e');
      }
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(PrefKeys.accountMove, jsonEncode(accountMovesList.toList()));
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error saving account moves to SharedPreferences: $fallbackError');
        }
      }
    }
  }

  /// جلب الحركات المحاسبية من Hive
  static Future<RxList<AccountMoveModel>> getAccountMoves() async {
    try {
      // التأكد من تهيئة HiveService
      await HiveService.instance.init();
      // جلب من Hive
      final accountMovesList = await HiveService.instance.getAccountMoves();
      final accountList = accountMovesList
          .map((e) => AccountMoveModel.fromJson(e is Map ? e : e.toJson()))
          .toList();
      accountMoves.value = accountList;
      
      if (kDebugMode) {
        print('✅ Loaded ${accountList.length} account moves from Hive');
      }
      
      return accountMoves;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading account moves from Hive: $e');
        print('🔄 Falling back to SharedPreferences...');
      }
      
      // Fallback إلى SharedPreferences
      try {
        final prefs = await SharedPreferences.getInstance();
        var accountMoveString = prefs.getString(PrefKeys.accountMove);
        if (accountMoveString == null || accountMoveString.isEmpty) {
          accountMoves.value = <AccountMoveModel>[].obs;
          return accountMoves;
        }
        List<dynamic> decoded = jsonDecode(accountMoveString);
        accountMoves.value = RxList(decoded.map((e) => AccountMoveModel.fromJson(e)).toList());
        return accountMoves;
      } catch (fallbackError) {
        if (kDebugMode) {
          print('❌ Error loading account moves from SharedPreferences: $fallbackError');
        }
        accountMoves.value = <AccountMoveModel>[].obs;
        return accountMoves;
      }
    }
  }

  /// مسح جميع الحركات المحاسبية
  static Future<void> clearAccountMoves() async {
    try {
      await HiveService.instance.init();
      await HiveService.instance.clearAccountMoves();
      accountMoves.clear();
      
      if (kDebugMode) {
        print('✅ Cleared all account moves from Hive');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing account moves: $e');
      }
    }
  }

  /// عدد الحركات المحاسبية
  static int get accountMovesCount {
    try {
      return HiveService.instance.accountMovesCount;
    } catch (e) {
      return accountMoves.length;
    }
  }
}

