enum FallbackLevel {
  predefined, // المستوى 1: اللائحة المعدة مسبقاً
  cleaned, // المستوى 2: اللائحة بعد حذف الحقول المفقودة
  required, // المستوى 3: الحقول المطلوبة فقط (required=true)
  minimal, // المستوى 4: id + name
  ultimate, // المستوى 5: id فقط
}

class FieldFallbackStrategy {
  // المستوى الحالي
  FallbackLevel currentLevel = FallbackLevel.predefined;

  // Counter للمحاولات
  int retryCount = 0;
  final int maxRetries = 10;

  // Cache للحقول المفقودة
  final Map<String, Set<String>> _invalidFieldsCache = {};

  // اللائحة الأصلية
  List<String>? _originalFields;

  // اللائحة الحالية
  List<String>? _currentFields;

  // Model name
  final String model;

  // Callback لاستدعاء fields_get
  final Future<Map<String, dynamic>> Function(String model) onFieldsGet;

  FieldFallbackStrategy({required this.model, required this.onFieldsGet});

  // ════════════════════════════════════════════════════════════
  // تهيئة اللائحة الأولية
  // ════════════════════════════════════════════════════════════

  void initialize(List<String> fields) {
    _originalFields = List.from(fields);
    _currentFields = _cleanFields(fields);
    currentLevel = FallbackLevel.predefined;
    retryCount = 0;

    print('📋 Initialized with ${_currentFields?.length ?? 0} fields');
    print('   Original: ${_originalFields?.length ?? 0}');
    if (_originalFields!.length != _currentFields!.length) {
      print(
        '   Pre-cleaned: ${_originalFields!.length - _currentFields!.length} known invalid fields',
      );
    }
  }

  // ════════════════════════════════════════════════════════════
  // الحصول على الحقول الحالية
  // ════════════════════════════════════════════════════════════

  List<String>? getCurrentFields() {
    return _currentFields;
  }

  // ════════════════════════════════════════════════════════════
  // معالجة خطأ Invalid Field
  // ════════════════════════════════════════════════════════════

  Future<List<String>?> handleInvalidField(String errorMessage) async {
    retryCount++;

    if (retryCount > maxRetries) {
      throw Exception('Max retries ($maxRetries) exceeded');
    }

    // استخراج اسم الحقل المفقود
    final invalidField = _extractInvalidField(errorMessage);

    if (invalidField == null) {
      print('⚠️  Could not extract invalid field from error');
      return await _moveToNextLevel();
    }

    print('❌ Invalid field detected: $invalidField (Retry #$retryCount)');

    // حفظ في Cache
    _cacheInvalidField(invalidField);

    // حذف من اللائحة الحالية
    if (_currentFields != null && _currentFields!.contains(invalidField)) {
      _currentFields = List.from(_currentFields!)..remove(invalidField);
      currentLevel = FallbackLevel.cleaned;

      print('🔄 Removed field, ${_currentFields!.length} fields remaining');

      // تحقق: هل اللائحة فارغة؟
      if (_currentFields!.isEmpty) {
        print('⚠️  All predefined fields exhausted');
        return await _moveToNextLevel();
      }

      return _currentFields;
    }

    // الحقل ليس في اللائحة الحالية، انتقل للمستوى التالي
    return await _moveToNextLevel();
  }

  // ════════════════════════════════════════════════════════════
  // الانتقال للمستوى التالي
  // ════════════════════════════════════════════════════════════

  Future<List<String>?> _moveToNextLevel() async {
    switch (currentLevel) {
      case FallbackLevel.predefined:
      case FallbackLevel.cleaned:
        // الانتقال إلى Required Fields
        currentLevel = FallbackLevel.required;
        return await _getRequiredFields();

      case FallbackLevel.required:
        // الانتقال إلى Minimal
        currentLevel = FallbackLevel.minimal;
        return _getMinimalFields();

      case FallbackLevel.minimal:
        // الانتقال إلى Ultimate
        currentLevel = FallbackLevel.ultimate;
        return _getUltimateFields();

      case FallbackLevel.ultimate:
        throw Exception('All fallback levels exhausted - no fields available');
    }
  }

  // ════════════════════════════════════════════════════════════
  // Level 3: Required Fields
  // ════════════════════════════════════════════════════════════

  Future<List<String>> _getRequiredFields() async {
    print('🔍 Level 3: Fetching required fields from server...');

    try {
      // استدعاء fields_get
      final fieldsInfo = await onFieldsGet(model);

      // فلترة: required == true
      final requiredFields = <String>[];

      fieldsInfo.forEach((fieldName, fieldInfo) {
        if (fieldInfo is Map && fieldInfo['required'] == true) {
          requiredFields.add(fieldName);
        }
      });

      // تنظيف من الحقول المعروف أنها مفقودة
      final cleanedRequired = _cleanFields(requiredFields);

      if (cleanedRequired.isEmpty) {
        print('⚠️  No required fields available, moving to minimal');
        currentLevel = FallbackLevel.minimal;
        return _getMinimalFields();
      }

      print('✅ Found ${cleanedRequired.length} required fields');
      _currentFields = cleanedRequired;
      return cleanedRequired;
    } catch (e) {
      print('❌ Failed to get required fields: $e');
      print('🔄 Falling back to minimal fields');
      currentLevel = FallbackLevel.minimal;
      return _getMinimalFields();
    }
  }

  // ════════════════════════════════════════════════════════════
  // Level 4: Minimal Fields
  // ════════════════════════════════════════════════════════════

  List<String> _getMinimalFields() {
    print('🔍 Level 4: Using minimal fields [id, name]');
    _currentFields = ['id', 'name'];
    return _currentFields!;
  }

  // ════════════════════════════════════════════════════════════
  // Level 5: Ultimate Fallback
  // ════════════════════════════════════════════════════════════

  List<String> _getUltimateFields() {
    print('🔍 Level 5: Using ultimate fallback [id only]');
    _currentFields = ['id'];
    return _currentFields!;
  }

  // ════════════════════════════════════════════════════════════
  // استخراج الحقل المفقود من رسالة الخطأ
  // ════════════════════════════════════════════════════════════

  String? _extractInvalidField(String errorMessage) {
    final patterns = [
      RegExp(r"Invalid field '([^']+)'"),
      RegExp(r'Invalid field "([^"]+)"'),
      RegExp(r'field (\w+) does not exist'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(errorMessage);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  // ════════════════════════════════════════════════════════════
  // حفظ الحقل المفقود في الـ cache
  // ════════════════════════════════════════════════════════════

  void _cacheInvalidField(String field) {
    _invalidFieldsCache.putIfAbsent(model, () => {});
    _invalidFieldsCache[model]!.add(field);
    print('💾 Cached invalid field: $model.$field');
  }

  // ════════════════════════════════════════════════════════════
  // تنظيف الحقول من المعروف أنها مفقودة
  // ════════════════════════════════════════════════════════════

  List<String> _cleanFields(List<String> fields) {
    if (!_invalidFieldsCache.containsKey(model)) {
      return fields;
    }

    final invalidFields = _invalidFieldsCache[model]!;
    return fields.where((f) => !invalidFields.contains(f)).toList();
  }

  // ════════════════════════════════════════════════════════════
  // الحصول على معلومات الحالة
  // ════════════════════════════════════════════════════════════

  Map<String, dynamic> getStatus() {
    return {
      'model': model,
      'current_level': currentLevel.toString().split('.').last,
      'retry_count': retryCount,
      'current_fields': _currentFields,
      'current_fields_count': _currentFields?.length ?? 0,
      'original_fields_count': _originalFields?.length ?? 0,
      'cached_invalid_fields': _invalidFieldsCache[model]?.toList() ?? [],
    };
  }

  // ════════════════════════════════════════════════════════════
  // Reset
  // ════════════════════════════════════════════════════════════

  void reset() {
    currentLevel = FallbackLevel.predefined;
    retryCount = 0;
    _currentFields = _originalFields != null
        ? _cleanFields(List.from(_originalFields!))
        : null;
  }

  // ════════════════════════════════════════════════════════════
  // الحصول على Cache الكامل (static)
  // ════════════════════════════════════════════════════════════

  static final Map<String, Set<String>> _globalCache = {};

  static Map<String, List<String>> getGlobalInvalidFieldsCache() {
    return _globalCache.map((k, v) => MapEntry(k, v.toList()));
  }

  static void clearGlobalCache() {
    _globalCache.clear();
    print('🧹 Global invalid fields cache cleared');
  }

  static void loadGlobalCache(Map<String, Set<String>> cache) {
    _globalCache.clear();
    _globalCache.addAll(cache);
  }
}
