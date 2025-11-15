import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/api_factory/modules/authentication_module.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/res_partner_model.dart';

resPartnerApi({required OnResponse<PartnerModel> onResponse}) {
  Api.callKW(
    model: "res.partner",
    method: 'search_read',
    args: [
      [],
      ["name", "email", "phone"]
    ],
    // domain: [],
    // fields: ["name", "email", "image_128"],
    onResponse: (response) {
      var res = PartnerModel.fromJson(response);
      print(res);
      onResponse(res);
    },
    onError: (error, data) {
      handleApiError(error);
    },
  );
}
