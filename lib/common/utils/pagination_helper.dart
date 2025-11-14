import 'package:flutter/foundation.dart';

/// Helper class for pagination management
class PaginationHelper<T> {
  final int pageSize;
  final Future<List<T>> Function(int offset, int limit) loadData;
  
  List<T> _allItems = [];
  List<T> _currentPageItems = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  
  PaginationHelper({
    required this.pageSize,
    required this.loadData,
  });
  
  List<T> get items => _currentPageItems;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  int get currentPage => _currentPage;
  int get totalItems => _allItems.length;
  
  /// Load first page
  Future<void> loadFirstPage() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _currentPage = 0;
    _hasMore = true;
    
    try {
      final data = await loadData(0, pageSize);
      _allItems = data;
      _currentPageItems = List.from(data);
      _hasMore = data.length >= pageSize;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading first page: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Load next page
  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    _currentPage++;
    
    try {
      final offset = _currentPage * pageSize;
      final data = await loadData(offset, pageSize);
      
      if (data.isEmpty) {
        _hasMore = false;
      } else {
        _allItems.addAll(data);
        _currentPageItems.addAll(data);
        _hasMore = data.length >= pageSize;
      }
    } catch (e) {
      _currentPage--; // Rollback on error
      if (kDebugMode) {
        print('Error loading next page: $e');
      }
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Refresh all data
  Future<void> refresh() async {
    _allItems.clear();
    _currentPageItems.clear();
    _currentPage = 0;
    _hasMore = true;
    await loadFirstPage();
  }
  
  /// Add item to current list
  void addItem(T item) {
    _allItems.add(item);
    _currentPageItems.add(item);
  }
  
  /// Remove item from list
  void removeItem(T item) {
    _allItems.remove(item);
    _currentPageItems.remove(item);
  }
  
  /// Update item in list
  void updateItem(T oldItem, T newItem) {
    final allIndex = _allItems.indexOf(oldItem);
    final currentIndex = _currentPageItems.indexOf(oldItem);
    
    if (allIndex != -1) {
      _allItems[allIndex] = newItem;
    }
    if (currentIndex != -1) {
      _currentPageItems[currentIndex] = newItem;
    }
  }
  
  /// Clear all data
  void clear() {
    _allItems.clear();
    _currentPageItems.clear();
    _currentPage = 0;
    _hasMore = true;
  }
}

