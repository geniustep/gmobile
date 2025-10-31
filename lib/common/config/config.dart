import 'package:flutter/widgets.dart';

class Config {
  Config._();

  ///Odoo URLs
  static const String odooDevURL = "https://app.propanel.ma/";
  static const String odooProdURL = "https://app.propanel.ma/";
  static const String odooUATURL = "https://app.propanel.ma/";
  // static const String odooDevURL = "http://207.154.252.42:8069/";
  // static const String odooProdURL = "http://207.154.252.42:8069/";
  // static const String odooUATURL = "http://207.154.252.42:8069/";

  /// SelfSignedCert:
  static const selfSignedCert = false;

  /// API Config
  static const timeout = 90000;
  static const logNetworkRequest = true;
  static const logNetworkRequestHeader = true;
  static const logNetworkRequestBody = true;
  static const logNetworkResponseHeader = false;
  static const logNetworkResponseBody = true;
  static const logNetworkError = true;

  /// Localization Config
  static const supportedLocales = <Locale>[Locale('en', ''), Locale('pt', '')];

  /// Common Const
  static const actionLocale = 'locale';
  static const int SIGNUP = 0;
  static const int SIGNIN = 1;
  static const String CURRENCY_SYMBOL = "Dh";
  static String FCM_TOKEN = "";
  static String dataBase = "done2026";
}
