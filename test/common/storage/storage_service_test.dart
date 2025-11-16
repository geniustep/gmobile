// ════════════════════════════════════════════════════════════
// StorageService Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/user/user_model.dart';

void main() {
  // تهيئة Flutter binding
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService Singleton', () {
    test('should return same instance', () {
      final instance1 = StorageService.instance;
      final instance2 = StorageService.instance;

      expect(instance1, same(instance2));
    });

    test('instance should not be null', () {
      expect(StorageService.instance, isNotNull);
    });
  });

  group('StorageService Token Operations', () {
    setUp(() async {
      // تنظيف قبل كل اختبار
      await StorageService.instance.setToken('');
    });

    test('should save and retrieve token', () async {
      const testToken = 'test_token_123';

      await StorageService.instance.setToken(testToken);
      final retrievedToken = await StorageService.instance.getToken();

      expect(retrievedToken, equals(testToken));
    });

    test('should return null when token not set', () async {
      final token = await StorageService.instance.getToken();

      expect(token, isNull);
    });

    test('should update token value', () async {
      await StorageService.instance.setToken('token1');
      await StorageService.instance.setToken('token2');

      final token = await StorageService.instance.getToken();

      expect(token, equals('token2'));
    });

    test('should clear token', () async {
      await StorageService.instance.setToken('test_token');
      await StorageService.instance.setToken('');

      final token = await StorageService.instance.getToken();

      expect(token, isNull);
    });
  });

  group('StorageService Login State', () {
    setUp(() async {
      await StorageService.instance.setIsLoggedIn(false);
    });

    test('should save and retrieve login state', () async {
      await StorageService.instance.setIsLoggedIn(true);
      final isLoggedIn = await StorageService.instance.getIsLoggedIn();

      expect(isLoggedIn, isTrue);
    });

    test('should default to false when not set', () async {
      final isLoggedIn = await StorageService.instance.getIsLoggedIn();

      expect(isLoggedIn, isFalse);
    });

    test('should toggle login state', () async {
      await StorageService.instance.setIsLoggedIn(true);
      expect(await StorageService.instance.getIsLoggedIn(), isTrue);

      await StorageService.instance.setIsLoggedIn(false);
      expect(await StorageService.instance.getIsLoggedIn(), isFalse);
    });
  });

  group('StorageService User Operations', () {
    setUp(() async {
      await StorageService.instance.setUser(UserModel());
    });

    test('should save and retrieve user', () async {
      final testUser = UserModel(
        uid: 123,
        name: 'Test User',
        username: 'test@example.com',
      );

      await StorageService.instance.setUser(testUser);
      final retrievedUser = await StorageService.instance.getUser();

      expect(retrievedUser, isNotNull);
      expect(retrievedUser?.uid, equals(123));
      expect(retrievedUser?.name, equals('Test User'));
      expect(retrievedUser?.username, equals('test@example.com'));
    });

    test('should return null when user not set', () async {
      final user = await StorageService.instance.getUser();

      expect(user, isNull);
    });

    test('should clear user', () async {
      final testUser = UserModel(uid: 1, name: 'Test');
      await StorageService.instance.setUser(testUser);
      await StorageService.instance.setUser(UserModel());

      final user = await StorageService.instance.getUser();

      expect(user, isNull);
    });
  });

  group('StorageService Products Operations', () {
    final testProducts = [
      ProductModel(
        id: 1,
        name: 'Product 1',
        list_price: 100.0,
        image_128: 'url1',
      ),
      ProductModel(
        id: 2,
        name: 'Product 2',
        list_price: 200.0,
        image_128: 'url2',
      ),
    ];

    setUp(() async {
      await StorageService.instance.clearProducts();
    });

    test('should save and retrieve products', () async {
      await StorageService.instance.setProducts(testProducts);
      final retrievedProducts = await StorageService.instance.getProducts();

      expect(retrievedProducts, isNotNull);
      expect(retrievedProducts.length, equals(2));
      expect(retrievedProducts[0].id, equals(1));
      expect(retrievedProducts[1].id, equals(2));
    });

    test('should return empty list when no products', () async {
      final products = await StorageService.instance.getProducts();

      expect(products, isEmpty);
    });

    test('should support pagination', () async {
      await StorageService.instance.setProducts(testProducts);

      final page1 = await StorageService.instance.getProducts(
        limit: 1,
        offset: 0,
      );

      expect(page1.length, equals(1));
      expect(page1[0].id, equals(1));

      final page2 = await StorageService.instance.getProducts(
        limit: 1,
        offset: 1,
      );

      expect(page2.length, equals(1));
      expect(page2[0].id, equals(2));
    });

    test('should clear products', () async {
      await StorageService.instance.setProducts(testProducts);
      await StorageService.instance.clearProducts();

      final products = await StorageService.instance.getProducts();

      expect(products, isEmpty);
    });

    test('should handle large product lists', () async {
      final largeList = List.generate(
        100,
        (i) => ProductModel(
          id: i,
          name: 'Product $i',
          list_price: i * 10.0,
          image_128: 'url$i',
        ),
      );

      await StorageService.instance.setProducts(largeList);
      final retrieved = await StorageService.instance.getProducts();

      expect(retrieved.length, equals(100));
    });
  });

  group('StorageService Location Operations', () {
    test('should save and retrieve latitude', () async {
      const testLat = 25.276987;

      await StorageService.instance.setLatitude(testLat);
      final lat = StorageService.instance.getLatitude();

      expect(lat, equals(testLat));
    });

    test('should save and retrieve longitude', () async {
      const testLong = 55.296249;

      await StorageService.instance.setLongitude(testLong);
      final long = StorageService.instance.getLongitude();

      expect(long, equals(testLong));
    });

    test('should handle location coordinates together', () async {
      const lat = 25.276987;
      const long = 55.296249;

      await StorageService.instance.setLatitude(lat);
      await StorageService.instance.setLongitude(long);

      final retrievedLat = StorageService.instance.getLatitude();
      final retrievedLong = StorageService.instance.getLongitude();

      expect(retrievedLat, equals(lat));
      expect(retrievedLong, equals(long));
    });
  });

  group('StorageService Error Handling', () {
    test('should handle null values gracefully', () async {
      // Saving null should not throw
      expect(
        () => StorageService.instance.setUser(UserModel()),
        returnsNormally,
      );
    });

    test('should handle empty strings', () async {
      await StorageService.instance.setToken('');
      final token = await StorageService.instance.getToken();

      expect(token, equals(''));
    });

    test('should handle concurrent operations', () async {
      final futures = List.generate(
        10,
        (i) => StorageService.instance.setToken('token$i'),
      );

      await Future.wait(futures);

      // Should complete without errors
      final token = await StorageService.instance.getToken();
      expect(token, isNotNull);
    });
  });

  group('StorageService Data Persistence', () {
    test('should persist data across multiple operations', () async {
      const token = 'persistent_token';
      final user = UserModel(uid: 999, name: 'Persistent User');

      // Save multiple pieces of data
      await StorageService.instance.setToken(token);
      await StorageService.instance.setUser(user);
      await StorageService.instance.setIsLoggedIn(true);

      // Verify all data is still there
      expect(await StorageService.instance.getToken(), equals(token));
      expect(await StorageService.instance.getIsLoggedIn(), isTrue);

      final retrievedUser = await StorageService.instance.getUser();
      expect(retrievedUser?.uid, equals(999));
    });
  });
}
