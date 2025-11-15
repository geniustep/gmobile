import 'package:get/get.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/common/controllers/signin_controller.dart';

class Dependencies {
  Dependencies._();

  static void injectDependencies() {
    Get.put(SignInController());
    Get.put(InvoiceController());
  }
}
