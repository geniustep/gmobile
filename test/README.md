# 🧪 Tests Documentation

## 📋 Overview

This directory contains comprehensive tests for the gmobile Flutter application.

### Test Statistics

- **Total Test Files**: 13
- **Test Categories**: 6
- **Coverage Target**: 60%+

---

## 📁 Test Structure

```
test/
├── common/                           # Unit tests for common utilities
│   ├── cache/
│   │   └── cache_manager_test.dart         (17 tests)
│   ├── offline/
│   │   └── offline_queue_manager_test.dart (18 tests)
│   ├── security/
│   │   └── secure_token_storage_test.dart  (14 tests)
│   ├── session/
│   │   └── session_manager_test.dart       (7 tests)
│   ├── storage/
│   │   └── storage_service_test.dart       (NEW - 30+ tests)
│   ├── repositories/
│   │   └── product/
│   │       └── product_repository_test.dart (NEW - 35+ tests)
│   ├── controllers/
│   │   ├── signin_controller_test.dart      (NEW - 15 tests)
│   │   └── paginated_controller_test.dart   (NEW - 40+ tests)
│   └── api_factory/
│       └── bridgecore/
│           └── api_mode_config_test.dart    (NEW - 10+ tests)
├── integration/
│   └── app_integration_test.dart            (NEW - 15+ tests)
└── widget_test.dart                          (UPDATED - 5 tests)
```

---

## 🚀 Running Tests

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/common/cache/cache_manager_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
```

### Generate HTML Coverage Report

```bash
# Install genhtml (Linux/Mac)
sudo apt-get install lcov  # Linux
brew install lcov          # Mac

# Generate report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html  # Mac
xdg-open coverage/html/index.html  # Linux
```

### Run in Watch Mode (Auto-reload on changes)

```bash
flutter test --watch
```

### Run Only Unit Tests

```bash
flutter test test/common
```

### Run Only Integration Tests

```bash
flutter test test/integration
```

---

## 📊 Test Categories

### 1. Unit Tests ✅

Tests individual units of code in isolation.

**Files:**
- `cache_manager_test.dart` - Cache operations with TTL
- `offline_queue_manager_test.dart` - Offline request queue
- `secure_token_storage_test.dart` - Secure token storage
- `session_manager_test.dart` - Session management
- `storage_service_test.dart` - Hybrid storage system
- `product_repository_test.dart` - Product repository with mocking
- `signin_controller_test.dart` - SignIn controller
- `paginated_controller_test.dart` - Pagination controller
- `api_mode_config_test.dart` - API mode configuration

**Coverage:** ~80%

### 2. Widget Tests ✅

Tests UI components.

**Files:**
- `widget_test.dart` - App-level widget tests

**Coverage:** Basic

### 3. Integration Tests ✅

Tests multiple components working together.

**Files:**
- `app_integration_test.dart` - System integration tests

**Coverage:** ~60%

---

## 🎯 Test Patterns Used

### 1. AAA Pattern (Arrange-Act-Assert)

```dart
test('should save and retrieve token', () async {
  // Arrange
  const testToken = 'test_token';

  // Act
  await storageService.saveToken(testToken);
  final retrievedToken = await storageService.getToken();

  // Assert
  expect(retrievedToken, equals(testToken));
});
```

### 2. Mocking with Mocktail

```dart
class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

test('should fetch products from server', () async {
  // Arrange
  when(() => mockRemote.getProducts())
      .thenAnswer((_) async => mockProducts);

  // Act
  final result = await repository.getProducts();

  // Assert
  verify(() => mockRemote.getProducts()).called(1);
});
```

### 3. setUp & tearDown

```dart
late CacheManager cacheManager;

setUp(() {
  cacheManager = CacheManager.instance;
});

tearDown(() async {
  await cacheManager.invalidateAll();
});
```

---

## 🔍 What's Tested

### ✅ CacheManager
- Save/retrieve data
- TTL expiration
- Invalidation (single & all)
- Complex data types
- Null handling
- **NEW:** Error cases, edge cases, concurrent operations

### ✅ OfflineQueueManager
- Add/remove requests
- Priority ordering
- Retry limits
- Queue export
- Auto-sync
- JSON serialization

### ✅ SecureTokenStorage
- Token storage (session, access, refresh)
- User data (UID, username, database)
- Last activity tracking
- Session expiry detection
- Clear methods

### ✅ SessionManager
- Start/stop monitoring
- Remaining time calculation
- Session refresh
- Activity updates

### ✅ StorageService (NEW)
- Token operations
- Login state
- User CRUD
- Products CRUD with pagination
- Location coordinates
- Error handling
- Data persistence

### ✅ ProductRepository (NEW)
- Cache-first strategy
- Network availability checks
- CRUD operations
- Search functionality
- Error handling with Result type
- Mock remote data source

### ✅ Controllers (NEW)
- SignInController: User state management
- PaginatedController: Infinite scroll, refresh, retry

### ✅ BridgeCore (NEW)
- ApiModeConfig: Mode switching, A/B testing

### ✅ Integration Tests (NEW)
- Storage & Cache integration
- Session & Storage integration
- Offline Queue persistence
- Data flow testing
- Error recovery
- Performance testing

---

## 📈 Coverage Goals

| Component | Current | Target |
|-----------|---------|--------|
| Cache | 85% | 90% |
| Offline | 75% | 80% |
| Security | 80% | 85% |
| Session | 70% | 80% |
| Storage | 80% | 85% |
| Repositories | 75% | 80% |
| Controllers | 70% | 75% |
| BridgeCore | 60% | 70% |
| **Overall** | **~35%** | **60%+** |

---

## 🐛 Common Issues & Solutions

### Issue: Tests fail with "Binding not initialized"

**Solution:**
```dart
TestWidgetsFlutterBinding.ensureInitialized();
```

### Issue: GetX controller not found

**Solution:**
```dart
setUp(() {
  Get.testMode = true;
});

tearDown() {
  Get.reset();
});
```

### Issue: Async tests hanging

**Solution:**
```dart
// Add timeout
test('should complete', () async {
  // ...
}, timeout: const Timeout(Duration(seconds: 5)));
```

### Issue: SharedPreferences not mocked

**Solution:**
```dart
// Use mocktail to mock SharedPreferences
class MockSharedPreferences extends Mock implements SharedPreferences {}
```

---

## 📝 Writing New Tests

### Template for Unit Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDependency extends Mock implements Dependency {}

void main() {
  late YourClass yourClass;
  late MockDependency mockDep;

  setUp(() {
    mockDep = MockDependency();
    yourClass = YourClass(dependency: mockDep);
  });

  tearDown(() {
    // Cleanup
  });

  group('YourClass Tests', () {
    test('should do something', () async {
      // Arrange
      when(() => mockDep.method()).thenAnswer((_) async => result);

      // Act
      final output = await yourClass.doSomething();

      // Assert
      expect(output, equals(expected));
      verify(() => mockDep.method()).called(1);
    });
  });
}
```

### Template for Widget Test

```dart
testWidgets('Widget should display correctly', (WidgetTester tester) async {
  // Build widget
  await tester.pumpWidget(
    MaterialApp(home: YourWidget()),
  );

  // Find elements
  expect(find.text('Expected Text'), findsOneWidget);

  // Interact
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Verify
  expect(find.text('Result'), findsOneWidget);
});
```

---

## 🎓 Best Practices

1. ✅ **Test one thing per test**
2. ✅ **Use descriptive test names**
3. ✅ **Follow AAA pattern**
4. ✅ **Mock external dependencies**
5. ✅ **Clean up in tearDown**
6. ✅ **Test edge cases and error scenarios**
7. ✅ **Keep tests fast (< 1s each)**
8. ✅ **Use const constructors where possible**
9. ✅ **Group related tests**
10. ✅ **Maintain test independence**

---

## 🚀 Next Steps

### To Improve Coverage:

1. Add tests for remaining repositories:
   - InvoiceRepository
   - PartnerRepository

2. Add tests for remaining controllers:
   - InvoiceController
   - PaymentController
   - ExpenseController
   - HomeController

3. Add tests for API layer:
   - ApiClientFactory
   - BridgeCoreClient
   - OdooDirectClient

4. Add tests for services:
   - ApiRequestManager
   - NetworkMonitor
   - CachedDataService
   - AnalyticsService

5. Add more widget tests:
   - Common widgets
   - Screen widgets

6. Add more integration tests:
   - Login flow
   - Create order flow
   - Offline sync flow

---

## 📚 Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Test-Driven Development](https://en.wikipedia.org/wiki/Test-driven_development)

---

**Last Updated:** 2025-11-15
**Maintainer:** Development Team
