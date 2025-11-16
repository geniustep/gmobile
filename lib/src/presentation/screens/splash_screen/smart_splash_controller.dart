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
import 'package:gsloution_mobile/common/api_factory/models/user/user_model.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

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
  // Validate Token
  // ════════════════════════════════════════════════════════════

  Future<bool> _validateToken(String token) async {
    try {
      final client = ApiClientFactory.instance;
      final completer = Completer<bool>();

      // Try to fetch user info as token validation
      await client.read(
        model: 'res.users',
        ids: [],
        fields: ['id', 'name', 'email'],
        onResponse: (_) {
          if (kDebugMode) print('✅ Token validation successful');
          completer.complete(true);
        },
        onError: (error, data) {
          if (kDebugMode) print('❌ Token validation failed: $error');
          completer.complete(false);
        },
      );

      return await completer.future;
    } catch (e) {
      if (kDebugMode) print('❌ Token validation failed: $e');
      return false;
    }
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
  // Initialize WebSocket
  // ════════════════════════════════════════════════════════════

  Future<void> _initializeWebSocket(String token) async {
    try {
      if (kDebugMode) print('🔌 Initializing WebSocket...');

      await WebSocketManager.instance.enable();
      await WebSocketManager.instance.connect(token);

      if (kDebugMode) print('✅ WebSocket connected');
    } catch (e) {
      if (kDebugMode) print('⚠️ WebSocket initialization failed: $e');
      // Continue without WebSocket
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
      });
    } catch (e) {
      if (kDebugMode) print('❌ Parallel data loading failed: $e');
      rethrow;
    }
  }

  Future<void> _loadProducts(dynamic client) async {
    try {
      statusMessage.value = 'جاري تحميل المنتجات...';

      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'product.product',
        domain: [
          ['sale_ok', '=', true],
        ],
        fields: ['id', 'name', 'default_code', 'list_price', 'standard_price'],
        limit: 1000,
        onResponse: (response) {
          final products = (response as List).toList();
          completer.complete(products);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final products = await completer.future;

      // Save to cache
      // await _storage.setProducts(products);

      if (kDebugMode) print('✅ Loaded ${products.length} products');
    } catch (e) {
      if (kDebugMode) print('⚠️ Products loading failed: $e');
    }
  }

  Future<void> _loadPartners(dynamic client) async {
    try {
      statusMessage.value = 'جاري تحميل العملاء...';

      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'res.partner',
        domain: [
          ['customer_rank', '>', 0],
        ],
        fields: ['id', 'name', 'email', 'phone', 'mobile'],
        limit: 1000,
        onResponse: (response) {
          final partners = (response as List).toList();
          completer.complete(partners);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final partners = await completer.future;

      // Save to cache
      // await _storage.setPartners(partners);

      if (kDebugMode) print('✅ Loaded ${partners.length} partners');
    } catch (e) {
      if (kDebugMode) print('⚠️ Partners loading failed: $e');
    }
  }

  Future<void> _loadSales(dynamic client) async {
    try {
      statusMessage.value = 'جاري تحميل المبيعات...';

      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'sale.order',
        domain: [],
        fields: ['id', 'name', 'partner_id', 'amount_total', 'state'],
        limit: 100,
        onResponse: (response) {
          final sales = (response as List).toList();
          completer.complete(sales);
        },
        onError: (error, data) {
          completer.completeError(error);
        },
      );

      final sales = await completer.future;

      // Save to cache
      // await _storage.setSales(sales);

      if (kDebugMode) print('✅ Loaded ${sales.length} sales');
    } catch (e) {
      if (kDebugMode) print('⚠️ Sales loading failed: $e');
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

      // Load from cache
      final products = await _storage.getProducts();
      final partners = await _storage.getPartners();
      final sales = await _storage.getSales();

      if (kDebugMode) {
        print('📦 Cache: ${products.length} products');
        print('👥 Cache: ${partners.length} partners');
        print('🛒 Cache: ${sales.length} sales');
      }

      if (products.isEmpty && partners.isEmpty && sales.isEmpty) {
        // No cache available
        if (kDebugMode) print('⚠️ No cache available');
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

  @override
  void onClose() {
    // Cleanup if needed
    super.onClose();
  }
}
