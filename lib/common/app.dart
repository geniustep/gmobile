import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/app_fonts.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/localization/translations.dart';
import 'package:gsloution_mobile/routes.dart';
import 'package:gsloution_mobile/src/authentication/views/signin.dart';
import 'package:gsloution_mobile/src/screen/homepage.dart';
import 'package:gsloution_mobile/src/screen/splashscreen.dart';

/// Main App Widget responsible for initializing the application.
class App extends StatefulWidget {
  final bool isLoggedIn;

  App(this.isLoggedIn);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  /// Flag to track if the initialization logic has run.
  var _initStateFlag = false;

  @override
  void initState() {
    super.initState();
    if (!kReleaseMode) {
      log('initState called', name: '_AppState::initState');
    }
    _initStateFlag = true;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    if (_initStateFlag) {
      _initStateFlag = false;
      await DioFactory.computeDeviceInfo();
    }
  }

  /// Builds the main app with configurations.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "G'Solution",
      getPages: AppRoutes.pages,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      theme: _buildAppTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: Config.supportedLocales,
      home: widget.isLoggedIn ? const SplashScreenApp() : SignIn(),
    );
  }

  /// Builds and returns the application theme.
  ThemeData _buildAppTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: AppColors.orangeThemeColor,
      fontFamily: AppFont.Roboto_Regular,
    );
  }
}
