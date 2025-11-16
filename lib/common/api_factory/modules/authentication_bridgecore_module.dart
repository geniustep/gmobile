// ════════════════════════════════════════════════════════════
// BridgeCore Authentication Module
// ════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/clients/bridgecore_client.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_manager.dart';
import 'package:gsloution_mobile/common/api_factory/models/user/user_model.dart';
import 'package:gsloution_mobile/common/config/config.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/common/controllers/signin_controller.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class AuthenticationBridgeCoreModule {
  AuthenticationBridgeCoreModule._();

  // ════════════════════════════════════════════════════════════
  // Sign In with BridgeCore
  // ════════════════════════════════════════════════════════════

  static Future<void> signIn({
    required String email,
    required String password,
    String? database,
  }) async {
    try {
      if (kDebugMode) {
        print('🔐 BridgeCore SignIn: Starting authentication...');
        print('   Email: $email');
        print('   Database: ${database ?? Config.bridgeCoreDefaultDatabase}');
      }

      // Get BridgeCore client
      final client = ApiClientFactory.instance as BridgeCoreClient;

      // Authenticate with BridgeCore
      // Note: Using email as username since BridgeCore accepts email as username
      await client.authenticate(
        username: email,
        password: password,
        database: database ?? Config.bridgeCoreDefaultDatabase,
        onResponse: (userResponse) async {
          try {
            if (kDebugMode) {
              print('✅ Authentication successful');
              print('   Response: $userResponse');
            }

            // Get tokens from secure storage (they're saved by the client)
            final storage = const FlutterSecureStorage();
            final accessToken =
                await storage.read(key: 'bridgecore_access_token') ?? '';
            final refreshToken = await storage.read(
              key: 'bridgecore_refresh_token',
            );

            // Extract user data from response
            final userData = {
              'uid': userResponse['uid'],
              'username': userResponse['username'],
              'name': userResponse['name'],
              'company_id': userResponse['company_id'],
              'partner_id': userResponse['partner_id'],
            };

            // Create UserModel
            final user = UserModel.fromJson(userData);

            if (kDebugMode) {
              print('👤 User: ${user.name} (${user.username})');
              if (accessToken.isNotEmpty) {
                print('🔑 Access Token: ${accessToken.substring(0, 20)}...');
              }
              if (refreshToken != null && refreshToken.isNotEmpty) {
                print('🔄 Refresh Token: ${refreshToken.substring(0, 20)}...');
              }
            }

            // Save authentication data
            await _saveAuthenticationData(
              accessToken: accessToken,
              refreshToken: refreshToken,
              user: user,
            );

            // Initialize WebSocket
            await _initializeWebSocket(accessToken);

            // Update current user
            currentUser.value = user;

            if (kDebugMode) {
              print('✅ SignIn completed successfully');
              print('   Navigating to splash screen...');
            }

            // Navigate to splash screen to load data
            Get.offAllNamed(AppRoutes.splashScreen);
          } catch (error, stackTrace) {
            if (kDebugMode) {
              print('❌ Error processing authentication response: $error');
              print('📍 Stack trace: $stackTrace');
            }
            _handleAuthenticationError(error.toString(), {});
          }
        },
        onError: (error, data) {
          if (kDebugMode) {
            print('❌ BridgeCore SignIn failed: $error');
            print('📊 Error Data: $data');
          }
          _handleAuthenticationError(error, data);
        },
      );
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ BridgeCore SignIn failed: $error');
        print('📍 Stack trace: $stackTrace');
      }

      _handleAuthenticationError(error.toString(), {});
    }
  }

  // ════════════════════════════════════════════════════════════
  // Save Authentication Data
  // ════════════════════════════════════════════════════════════

  static Future<void> _saveAuthenticationData({
    required String accessToken,
    String? refreshToken,
    required UserModel user,
  }) async {
    try {
      final storage = StorageService.instance;

      // Save tokens
      await storage.setToken(accessToken);

      // Save refresh token if available
      if (refreshToken != null) {
        // TODO: Add refresh token storage to StorageService
        // await storage.setRefreshToken(refreshToken);
      }

      // Save user data
      await storage.setUser(user);

      // Set logged in flag
      await storage.setIsLoggedIn(true);

      // For backward compatibility with old code using PrefUtils
      await PrefUtils.setToken(accessToken);
      await PrefUtils.setUser(jsonEncode(user.toJson()));
      await PrefUtils.setIsLoggedIn(true);

      if (kDebugMode) {
        print('✅ Authentication data saved successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving authentication data: $e');
      }
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Initialize WebSocket
  // ════════════════════════════════════════════════════════════

  static Future<void> _initializeWebSocket(String token) async {
    try {
      if (kDebugMode) {
        print('🔌 Initializing WebSocket...');
      }

      await WebSocketManager.instance.enable();
      await WebSocketManager.instance.connect(token);

      if (kDebugMode) {
        print('✅ WebSocket connected');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ WebSocket initialization failed: $e');
      }
      // Don't throw - WebSocket is optional
    }
  }

  // ════════════════════════════════════════════════════════════
  // Sign Out (Smart Logout)
  // ════════════════════════════════════════════════════════════

  static Future<void> signOut({bool clearCache = false}) async {
    try {
      if (kDebugMode) {
        print('🚪 BridgeCore SignOut: Starting logout...');
        print('   Clear cache: $clearCache');
      }

      // Disconnect WebSocket
      WebSocketManager.instance.disconnect();
      WebSocketManager.instance.disable();

      if (kDebugMode) {
        print('🔌 WebSocket disconnected');
      }

      final storage = StorageService.instance;

      if (clearCache) {
        // Clear all data including cache
        await storage.clearAll();
        await PrefUtils.clearPrefs();

        if (kDebugMode) {
          print('🗑️ All data cleared (including cache)');
        }
      } else {
        // Smart logout: Clear only sensitive data, keep offline cache
        await _clearSensitiveDataOnly(storage);

        if (kDebugMode) {
          print('🔐 Sensitive data cleared (cache preserved)');
        }
      }

      // Clear current user
      currentUser.value = UserModel();

      if (kDebugMode) {
        print('✅ SignOut completed successfully');
        print('   Navigating to login screen...');
      }

      // Navigate to login
      Get.offAllNamed(AppRoutes.login);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print('❌ BridgeCore SignOut failed: $error');
        print('📍 Stack trace: $stackTrace');
      }

      // Force logout even if there's an error
      Get.offAllNamed(AppRoutes.login);
    }
  }

  // ════════════════════════════════════════════════════════════
  // Clear Sensitive Data Only
  // ════════════════════════════════════════════════════════════

  static Future<void> _clearSensitiveDataOnly(StorageService storage) async {
    try {
      // Clear tokens
      await storage.setToken('');
      await PrefUtils.setToken('');

      // Clear user data
      await storage.setUser(UserModel());
      await PrefUtils.setUser('{}');

      // Clear logged in flag
      await storage.setIsLoggedIn(false);
      await PrefUtils.setIsLoggedIn(false);

      // Keep cached data: products, partners, sales, etc.
      // They remain in Hive for offline access

      if (kDebugMode) {
        print('✅ Sensitive data cleared');
        print('   Cached data preserved for offline access');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error clearing sensitive data: $e');
      }
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Error Handling
  // ════════════════════════════════════════════════════════════

  static void _handleAuthenticationError(
    String error,
    Map<String, dynamic> data,
  ) {
    if (kDebugMode) {
      print('🔐 Authentication Error: $error');
      print('📊 Error Data: $data');
    }

    String userFriendlyMessage = '';
    String errorType = '';

    // Analyze error type
    if (error.toLowerCase().contains('access denied') ||
        error.toLowerCase().contains('accessdenied') ||
        error.toLowerCase().contains('invalid credentials') ||
        error.toLowerCase().contains('wrong password')) {
      errorType = 'invalid_credentials';
      userFriendlyMessage = '❌ خطأ في الإيميل أو كلمة المرور';
    } else if (error.toLowerCase().contains('server unreachable') ||
        error.toLowerCase().contains('connection') ||
        error.toLowerCase().contains('network')) {
      errorType = 'network_error';
      userFriendlyMessage = '🌐 مشكلة في الاتصال بالإنترنت';
    } else if (error.toLowerCase().contains('timeout')) {
      errorType = 'timeout_error';
      userFriendlyMessage = '⏰ انتهت مهلة الاتصال';
    } else if (error.toLowerCase().contains('session expired')) {
      errorType = 'session_expired';
      userFriendlyMessage = '⏰ انتهت صلاحية الجلسة';
    } else if (error.toLowerCase().contains('database')) {
      errorType = 'database_error';
      userFriendlyMessage = '🗄️ خطأ في قاعدة البيانات';
    } else {
      errorType = 'unknown_error';
      userFriendlyMessage = '❓ خطأ غير متوقع';
    }

    // Show error dialog
    _showAuthenticationErrorDialog(
      errorType: errorType,
      message: userFriendlyMessage,
      technicalError: error,
    );
  }

  static void _showAuthenticationErrorDialog({
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                showSnackBar(
                  backgroundColor: Colors.blue,
                  message: 'يرجى إعادة المحاولة مع نفس البيانات',
                );
              },
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
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

  // ════════════════════════════════════════════════════════════
  // Error UI Helpers
  // ════════════════════════════════════════════════════════════

  static IconData _getErrorIcon(String errorType) {
    switch (errorType) {
      case 'invalid_credentials':
        return Icons.lock_outline;
      case 'network_error':
        return Icons.wifi_off;
      case 'timeout_error':
        return Icons.access_time;
      case 'session_expired':
        return Icons.access_time;
      case 'database_error':
        return Icons.storage;
      default:
        return Icons.error_outline;
    }
  }

  static Color _getErrorColor(String errorType) {
    switch (errorType) {
      case 'invalid_credentials':
        return Colors.red;
      case 'network_error':
        return Colors.orange;
      case 'timeout_error':
        return Colors.amber;
      case 'session_expired':
        return Colors.amber;
      case 'database_error':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  static String _getErrorTitle(String errorType) {
    switch (errorType) {
      case 'invalid_credentials':
        return 'بيانات الدخول غير صحيحة';
      case 'network_error':
        return 'مشكلة في الاتصال';
      case 'timeout_error':
        return 'انتهت مهلة الاتصال';
      case 'session_expired':
        return 'انتهت صلاحية الجلسة';
      case 'database_error':
        return 'خطأ في قاعدة البيانات';
      default:
        return 'خطأ غير متوقع';
    }
  }
}
