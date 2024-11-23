import 'dart:convert';

import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/common/widgets/log.dart';
import 'package:gsloution_mobile/src/authentication/controllers/signin_controller.dart';
import 'package:gsloution_mobile/src/authentication/models/user_model.dart';
import 'package:gsloution_mobile/src/authentication/views/signin.dart';
import 'package:gsloution_mobile/src/home/view/home.dart';

getVersionInfoAPI() {
  Api.getVersionInfo(
    onResponse: (response) {
      Api.getDatabases(
        serverVersionNumber: response.serverVersionInfo![0],
        onResponse: (response) {
          Log(response);
          // Config.dataBase = response[0];
        },
        onError: (error, data) {
          handleApiError(error);
        },
      );
    },
    onError: (error, data) {
      handleApiError(error);
    },
  );
}

authenticationAPI(String email, String pass) {
  Api.authenticate(
    username: email,
    password: pass,
    database: Config.dataBase,
    onResponse: (UserModel response) {
      currentUser.value = response;
      PrefUtils.setIsLoggedIn(true);
      PrefUtils.setUser(jsonEncode(response));
      Get.offAll(() => Home());
    },
    onError: (error, data) {
      handleApiError(error);
    },
  );
}

logoutApi() {
  Api.destroy(
    onResponse: (response) {
      PrefUtils.clearPrefs();
      Get.offAll(() => SignIn());
    },
    onError: (error, data) {
      handleApiError(error);
    },
  );
}
