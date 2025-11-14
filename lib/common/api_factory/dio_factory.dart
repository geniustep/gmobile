import 'dart:developer' show log;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/api_factory/interceptors/retry_interceptor.dart';
import 'package:gsloution_mobile/common/api_factory/interceptors/auth_interceptor.dart';

typedef void OnError(String error, Map<String, dynamic> data);
typedef void OnResponse<T>(T response);

class DioFactory {
  static final _singleton = DioFactory._instance();

  static Dio? get dio => _singleton._dio;
  static var _deviceName = 'Generic Device';
  static var _authorization = '';

  /// الحصول على معلومات الجهاز
  static Future<bool> computeDeviceInfo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        _deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        _deviceName = iosInfo.utsname.machine;
      }
    } else if (Platform.isFuchsia) {
      _deviceName = 'Generic Fuchsia Device';
    } else if (Platform.isLinux) {
      _deviceName = 'Generic Linux Device';
    } else if (Platform.isMacOS) {
      _deviceName = 'Generic Macintosh Device';
    } else if (Platform.isWindows) {
      _deviceName = 'Generic Windows Device';
    }

    return true;
  }

  /// تهيئة الترويسة Authorization
  static void initialiseHeaders(String token) {
    _authorization = token;
    _singleton._dio!.options.headers[HttpHeaders.cookieHeader] = _authorization;
  }

  /// تعيين توكن FCM
  static void initFCMToken(String token) {
    var _token = token;
    _singleton._dio!.options.headers["device_id"] = _token;
  }

  Dio? _dio;

  /// المُنشئ الخاص بـ DioFactory
  DioFactory._instance() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEnvironment.Dev.endpoint,
        headers: {
          HttpHeaders.userAgentHeader: _deviceName,
          HttpHeaders.authorizationHeader: _authorization,
          'Connection': 'Keep-Alive',
          'Keep-Alive': 'timeout=120, max=1000',
        },
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        contentType: Headers.jsonContentType,
      ),
    );

    if (!kReleaseMode) {
      _dio!.interceptors.add(
        LogInterceptor(
          request: Config.logNetworkRequest,
          requestHeader: Config.logNetworkRequestHeader,
          requestBody: Config.logNetworkRequestBody,
          responseHeader: Config.logNetworkResponseHeader,
          responseBody: Config.logNetworkResponseBody,
          error: Config.logNetworkError,
          logPrint: (Object object) {
            log(object.toString(), name: 'dio');
          },
        ),
      );
    }

    // Add auth interceptor first (handles token refresh)
    _dio!.interceptors.add(AuthInterceptor());
    
    // Add retry interceptor before other interceptors
    _dio!.interceptors.add(RetryInterceptor(
      dio: _dio!,
      maxRetries: 3,
      retryDelay: const Duration(seconds: 2),
    ));

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // معالجة الطلب قبل الإرسال
          log('Request [${options.method}] => PATH: ${options.path}');
          return handler.next(options); // متابعة الطلب
        },
        onResponse: (response, handler) {
          // معالجة الاستجابة
          log('Response [${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response); // متابعة الاستجابة
        },
        onError: (DioException e, handler) async {
          // التحقق من حالة الخطأ 401
          if (e.response?.statusCode == 401) {
            log('Session expired. Showing dialog...');
            showSessionDialog(); // استدعاء الدالة لعرض نافذة انتهاء الجلسة
            return handler.next(e); // متابعة الخطأ
          }

          log('Error [${e.type}] => MESSAGE: ${e.message}');
          return handler.next(e); // متابعة الخطأ
        },
      ),
    );
  }
}
