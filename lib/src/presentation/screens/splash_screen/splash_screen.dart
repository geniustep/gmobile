// ════════════════════════════════════════════════════════════
// splash_screen.dart - النسخة المحدثة مع Smart Fallback
// ════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_list/pricelist_module.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';
import 'package:gsloution_mobile/common/api_factory/modules/settings_odoo_module.dart';

import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _logoController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;

  final RxBool isReady = false.obs;
  String currentStatus = 'جاري التهيئة...';
  int progress = 0;

  // مؤشر التقدم العام
  late ValueNotifier<int> _progressNotifier;
  late ValueNotifier<String> _statusNotifier;

  // مؤشر التقدم الخاص بكل موديل
  late ValueNotifier<int> _modelProgressNotifier;
  late ValueNotifier<String> _modelStatusNotifier;
  String currentModel = '';
  int modelProgress = 0;

  final Controller _apiController = Get.put(Controller());

  // إعدادات إعادة المحاولة
  int _retryCount = 0;
  static const int _maxRetries = 3;
  static const List<int> _retryDelays = [1000, 2000, 4000];

  // البيانات
  var products = <ProductModel>[].obs;
  var categoryProduct = <ProductCategoryModel>[].obs;
  var sales = <OrderModel>[].obs;
  var orderLine = <OrderLineModel>[].obs;
  var partners = <PartnerModel>[].obs;
  var accountMove = <AccountMoveModel>[].obs;
  var accountMoveLine = <AccountMoveLineModel>[].obs;
  var listesPrix = <PricelistModel>[].obs;
  var stockPicking = <StockPickingModel>[].obs;
  List<dynamic> conditionsPaiement = [];

  // أوزان التقدم
  static final Map<String, int> _progressWeights = {
    'initial': 2,
    'settings': 3,
    'journals': 2,
    'payment_terms': 4,
    'price_lists': 8,
    'products': 12,
    'categories': 10,
    'sales': 6,
    'order_lines': 6,
    'partners': 8,
    'account_moves': 6,
    'stock_picking': 6,
  };

  // رسائل الحالة
  static final Map<String, String> _statusMessages = {
    'initial': 'جاري التهيئة...',
    'settings': 'جاري تحميل الإعدادات...',
    'journals': 'جاري تحميل الدفاتر...',
    'payment_terms': 'جاري تحميل شروط الدفع...',
    'price_lists': 'جاري تحميل قوائم الأسعار...',
    'products': 'جاري تحميل المنتجات...',
    'categories': 'جاري تحميل الفئات...',
    'sales': 'جاري تحميل المبيعات...',
    'order_lines': 'جاري تحميل بنود الطلبات...',
    'partners': 'جاري تحميل العملاء...',
    'account_moves': 'جاري تحميل الحركات المحاسبية...',
    'stock_picking': 'جاري تحميل إدارة المخزون...',
    'finalizing': 'جاري إنهاء التحميل...',
  };

  @override
  void initState() {
    super.initState();

    // إعداد معالج الأخطاء العام
    _setupGlobalErrorHandler();

    _progressNotifier = ValueNotifier<int>(0);
    _statusNotifier = ValueNotifier<String>('جاري التهيئة...');

    // تهيئة مؤشر التقدم الخاص بكل موديل
    _modelProgressNotifier = ValueNotifier<int>(0);
    _modelStatusNotifier = ValueNotifier<String>('');

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.1, end: 0.1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _logoController.repeat(reverse: true);

    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      print('🚀 Starting data initialization...');
      await _loadInitialSettings();
    } catch (e, stackTrace) {
      print('❌ Error in _initializeData: $e');
      print('📍 Stack trace: $stackTrace');
      print('🔍 Error type: ${e.runtimeType}');

      // ✅ محاولة تحميل البيانات الأساسية فقط
      try {
        print('🔄 Attempting to load essential data only...');
        _updateProgress('products', 20);
        await _loadProducts();
        _updateProgress('categories', 40);
        await _loadCategories();
        _updateProgress('partners', 60);
        await _loadPartners();
        _updateProgress('sales', 80);
        await _loadSales();
        _updateProgress('complete', 100);
        print('✅ Essential data loaded successfully');

        // ✅ الانتقال للوحة التحكم
        Future.delayed(const Duration(seconds: 1), () {
          Get.offNamed(AppRoutes.dashboard);
        });
      } catch (fallbackError) {
        print('❌ Fallback data loading also failed: $fallbackError');

        // تحليل نوع الخطأ
        String errorDetails = _analyzeError(e);
        print('📊 Error analysis: $errorDetails');

        await _handleRetry('$e\nDetails: $errorDetails');
      }
    }
  }

  Future<void> _handleRetry(String error) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = _retryDelays[_retryCount - 1];

      print('🔄 Retry attempt $_retryCount/$_maxRetries');
      print('⏱️  Waiting ${delay ~/ 1000} seconds before retry...');
      print('🔍 Previous error: $error');

      currentStatus =
          'إعادة المحاولة ($_retryCount/$_maxRetries) خلال ${delay ~/ 1000} ثانية...';
      _statusNotifier.value = currentStatus;

      await Future.delayed(Duration(milliseconds: delay));

      try {
        print('🔄 Starting retry attempt $_retryCount...');
        await _loadInitialSettings();
        print('✅ Retry successful!');
        _retryCount = 0;
      } catch (e, stackTrace) {
        print('❌ Retry $_retryCount failed: $e');
        print('📍 Stack trace: $stackTrace');
        await _handleRetry('$e\nDetails: ${_analyzeError(e)}');
      }
    } else {
      print('❌ Max retries reached ($_maxRetries). Showing error dialog.');
      _showErrorDialog(error);
    }
  }

  Future<void> _loadInitialSettings() async {
    try {
      print('🔧 Loading initial settings...');
      print('🔍 Starting _loadInitialSettings function');
      _updateProgress('initial', 5);

      final completer = Completer<dynamic>();
      bool isCompleted = false;
      print('🔍 Completer created for group ID');

      print('🔍 Calling SettingsOdooModule.getGroupIdByXmlId...');
      SettingsOdooModule.getGroupIdByXmlId(
        showGlobalLoading: false,
        onResponse: (resId) {
          print('📋 Group ID response received: $resId');
          print('🔍 Response type: ${resId.runtimeType}');
          if (!isCompleted) {
            isCompleted = true;
            if (resId != null) {
              print('✅ Group ID loaded successfully: $resId');
              print('🔍 Completing completer with group ID');
              completer.complete(resId);
            } else {
              print(
                '⚠️ Group ID is null - user may not have admin permissions, continuing without group assignment',
              );
              print('🔍 Completing completer with null');
              completer.complete(null);
            }
          } else {
            print('⚠️ Duplicate onResponse call ignored');
          }
        },
      );
      print('🔍 getGroupIdByXmlId call completed, waiting for response...');

      print('🔍 Waiting for group ID completer.future...');
      final resId = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Timeout waiting for group ID response');
          throw Exception('Timeout loading group ID');
        },
      );
      print('🔍 Received group ID data: $resId');
      print('✅ Group ID processing completed: $resId');

      print('🔍 Calling _loadSettings...');

      try {
        await _loadSettings();
        print('🔍 _loadSettings completed successfully');
      } catch (e, stackTrace) {
        print('❌ Error in _loadSettings from _loadInitialSettings: $e');
        print('📍 Stack trace: $stackTrace');
        print('🔍 Continuing with other data loading...');
        // ✅ المتابعة مع تحميل البيانات الأخرى
        _updateProgress('settings'); // تحديث التقدم
        await _loadProducts();
      }

      print('🔍 _loadInitialSettings completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error in _loadInitialSettings: $e');
      print('📍 Stack trace: $stackTrace');
      print('🔍 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> _loadSettings() async {
    try {
      print('⚙️ Loading settings...');
      print('🔍 Starting _loadSettings function');
      final completer = Completer<bool>();
      print('🔍 Completer created for settings');

      print('🔍 Calling _apiController.getSettingsOdooController...');
      _apiController.getSettingsOdooController(
        showGlobalLoading: false,
        onResponse: (resSettings) {
          print('📋 Settings response received: $resSettings');
          print('🔍 Response type: ${resSettings.runtimeType}');
          if (resSettings != null && resSettings) {
            print('🔍 Settings response is valid, completing completer');
            completer.complete(true);
          } else {
            print('❌ Settings response is null or false');
            completer.completeError(Exception('Failed to load settings'));
          }
        },
      );
      print(
        '🔍 getSettingsOdooController call completed, waiting for response...',
      );

      print('🔍 Waiting for settings completer.future...');
      final resSettings = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Timeout waiting for settings response');
          throw Exception('Timeout loading settings');
        },
      );
      print('🔍 Received settings data: $resSettings');

      if (!resSettings) {
        print('❌ Settings loading failed');
        throw Exception('Failed to load settings');
      }

      print('✅ Settings loaded successfully');
      print('🔍 Updating progress to settings step');
      _updateProgress('settings');
      print('🔍 Calling _loadJournals...');

      try {
        await _loadJournals();
        print('🔍 _loadJournals completed successfully');
      } catch (e, stackTrace) {
        print('❌ Error in _loadJournals from _loadSettings: $e');
        print('📍 Stack trace: $stackTrace');
        print('🔍 Continuing with other data loading...');
        // ✅ المتابعة مع تحميل البيانات الأخرى بدلاً من التوقف
        _updateProgress('journals'); // تحديث التقدم حتى لو فشل
        await _loadPaymentTerms();
      }

      print('🔍 _loadSettings completed successfully');
    } catch (e, stackTrace) {
      print('❌ Error in _loadSettings: $e');
      print('📍 Stack trace: $stackTrace');
      print('🔍 Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<void> _loadJournals() async {
    try {
      print('📚 Loading journals...');
      _updateModelProgress('الدفاتر', 0, 'جاري تحميل الدفاتر...');

      final completer = Completer<List<AccountJournalModel>?>();

      _apiController.getAccountJournal(
        showGlobalLoading: false,
        onResponse: (resJournals) {
          print('📋 Journals received: ${resJournals?.length ?? 0}');
          completer.complete(resJournals);
        },
      );

      final resJournals = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Timeout loading journals');
          return null;
        },
      );

      if (resJournals == null || resJournals.isEmpty) {
        print('⚠️  No journals loaded');
        _updateModelProgress('الدفاتر', 100, 'تم تخطي الدفاتر');
      } else {
        print('✅ Journals loaded: ${resJournals.length}');
        _updateModelProgress('الدفاتر', 100, 'تم تحميل الدفاتر بنجاح');
      }
    } catch (e, stackTrace) {
      print('❌ Error in _loadJournals: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('الدفاتر', 100, 'تم تخطي الدفاتر');
    }

    _updateProgress('journals');
    await _loadPaymentTerms();
  }

  Future<void> _loadPaymentTerms() async {
    try {
      print('💳 Loading payment terms...');
      _updateModelProgress('شروط الدفع', 0, 'جاري تحميل شروط الدفع...');

      final completer = Completer<List<dynamic>?>();

      _apiController.getConditionsPaiementController(
        onResponse: (resCdt) {
          print('📋 Payment terms response: ${resCdt?.length ?? 0} terms');
          _updateModelProgress('شروط الدفع', 50, 'جاري معالجة شروط الدفع...');
          completer.complete(resCdt);
        },
      );

      final resCdt = await completer.future;
      if (resCdt == null) {
        print('❌ Payment terms response is null');
        throw Exception('Failed to load payment terms');
      }

      _updateModelProgress('شروط الدفع', 80, 'جاري حفظ شروط الدفع...');
      conditionsPaiement = resCdt;
      await PrefUtils.setPaymentTerms(conditionsPaiement);

      _updateModelProgress('شروط الدفع', 100, 'تم تحميل شروط الدفع بنجاح');
      print('✅ Payment terms loaded successfully: ${resCdt.length} terms');
      _updateProgress('payment_terms');
      await _loadPriceLists();
    } catch (e, stackTrace) {
      print('❌ Error in _loadPaymentTerms: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('شروط الدفع', 0, 'فشل في تحميل شروط الدفع');
      rethrow;
    }
  }

  Future<void> _loadPriceLists() async {
    try {
      print('💰 Loading price lists...');
      _updateModelProgress('قوائم الأسعار', 0, 'جاري تحميل قوائم الأسعار...');

      final completer = Completer<List<PricelistModel>?>();

      PricelistModule.searchReadPricelists(
        onResponse: (resPriceLists) {
          print('📋 Price lists response: ${resPriceLists?.length ?? 0} lists');
          _updateModelProgress(
            'قوائم الأسعار',
            50,
            'جاري معالجة قوائم الأسعار...',
          );
          completer.complete(resPriceLists);
        },
      );

      final resPriceLists = await completer.future;
      if (resPriceLists == null) {
        print('❌ Price lists response is null');
        throw Exception('Failed to load price lists');
      }

      _updateModelProgress('قوائم الأسعار', 80, 'جاري حفظ قوائم الأسعار...');
      listesPrix.addAll(resPriceLists);
      await PrefUtils.setPriceLists(listesPrix);

      _updateModelProgress(
        'قوائم الأسعار',
        100,
        'تم تحميل قوائم الأسعار بنجاح',
      );
      print('✅ Price lists loaded successfully: ${resPriceLists.length} lists');
      _updateProgress('price_lists');
      await _loadProducts();
    } catch (e, stackTrace) {
      print('❌ Error in _loadPriceLists: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('قوائم الأسعار', 0, 'فشل في تحميل قوائم الأسعار');
      rethrow;
    }
  }

  // ✅ تحميل المنتجات مع Smart Fallback
  Future<void> _loadProducts() async {
    try {
      print('📦 Loading products with Smart Fallback...');
      _updateModelProgress('المنتجات', 0, 'جاري تحميل المنتجات...');

      final completer = Completer<List<ProductModel>?>();

      // استخدام ProductModule الجديد مع Smart Fallback
      await ProductModule.searchReadProducts(
        showGlobalLoading: false,
        onResponse: (resProducts) {
          print('📋 Products response: ${resProducts?.length ?? 0} products');
          _updateModelProgress('المنتجات', 50, 'جاري معالجة المنتجات...');
          completer.complete(resProducts);
        },
      );

      final resProducts = await completer.future;
      if (resProducts == null) {
        print('❌ Products response is null');
        throw Exception('Failed to load products');
      }

      _updateModelProgress('المنتجات', 80, 'جاري حفظ المنتجات...');
      print('✅ Products loaded successfully: ${resProducts.length} products');
      products.addAll(resProducts);
      await PrefUtils.setProducts(products);

      _updateModelProgress('المنتجات', 100, 'تم تحميل المنتجات بنجاح');
      _updateProgress('products');
      await _loadCategories();
    } catch (e, stackTrace) {
      print('❌ Error in _loadProducts: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('المنتجات', 0, 'فشل في تحميل المنتجات');
      rethrow;
    }
  }

  Future<void> _loadCategories() async {
    try {
      _updateModelProgress('الفئات', 0, 'جاري تحميل الفئات...');

      final completer = Completer<List<ProductCategoryModel>?>();

      _apiController.getCategoryProductsController(
        showGlobalLoading: false,
        onResponse: (resCategories) {
          _updateModelProgress('الفئات', 50, 'جاري معالجة الفئات...');
          completer.complete(resCategories);
        },
      );

      final resCategories = await completer.future;
      if (resCategories == null) throw Exception('Failed to load categories');

      _updateModelProgress('الفئات', 80, 'جاري حفظ الفئات...');
      categoryProduct.addAll(resCategories);
      await PrefUtils.setCatgProducts(categoryProduct);

      _updateModelProgress('الفئات', 100, 'تم تحميل الفئات بنجاح');
      _updateProgress('categories');
      await _loadSales();
    } catch (e, stackTrace) {
      print('❌ Error in _loadCategories: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('الفئات', 0, 'فشل في تحميل الفئات');
      rethrow;
    }
  }

  Future<void> _loadSales() async {
    try {
      print('🛒 Loading sales...');
      _updateModelProgress('المبيعات', 0, 'جاري تحميل المبيعات...');

      final completer = Completer<List<OrderModel>?>();

      _apiController.getSalesController(
        onResponse: (resSales) {
          print('📋 Sales response: ${resSales?.length ?? 0} sales');
          _updateModelProgress('المبيعات', 50, 'جاري معالجة المبيعات...');
          completer.complete(resSales);
        },
      );

      final resSales = await completer.future;
      if (resSales == null) {
        print('❌ Sales response is null');
        throw Exception('Failed to load sales');
      }

      _updateModelProgress('المبيعات', 80, 'جاري حفظ المبيعات...');
      sales.addAll(resSales);
      await PrefUtils.setSales(sales);

      _updateModelProgress('المبيعات', 100, 'تم تحميل المبيعات بنجاح');
      print('✅ Sales loaded successfully: ${resSales.length} sales');
      _updateProgress('sales');
      await _loadOrderLines();
    } catch (e, stackTrace) {
      print('❌ Error in _loadSales: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('المبيعات', 0, 'فشل في تحميل المبيعات');
      rethrow;
    }
  }

  Future<void> _loadOrderLines() async {
    // Order lines loading is currently disabled
    // This method is kept for future implementation

    // _apiController.getSalesOrdersLineController(
    //   onResponse: (resOrderLines) {
    //     completer.complete(resOrderLines);
    //   },
    // );

    // final resOrderLines = await completer.future;
    // if (resOrderLines == null) throw Exception('Failed to load order lines');

    // orderLine.addAll(resOrderLines);
    // await PrefUtils.setSalesLine(orderLine);

    // _updateProgress('order_lines');
    await _loadPartners();
  }

  // ✅ تحميل العملاء مع Smart Fallback
  Future<void> _loadPartners() async {
    try {
      print('👥 Loading partners with Smart Fallback...');
      _updateModelProgress('العملاء', 0, 'جاري تحميل العملاء...');

      final completer = Completer<List<PartnerModel>?>();

      // استخدام PartnerModule الجديد مع Smart Fallback
      await PartnerModule.searchReadPartners(
        showGlobalLoading: false,
        onResponse: (resPartners) {
          print('📋 Partners response: ${resPartners?.length ?? 0} partners');
          _updateModelProgress('العملاء', 50, 'جاري معالجة العملاء...');
          completer.complete(resPartners);
        },
      );

      final resPartners = await completer.future;
      if (resPartners == null) {
        print('❌ Partners response is null');
        throw Exception('Failed to load partners');
      }

      _updateModelProgress('العملاء', 80, 'جاري حفظ العملاء...');
      print('✅ Partners loaded successfully: ${resPartners.length} partners');
      partners.addAll(resPartners);
      await PrefUtils.setPartners(partners);

      _updateModelProgress('العملاء', 100, 'تم تحميل العملاء بنجاح');
      _updateProgress('partners');
      await _loadAccountMoves();
    } catch (e, stackTrace) {
      print('❌ Error in _loadPartners: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('العملاء', 0, 'فشل في تحميل العملاء');
      rethrow;
    }
  }

  Future<void> _loadAccountMoves() async {
    try {
      print('📊 Loading account moves...');
      _updateModelProgress(
        'الحركات المحاسبية',
        0,
        'جاري تحميل الحركات المحاسبية...',
      );

      final completer = Completer<List<AccountMoveModel>?>();

      _apiController.getAccountMove(
        showGlobalLoading: false,
        onResponse: (resAccountMove) {
          print(
            '📋 Account moves response: ${resAccountMove?.length ?? 0} moves',
          );
          _updateModelProgress(
            'الحركات المحاسبية',
            50,
            'جاري معالجة الحركات المحاسبية...',
          );
          completer.complete(resAccountMove);
        },
      );

      final resAccountMove = await completer.future;
      if (resAccountMove == null) {
        print('❌ Account moves response is null');
        throw Exception('Failed to load account moves');
      }

      _updateModelProgress(
        'الحركات المحاسبية',
        80,
        'جاري حفظ الحركات المحاسبية...',
      );
      accountMove.addAll(resAccountMove);
      await PrefUtils.setAccountMove(accountMove);

      _updateModelProgress(
        'الحركات المحاسبية',
        100,
        'تم تحميل الحركات المحاسبية بنجاح',
      );
      print(
        '✅ Account moves loaded successfully: ${resAccountMove.length} moves',
      );
      _updateProgress('account_moves');
      await _loadStockPicking();
    } catch (e, stackTrace) {
      print('❌ Error in _loadAccountMoves: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress(
        'الحركات المحاسبية',
        0,
        'فشل في تحميل الحركات المحاسبية',
      );
      rethrow;
    }
  }

  Future<void> _loadStockPicking() async {
    try {
      print('📦 Loading stock picking...');
      _updateModelProgress('إدارة المخزون', 0, 'جاري تحميل إدارة المخزون...');

      final completer = Completer<List<StockPickingModel>?>();
      _apiController.getStockPickingController(
        showGlobalLoading: false,
        onResponse: (resStockPicking) {
          print(
            '📋 Stock picking response: ${resStockPicking?.length ?? 0} pickings',
          );
          _updateModelProgress(
            'إدارة المخزون',
            50,
            'جاري معالجة إدارة المخزون...',
          );
          completer.complete(resStockPicking);
        },
      );

      final resStockPicking = await completer.future;
      if (resStockPicking == null) {
        print('❌ Stock picking response is null');
        throw Exception('Failed to load stock picking');
      }

      _updateModelProgress('إدارة المخزون', 80, 'جاري حفظ إدارة المخزون...');
      stockPicking.addAll(resStockPicking);
      await PrefUtils.setStockPicking(stockPicking);

      _updateModelProgress(
        'إدارة المخزون',
        100,
        'تم تحميل إدارة المخزون بنجاح',
      );
      print(
        '✅ Stock picking loaded successfully: ${resStockPicking.length} pickings',
      );
      _updateProgress('stock_picking');
      await _finishLoading();
    } catch (e, stackTrace) {
      print('❌ Error in _loadStockPicking: $e');
      print('📍 Stack trace: $stackTrace');
      _updateModelProgress('إدارة المخزون', 0, 'فشل في تحميل إدارة المخزون');
      rethrow;
    }
  }

  Future<void> _finishLoading() async {
    try {
      print('🏁 Finalizing loading process...');
      _updateProgress('finalizing', 100);

      // ✅ طباعة إحصائيات Smart Fallback
      print('\n═══════════════════════════════════════════');
      print('📊 Smart Fallback Statistics:');
      print('═══════════════════════════════════════════');

      final stats = Api.getGlobalInvalidFieldsCache();
      if (stats.isEmpty) {
        print('✅ No invalid fields detected - All good!');
      } else {
        print('⚠️  Invalid fields found:');
        stats.forEach((model, fields) {
          print('   $model: ${fields.join(", ")}');
        });
      }

      // ✅ طباعة إحصائيات التحميل
      print('\n📈 Loading Statistics:');
      print('   Products: ${products.length}');
      print('   Categories: ${categoryProduct.length}');
      print('   Sales: ${sales.length}');
      print('   Order Lines: ${orderLine.length}');
      print('   Partners: ${partners.length}');
      print('   Account Moves: ${accountMove.length}');
      print('   Account Move Lines: ${accountMoveLine.length}');
      print('   Price Lists: ${listesPrix.length}');
      print('   Stock Picking: ${stockPicking.length}');
      print('   Payment Terms: ${conditionsPaiement.length}');
      print('═══════════════════════════════════════════\n');

      await Future.delayed(const Duration(milliseconds: 500));
      print('🎉 Loading completed successfully!');
      isReady.value = true;
    } catch (e, stackTrace) {
      print('❌ Error in _finishLoading: $e');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// تحديث مؤشر التقدم الخاص بكل موديل
  void _updateModelProgress(String modelName, int progress, String status) {
    try {
      currentModel = modelName;
      modelProgress = progress.clamp(0, 100);

      _modelProgressNotifier.value = modelProgress;
      _modelStatusNotifier.value = status;

      print('📊 Model Progress: $modelName - $modelProgress% - $status');
    } catch (e) {
      print('❌ Error updating model progress: $e');
    }
  }

  void _updateProgress(String step, [dynamic customProgress]) {
    try {
      print('🔄 Updating progress for step: $step');

      // التحقق من وجود الخطوة في الأوزان
      if (!_progressWeights.containsKey(step) && step != 'finalizing') {
        print('⚠️  Warning: Step "$step" not found in progress weights');
        print('📋 Available steps: ${_progressWeights.keys.join(", ")}');
        print('🔧 Adding step "$step" with default weight 1');
        _progressWeights[step] = 1;
      }

      int totalWeight = _progressWeights.values.isNotEmpty
          ? _progressWeights.values.reduce((a, b) => a + b)
          : 100; // قيمة افتراضية
      int completedWeight = 0;

      final progressKeys = _progressWeights.keys.toList();
      final stepIndex = progressKeys.indexOf(step);

      if (stepIndex == -1 && step != 'finalizing') {
        print('⚠️  Warning: Step "$step" not found in progress keys');
        print('📋 Available keys: ${progressKeys.join(", ")}');
      }

      _progressWeights.forEach((key, weight) {
        final keyIndex = progressKeys.indexOf(key);
        if (keyIndex != -1 && keyIndex <= stepIndex) {
          completedWeight += weight;
        }
      });

      if (step != 'finalizing') {
        final stepWeight = _progressWeights[step];
        if (stepWeight != null) {
          completedWeight += stepWeight;
        } else {
          print('⚠️  Warning: No weight found for step: $step');
        }
      }

      if (customProgress != null) {
        progress = customProgress;
      } else {
        if (totalWeight > 0) {
          progress = ((completedWeight / totalWeight) * 100).round();
        } else {
          progress = 0;
        }
      }

      // التأكد من أن التقدم بين 0 و 100
      progress = progress.clamp(0, 100);

      // ✅ تحديث UI
      try {
        _progressNotifier.value = progress;
      } catch (e) {
        print('⚠️  Warning: Failed to update progress notifier: $e');
      }

      currentStatus = _statusMessages[step] ?? 'جاري المعالجة...';

      // إضافة رسالة افتراضية إذا لم تكن موجودة
      if (!_statusMessages.containsKey(step)) {
        print('⚠️  Warning: Step "$step" not found in status messages');
        print('📋 Available messages: ${_statusMessages.keys.join(", ")}');
        print('🔧 Adding step "$step" with default message');
        _statusMessages[step] = 'جاري المعالجة...';
      }
      try {
        _statusNotifier.value = currentStatus;
      } catch (e) {
        print('⚠️  Warning: Failed to update status notifier: $e');
      }

      print('📊 Progress: $progress% - $currentStatus');
      print(
        '🔍 Step details: $step, Weight: ${_progressWeights[step]}, Total: $totalWeight, Completed: $completedWeight',
      );
    } catch (e, stackTrace) {
      print('❌ Error in _updateProgress: $e');
      print('📍 Stack trace: $stackTrace');
      print('🔍 Step: $step, CustomProgress: $customProgress');
      print('📋 Available steps: ${_progressWeights.keys.join(", ")}');

      // Fallback values
      progress = customProgress ?? 0;
      progress = progress.clamp(0, 100);

      try {
        _progressNotifier.value = progress;
      } catch (e) {
        print(
          '⚠️  Warning: Failed to update progress notifier in fallback: $e',
        );
      }

      currentStatus = 'جاري المعالجة...';
      try {
        _statusNotifier.value = currentStatus;
      } catch (e) {
        print('⚠️  Warning: Failed to update status notifier in fallback: $e');
      }

      print('📊 Fallback Progress: $progress% - $currentStatus');
      print(
        '🔍 Fallback details: Step: $step, CustomProgress: $customProgress',
      );
      print('📋 Available steps: ${_progressWeights.keys.join(", ")}');
      print('📋 Available messages: ${_statusMessages.keys.join(", ")}');
      print('🔧 Progress weights: $_progressWeights');
      print('🔧 Status messages: $_statusMessages');
      print('🔧 Step index: ${_progressWeights.keys.toList().indexOf(step)}');
      print('🔧 Step weight: ${_progressWeights[step]}');
      print('🔧 Step message: ${_statusMessages[step]}');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Global Error Handler
  // ════════════════════════════════════════════════════════════

  /// إعداد معالج الأخطاء العام
  void _setupGlobalErrorHandler() {
    // معالجة أخطاء Flutter العامة
    FlutterError.onError = (FlutterErrorDetails details) {
      print('🚨 Flutter Error: ${details.exception}');
      print('📍 Stack: ${details.stack}');
      _handleUnexpectedError(details.exception, details.stack);
    };

    // معالجة أخطاء Dart العامة
    PlatformDispatcher.instance.onError = (error, stack) {
      print('🚨 Platform Error: $error');
      print('📍 Stack: $stack');
      _handleUnexpectedError(error, stack);
      return true;
    };
  }

  /// معالجة الأخطاء غير المتوقعة
  void _handleUnexpectedError(dynamic error, StackTrace? stackTrace) {
    try {
      print('🚨 Unexpected Error Caught: $error');
      print('📍 Stack Trace: $stackTrace');

      // ✅ محاولة استعادة التطبيق
      try {
        print('🔄 Attempting to recover from unexpected error...');
        _updateProgress('recovery', 50);

        // ✅ محاولة تحميل البيانات الأساسية
        _loadProducts()
            .then((_) {
              _updateProgress('recovery', 75);
              return _loadPartners();
            })
            .then((_) {
              _updateProgress('recovery', 100);
              print('✅ Recovery successful, navigating to dashboard');
              Get.offNamed(AppRoutes.dashboard);
            })
            .catchError((recoveryError) {
              print('❌ Recovery failed: $recoveryError');
              _showUnexpectedErrorDialog(
                errorType: 'recovery_failed',
                message: 'فشل في استعادة التطبيق',
                technicalError: error.toString(),
                stackTrace: stackTrace?.toString(),
              );
            });
      } catch (recoveryError) {
        print('❌ Recovery attempt failed: $recoveryError');

        // تحليل نوع الخطأ
        String errorType = _analyzeUnexpectedError(error);
        String userMessage = _getUserFriendlyErrorMessage(errorType);

        // عرض نافذة خطأ للمستخدم
        _showUnexpectedErrorDialog(
          errorType: errorType,
          message: userMessage,
          technicalError: error.toString(),
          stackTrace: stackTrace?.toString(),
        );
      }
    } catch (e) {
      print('❌ Error in error handler: $e');
      // في حالة فشل معالج الأخطاء، عرض رسالة بسيطة
      _showSimpleErrorDialog();
    }
  }

  /// تحليل نوع الخطأ غير المتوقع
  String _analyzeUnexpectedError(dynamic error) {
    String errorStr = error.toString().toLowerCase();

    if (errorStr.contains('null check operator used on a null value')) {
      return 'null_safety';
    } else if (errorStr.contains('no such method') ||
        errorStr.contains('method not found')) {
      return 'method_not_found';
    } else if (errorStr.contains('type') &&
        errorStr.contains('is not a subtype')) {
      return 'type_error';
    } else if (errorStr.contains('connection') ||
        errorStr.contains('network')) {
      return 'network_error';
    } else if (errorStr.contains('timeout')) {
      return 'timeout_error';
    } else if (errorStr.contains('permission')) {
      return 'permission_error';
    } else if (errorStr.contains('memory') ||
        errorStr.contains('out of memory')) {
      return 'memory_error';
    } else {
      return 'unknown_error';
    }
  }

  /// الحصول على رسالة خطأ مفهومة للمستخدم
  String _getUserFriendlyErrorMessage(String errorType) {
    switch (errorType) {
      case 'null_safety':
        return '❌ خطأ في البيانات\n\n'
            'يبدو أن هناك مشكلة في البيانات المحملة.\n'
            'يرجى إعادة تشغيل التطبيق.';
      case 'method_not_found':
        return '⚠️ خطأ في التطبيق\n\n'
            'حدث خطأ غير متوقع في التطبيق.\n'
            'يرجى إعادة تشغيل التطبيق.';
      case 'type_error':
        return '🔄 خطأ في نوع البيانات\n\n'
            'هناك مشكلة في تنسيق البيانات.\n'
            'يرجى إعادة المحاولة.';
      case 'network_error':
        return '🌐 مشكلة في الاتصال\n\n'
            'تحقق من اتصال الإنترنت\n'
            'وأعد المحاولة.';
      case 'timeout_error':
        return '⏰ انتهت مهلة الاتصال\n\n'
            'الخادم لا يستجيب.\n'
            'يرجى المحاولة مرة أخرى.';
      case 'permission_error':
        return '🔒 مشكلة في الصلاحيات\n\n'
            'التطبيق يحتاج صلاحيات إضافية.\n'
            'يرجى التحقق من الإعدادات.';
      case 'memory_error':
        return '💾 مشكلة في الذاكرة\n\n'
            'التطبيق يحتاج ذاكرة إضافية.\n'
            'يرجى إغلاق التطبيقات الأخرى.';
      default:
        return '❓ خطأ غير متوقع\n\n'
            'حدث خطأ غير متوقع.\n'
            'يرجى إعادة تشغيل التطبيق.';
    }
  }

  /// عرض نافذة خطأ غير متوقع
  void _showUnexpectedErrorDialog({
    required String errorType,
    required String message,
    required String technicalError,
    String? stackTrace,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getUnexpectedErrorIcon(errorType),
              color: _getUnexpectedErrorColor(errorType),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _getUnexpectedErrorTitle(errorType),
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
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _reloadSplash();
                    },
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('إعادة المحاولة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      _continueWithBasicData();
                    },
                    icon: const Icon(Icons.skip_next, size: 18),
                    label: const Text('متابعة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                      Get.offAllNamed(AppRoutes.login);
                    },
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('تسجيل الخروج'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            if (!kReleaseMode && stackTrace != null) ...[
              const SizedBox(height: 16),
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
                child: SingleChildScrollView(
                  child: Text(
                    '$technicalError\n\n$stackTrace',
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'monospace',
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إغلاق')),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// عرض رسالة خطأ بسيطة في حالة فشل معالج الأخطاء
  void _showSimpleErrorDialog() {
    Get.dialog(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text('خطأ في التطبيق'),
          ],
        ),
        content: const Text(
          'حدث خطأ غير متوقع في التطبيق.\nيرجى إعادة تشغيل التطبيق.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back();
              _reloadSplash();
            },
            child: const Text('إعادة المحاولة'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// الحصول على أيقونة الخطأ غير المتوقع
  IconData _getUnexpectedErrorIcon(String errorType) {
    switch (errorType) {
      case 'null_safety':
        return Icons.data_usage;
      case 'method_not_found':
        return Icons.bug_report;
      case 'type_error':
        return Icons.type_specimen;
      case 'network_error':
        return Icons.wifi_off;
      case 'timeout_error':
        return Icons.access_time;
      case 'permission_error':
        return Icons.lock;
      case 'memory_error':
        return Icons.memory;
      default:
        return Icons.error_outline;
    }
  }

  /// الحصول على لون الخطأ غير المتوقع
  Color _getUnexpectedErrorColor(String errorType) {
    switch (errorType) {
      case 'null_safety':
        return Colors.orange;
      case 'method_not_found':
        return Colors.purple;
      case 'type_error':
        return Colors.blue;
      case 'network_error':
        return Colors.red;
      case 'timeout_error':
        return Colors.amber;
      case 'permission_error':
        return Colors.deepOrange;
      case 'memory_error':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  /// الحصول على عنوان الخطأ غير المتوقع
  String _getUnexpectedErrorTitle(String errorType) {
    switch (errorType) {
      case 'null_safety':
        return 'خطأ في البيانات';
      case 'method_not_found':
        return 'خطأ في التطبيق';
      case 'type_error':
        return 'خطأ في نوع البيانات';
      case 'network_error':
        return 'مشكلة في الاتصال';
      case 'timeout_error':
        return 'انتهت مهلة الاتصال';
      case 'permission_error':
        return 'مشكلة في الصلاحيات';
      case 'memory_error':
        return 'مشكلة في الذاكرة';
      default:
        return 'خطأ غير متوقع';
    }
  }

  // ════════════════════════════════════════════════════════════
  // Error Analysis
  // ════════════════════════════════════════════════════════════

  String _analyzeError(dynamic error) {
    String errorStr = error.toString();

    if (errorStr.contains('Null check operator used on a null value')) {
      return 'Null Safety Error: محاولة الوصول لقيمة null باستخدام ! operator';
    } else if (errorStr.contains('Failed to get group ID')) {
      return 'Authentication Error: فشل في الحصول على معرف المجموعة';
    } else if (errorStr.contains('Failed to load settings')) {
      return 'Settings Error: فشل في تحميل الإعدادات';
    } else if (errorStr.contains('Failed to load journals')) {
      return 'Journals Error: فشل في تحميل الدفاتر';
    } else if (errorStr.contains('Failed to load payment terms')) {
      return 'Payment Terms Error: فشل في تحميل شروط الدفع';
    } else if (errorStr.contains('Failed to load price lists')) {
      return 'Price Lists Error: فشل في تحميل قوائم الأسعار';
    } else if (errorStr.contains('Failed to load products')) {
      return 'Products Error: فشل في تحميل المنتجات';
    } else if (errorStr.contains('Failed to load categories')) {
      return 'Categories Error: فشل في تحميل الفئات';
    } else if (errorStr.contains('Failed to load sales')) {
      return 'Sales Error: فشل في تحميل المبيعات';
    } else if (errorStr.contains('Failed to load order lines')) {
      return 'Order Lines Error: فشل في تحميل بنود الطلبات';
    } else if (errorStr.contains('Failed to load partners')) {
      return 'Partners Error: فشل في تحميل العملاء';
    } else if (errorStr.contains('Failed to load account moves')) {
      return 'Account Moves Error: فشل في تحميل الحركات المحاسبية';
    } else if (errorStr.contains('Failed to load stock picking')) {
      return 'Stock Picking Error: فشل في تحميل إدارة المخزون';
    } else if (errorStr.contains('SocketException')) {
      return 'Network Error: مشكلة في الاتصال بالشبكة';
    } else if (errorStr.contains('TimeoutException')) {
      return 'Timeout Error: انتهت مهلة الاتصال';
    } else if (errorStr.contains('FormatException')) {
      return 'Format Error: خطأ في تنسيق البيانات';
    } else {
      return 'Unknown Error: خطأ غير معروف - ${error.runtimeType}';
    }
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('خطأ في التحميل'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('فشل تحميل البيانات بعد عدة محاولات.'),
            const SizedBox(height: 10),
            Text(
              'التفاصيل: $error',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _retryCount = 0;
              _initializeData();
            },
            child: const Text('إعادة المحاولة'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offNamed(AppRoutes.login);
            },
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // أزرار التحكم
  // ════════════════════════════════════════════════════════════

  /// إعادة تحميل صفحة الـ splash
  void _reloadSplash() {
    print('🔄 إعادة تحميل صفحة الـ splash...');

    // إعادة تعيين المتغيرات
    _retryCount = 0;
    isReady.value = false;
    progress = 0;
    currentStatus = 'جاري التهيئة...';

    // إعادة تعيين التقدم والحالة العام
    _progressNotifier.value = 0;
    _statusNotifier.value = 'جاري التهيئة...';

    // إعادة تعيين التقدم والحالة الخاص بكل موديل
    _modelProgressNotifier.value = 0;
    _modelStatusNotifier.value = '';
    currentModel = '';
    modelProgress = 0;

    // إعادة تعيين البيانات
    products.clear();
    categoryProduct.clear();
    sales.clear();
    orderLine.clear();
    partners.clear();
    accountMove.clear();
    accountMoveLine.clear();
    listesPrix.clear();
    stockPicking.clear();
    conditionsPaiement.clear();

    // إعادة تشغيل التهيئة
    _initializeData();
  }

  /// المتابعة مع البيانات الأساسية فقط
  void _continueWithBasicData() {
    print('🚀 Continuing with basic data only...');
    _updateProgress('basic_data', 20);

    // ✅ تحميل البيانات الأساسية فقط
    Future(() async {
      try {
        await _loadProducts();
        _updateProgress('basic_data', 40);
        await _loadCategories();
        _updateProgress('basic_data', 60);
        await _loadPartners();
        _updateProgress('basic_data', 80);
        await _loadSales();
        _updateProgress('basic_data', 100);

        print('✅ Basic data loaded successfully');
        Get.offNamed(AppRoutes.dashboard);
      } catch (e) {
        print('❌ Failed to load basic data: $e');
        _showSimpleErrorDialog();
      }
    });
  }

  /// تسجيل الخروج من التطبيق
  void _logoutUser() {
    print('🚪 تسجيل الخروج من التطبيق...');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout();
            },
            child: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  /// تنفيذ تسجيل الخروج
  void _performLogout() async {
    try {
      print('🧹 مسح البيانات المحفوظة...');

      // مسح البيانات المحفوظة
      await PrefUtils.clearPrefs();

      print('✅ تم مسح البيانات بنجاح');
      print('🔄 الانتقال إلى صفحة تسجيل الدخول...');

      // الانتقال إلى صفحة تسجيل الدخول
      Get.offAllNamed(AppRoutes.login);
    } catch (e, stackTrace) {
      print('❌ خطأ في تسجيل الخروج: $e');
      print('📍 Stack trace: $stackTrace');

      // في حالة حدوث خطأ، انتقل إلى صفحة تسجيل الدخول مباشرة
      Get.offAllNamed(AppRoutes.login);
    }
  }

  Widget _buildSplashContent() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6), Color(0xFF60A5FA)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: BackgroundPainter())),
            // أزرار التحكم في أعلى الصفحة
            Positioned(
              top: 20,
              right: 20,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر إعادة التحميل
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _reloadSplash,
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'إعادة التحميل',
                    ),
                  ),
                  const SizedBox(width: 10),
                  // زر تسجيل الخروج
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _logoutUser,
                      icon: const Icon(
                        Icons.logout,
                        color: Colors.white,
                        size: 20,
                      ),
                      tooltip: 'تسجيل الخروج',
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // اللوغو في أعلى الوسط
                  const SizedBox(height: 60),
                  Center(
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Transform.rotate(
                              angle: _logoRotationAnimation.value,
                              child: Opacity(
                                opacity: _logoOpacityAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.2),
                                        blurRadius: 30,
                                        spreadRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius:
                                        MediaQuery.of(context).size.width *
                                        0.15,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Image.asset(
                                        "assets/images/logo/login-logo.png",
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        RepaintBoundary(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              children: [
                                // مؤشر التقدم العام
                                ValueListenableBuilder<int>(
                                  valueListenable: _progressNotifier,
                                  builder: (context, progressValue, child) {
                                    return AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: LinearProgressIndicator(
                                        value: progressValue / 100,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.3),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              progressValue == 100
                                                  ? Colors.green
                                                  : Colors.white,
                                            ),
                                        minHeight: 8,
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 10),
                                ValueListenableBuilder<int>(
                                  valueListenable: _progressNotifier,
                                  builder: (context, progressValue, child) {
                                    return AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      style: GoogleFonts.nunito(
                                        color: progressValue == 100
                                            ? Colors.green
                                            : Colors.white,
                                        fontSize: progressValue == 100
                                            ? 18
                                            : 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      child: Text("$progressValue %"),
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                ValueListenableBuilder<String>(
                                  valueListenable: _statusNotifier,
                                  builder: (context, status, child) {
                                    return AnimatedSwitcher(
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.3),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        status,
                                        key: ValueKey(status),
                                        style: GoogleFonts.nunito(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),

                                // مؤشر التقدم الخاص بكل موديل
                                const SizedBox(height: 20),
                                ValueListenableBuilder<String>(
                                  valueListenable: _modelStatusNotifier,
                                  builder: (context, modelStatus, child) {
                                    if (modelStatus.isEmpty)
                                      return const SizedBox.shrink();

                                    return Column(
                                      children: [
                                        // عنوان الموديل الحالي
                                        ValueListenableBuilder<String>(
                                          valueListenable: _modelStatusNotifier,
                                          builder: (context, status, child) {
                                            if (status.isEmpty)
                                              return const SizedBox.shrink();

                                            return Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Text(
                                                currentModel,
                                                style: GoogleFonts.nunito(
                                                  color: Colors.white
                                                      .withOpacity(0.9),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 8),

                                        // مؤشر التقدم الخاص بالموديل
                                        ValueListenableBuilder<int>(
                                          valueListenable:
                                              _modelProgressNotifier,
                                          builder:
                                              (
                                                context,
                                                modelProgressValue,
                                                child,
                                              ) {
                                                return AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  curve: Curves.easeInOut,
                                                  child: LinearProgressIndicator(
                                                    value:
                                                        modelProgressValue /
                                                        100,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(0.2),
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(
                                                          modelProgressValue ==
                                                                  100
                                                              ? Colors.blue
                                                              : Colors.cyan,
                                                        ),
                                                    minHeight: 4,
                                                  ),
                                                );
                                              },
                                        ),
                                        const SizedBox(height: 6),

                                        // النسبة المئوية للموديل
                                        ValueListenableBuilder<int>(
                                          valueListenable:
                                              _modelProgressNotifier,
                                          builder:
                                              (
                                                context,
                                                modelProgressValue,
                                                child,
                                              ) {
                                                return AnimatedDefaultTextStyle(
                                                  duration: const Duration(
                                                    milliseconds: 300,
                                                  ),
                                                  style: GoogleFonts.nunito(
                                                    color:
                                                        modelProgressValue ==
                                                            100
                                                        ? Colors.blue
                                                        : Colors.cyan,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  child: Text(
                                                    "$modelProgressValue %",
                                                  ),
                                                );
                                              },
                                        ),
                                        const SizedBox(height: 4),

                                        // حالة الموديل
                                        ValueListenableBuilder<String>(
                                          valueListenable: _modelStatusNotifier,
                                          builder: (context, modelStatus, child) {
                                            return AnimatedSwitcher(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              transitionBuilder:
                                                  (child, animation) {
                                                    return FadeTransition(
                                                      opacity: animation,
                                                      child: SlideTransition(
                                                        position: Tween<Offset>(
                                                          begin: const Offset(
                                                            0,
                                                            0.2,
                                                          ),
                                                          end: Offset.zero,
                                                        ).animate(animation),
                                                        child: child,
                                                      ),
                                                    );
                                                  },
                                              child: Text(
                                                modelStatus,
                                                key: ValueKey(modelStatus),
                                                style: GoogleFonts.nunito(
                                                  color: Colors.white
                                                      .withOpacity(0.8),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 1000),
                          child: const RepaintBoundary(
                            child: Text(
                              "Powered By GENIUSTEP",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: 1.0,
                          duration: const Duration(milliseconds: 1500),
                          child: const RepaintBoundary(
                            child: Text(
                              "V 1.0.2",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isReady.value) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.offNamed(AppRoutes.dashboard);
        });
        return _buildSplashContent();
      } else {
        return _buildSplashContent();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _logoController.dispose();
    _progressNotifier.dispose();
    _statusNotifier.dispose();
    _modelProgressNotifier.dispose();
    _modelStatusNotifier.dispose();
    super.dispose();
  }
}

// ════════════════════════════════════════════════════════════
// Background Painter (نفسه كما في الملف الأصلي)
// ════════════════════════════════════════════════════════════

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // رسم دوائر عشوائية في الخلفية
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.3), 100, paint);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.7), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.1), 80, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
