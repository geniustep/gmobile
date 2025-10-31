import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/app.dart';
import 'package:gsloution_mobile/common/config/dependencies.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/location.dart';

void main() async {
  // ✅ إعداد Error Handlers قبل ensureInitialized
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      print('════════════════════════════════════════════');
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');
      print('════════════════════════════════════════════');
    }
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      print('════════════════════════════════════════════');
      print('Platform Error: $error');
      print('Stack trace: $stack');
      print('════════════════════════════════════════════');
    }
    return true;
  };

  // ✅ استخدام runZonedGuarded لكل شيء
  runZonedGuarded(
    () async {
      // ✅ نقل ensureInitialized داخل الـ Zone
      WidgetsFlutterBinding.ensureInitialized();

      try {
        await MyLocation.getLatAndLong();
      } catch (e) {
        if (kDebugMode) {
          print('Error getting location: $e');
        }
      }

      Dependencies.injectDependencies();

      DioFactory.initialiseHeaders(await PrefUtils.getToken());
      bool isLoggedIn = await PrefUtils.getIsLoggedIn();

      runApp(App(isLoggedIn));
    },
    (error, stack) {
      if (kDebugMode) {
        print('════════════════════════════════════════════');
        print('Zone Error: $error');
        print('Stack trace: $stack');
        print('════════════════════════════════════════════');
      }
    },
  );
}
