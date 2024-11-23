import 'package:get/get.dart';
import 'package:gsloution_mobile/common/app.dart';
import 'package:gsloution_mobile/frontend/view/product/view/product_template_view.dart';
import 'package:gsloution_mobile/src/screen/homepage.dart';

class AppRoutes {
  // تعريف أسماء المسارات كقيم ثابتة
  static const app = '/app';
  static const homePage = '/homepage';
  static const products = '/products';
  static const settings = '/settings';

  // تعريف قائمة الصفحات المستخدمة في التطبيق
  static final List<GetPage> pages = [
    GetPage(name: app, page: () => App(Get.arguments)),
    GetPage(name: homePage, page: () => Homepage()),
    GetPage(name: products, page: () => Products()),
    // GetPage(name: settings, page: () => SettingsPage()),
  ];
}
