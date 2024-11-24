import 'dart:developer' show log;
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/config/config.dart';

typedef void OnError(String error, Map<String, dynamic> data);
typedef void OnResponse<T>(T response);

class DioFactory {
  static final _singleton = DioFactory._instance();

  static Dio? get dio => _singleton._dio;
  static var _deviceName = 'Generic Device';
  static var _authorization = '';

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

  static void initialiseHeaders(String token) {
    _authorization = token;
    _singleton._dio!.options.headers[HttpHeaders.cookieHeader] = _authorization;
  }

  static void initFCMToken(String token) {
    var _token = token;
    _singleton._dio!.options.headers["device_id"] = _token;
  }

  Dio? _dio;

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
      _dio!.interceptors.add(LogInterceptor(
        request: Config.logNetworkRequest,
        requestHeader: Config.logNetworkRequestHeader,
        requestBody: Config.logNetworkRequestBody,
        responseHeader: Config.logNetworkResponseHeader,
        responseBody: Config.logNetworkResponseBody,
        error: Config.logNetworkError,
        logPrint: (Object object) {
          log(object.toString(), name: 'dio');
        },
      ));
    }

    _dio!.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Custom logic before the request is sent
        log('Request [${options.method}] => PATH: ${options.path}');
        return handler.next(options); // Continue
      },
      onResponse: (response, handler) {
        // Custom logic with response data
        log('Response [${response.statusCode}] => DATA: ${response.data}');
        return handler.next(response); // Continue
      },
      onError: (DioException e, handler) {
        // Custom error handling logic
        log('Error [${e.type}] => MESSAGE: ${e.message}');
        if (e.response?.statusCode == 401) {
          log('Unauthorized request detected.');
        }
        return handler.next(e); // Continue
      },
    ));
  }
}
