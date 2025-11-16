import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/base_list.dart';
import 'package:gsloution_mobile/common/api_factory/modules/authentication_module.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/app_fonts.dart';
import 'package:gsloution_mobile/common/config/app_images.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/localization/localize.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/widgets/log.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> ackAlert(
  BuildContext context,
  String title,
  String content,
  VoidCallback onPressed,
) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        titleTextStyle: TextStyle(
          fontFamily: AppFont.Roboto_Regular,
          fontSize: 21,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        content: Text(content),
        contentTextStyle: TextStyle(
          fontFamily: AppFont.Roboto_Regular,
          fontSize: 17,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              Localize.done.tr,
              style: TextStyle(
                fontFamily: AppFont.Roboto_Regular,
                fontSize: 17,
                color: AppColors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: onPressed,
          ),
        ],
      );
    },
  );
}

void showLoading() {
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Indicator مع تدرج لوني
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // النص
              const Text(
                'جاري التحميل...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: false,
  );
}

void hideLoading() {
  Get.back();
}

void showSnackBar({
  title,
  message,
  SnackPosition? snackPosition,
  Color? backgroundColor,
  Duration? duration,
}) {
  Get.showSnackbar(
    GetBar(
      title: title,
      message: message.toString(),
      duration: duration ?? Duration(seconds: 2),
      snackPosition: snackPosition ?? SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? Colors.black87,
    ),
  );
}

handleApiError(errorMessage) {
  showSnackBar(backgroundColor: Colors.redAccent, message: errorMessage);
}

showWarning(message) {
  showSnackBar(backgroundColor: Colors.blueAccent, message: message);
}

bool validatePassword(String password) {
  return RegExp(
    r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~?]).{8,}$',
  ).hasMatch(password);
}

bool validateEmail(String email) {
  return RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
}

bool validURL(String url) {
  return Uri.parse(url).isAbsolute;
}

typedef OnItemsSelected(BaseListModel data);
typedef OnMultiItemSelected(List<BaseListModel> data);
typedef OnFilterSelected(String salary);

//MARK - Open single select bottomsheet -
//-----------------------------------
showCustomBottomSheet({
  @required List<BaseListModel>? list,
  @required String? title,
  @required OnItemsSelected? onItemsSelected,
  bool isMultiSelect = false,
}) {
  Get.bottomSheet(
    BottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30.0),
          topLeft: Radius.circular(30.0),
        ),
      ),
      onClosing: () {
        Log("on Close bottom sheet");
      },
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(30.0),
              topLeft: Radius.circular(30.0),
            ),
          ),
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(width: 40, height: 4, color: AppColors.greyDotColor),
              SizedBox(height: 25),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Image.asset(AppImages.ic_back),
                  ),
                  SizedBox(width: 25),
                  Text(title ?? "", style: AppFont.Title_H6_Medium()),
                  isMultiSelect
                      ? Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              height: 41,
                              width: 75,
                              child: MaterialButton(
                                elevation: 0.0,
                                color: AppColors.blueButtonColor,
                                onPressed: () {
                                  var isSelectedItems = list!
                                      .where((e) => e.isSelected)
                                      .toList();
                                  if (isSelectedItems.length == 0) {
                                    // showWarning(Localize.selectAnyItem.tr);
                                  } else {
                                    Get.back(result: isSelectedItems);
                                  }
                                },
                                child: Text(
                                  Localize.done.tr,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 17,
                                  ),
                                ),
                                textColor: AppColors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height / 2 - 170,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    itemCount: list!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 50,
                        child: InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                list[index].name!,
                                style: AppFont.Body1_Regular(),
                              ),
                              list[index].isSelected
                                  ? Icon(Icons.done)
                                  : SizedBox(),
                            ],
                          ),
                          onTap: () {
                            if (isMultiSelect) {
                              list[index].isSelected = !list[index].isSelected;
                            } else {
                              list[index].isSelected = !list[index].isSelected;
                              Get.back(result: list[index]);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  ).then((value) {
    FocusManager.instance.primaryFocus!.unfocus();
    onItemsSelected!(value);
    Log(value);
  });
}

showSessionDialog() {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Text("Session Time out", style: AppFont.Title_H4_Medium()),
      content: Text(
        "Sorry! your session is expired, Please login again",
        style: AppFont.Body2_Regular(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            await PrefUtils.clearPrefs();
            // ✅ استخدام offAllNamed بدلاً من toNamed للعودة الصحيحة
            Get.offAllNamed(AppRoutes.login);
          },
          child: Text(Localize.signin.tr, style: AppFont.Body2_Regular()),
        ),
      ],
    ),
  );
}

showLogoutDialog() {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      title: Text("Logout", style: AppFont.Title_H4_Medium()),
      content: Text(
        "Are you sure you want to logout?",
        style: AppFont.Body2_Regular(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            Get.back();
          },
          child: Text(Localize.cancel.tr, style: AppFont.Body2_Regular()),
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            logoutApi();
          },
          child: Text("Logout", style: AppFont.Body2_Regular()),
        ),
      ],
    ),
  );
}

Future<String> getImageUrl({
  required String model,
  required String field,
  required String id,
}) async {
  String session = await PrefUtils.getToken();
  return Config.odooDevURL +
      "/web/image?model=$model&field=$field&$session&id=$id";
}

Future<void> handleSessionExpired() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  // ✅ استخدام Get.offAllNamed بدلاً من navigatorKey
  Get.offAllNamed(AppRoutes.login);
}

// ============= Enhanced Error Handling =============

/// خدمة معالجة الأخطاء المحسنة
class OrderErrorHandler {
  static void handleOrderCreationError(dynamic error, {String? context}) {
    String title = 'خطأ في إنشاء الطلب';
    String message = 'حدث خطأ غير متوقع';
    IconData icon = Icons.error;
    Color color = Colors.red;

    if (error is SocketException) {
      title = 'خطأ في الاتصال';
      message = 'يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى';
      icon = Icons.wifi_off;
    } else if (error is TimeoutException) {
      title = 'انتهت مهلة الاتصال';
      message = 'استغرق الطلب وقتاً أطول من المتوقع، يرجى المحاولة مرة أخرى';
      icon = Icons.timer_off;
    } else if (error is FormatException) {
      title = 'خطأ في تنسيق البيانات';
      message = 'البيانات المرسلة غير صحيحة، يرجى المحاولة مرة أخرى';
      icon = Icons.data_usage;
    } else if (error.toString().contains('partner_id')) {
      title = 'خطأ في بيانات العميل';
      message = 'يرجى اختيار عميل صالح والمحاولة مرة أخرى';
      icon = Icons.person_off;
    } else if (error.toString().contains('product_id')) {
      title = 'خطأ في بيانات المنتج';
      message = 'يرجى التحقق من المنتجات المضافة والمحاولة مرة أخرى';
      icon = Icons.inventory_2;
    }

    _showDetailedErrorSnackbar(title, message, icon, color, context);
  }

  static void _showDetailedErrorSnackbar(
    String title,
    String message,
    IconData icon,
    Color color,
    String? context,
  ) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: Icon(icon, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      // ✅ إضافة زر "المحاولة مرة أخرى"
      mainButton: TextButton(
        onPressed: () {
          Get.back(); // إغلاق الـ snackbar
          // إعادة المحاولة
          if (context == 'order_creation') {
            // إعادة محاولة إنشاء الطلب
          }
        },
        child: const Text(
          'المحاولة مرة أخرى',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// خدمة الإشعارات المحسنة
class NotificationService {
  static void showSuccess(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.check_circle, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
    );
  }

  static void showWarning(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      icon: const Icon(Icons.warning, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
    );
  }

  static void showInfo(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.blue.withOpacity(0.9),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.info, color: Colors.white),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      isDismissible: true,
    );
  }
}

/// مؤشر التحميل المحسن
class LoadingOverlay extends StatelessWidget {
  final String message;
  final double progress;
  final bool isIndeterminate;

  const LoadingOverlay({
    Key? key,
    required this.message,
    this.progress = 0.0,
    this.isIndeterminate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ مؤشر تحميل مخصص
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                  ),
                  child: isIndeterminate
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        )
                      : CircularProgressIndicator(
                          value: progress,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!isIndeterminate) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// خدمة التحقق المتقدم
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    required this.errors,
    this.warnings = const [],
  });
}

class OrderValidationException implements Exception {
  final List<String> errors;
  OrderValidationException(this.errors);

  @override
  String toString() => 'OrderValidationException: ${errors.join(', ')}';
}
