// ════════════════════════════════════════════════════════════
// PaginatedController - Pagination مع Infinite Scroll
// ════════════════════════════════════════════════════════════

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/utils/result.dart';

class PaginatedController<T> extends GetxController {
  // ════════════════════════════════════════════════════════════
  // State
  // ════════════════════════════════════════════════════════════

  final RxList<T> _items = <T>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _hasMore = true.obs;
  final Rx<AppError?> _error = Rx<AppError?>(null);

  int _currentPage = 0;
  final int pageSize;

  // ════════════════════════════════════════════════════════════
  // Data Fetcher
  // ════════════════════════════════════════════════════════════

  final Future<Result<List<T>>> Function(int limit, int offset) fetcher;

  // ════════════════════════════════════════════════════════════
  // Constructor
  // ════════════════════════════════════════════════════════════

  PaginatedController({
    required this.fetcher,
    this.pageSize = 50,
  });

  // ════════════════════════════════════════════════════════════
  // Getters
  // ════════════════════════════════════════════════════════════

  List<T> get items => _items;
  bool get isLoading => _isLoading.value;
  bool get hasMore => _hasMore.value;
  AppError? get error => _error.value;
  bool get isEmpty => _items.isEmpty;
  bool get isNotEmpty => _items.isNotEmpty;
  int get itemsCount => _items.length;

  // ════════════════════════════════════════════════════════════
  // Lifecycle
  // ════════════════════════════════════════════════════════════

  @override
  void onInit() {
    super.onInit();
    loadMore(); // تحميل أول صفحة تلقائياً
  }

  // ════════════════════════════════════════════════════════════
  // Load More (Infinite Scroll)
  // ════════════════════════════════════════════════════════════

  Future<void> loadMore() async {
    // تجنب التحميل المتعدد
    if (_isLoading.value || !_hasMore.value) {
      if (kDebugMode) {
        print('⏸️ Skipping loadMore (loading: ${_isLoading.value}, hasMore: ${_hasMore.value})');
      }
      return;
    }

    _isLoading.value = true;
    _error.value = null;

    try {
      if (kDebugMode) {
        print('📥 Loading page $_currentPage (offset: ${_currentPage * pageSize}, limit: $pageSize)');
      }

      final result = await fetcher(pageSize, _currentPage * pageSize);

      result.when(
        success: (newItems) {
          if (kDebugMode) {
            print('✅ Loaded ${newItems.length} items');
          }

          // إذا عدد العناصر أقل من pageSize، لا يوجد المزيد
          if (newItems.length < pageSize) {
            _hasMore.value = false;
            if (kDebugMode) {
              print('🏁 No more items to load');
            }
          }

          _items.addAll(newItems);
          _currentPage++;

          if (kDebugMode) {
            print('📊 Total items: ${_items.length}');
          }
        },
        error: (err) {
          if (kDebugMode) {
            print('❌ Error loading items: ${err.message}');
          }
          _error.value = err;
        },
        loading: () {
          // لن يحدث هنا
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Unexpected error: $e');
      }
      _error.value = AppError.unknown(e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Refresh (Pull to Refresh)
  // ════════════════════════════════════════════════════════════

  Future<void> refresh() async {
    if (kDebugMode) {
      print('🔄 Refreshing...');
    }

    _currentPage = 0;
    _hasMore.value = true;
    _error.value = null;
    _items.clear();

    await loadMore();
  }

  // ════════════════════════════════════════════════════════════
  // Search (with reset)
  // ════════════════════════════════════════════════════════════

  Future<void> search(String query) async {
    if (kDebugMode) {
      print('🔍 Searching for: $query');
    }

    // يمكن تعديل الـ fetcher ليدعم البحث
    // أو استخدام controller منفصل للبحث
    await refresh();
  }

  // ════════════════════════════════════════════════════════════
  // Clear
  // ════════════════════════════════════════════════════════════

  void clear() {
    _currentPage = 0;
    _hasMore.value = true;
    _error.value = null;
    _items.clear();
    _isLoading.value = false;

    if (kDebugMode) {
      print('🧹 Cleared all items');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Retry (في حالة الخطأ)
  // ════════════════════════════════════════════════════════════

  Future<void> retry() async {
    if (kDebugMode) {
      print('🔁 Retrying...');
    }

    _error.value = null;
    await loadMore();
  }

  // ════════════════════════════════════════════════════════════
  // Get Item by Index
  // ════════════════════════════════════════════════════════════

  T? getItem(int index) {
    if (index >= 0 && index < _items.length) {
      return _items[index];
    }
    return null;
  }

  // ════════════════════════════════════════════════════════════
  // Add Item
  // ════════════════════════════════════════════════════════════

  void addItem(T item) {
    _items.add(item);
  }

  // ════════════════════════════════════════════════════════════
  // Remove Item
  // ════════════════════════════════════════════════════════════

  void removeItem(T item) {
    _items.remove(item);
  }

  // ════════════════════════════════════════════════════════════
  // Update Item
  // ════════════════════════════════════════════════════════════

  void updateItem(int index, T item) {
    if (index >= 0 && index < _items.length) {
      _items[index] = item;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Find Item
  // ════════════════════════════════════════════════════════════

  T? findItem(bool Function(T) test) {
    try {
      return _items.firstWhere(test);
    } catch (e) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Info
  // ════════════════════════════════════════════════════════════

  Map<String, dynamic> getInfo() {
    return {
      'itemsCount': _items.length,
      'currentPage': _currentPage,
      'pageSize': pageSize,
      'isLoading': _isLoading.value,
      'hasMore': _hasMore.value,
      'hasError': _error.value != null,
      'error': _error.value?.message,
    };
  }
}
