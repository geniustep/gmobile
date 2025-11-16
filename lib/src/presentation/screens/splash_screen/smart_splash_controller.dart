// ════════════════════════════════════════════════════════════
// SmartSplashController - Auto-login with BridgeCore Integration
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/websocket/websocket_manager.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/config/hive/hive_products.dart';
import 'package:gsloution_mobile/common/config/hive/hive_partners.dart';
import 'package:gsloution_mobile/common/config/hive/hive_sales.dart';

enum SplashState {
  initializing,
  checkingToken,
  validatingToken,
  loadingData,
  ready,
  error,
}

class SmartSplashController extends GetxController {
  // ════════════════════════════════════════════════════════════
  // Constants
  // ════════════════════════════════════════════════════════════

  static const Duration _apiTimeout = Duration(seconds: 30);
  static const Duration _websocketTimeout = Duration(seconds: 10);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // ════════════════════════════════════════════════════════════
  // Observables
  // ════════════════════════════════════════════════════════════

  final state = SplashState.initializing.obs;
  final progress = 0.0.obs;
  final statusMessage = 'جاري التهيئة...'.obs;
  final hasInternet = true.obs;

  // ════════════════════════════════════════════════════════════
  // Services
  // ════════════════════════════════════════════════════════════

  final StorageService _storage = StorageService.instance;
  final Connectivity _connectivity = Connectivity();

  // ════════════════════════════════════════════════════════════
  // Resources to Cleanup
  // ════════════════════════════════════════════════════════════

  Timer? _timeoutTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // ════════════════════════════════════════════════════════════
  // Lifecycle
  // ════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  // ════════════════════════════════════════════════════════════
  // Initialization Flow
  // ════════════════════════════════════════════════════════════

  Future<void> _initialize() async {
    try {
      if (kDebugMode)
        print('🚀 SmartSplashController: Starting initialization...');

      // Step 1: Initialize storage
      await _initializeStorage();

      // Step 2: Check connectivity
      await _checkConnectivity();

      // Step 3: Check for existing token
      await _checkExistingToken();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ SmartSplashController: Initialization error: $e');
        print('📍 Stack trace: $stackTrace');
      }
      _handleError(e.toString());
    }
  }

  // ════════════════════════════════════════════════════════════
  // Step 1: Initialize Storage
  // ════════════════════════════════════════════════════════════

  Future<void> _initializeStorage() async {
    try {
      state.value = SplashState.initializing;
      statusMessage.value = 'جاري تهيئة التخزين...';
      progress.value = 0.1;

      await _storage.init();

      progress.value = 0.2;
      if (kDebugMode) print('✅ Storage initialized');
    } catch (e) {
      if (kDebugMode) print('❌ Storage initialization failed: $e');
      rethrow;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Step 2: Check Connectivity
  // ════════════════════════════════════════════════════════════

  Future<void> _checkConnectivity() async {
    try {
      statusMessage.value = 'جاري التحقق من الاتصال...';
      progress.value = 0.3;

      final connectivityResult = await _connectivity.checkConnectivity();
      hasInternet.value = connectivityResult != ConnectivityResult.none;

      if (kDebugMode) {
        print('🌐 Connectivity: ${hasInternet.value ? "Online" : "Offline"}');
      }

      progress.value = 0.4;
    } catch (e) {
      if (kDebugMode) print('⚠️ Connectivity check failed: $e');
      hasInternet.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Step 3: Check Existing Token (Auto-login)
  // ════════════════════════════════════════════════════════════

  Future<void> _checkExistingToken() async {
    try {
      state.value = SplashState.checkingToken;
      statusMessage.value = 'جاري التحقق من الجلسة...';
      progress.value = 0.5;

      final isLoggedIn = await _storage.getIsLoggedIn();
      final token = await _storage.getToken();

      if (kDebugMode) {
        print('🔐 IsLoggedIn: $isLoggedIn');
        print('🔑 Token exists: ${token.isNotEmpty}');
      }

      if (isLoggedIn && token.isNotEmpty) {
        // User was logged in, try auto-login
        await _performAutoLogin(token);
      } else {
        // No token, go to login screen
        if (kDebugMode) print('➡️ No valid session, redirecting to login');
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Token check failed: $e');
      _navigateToLogin();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Auto-login with Token Validation
  // ════════════════════════════════════════════════════════════

  Future<void> _performAutoLogin(String token) async {
    try {
      state.value = SplashState.validatingToken;
      statusMessage.value = 'جاري التحقق من صلاحية الجلسة...';
      progress.value = 0.6;

      if (!hasInternet.value) {
        // Offline mode - load from cache
        if (kDebugMode) print('📴 Offline mode - loading from cache');
        await _loadFromCache();
        return;
      }

      // Validate token with server
      final isValid = await _validateToken(token);

      if (isValid) {
        // Token is valid, load data
        await _loadApplicationData(token);
      } else {
        // Token invalid, go to login
        if (kDebugMode) print('❌ Token invalid, redirecting to login');
        await _storage.setIsLoggedIn(false);
        _navigateToLogin();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Auto-login failed: $e');

      // Fallback to cache if available
      await _loadFromCache();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Validate Token (Improved with Timeout & Retry)
  // ════════════════════════════════════════════════════════════

  Future<bool> _validateToken(String token) async {
    return await _retryOperation(
      operation: () async {
        final client = ApiClientFactory.instance;
        final completer = Completer<bool>();
        Timer? timeoutTimer;

        try {
          // Set timeout
          timeoutTimer = Timer(_apiTimeout, () {
            if (!completer.isCompleted) {
              if (kDebugMode) print('⏱️ Token validation timeout');
              completer.complete(false);
            }
          });

          // Try to fetch current user info as token validation
          // Using searchRead with limit 1 to get current user
          await client.searchRead(
            model: 'res.users',
            domain: [],
            fields: ['id', 'name', 'email'],
            limit: 1,
            onResponse: (response) {
              timeoutTimer?.cancel();
              if (response is List && response.isNotEmpty) {
                if (kDebugMode) print('✅ Token validation successful');
                completer.complete(true);
              } else {
                if (kDebugMode) print('❌ Token validation: No user found');
                completer.complete(false);
              }
            },
            onError: (error, data) {
              timeoutTimer?.cancel();
              if (kDebugMode) print('❌ Token validation failed: $error');
              completer.complete(false);
            },
          );

          return await completer.future;
        } catch (e) {
          timeoutTimer?.cancel();
          if (kDebugMode) print('❌ Token validation exception: $e');
          return false;
        }
      },
      operationName: 'Token Validation',
    );
  }

  // ════════════════════════════════════════════════════════════
  // Load Application Data
  // ════════════════════════════════════════════════════════════

  Future<void> _loadApplicationData(String token) async {
    try {
      state.value = SplashState.loadingData;
      statusMessage.value = 'جاري تحميل البيانات...';
      progress.value = 0.7;

      // Initialize WebSocket
      await _initializeWebSocket(token);

      // Load data in parallel (much faster than sequential)
      await _loadDataInParallel();

      progress.value = 1.0;
      state.value = SplashState.ready;
      statusMessage.value = 'تم التحميل بنجاح!';

      // Navigate to dashboard
      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToDashboard();
    } catch (e) {
      if (kDebugMode) print('❌ Data loading failed: $e');

      // Try to load from cache
      await _loadFromCache();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Initialize WebSocket (Improved with Timeout)
  // ════════════════════════════════════════════════════════════

  Future<void> _initializeWebSocket(String token) async {
    try {
      if (kDebugMode) print('🔌 Initializing WebSocket...');

      await _executeWithTimeout(
        operation: () async {
          await WebSocketManager.instance.enable();
          await WebSocketManager.instance.connect(token);
        },
        timeout: _websocketTimeout,
        operationName: 'WebSocket Connection',
      );

      if (kDebugMode) print('✅ WebSocket connected');
    } catch (e) {
      if (kDebugMode) print('⚠️ WebSocket initialization failed: $e');
      // Continue without WebSocket - not critical
    }
  }

  // ════════════════════════════════════════════════════════════
  // Load Data in Parallel
  // ════════════════════════════════════════════════════════════

  Future<void> _loadDataInParallel() async {
    try {
      if (kDebugMode) print('📦 Loading data in parallel...');

      final client = ApiClientFactory.instance;

      // Load essential data in parallel
      await Future.wait([
        _loadProducts(client),
        _loadPartners(client),
        _loadSales(client),
      ]);

      if (kDebugMode) print('✅ Essential data loaded');

      // Load secondary data (non-blocking)
      Future.wait([
        _loadCategories(client),
        _loadAccountMoves(client),
        _loadStockPicking(client),
      ]).catchError((e) {
        if (kDebugMode) print('⚠️ Secondary data loading failed: $e');
        return <void>[];
      });
    } catch (e) {
      if (kDebugMode) print('❌ Parallel data loading failed: $e');
      rethrow;
    }
  }

  Future<void> _loadProducts(dynamic client) async {
    try {
      statusMessage.value = 'جاري تحميل المنتجات...';

      final products = await _executeWithTimeout<List<dynamic>>(
        operation: () async {
          final completer = Completer<List<dynamic>>();

          await client.searchRead(
            model: 'product.product',
            domain: [
              ['sale_ok', '=', true],
            ],
            fields: [
              'id',
              'name',
              'default_code',
              'list_price',
              'standard_price',
            ],
            limit: 1000,
            onResponse: (response) {
              final productsList = (response as List).toList();
              completer.complete(productsList);
            },
            onError: (error, data) {
              completer.completeError(error);
            },
          );

          return await completer.future;
        },
        timeout: _apiTimeout,
        operationName: 'Load Products',
      );

      // Convert to ProductModel and save to Hive (updates RxList automatically)
      if (products.isNotEmpty) {
        try {
          final productModels = products
              .map((p) => ProductModel.fromJson(p as Map<String, dynamic>))
              .toList();

          // Use HiveProducts.setProducts() - saves to Hive AND updates RxList
          await HiveProducts.setProducts(RxList(productModels));

          if (kDebugMode) {
            print('✅ Saved ${productModels.length} products to Hive');
            print(
              '✅ Updated HiveProducts.products (${HiveProducts.products.length} items)',
            );
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to save products to Hive: $e');
        }
      }

      if (kDebugMode) print('✅ Loaded ${products.length} products');
    } catch (e) {
      if (kDebugMode) print('⚠️ Products loading failed: $e');
      rethrow;
    }
  }

  Future<void> _loadPartners(dynamic client) async {
    try {
      statusMessage.value = 'جاري تحميل العملاء...';

      final partners = await _executeWithTimeout<List<dynamic>>(
        operation: () async {
          final completer = Completer<List<dynamic>>();

          await client.searchRead(
            model: 'res.partner',
            domain: [
              ['customer_rank', '>', 0],
            ],
            fields: ['id', 'name', 'email', 'phone', 'mobile'],
            limit: 1000,
            onResponse: (response) {
              final partnersList = (response as List).toList();
              completer.complete(partnersList);
            },
            onError: (error, data) {
              completer.completeError(error);
            },
          );

          return await completer.future;
        },
        timeout: _apiTimeout,
        operationName: 'Load Partners',
      );

      // Convert to PartnerModel and save to Hive (updates RxList automatically)
      if (partners.isNotEmpty) {
        try {
          final partnerModels = partners
              .map((p) => PartnerModel.fromJson(p as Map<String, dynamic>))
              .toList();

          // Use HivePartners.setPartners() - saves to Hive AND updates RxList
          await HivePartners.setPartners(RxList(partnerModels));

          if (kDebugMode) {
            print('✅ Saved ${partnerModels.length} partners to Hive');
            print(
              '✅ Updated HivePartners.partners (${HivePartners.partners.length} items)',
            );
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to save partners to Hive: $e');
        }
      }

      if (kDebugMode) print('✅ Loaded ${partners.length} partners');
    } catch (e) {
      if (kDebugMode) print('⚠️ Partners loading failed: $e');
      rethrow;
    }
  }

  Future<void> _loadSales(dynamic client) async {
    try {
      statusMessage.value = 'جاري تحميل المبيعات...';

      final sales = await _executeWithTimeout<List<dynamic>>(
        operation: () async {
          final completer = Completer<List<dynamic>>();

          await client.searchRead(
            model: 'sale.order',
            domain: [],
            fields: ['id', 'name', 'partner_id', 'amount_total', 'state'],
            limit: 100,
            onResponse: (response) {
              final salesList = (response as List).toList();
              completer.complete(salesList);
            },
            onError: (error, data) {
              completer.completeError(error);
            },
          );

          return await completer.future;
        },
        timeout: _apiTimeout,
        operationName: 'Load Sales',
      );

      // Convert to OrderModel and save to Hive (updates RxList automatically)
      if (sales.isNotEmpty) {
        try {
          final orderModels = sales
              .map((s) => OrderModel.fromJson(s as Map<String, dynamic>))
              .toList();

          // Use HiveSales.setSales() - saves to Hive AND updates RxList
          await HiveSales.setSales(RxList(orderModels));

          if (kDebugMode) {
            print('✅ Saved ${orderModels.length} sales to Hive');
            print(
              '✅ Updated HiveSales.sales (${HiveSales.sales.length} items)',
            );
          }
        } catch (e) {
          if (kDebugMode) print('⚠️ Failed to save sales to Hive: $e');
        }
      }

      if (kDebugMode) print('✅ Loaded ${sales.length} sales');
    } catch (e) {
      if (kDebugMode) print('⚠️ Sales loading failed: $e');
      rethrow;
    }
  }

  Future<void> _loadCategories(dynamic client) async {
    try {
      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'product.category',
        domain: [],
        fields: ['id', 'name', 'parent_id'],
        onResponse: (response) {
          final categories = (response as List).toList();
          completer.complete(categories);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final categories = await completer.future;

      if (kDebugMode) print('✅ Loaded ${categories.length} categories');
    } catch (e) {
      if (kDebugMode) print('⚠️ Categories loading failed: $e');
    }
  }

  Future<void> _loadAccountMoves(dynamic client) async {
    try {
      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'account.move',
        domain: [
          ['move_type', '=', 'out_invoice'],
        ],
        fields: ['id', 'name', 'partner_id', 'amount_total', 'state'],
        limit: 100,
        onResponse: (response) {
          final moves = (response as List).toList();
          completer.complete(moves);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final moves = await completer.future;

      if (kDebugMode) print('✅ Loaded ${moves.length} account moves');
    } catch (e) {
      if (kDebugMode) print('⚠️ Account moves loading failed: $e');
    }
  }

  Future<void> _loadStockPicking(dynamic client) async {
    try {
      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'stock.picking',
        domain: [],
        fields: ['id', 'name', 'partner_id', 'state'],
        limit: 100,
        onResponse: (response) {
          final pickings = (response as List).toList();
          completer.complete(pickings);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final pickings = await completer.future;

      if (kDebugMode) print('✅ Loaded ${pickings.length} stock pickings');
    } catch (e) {
      if (kDebugMode) print('⚠️ Stock picking loading failed: $e');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Load from Cache (Offline Mode)
  // ════════════════════════════════════════════════════════════

  Future<void> _loadFromCache() async {
    try {
      if (kDebugMode) print('💾 Loading from cache...');

      state.value = SplashState.loadingData;
      statusMessage.value = 'وضع عدم الاتصال - تحميل من الذاكرة...';
      progress.value = 0.8;

      // Load from Hive (automatically updates RxList)
      final productsList = await HiveProducts.getProducts();
      final partnersList = await HivePartners.getPartners();
      final salesList = await HiveSales.getSales();

      if (kDebugMode) {
        print('📦 Hive: ${productsList.length} products');
        print('👥 Hive: ${partnersList.length} partners');
        print('🛒 Hive: ${salesList.length} sales');
      }

      if (productsList.isEmpty && partnersList.isEmpty && salesList.isEmpty) {
        // No cache available
        if (kDebugMode) print('⚠️ No cache available in Hive');
        _handleError('لا توجد بيانات محفوظة. يرجى الاتصال بالإنترنت.');
        return;
      }

      progress.value = 1.0;
      state.value = SplashState.ready;
      statusMessage.value = 'تم التحميل من الذاكرة!';

      await Future.delayed(const Duration(milliseconds: 500));
      _navigateToDashboard();
    } catch (e) {
      if (kDebugMode) print('❌ Cache loading failed: $e');
      _handleError('فشل تحميل البيانات المحفوظة');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Navigation
  // ════════════════════════════════════════════════════════════

  void _navigateToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  void _navigateToDashboard() {
    Get.offAllNamed(AppRoutes.dashboard);
  }

  // ════════════════════════════════════════════════════════════
  // Error Handling
  // ════════════════════════════════════════════════════════════

  void _handleError(String message) {
    state.value = SplashState.error;
    statusMessage.value = message;

    Get.dialog(
      AlertDialog(
        title: const Text('خطأ'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _initialize(); // Retry
            },
            child: const Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _navigateToLogin();
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods: Timeout & Retry
  // ════════════════════════════════════════════════════════════

  /// Execute operation with timeout
  Future<T> _executeWithTimeout<T>({
    required Future<T> Function() operation,
    required Duration timeout,
    required String operationName,
  }) async {
    return await Future.any([
      operation(),
      Future.delayed(timeout).then((_) {
        throw TimeoutException(
          '$operationName timed out after ${timeout.inSeconds} seconds',
          timeout,
        );
      }),
    ]);
  }

  /// Retry operation with exponential backoff
  Future<T> _retryOperation<T>({
    required Future<T> Function() operation,
    required String operationName,
    int maxRetries = _maxRetries,
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        attempt++;

        if (attempt < maxRetries) {
          if (kDebugMode) {
            print(
              '⚠️ $operationName failed (attempt $attempt/$maxRetries): $e',
            );
            print('🔄 Retrying in ${_retryDelay.inSeconds} seconds...');
          }
          await Future.delayed(_retryDelay * attempt); // Exponential backoff
        } else {
          if (kDebugMode) {
            print('❌ $operationName failed after $maxRetries attempts');
          }
        }
      }
    }

    throw lastException ??
        Exception('$operationName failed after $maxRetries attempts');
  }

  // ════════════════════════════════════════════════════════════
  // Cleanup
  // ════════════════════════════════════════════════════════════

  @override
  void onClose() {
    // Cancel timeout timer
    _timeoutTimer?.cancel();
    _timeoutTimer = null;

    // Cancel connectivity subscription
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    if (kDebugMode) print('🧹 SmartSplashController cleaned up');

    super.onClose();
  }
}
