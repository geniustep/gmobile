import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/app.dart';
import 'package:gsloution_mobile/common/config/dependencies.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/storage/migration_service.dart';
import 'package:gsloution_mobile/common/storage/hive/hive_service.dart';
import 'package:gsloution_mobile/common/error/error_handler.dart';
import 'package:gsloution_mobile/common/session/session_manager.dart';
import 'package:gsloution_mobile/common/offline/offline_queue_manager.dart';
import 'package:gsloution_mobile/common/analytics/analytics_service.dart';
import 'package:gsloution_mobile/location.dart';

void main() async {
  // ✅ نقل ensureInitialized للأول
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ تفعيل Global Error Handler الجديد
  GlobalErrorHandler.setup();

  if (kDebugMode) {
    print('═══════════════════════════════════════════════════════');
    print('🚀 Starting gmobile Application');
    print('═══════════════════════════════════════════════════════');
  }

  // ✅ استخدام runZonedGuarded لكل شيء
  runZonedGuarded(
    () async {
      // 🚀 تهيئة الـ Storage الهجين (SharedPreferences + Hive)
      if (kDebugMode) {
        print('\n🚀 Initializing Hybrid Storage System...');
      }
      await StorageService.instance.init();

      // 🗄️ تهيئة Hive Service
      if (kDebugMode) {
        print('🗄️ Initializing Hive Service...');
      }
      await HiveService.instance.init();

      // 📦 تنفيذ Migration من SharedPreferences إلى Hive
      if (kDebugMode) {
        print('📦 Running Data Migration...');
      }
      await MigrationService.instance.migrate();

      // 📊 تهيئة Analytics Service
      if (kDebugMode) {
        print('📊 Initializing Analytics Service...');
      }
      await AnalyticsService.instance.initialize(
        enableFirebase: false, // سيتم تفعيله لاحقاً عند إضافة Firebase
        enableLocal: true,
      );

      // 📍 الحصول على الموقع
      try {
        if (kDebugMode) {
          print('📍 Getting Location...');
        }
        await MyLocation.getLatAndLong();
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Error getting location: $e');
        }
        await AnalyticsService.instance.logError('location_error: $e');
      }

      // 💉 حقن Dependencies
      if (kDebugMode) {
        print('💉 Injecting Dependencies...');
      }
      Dependencies.injectDependencies();

      // ✅ استخدام StorageService بدلاً من PrefUtils (للتوافق مع الكود القديم)
      DioFactory.initialiseHeaders(await StorageService.instance.getToken());
      bool isLoggedIn = await StorageService.instance.getIsLoggedIn();

      // 🔐 تفعيل Session Manager إذا كان المستخدم مسجل دخول
      if (isLoggedIn) {
        if (kDebugMode) {
          print('🔐 Starting Session Manager...');
        }
        SessionManager.instance.startMonitoring();
      }

      // 📡 تفعيل Offline Queue Manager
      if (kDebugMode) {
        print('📡 Starting Offline Queue Manager...');
      }
      OfflineQueueManager.instance.startAutoSync(
        interval: const Duration(minutes: 5),
      );

      // 📱 تسجيل فتح التطبيق
      await AnalyticsService.instance.logAppOpen();

      if (kDebugMode) {
        print('✅ All systems initialized successfully!');
        print('═══════════════════════════════════════════════════════\n');
      }

      runApp(App(isLoggedIn));
    },
    (error, stack) {
      // استخدام GlobalErrorHandler للأخطاء العامة
      GlobalErrorHandler.instance.handleError(
        AppError(
          message: error.toString(),
          stackTrace: stack,
          type: ErrorType.platform,
        ),
      );
    },
  );
}
