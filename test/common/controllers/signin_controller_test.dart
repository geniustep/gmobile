// ════════════════════════════════════════════════════════════
// SignInController Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/controllers/signin_controller.dart';
import 'package:gsloution_mobile/common/api_factory/models/user/user_model.dart';

void main() {
  late SignInController controller;

  setUp(() {
    // Initialize GetX
    Get.testMode = true;
    controller = SignInController();
  });

  tearDown(() {
    Get.delete<SignInController>();
    Get.reset();
  });

  group('SignInController Tests', () {
    test('should initialize controller', () {
      expect(controller, isNotNull);
      expect(controller, isA<GetxController>());
    });

    test('should have currentUser observable', () {
      expect(currentUser, isNotNull);
      expect(currentUser, isA<Rx<UserModel>>());
    });

    test('currentUser should be observable and reactive', () {
      // Initial state
      final initialUser = currentUser.value;

      // Create a new user
      final newUser = UserModel(
        uid: 1,
        name: 'Test User',
        login: 'test@example.com',
      );

      // Update currentUser
      currentUser.value = newUser;

      // Verify update
      expect(currentUser.value, equals(newUser));
      expect(currentUser.value.uid, equals(1));
      expect(currentUser.value.name, equals('Test User'));
      expect(currentUser.value, isNot(equals(initialUser)));
    });

    test('should update currentUser multiple times', () {
      final user1 = UserModel(uid: 1, name: 'User 1');
      final user2 = UserModel(uid: 2, name: 'User 2');
      final user3 = UserModel(uid: 3, name: 'User 3');

      currentUser.value = user1;
      expect(currentUser.value.uid, equals(1));

      currentUser.value = user2;
      expect(currentUser.value.uid, equals(2));

      currentUser.value = user3;
      expect(currentUser.value.uid, equals(3));
    });

    test('should handle null or empty user', () {
      // Set to empty user
      currentUser.value = UserModel();

      expect(currentUser.value, isNotNull);
      expect(currentUser.value.uid, isNull);
      expect(currentUser.value.name, isNull);
    });

    test('should maintain user state across updates', () {
      final user = UserModel(
        uid: 123,
        name: 'John Doe',
        login: 'john@example.com',
      );

      currentUser.value = user;

      // Verify all fields are preserved
      expect(currentUser.value.uid, equals(123));
      expect(currentUser.value.name, equals('John Doe'));
      expect(currentUser.value.login, equals('john@example.com'));
    });
  });

  group('SignInController Lifecycle Tests', () {
    test('should call onInit when controller is initialized', () {
      // Controller is already initialized in setUp
      // Verify it doesn't throw
      expect(() => controller.onInit(), returnsNormally);
    });

    test('should be disposable', () {
      expect(() => controller.dispose(), returnsNormally);
    });
  });

  group('SignInController Integration with GetX', () {
    test('should be injectable via Get.put', () {
      Get.delete<SignInController>();
      final injectedController = Get.put(SignInController());

      expect(injectedController, isNotNull);
      expect(Get.find<SignInController>(), equals(injectedController));

      Get.delete<SignInController>();
    });

    test('should be accessible via Get.find after injection', () {
      Get.delete<SignInController>();
      Get.put(SignInController());

      final foundController = Get.find<SignInController>();

      expect(foundController, isNotNull);
      expect(foundController, isA<SignInController>());

      Get.delete<SignInController>();
    });
  });
}
