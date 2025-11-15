// ════════════════════════════════════════════════════════════
// ApiModeConfig Tests
// ════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';

void main() {
  late ApiModeConfig config;

  setUp(() {
    config = ApiModeConfig.instance;
  });

  group('ApiMode Enum', () {
    test('should have correct enum values', () {
      expect(ApiMode.values, hasLength(2));
      expect(ApiMode.values, contains(ApiMode.odooDirect));
      expect(ApiMode.values, contains(ApiMode.bridgeCore));
    });

    test('should have correct names', () {
      expect(ApiMode.odooDirect.name, equals('Odoo Direct'));
      expect(ApiMode.bridgeCore.name, equals('BridgeCore'));
    });

    test('should have correct descriptions', () {
      expect(
        ApiMode.odooDirect.description,
        equals('الاتصال المباشر بـ Odoo (النظام التقليدي)'),
      );
      expect(
        ApiMode.bridgeCore.description,
        contains('BridgeCore'),
      );
    });
  });

  group('ApiModeConfig Instance', () {
    test('should be singleton', () {
      final instance1 = ApiModeConfig.instance;
      final instance2 = ApiModeConfig.instance;

      expect(instance1, same(instance2));
    });

    test('should have default values', () {
      // Default should be odooDirect for backward compatibility
      expect(config.currentMode, equals(ApiMode.odooDirect));
      expect(config.useOdooDirect, isTrue);
      expect(config.useBridgeCore, isFalse);
      expect(config.enableABTesting, isFalse);
    });
  });

  group('ApiModeConfig Getters', () {
    test('useOdooDirect should return true when mode is odooDirect', () {
      // Assuming default is odooDirect
      expect(config.useOdooDirect, isTrue);
      expect(config.useBridgeCore, isFalse);
    });

    test('bridgeCoreUserPercentage should be between 0 and 1', () {
      final percentage = config.bridgeCoreUserPercentage;

      expect(percentage, greaterThanOrEqualTo(0.0));
      expect(percentage, lessThanOrEqualTo(1.0));
    });
  });

  group('ApiModeConfig Mode Switching', () {
    test('should be able to query current mode', () {
      final mode = config.currentMode;

      expect(mode, isA<ApiMode>());
      expect(mode, isIn([ApiMode.odooDirect, ApiMode.bridgeCore]));
    });

    test('should return correct boolean for each mode', () {
      final currentMode = config.currentMode;

      if (currentMode == ApiMode.odooDirect) {
        expect(config.useOdooDirect, isTrue);
        expect(config.useBridgeCore, isFalse);
      } else {
        expect(config.useOdooDirect, isFalse);
        expect(config.useBridgeCore, isTrue);
      }
    });
  });

  group('ApiModeConfig A/B Testing', () {
    test('enableABTesting should return boolean', () {
      expect(config.enableABTesting, isA<bool>());
    });

    test('should have valid user percentage range', () {
      final percentage = config.bridgeCoreUserPercentage;

      // Should be between 0 and 1 (0% to 100%)
      expect(percentage, greaterThanOrEqualTo(0.0));
      expect(percentage, lessThanOrEqualTo(1.0));
    });
  });

  group('ApiModeConfig State Consistency', () {
    test('only one mode should be active at a time', () {
      // Either odooDirect OR bridgeCore, never both
      expect(
        config.useOdooDirect && config.useBridgeCore,
        isFalse,
      );

      // At least one should be active
      expect(
        config.useOdooDirect || config.useBridgeCore,
        isTrue,
      );
    });

    test('currentMode should match boolean flags', () {
      if (config.currentMode == ApiMode.odooDirect) {
        expect(config.useOdooDirect, isTrue);
        expect(config.useBridgeCore, isFalse);
      } else if (config.currentMode == ApiMode.bridgeCore) {
        expect(config.useOdooDirect, isFalse);
        expect(config.useBridgeCore, isTrue);
      }
    });
  });
}
