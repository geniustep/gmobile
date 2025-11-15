import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/common/widgets/log.dart';
import 'package:gsloution_mobile/common/controllers/signin_controller.dart';
import 'package:gsloution_mobile/common/api_factory/models/user/user_model.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

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
    onResponse: (UserModel response) async {
      currentUser.value = response;
      PrefUtils.setIsLoggedIn(true);
      await PrefUtils.setUser(jsonEncode(response));
      await PrefUtils.getUser().then((_) {
        Get.offAllNamed(AppRoutes.splashScreen);
      });
    },
    onError: (error, data) {
      _handleAuthenticationError(error, data);
    },
  );
}

/// معالجة أخطاء المصادقة بطريقة أنيقة ومفهومة
void _handleAuthenticationError(String error, Map<String, dynamic> data) {
  print('🔐 Authentication Error: $error');
  print('📊 Error Data: $data');

  String userFriendlyMessage = '';
  String errorType = '';

  // تحليل نوع الخطأ
  if (error.toLowerCase().contains('access denied') ||
      error.toLowerCase().contains('accessdenied')) {
    errorType = 'invalid_credentials';
    userFriendlyMessage = '❌ خطأ في الإيميل أو كلمة المرور';
  } else if (error.toLowerCase().contains('server unreachable') ||
      error.toLowerCase().contains('connection timeout')) {
    errorType = 'network_error';
    userFriendlyMessage = '🌐 مشكلة في الاتصال بالإنترنت';
  } else if (error.toLowerCase().contains('session expired')) {
    errorType = 'session_expired';
    userFriendlyMessage = '⏰ انتهت صلاحية الجلسة';
  } else if (data.containsKey('error') &&
      data['error'] is Map<String, dynamic> &&
      data['error'].containsKey('message')) {
    final serverMessage = data['error']['message'];
    if (serverMessage.toLowerCase().contains('access denied')) {
      errorType = 'invalid_credentials';
      userFriendlyMessage = '❌ خطأ في الإيميل أو كلمة المرور';
    } else {
      errorType = 'server_error';
      userFriendlyMessage = '⚠️ خطأ في الخادم';
    }
  } else {
    errorType = 'unknown_error';
    userFriendlyMessage = '❓ خطأ غير متوقع';
  }

  // عرض رسالة الخطأ بطريقة أنيقة
  _showAuthenticationErrorDialog(
    errorType: errorType,
    message: userFriendlyMessage,
    technicalError: error,
  );
}

/// عرض نافذة خطأ المصادقة بطريقة أنيقة
void _showAuthenticationErrorDialog({
  required String errorType,
  required String message,
  required String technicalError,
}) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            _getErrorIcon(errorType),
            color: _getErrorColor(errorType),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getErrorTitle(errorType),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: const TextStyle(fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          if (!kReleaseMode) ...[
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'تفاصيل تقنية:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                technicalError,
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (errorType == 'network_error') ...[
          TextButton(
            onPressed: () {
              Get.back();
              // إعادة المحاولة - سيحتاج المستخدم لإدخال البيانات مرة أخرى
              showSnackBar(
                backgroundColor: Colors.blue,
                message: 'يرجى إعادة المحاولة مع نفس البيانات',
              );
            },
            child: const Text(
              'إعادة المحاولة',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('حسناً', style: TextStyle(color: Colors.grey)),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}

/// الحصول على أيقونة الخطأ
IconData _getErrorIcon(String errorType) {
  switch (errorType) {
    case 'invalid_credentials':
      return Icons.lock_outline;
    case 'network_error':
      return Icons.wifi_off;
    case 'session_expired':
      return Icons.access_time;
    case 'server_error':
      return Icons.error_outline;
    default:
      return Icons.help_outline;
  }
}

/// الحصول على لون الخطأ
Color _getErrorColor(String errorType) {
  switch (errorType) {
    case 'invalid_credentials':
      return Colors.red;
    case 'network_error':
      return Colors.orange;
    case 'session_expired':
      return Colors.amber;
    case 'server_error':
      return Colors.purple;
    default:
      return Colors.grey;
  }
}

/// الحصول على عنوان الخطأ
String _getErrorTitle(String errorType) {
  switch (errorType) {
    case 'invalid_credentials':
      return 'بيانات الدخول غير صحيحة';
    case 'network_error':
      return 'مشكلة في الاتصال';
    case 'session_expired':
      return 'انتهت صلاحية الجلسة';
    case 'server_error':
      return 'خطأ في الخادم';
    default:
      return 'خطأ غير متوقع';
  }
}

logoutApi() {
  Api.destroy(
    onResponse: (response) {
      print("onResponse called with response: $response");
      PrefUtils.clearPrefs();
      // ✅ استخدام offAllNamed بدلاً من toNamed للعودة الصحيحة
      Get.offAllNamed(AppRoutes.login);
    },
    onError: (error, data) {
      handleApiError(error);
      PrefUtils.clearPrefs().then((_) => Get.offAllNamed(AppRoutes.login));
    },
  );
}
