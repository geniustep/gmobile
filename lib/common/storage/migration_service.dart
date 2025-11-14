// ═══════════════════════════════════════════════════════════
// MigrationService - نقل البيانات من SharedPreferences إلى Hive
// ═══════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/storage/hive/entities/product_entity.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';

class MigrationService {
  MigrationService._();

  static final MigrationService instance = MigrationService._();

  static const String _migrationVersionKey = 'migration_version';
  static const int _currentMigrationVersion = 1;

  // ═══════════════════════════════════════════════════════════
  // Main Migration Method
  // ═══════════════════════════════════════════════════════════

  Future<void> migrate() async {
    try {
      if (kDebugMode) {
        print('\n📦 Starting Migration Process...');
      }

      final prefs = await SharedPreferences.getInstance();
      final currentVersion = prefs.getInt(_migrationVersionKey) ?? 0;

      if (currentVersion >= _currentMigrationVersion) {
        if (kDebugMode) {
          print('✅ Already migrated to version $_currentMigrationVersion');
        }
        return;
      }

      // تنفيذ Migration حسب الإصدار
      if (currentVersion == 0) {
        await _migrateFromV0ToV1(prefs);
      }

      // حفظ إصدار الـ Migration الحالي
      await prefs.setInt(_migrationVersionKey, _currentMigrationVersion);

      if (kDebugMode) {
        print('✅ Migration completed successfully!');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Migration failed: $e');
        print('Stack trace: ${StackTrace.current}');
      }
      // لا نرمي Exception حتى لا يتعطل التطبيق
      // المستخدم سيحتاج إلى إعادة تحميل البيانات من السيرفر
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Migration V0 → V1: SharedPreferences → Hive
  // ═══════════════════════════════════════════════════════════

  Future<void> _migrateFromV0ToV1(SharedPreferences prefs) async {
    if (kDebugMode) {
      print('\n🔄 Migrating from V0 to V1 (SharedPreferences → Hive)...');
    }

    final storage = StorageService.instance;

    // ─────── Products ───────
    await _migrateProducts(prefs, storage);

    // ─────── Partners ───────
    await _migratePartners(prefs, storage);

    // ─────── Sales ───────
    await _migrateSales(prefs, storage);

    // ─────── Generic Data ───────
    await _migrateGenericData(prefs, storage, 'categoryProduct');
    await _migrateGenericData(prefs, storage, 'priceLists');
    await _migrateGenericData(prefs, storage, 'salesLine');
    await _migrateGenericData(prefs, storage, 'accountMove');
    await _migrateGenericData(prefs, storage, 'paymentTerms');
    await _migrateGenericData(prefs, storage, 'stockPicking');
    await _migrateGenericData(prefs, storage, 'stockMoveLines');

    // ─────── حذف البيانات القديمة من SharedPreferences ───────
    await _cleanupOldData(prefs);
  }

  // ═══════════════════════════════════════════════════════════
  // Migration Helpers
  // ═══════════════════════════════════════════════════════════

  Future<void> _migrateProducts(
    SharedPreferences prefs,
    StorageService storage,
  ) async {
    try {
      final productsJson = prefs.getString('products');
      if (productsJson == null || productsJson.isEmpty) {
        if (kDebugMode) {
          print('   ⏭️  No products to migrate');
        }
        return;
      }

      final List<dynamic> decoded = jsonDecode(productsJson);
      final products = decoded
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final entities = products
          .map((model) => ProductEntity.fromModel(model))
          .toList();

      await storage.setProducts(products);

      if (kDebugMode) {
        print('   ✅ Migrated ${entities.length} products');
      }
    } catch (e) {
      if (kDebugMode) {
        print('   ❌ Error migrating products: $e');
      }
    }
  }

  Future<void> _migratePartners(
    SharedPreferences prefs,
    StorageService storage,
  ) async {
    try {
      final partnersJson = prefs.getString('partners');
      if (partnersJson == null || partnersJson.isEmpty) {
        if (kDebugMode) {
          print('   ⏭️  No partners to migrate');
        }
        return;
      }

      final List<dynamic> decoded = jsonDecode(partnersJson);
      final partners = decoded
          .map((e) => PartnerModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await storage.setPartners(partners);

      if (kDebugMode) {
        print('   ✅ Migrated ${partners.length} partners');
      }
    } catch (e) {
      if (kDebugMode) {
        print('   ❌ Error migrating partners: $e');
      }
    }
  }

  Future<void> _migrateSales(
    SharedPreferences prefs,
    StorageService storage,
  ) async {
    try {
      final salesJson = prefs.getString('sales');
      if (salesJson == null || salesJson.isEmpty) {
        if (kDebugMode) {
          print('   ⏭️  No sales to migrate');
        }
        return;
      }

      final List<dynamic> decoded = jsonDecode(salesJson);
      final sales = decoded
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();

      await storage.setSales(sales);

      if (kDebugMode) {
        print('   ✅ Migrated ${sales.length} sales');
      }
    } catch (e) {
      if (kDebugMode) {
        print('   ❌ Error migrating sales: $e');
      }
    }
  }

  Future<void> _migrateGenericData(
    SharedPreferences prefs,
    StorageService storage,
    String key,
  ) async {
    try {
      final dataJson = prefs.getString(key);
      if (dataJson == null || dataJson.isEmpty) {
        if (kDebugMode) {
          print('   ⏭️  No $key to migrate');
        }
        return;
      }

      final decoded = jsonDecode(dataJson);
      await storage.saveGenericData(key, decoded);

      if (kDebugMode) {
        final count = decoded is List ? decoded.length : 1;
        print('   ✅ Migrated $key ($count items)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('   ❌ Error migrating $key: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Cleanup Old Data
  // ═══════════════════════════════════════════════════════════

  Future<void> _cleanupOldData(SharedPreferences prefs) async {
    if (kDebugMode) {
      print('\n🧹 Cleaning up old SharedPreferences data...');
    }

    final keysToRemove = [
      'products',
      'partners',
      'sales',
      'salesLine',
      'categoryProduct',
      'priceLists',
      'accountMove',
      'paymentTerms',
      'stockPicking',
      'stockMoveLines',
    ];

    for (final key in keysToRemove) {
      await prefs.remove(key);
    }

    if (kDebugMode) {
      print('   ✅ Removed ${keysToRemove.length} old keys');
      print('   📊 Remaining keys: ${prefs.getKeys().length}');
      print('   📝 Keys: ${prefs.getKeys()}');
    }
  }

  // ═══════════════════════════════════════════════════════════
  // Utility Methods
  // ═══════════════════════════════════════════════════════════

  /// إعادة تعيين Migration (للاختبار فقط)
  Future<void> resetMigration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_migrationVersionKey);

    if (kDebugMode) {
      print('🔄 Migration reset - will run again on next startup');
    }
  }

  /// التحقق من حالة Migration
  Future<Map<String, dynamic>> getMigrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_migrationVersionKey) ?? 0;

    return {
      'currentVersion': currentVersion,
      'targetVersion': _currentMigrationVersion,
      'needsMigration': currentVersion < _currentMigrationVersion,
      'migrationKeys': [
        'products',
        'partners',
        'sales',
        'salesLine',
        'categoryProduct',
        'priceLists',
        'accountMove',
        'paymentTerms',
        'stockPicking',
        'stockMoveLines',
      ],
    };
  }
}
