// lib/config/field_presets/presets_manager.dart

import 'package:gsloution_mobile/common/config/import.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FieldPreset { minimal, basic, clean, smart, full }

class FieldPresetsManager {
  static final Map<String, Map<FieldPreset, List<String>?>> _presets = {};

  static void initialize() {
    _presets['res.partner'] = {
      FieldPreset.minimal: ['id', 'display_name'],
      FieldPreset.basic: ['id', 'name', 'display_name', 'email', 'phone'],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'email',
        'phone',
        'mobile',
        'street',
        'city',
        'zip',
        'country_id',
        'image_1920',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };

    _presets['sale.order'] = {
      FieldPreset.minimal: ['id', 'name', 'display_name'],
      FieldPreset.basic: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'date_order',
        'amount_total',
        'state',
      ],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'date_order',
        'amount_total',
        'amount_untaxed',
        'state',
        'user_id',
        'team_id',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };

    _presets['product.product'] = {
      FieldPreset.minimal: ['id', 'display_name'],
      FieldPreset.basic: [
        'id',
        'name',
        'display_name',
        'default_code',
        'list_price',
      ],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'default_code',
        'list_price',
        'standard_price',
        'qty_available',
        'categ_id',
        'uom_id',
        'image_128',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };

    _presets['account.move'] = {
      FieldPreset.minimal: ['id', 'name', 'display_name'],
      FieldPreset.basic: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'invoice_date',
        'amount_total',
        'state',
      ],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'invoice_date',
        'amount_total',
        'amount_untaxed',
        'amount_tax',
        'state',
        'payment_state',
        'invoice_payment_term_id',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };

    _presets['stock.picking'] = {
      FieldPreset.minimal: ['id', 'name', 'display_name'],
      FieldPreset.basic: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'scheduled_date',
        'state',
        'picking_type_id',
      ],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'scheduled_date',
        'state',
        'picking_type_id',
        'location_id',
        'location_dest_id',
        'move_ids_without_package',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };

    _presets['account.payment'] = {
      FieldPreset.minimal: ['id', 'name', 'display_name'],
      FieldPreset.basic: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'amount',
        'date',
        'state',
      ],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'amount',
        'date',
        'state',
        'payment_type',
        'partner_type',
        'journal_id',
        'payment_method_id',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };

    _presets['crm.lead'] = {
      FieldPreset.minimal: ['id', 'name', 'display_name'],
      FieldPreset.basic: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'expected_revenue',
        'probability',
        'stage_id',
      ],
      FieldPreset.clean: [
        'id',
        'name',
        'display_name',
        'partner_id',
        'expected_revenue',
        'probability',
        'stage_id',
        'user_id',
        'team_id',
        'date_deadline',
        'priority',
      ],
      FieldPreset.smart: null,
      FieldPreset.full: null,
    };
  }

  static List<String>? getFields(String model, FieldPreset preset) {
    if (!_presets.containsKey(model)) {
      return null;
    }

    if (preset == FieldPreset.smart) {
      return _computeSmartFields(model);
    }

    return _presets[model]![preset];
  }

  static void setFields(
    String model,
    FieldPreset preset,
    List<String>? fields,
  ) {
    if (!_presets.containsKey(model)) {
      _presets[model] = {};
    }
    _presets[model]![preset] = fields;
  }

  static void addModel(
    String model, {
    Map<FieldPreset, List<String>?>? presets,
  }) {
    if (_presets.containsKey(model)) return;

    _presets[model] =
        presets ??
        {
          FieldPreset.minimal: ['id', 'display_name'],
          FieldPreset.basic: ['id', 'name', 'display_name'],
          FieldPreset.clean: ['id', 'name', 'display_name'],
          FieldPreset.smart: null,
          FieldPreset.full: null,
        };
  }

  static void removeModel(String model) {
    _presets.remove(model);
  }

  static List<String> getModels() {
    return _presets.keys.toList();
  }

  static bool hasModel(String model) {
    return _presets.containsKey(model);
  }

  static void addField(String model, FieldPreset preset, String field) {
    if (!_presets.containsKey(model)) return;
    if (_presets[model]![preset] == null) return;

    if (!_presets[model]![preset]!.contains(field)) {
      _presets[model]![preset]!.add(field);
    }
  }

  static void removeField(String model, FieldPreset preset, String field) {
    if (!_presets.containsKey(model)) return;
    if (_presets[model]![preset] == null) return;

    _presets[model]![preset]!.remove(field);
  }

  static void addFields(String model, FieldPreset preset, List<String> fields) {
    for (final field in fields) {
      addField(model, preset, field);
    }
  }

  static void removeFields(
    String model,
    FieldPreset preset,
    List<String> fields,
  ) {
    for (final field in fields) {
      removeField(model, preset, field);
    }
  }

  static List<String>? _computeSmartFields(String model) {
    final basicFields = _presets[model]?[FieldPreset.basic];
    if (basicFields == null) return null;

    return List<String>.from(basicFields);
  }

  static bool hasField(String model, FieldPreset preset, String field) {
    final fields = getFields(model, preset);
    if (fields == null) return true;
    return fields.contains(field);
  }

  static Map<String, dynamic> getPresetInfo(String model, FieldPreset preset) {
    final fields = getFields(model, preset);

    return {
      'model': model,
      'preset': preset.toString().split('.').last,
      'field_count': fields?.length ?? 'all',
      'is_full': fields == null,
      'custom_count': fields?.where((f) => f.startsWith('x_')).length ?? 0,
      'fields': fields,
    };
  }

  static Map<String, dynamic> exportToJson() {
    final result = <String, dynamic>{};

    _presets.forEach((model, presets) {
      result[model] = {};
      presets.forEach((preset, fields) {
        result[model][preset.toString().split('.').last] = fields;
      });
    });

    return result;
  }

  static void importFromJson(Map<String, dynamic> json) {
    _presets.clear();

    json.forEach((model, presetsMap) {
      _presets[model] = {};

      (presetsMap as Map<String, dynamic>).forEach((presetName, fields) {
        final preset = FieldPreset.values.firstWhere(
          (p) => p.toString().split('.').last == presetName,
        );

        _presets[model]![preset] = fields == null
            ? null
            : List<String>.from(fields);
      });
    });
  }

  static Future<void> saveToStorage() async {
    final json = exportToJson();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('field_presets', jsonEncode(json));
  }

  static Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('field_presets');

    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        importFromJson(json);
      } catch (e) {
        initialize();
      }
    } else {
      initialize();
    }
  }

  static void resetToDefaults() {
    _presets.clear();
    initialize();
  }

  static void clonePreset(
    String model,
    FieldPreset source,
    FieldPreset destination,
  ) {
    final fields = getFields(model, source);
    if (fields != null) {
      setFields(model, destination, List<String>.from(fields));
    }
  }

  static List<String> mergePresets(String model, List<FieldPreset> presets) {
    final allFields = <String>{};

    for (final preset in presets) {
      final fields = getFields(model, preset);
      if (fields != null) {
        allFields.addAll(fields);
      }
    }

    return allFields.toList();
  }

  static List<String> getDifference(
    String model,
    FieldPreset preset1,
    FieldPreset preset2,
  ) {
    final fields1 = getFields(model, preset1) ?? [];
    final fields2 = getFields(model, preset2) ?? [];

    return fields1.where((f) => !fields2.contains(f)).toList();
  }

  static List<String> getCommon(
    String model,
    FieldPreset preset1,
    FieldPreset preset2,
  ) {
    final fields1 = getFields(model, preset1) ?? [];
    final fields2 = getFields(model, preset2) ?? [];

    return fields1.where((f) => fields2.contains(f)).toList();
  }

  static void clearAll() {
    _presets.clear();
  }

  static int getModelsCount() {
    return _presets.length;
  }

  static int getFieldsCount(String model, FieldPreset preset) {
    final fields = getFields(model, preset);
    return fields?.length ?? 0;
  }
}
