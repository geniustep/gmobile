// ════════════════════════════════════════════════════════════
// PaginatedController Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/controllers/paginated_controller.dart';
import 'package:gsloution_mobile/common/utils/result.dart';

void main() {
  // Test data
  final mockItems1 = List.generate(50, (i) => 'Item $i');
  final mockItems2 = List.generate(50, (i) => 'Item ${i + 50}');
  final mockItems3 = List.generate(30, (i) => 'Item ${i + 100}'); // Last page

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('PaginatedController Initialization', () {
    test('should initialize with correct default values', () {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async => Result.success([]),
      );

      expect(controller.items, isEmpty);
      expect(controller.isLoading, isFalse);
      expect(controller.hasMore, isTrue);
      expect(controller.error, isNull);
      expect(controller.isEmpty, isTrue);
      expect(controller.isNotEmpty, isFalse);
      expect(controller.itemsCount, equals(0));
    });

    test('should accept custom pageSize', () {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async => Result.success([]),
        pageSize: 100,
      );

      expect(controller.pageSize, equals(100));
    });
  });

  group('PaginatedController loadMore', () {
    test('should load first page successfully', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          expect(limit, equals(50));
          expect(offset, equals(0));
          return Result.success(mockItems1);
        },
        pageSize: 50,
      );

      // Wait for onInit to complete
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.items.length, equals(50));
      expect(controller.hasMore, isTrue);
      expect(controller.isLoading, isFalse);
      expect(controller.error, isNull);
    });

    test('should load multiple pages sequentially', () async {
      var callCount = 0;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          callCount++;
          if (offset == 0) return Result.success(mockItems1);
          if (offset == 50) return Result.success(mockItems2);
          return Result.success([]);
        },
        pageSize: 50,
      );

      // Wait for first page (onInit)
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.items.length, equals(50));

      // Load second page
      await controller.loadMore();
      expect(controller.items.length, equals(100));
      expect(callCount, equals(2));
    });

    test('should set hasMore to false when last page is loaded', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          if (offset == 0) return Result.success(mockItems3); // Only 30 items
          return Result.success([]);
        },
        pageSize: 50,
      );

      // Wait for first page
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.items.length, equals(30));
      expect(controller.hasMore, isFalse); // Less than pageSize
    });

    test('should not load more when already loading', () async {
      var callCount = 0;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          callCount++;
          await Future.delayed(const Duration(milliseconds: 200));
          return Result.success(mockItems1);
        },
        pageSize: 50,
      );

      // Start loading
      final future1 = controller.loadMore();
      final future2 = controller.loadMore(); // Should be ignored

      await Future.wait([future1, future2]);

      expect(callCount, equals(1)); // Only one call
    });

    test('should not load more when hasMore is false', () async {
      var callCount = 0;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          callCount++;
          return Result.success(mockItems3); // 30 items, less than pageSize
        },
        pageSize: 50,
      );

      // Wait for first page
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.hasMore, isFalse);

      // Try to load more
      await controller.loadMore();

      // Should still be 1 call (from onInit only)
      expect(callCount, equals(1));
    });

    test('should handle error during loading', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          return Result.error(
            AppError.network('Network error'),
          );
        },
        pageSize: 50,
      );

      // Wait for first page attempt
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.items, isEmpty);
      expect(controller.error, isNotNull);
      expect(controller.error?.type, equals(ErrorType.network));
      expect(controller.isLoading, isFalse);
    });
  });

  group('PaginatedController refresh', () {
    test('should clear items and reload from first page', () async {
      var callCount = 0;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          callCount++;
          return Result.success(mockItems1);
        },
        pageSize: 50,
      );

      // Wait for first load
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.items.length, equals(50));
      expect(callCount, equals(1));

      // Refresh
      await controller.refresh();

      expect(controller.items.length, equals(50));
      expect(callCount, equals(2)); // onInit + refresh
    });

    test('should reset hasMore flag on refresh', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          return Result.success(mockItems3); // Less than pageSize
        },
        pageSize: 50,
      );

      // Wait for first load
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.hasMore, isFalse);

      // Refresh
      await controller.refresh();

      // hasMore should be reset before fetching
      expect(controller.items.length, equals(30));
    });

    test('should clear error on refresh', () async {
      var shouldError = true;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          if (shouldError) {
            return Result.error(AppError.network('Error'));
          }
          return Result.success(mockItems1);
        },
        pageSize: 50,
      );

      // Wait for error
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.error, isNotNull);

      // Fix and refresh
      shouldError = false;
      await controller.refresh();

      expect(controller.error, isNull);
      expect(controller.items.length, equals(50));
    });
  });

  group('PaginatedController retry', () {
    test('should retry loading after error', () async {
      var shouldError = true;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          if (shouldError) {
            return Result.error(AppError.network('Error'));
          }
          return Result.success(mockItems1);
        },
        pageSize: 50,
      );

      // Wait for error
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.error, isNotNull);

      // Fix and retry
      shouldError = false;
      await controller.retry();

      expect(controller.error, isNull);
      expect(controller.items.length, equals(50));
    });
  });

  group('PaginatedController clear', () {
    test('should clear all items and reset state', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async => Result.success(mockItems1),
        pageSize: 50,
      );

      // Wait for load
      await Future.delayed(const Duration(milliseconds: 100));
      expect(controller.items.length, equals(50));

      // Clear
      controller.clear();

      expect(controller.items, isEmpty);
      expect(controller.hasMore, isTrue);
      expect(controller.error, isNull);
      expect(controller.isLoading, isFalse);
      expect(controller.isEmpty, isTrue);
    });
  });

  group('PaginatedController item manipulation', () {
    late PaginatedController<String> controller;

    setUp(() async {
      controller = PaginatedController<String>(
        fetcher: (limit, offset) async => Result.success(mockItems1),
        pageSize: 50,
      );
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('should get item by index', () {
      final item = controller.getItem(0);
      expect(item, equals('Item 0'));

      final lastItem = controller.getItem(49);
      expect(lastItem, equals('Item 49'));
    });

    test('should return null for invalid index', () {
      expect(controller.getItem(-1), isNull);
      expect(controller.getItem(100), isNull);
    });

    test('should add item', () {
      final initialCount = controller.itemsCount;
      controller.addItem('New Item');

      expect(controller.itemsCount, equals(initialCount + 1));
      expect(controller.items.last, equals('New Item'));
    });

    test('should remove item', () {
      final initialCount = controller.itemsCount;
      controller.removeItem('Item 0');

      expect(controller.itemsCount, equals(initialCount - 1));
      expect(controller.items.contains('Item 0'), isFalse);
    });

    test('should update item at index', () {
      controller.updateItem(0, 'Updated Item');

      expect(controller.getItem(0), equals('Updated Item'));
    });

    test('should find item', () {
      final found = controller.findItem((item) => item == 'Item 10');

      expect(found, equals('Item 10'));
    });

    test('should return null when item not found', () {
      final found = controller.findItem((item) => item == 'Non-existent');

      expect(found, isNull);
    });
  });

  group('PaginatedController getInfo', () {
    test('should return correct info', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async => Result.success(mockItems1),
        pageSize: 50,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final info = controller.getInfo();

      expect(info['itemsCount'], equals(50));
      expect(info['pageSize'], equals(50));
      expect(info['isLoading'], isFalse);
      expect(info['hasMore'], isTrue);
      expect(info['hasError'], isFalse);
    });

    test('should show error in info when error occurs', () async {
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          return Result.error(AppError.network('Network error'));
        },
        pageSize: 50,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final info = controller.getInfo();

      expect(info['hasError'], isTrue);
      expect(info['error'], isNotNull);
    });
  });

  group('PaginatedController search', () {
    test('should call refresh on search', () async {
      var callCount = 0;
      final controller = PaginatedController<String>(
        fetcher: (limit, offset) async {
          callCount++;
          return Result.success(mockItems1);
        },
        pageSize: 50,
      );

      await Future.delayed(const Duration(milliseconds: 100));
      expect(callCount, equals(1));

      await controller.search('test');

      expect(callCount, equals(2)); // onInit + search
    });
  });
}
