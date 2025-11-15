import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/modules/home_api_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/res_partner_model.dart';

class HomeController extends GetxController {
  var listOfPartners = <Records>[].obs;

  getPartners() {
    resPartnerApi(
      onResponse: (response) {
        if (response.records != null) {
          listOfPartners.assignAll(response.records!);
        }
      },
    );
  }
}

