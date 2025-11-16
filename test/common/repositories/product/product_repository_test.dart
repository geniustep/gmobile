// ════════════════════════════════════════════════════════════
// ProductRepository Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:gsloution_mobile/common/repositories/product/product_repository.dart';
import 'package:gsloution_mobile/common/repositories/product/product_remote_data_source.dart';
import 'package:gsloution_mobile/common/storage/storage_service.dart';
import 'package:gsloution_mobile/common/services/network/network_info.dart';
import 'package:gsloution_mobile/common/api_factory/models/product/product_model.dart';
import 'package:gsloution_mobile/common/utils/result.dart';
import 'package:gsloution_mobile/common/services/cache/cached_data_service.dart';

// ════════════════════════════════════════════════════════════
// Mock Classes
// ════════════════════════════════════════════════════════════

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockStorageService extends Mock implements StorageService {}

class MockNetworkInfo extends Mock implements INetworkInfo {}

// ════════════════════════════════════════════════════════════
// Test Data
// ════════════════════════════════════════════════════════════

final mockProduct1 = ProductModel(
  id: 1,
  name: 'Product 1',
  list_price: 100.0,
  image_128: 'https://example.com/1.jpg',
);

final mockProduct2 = ProductModel(
  id: 2,
  name: 'Product 2',
  list_price: 200.0,
  image_128: 'https://example.com/2.jpg',
);

final mockProducts = [mockProduct1, mockProduct2];

// ════════════════════════════════════════════════════════════
// Tests
// ════════════════════════════════════════════════════════════

void main() {
  late ProductRepository repository;
  late MockProductRemoteDataSource mockRemote;
  late MockStorageService mockStorage;
  late MockNetworkInfo mockNetwork;

  setUp(() {
    mockRemote = MockProductRemoteDataSource();
    mockStorage = MockStorageService();
    mockNetwork = MockNetworkInfo();

    repository = ProductRepository(
      remote: mockRemote,
      storage: mockStorage,
      network: mockNetwork,
    );
  });

  group('getProducts', () {
    test(
      'should return cached products when available and not force refresh',
      () async {
        // Arrange
        when(
          () => mockStorage.getProducts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => mockProducts);

        // Act
        final result = await repository.getProducts();

        // Assert
        expect(result.isSuccess, isTrue);
        result.when(
          success: (products) {
            expect(products, equals(mockProducts));
            expect(products.length, equals(2));
          },
          error: (_) => fail('Should not return error'),
          loading: () => fail('Should not return loading'),
        );

        // Verify storage was called
        verify(
          () => mockStorage.getProducts(
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).called(1);
      },
    );

    test('should fetch from server when forceRefresh is true', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => mockProducts);
      when(
        () => mockStorage.setProducts(any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockStorage.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => mockProducts);

      // Act
      final result = await repository.getProducts(forceRefresh: true);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(
        () => mockRemote.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
    });

    test('should fetch from server when search query is provided', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          searchQuery: any(named: 'searchQuery'),
        ),
      ).thenAnswer((_) async => [mockProduct1]);

      // Act
      final result = await repository.getProducts(searchQuery: 'Product 1');

      // Assert
      expect(result.isSuccess, isTrue);
      result.when(
        success: (products) {
          expect(products.length, equals(1));
          expect(products.first.name, equals('Product 1'));
        },
        error: (_) => fail('Should not return error'),
        loading: () => fail('Should not return loading'),
      );
    });

    test('should return network error when no internet connection', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.getProducts(searchQuery: 'test');

      // Assert
      expect(result.isError, isTrue);
      result.when(
        success: (_) => fail('Should not return success'),
        error: (error) {
          expect(error.type, equals(ErrorType.network));
          expect(error.message, contains('لا يوجد اتصال'));
        },
        loading: () => fail('Should not return loading'),
      );
    });

    test('should handle exception from remote data source', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
          searchQuery: any(named: 'searchQuery'),
        ),
      ).thenThrow(NetworkException('Server error'));

      // Act
      final result = await repository.getProducts(searchQuery: 'test');

      // Assert
      expect(result.isError, isTrue);
      result.when(
        success: (_) => fail('Should not return success'),
        error: (error) {
          expect(error.type, equals(ErrorType.network));
        },
        loading: () => fail('Should not return loading'),
      );
    });
  });

  group('getProductById', () {
    test('should return product from cache when available', () async {
      // Arrange
      when(
        () => mockStorage.getProducts(),
      ).thenAnswer((_) async => mockProducts);

      // Act
      final result = await repository.getProductById(1);

      // Assert
      expect(result.isSuccess, isTrue);
      result.when(
        success: (product) {
          expect(product.id, equals(1));
          expect(product.name, equals('Product 1'));
        },
        error: (_) => fail('Should not return error'),
        loading: () => fail('Should not return loading'),
      );

      // Verify cache was checked first
      verify(() => mockStorage.getProducts()).called(1);
      verifyNever(() => mockRemote.getProductById(any()));
    });

    test('should fetch from server when not in cache', () async {
      // Arrange
      when(() => mockStorage.getProducts()).thenAnswer((_) async => []);
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getProductById(3),
      ).thenAnswer((_) async => mockProduct1);

      // Act
      final result = await repository.getProductById(3);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockStorage.getProducts()).called(1);
      verify(() => mockRemote.getProductById(3)).called(1);
    });

    test('should return error when no internet and not in cache', () async {
      // Arrange
      when(() => mockStorage.getProducts()).thenAnswer((_) async => []);
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.getProductById(999);

      // Assert
      expect(result.isError, isTrue);
      result.when(
        success: (_) => fail('Should not return success'),
        error: (error) {
          expect(error.type, equals(ErrorType.network));
        },
        loading: () => fail('Should not return loading'),
      );
    });
  });

  group('saveProduct', () {
    test('should save product to server and clear cache', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(() => mockRemote.createProduct(any())).thenAnswer((_) async => 123);
      when(
        () => mockStorage.clearProducts(),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.saveProduct(mockProduct1);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.createProduct(any())).called(1);
      verify(() => mockStorage.clearProducts()).called(1);
    });

    test('should return error when no internet connection', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.saveProduct(mockProduct1);

      // Assert
      expect(result.isError, isTrue);
      result.when(
        success: (_) => fail('Should not return success'),
        error: (error) {
          expect(error.type, equals(ErrorType.network));
        },
        loading: () => fail('Should not return loading'),
      );

      verifyNever(() => mockRemote.createProduct(any()));
    });

    test('should handle server error gracefully', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.createProduct(any()),
      ).thenThrow(Exception('Server error'));

      // Act
      final result = await repository.saveProduct(mockProduct1);

      // Assert
      expect(result.isError, isTrue);
      result.when(
        success: (_) => fail('Should not return success'),
        error: (error) {
          expect(error.type, equals(ErrorType.server));
        },
        loading: () => fail('Should not return loading'),
      );
    });
  });

  group('updateProduct', () {
    test('should update product on server and clear cache', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.updateProduct(any(), any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockStorage.clearProducts(),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.updateProduct(1, mockProduct1);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.updateProduct(1, any())).called(1);
      verify(() => mockStorage.clearProducts()).called(1);
    });

    test('should return error when offline', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.updateProduct(1, mockProduct1);

      // Assert
      expect(result.isError, isTrue);
      verifyNever(() => mockRemote.updateProduct(any(), any()));
    });
  });

  group('deleteProduct', () {
    test('should delete product from server and clear cache', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.deleteProduct(any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockStorage.clearProducts(),
      ).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.deleteProduct(1);

      // Assert
      expect(result.isSuccess, isTrue);
      verify(() => mockRemote.deleteProduct(1)).called(1);
      verify(() => mockStorage.clearProducts()).called(1);
    });

    test('should return error when offline', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.deleteProduct(1);

      // Assert
      expect(result.isError, isTrue);
      verifyNever(() => mockRemote.deleteProduct(any()));
    });
  });

  group('searchProducts', () {
    test('should delegate to getProducts with search query', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getProducts(
          searchQuery: any(named: 'searchQuery'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [mockProduct1]);

      // Act
      final result = await repository.searchProducts('Product 1');

      // Assert
      expect(result.isSuccess, isTrue);
      verify(
        () => mockRemote.getProducts(
          searchQuery: 'Product 1',
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
    });
  });

  group('clearCache', () {
    test('should clear products from storage', () async {
      // Arrange
      when(
        () => mockStorage.clearProducts(),
      ).thenAnswer((_) async => Future.value());

      // Act
      await repository.clearCache();

      // Assert
      verify(() => mockStorage.clearProducts()).called(1);
    });
  });

  group('sync', () {
    test('should sync products with server', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => mockProducts);
      when(
        () => mockStorage.setProducts(any()),
      ).thenAnswer((_) async => Future.value());
      when(
        () => mockStorage.getProducts(
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => mockProducts);

      // Act
      final result = await repository.sync();

      // Assert
      expect(result.isSuccess, isTrue);
    });

    test('should return error when sync fails', () async {
      // Arrange
      when(() => mockNetwork.isConnected).thenAnswer((_) async => false);

      // Act
      final result = await repository.sync();

      // Assert
      expect(result.isError, isTrue);
    });
  });
}
