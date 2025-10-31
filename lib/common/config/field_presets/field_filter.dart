// lib/config/field_presets/field_filter.dart

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FieldFilter {
  bool excludeMessage;
  bool excludeAvatar;
  bool excludeMetadata;
  bool excludeComputed;
  bool excludeRelated;
  bool excludeTranslations;

  List<String> customExcludePatterns;
  List<String> customIncludePatterns;

  FieldFilter({
    this.excludeMessage = true,
    this.excludeAvatar = true,
    this.excludeMetadata = true,
    this.excludeComputed = false,
    this.excludeRelated = false,
    this.excludeTranslations = false,
    this.customExcludePatterns = const [],
    this.customIncludePatterns = const [],
  });

  static FieldFilter? _instance;

  static FieldFilter get instance {
    _instance ??= FieldFilter();
    return _instance!;
  }

  static void setInstance(FieldFilter filter) {
    _instance = filter;
  }

  List<String> apply(List<String> fields) {
    return fields.where((field) {
      if (_matchesPatterns(field, customIncludePatterns)) {
        return true;
      }

      if (excludeMessage && _isMessageField(field)) {
        return false;
      }

      if (excludeAvatar && _isAvatarField(field)) {
        return false;
      }

      if (excludeMetadata && _isMetadataField(field)) {
        return false;
      }

      if (excludeComputed && _isComputedField(field)) {
        return false;
      }

      if (excludeRelated && _isRelatedField(field)) {
        return false;
      }

      if (excludeTranslations && _isTranslationField(field)) {
        return false;
      }

      if (_matchesPatterns(field, customExcludePatterns)) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _isMessageField(String field) {
    return field.startsWith('message_') ||
        field == 'message_ids' ||
        field == 'activity_ids' ||
        field == 'message_follower_ids' ||
        field == 'message_attachment_count';
  }

  bool _isAvatarField(String field) {
    final patterns = [
      'image',
      'avatar',
      'picture',
      'photo',
      'image_1920',
      'image_1024',
      'image_512',
      'image_256',
      'image_128',
      'image_64',
    ];

    return patterns.any((pattern) => field.contains(pattern));
  }

  bool _isMetadataField(String field) {
    final metadataFields = [
      '__last_update',
      'write_uid',
      'write_date',
      'create_uid',
      'create_date',
      'display_name',
    ];

    return metadataFields.contains(field);
  }

  bool _isComputedField(String field) {
    return field.endsWith('_count') || field.startsWith('compute_');
  }

  bool _isRelatedField(String field) {
    return field.contains('_related_');
  }

  bool _isTranslationField(String field) {
    return field.endsWith('_translated') || field.contains('_lang_');
  }

  bool _matchesPatterns(String field, List<String> patterns) {
    for (final pattern in patterns) {
      if (_matchPattern(field, pattern)) {
        return true;
      }
    }
    return false;
  }

  bool _matchPattern(String field, String pattern) {
    final regexPattern = pattern.replaceAll('*', '.*').replaceAll('?', '.');

    try {
      final regex = RegExp('^$regexPattern\$');
      return regex.hasMatch(field);
    } catch (e) {
      return false;
    }
  }

  void addExcludePattern(String pattern) {
    if (!customExcludePatterns.contains(pattern)) {
      customExcludePatterns = [...customExcludePatterns, pattern];
    }
  }

  void removeExcludePattern(String pattern) {
    customExcludePatterns = customExcludePatterns
        .where((p) => p != pattern)
        .toList();
  }

  void addIncludePattern(String pattern) {
    if (!customIncludePatterns.contains(pattern)) {
      customIncludePatterns = [...customIncludePatterns, pattern];
    }
  }

  void removeIncludePattern(String pattern) {
    customIncludePatterns = customIncludePatterns
        .where((p) => p != pattern)
        .toList();
  }

  void clearPatterns() {
    customExcludePatterns = [];
    customIncludePatterns = [];
  }

  FieldFilter copyWith({
    bool? excludeMessage,
    bool? excludeAvatar,
    bool? excludeMetadata,
    bool? excludeComputed,
    bool? excludeRelated,
    bool? excludeTranslations,
    List<String>? customExcludePatterns,
    List<String>? customIncludePatterns,
  }) {
    return FieldFilter(
      excludeMessage: excludeMessage ?? this.excludeMessage,
      excludeAvatar: excludeAvatar ?? this.excludeAvatar,
      excludeMetadata: excludeMetadata ?? this.excludeMetadata,
      excludeComputed: excludeComputed ?? this.excludeComputed,
      excludeRelated: excludeRelated ?? this.excludeRelated,
      excludeTranslations: excludeTranslations ?? this.excludeTranslations,
      customExcludePatterns:
          customExcludePatterns ?? this.customExcludePatterns,
      customIncludePatterns:
          customIncludePatterns ?? this.customIncludePatterns,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'excludeMessage': excludeMessage,
      'excludeAvatar': excludeAvatar,
      'excludeMetadata': excludeMetadata,
      'excludeComputed': excludeComputed,
      'excludeRelated': excludeRelated,
      'excludeTranslations': excludeTranslations,
      'customExcludePatterns': customExcludePatterns,
      'customIncludePatterns': customIncludePatterns,
    };
  }

  factory FieldFilter.fromJson(Map<String, dynamic> json) {
    return FieldFilter(
      excludeMessage: json['excludeMessage'] ?? true,
      excludeAvatar: json['excludeAvatar'] ?? true,
      excludeMetadata: json['excludeMetadata'] ?? true,
      excludeComputed: json['excludeComputed'] ?? false,
      excludeRelated: json['excludeRelated'] ?? false,
      excludeTranslations: json['excludeTranslations'] ?? false,
      customExcludePatterns: List<String>.from(
        json['customExcludePatterns'] ?? [],
      ),
      customIncludePatterns: List<String>.from(
        json['customIncludePatterns'] ?? [],
      ),
    );
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('field_filter', jsonEncode(toJson()));
  }

  static Future<FieldFilter> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('field_filter');

    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        return FieldFilter.fromJson(json);
      } catch (e) {
        return FieldFilter();
      }
    }

    return FieldFilter();
  }

  void reset() {
    excludeMessage = true;
    excludeAvatar = true;
    excludeMetadata = true;
    excludeComputed = false;
    excludeRelated = false;
    excludeTranslations = false;
    customExcludePatterns = [];
    customIncludePatterns = [];
  }

  bool get hasCustomPatterns {
    return customExcludePatterns.isNotEmpty || customIncludePatterns.isNotEmpty;
  }

  int get activeFiltersCount {
    int count = 0;
    if (excludeMessage) count++;
    if (excludeAvatar) count++;
    if (excludeMetadata) count++;
    if (excludeComputed) count++;
    if (excludeRelated) count++;
    if (excludeTranslations) count++;
    count += customExcludePatterns.length;
    return count;
  }

  @override
  String toString() {
    return 'FieldFilter(excludeMessage: $excludeMessage, excludeAvatar: $excludeAvatar, '
        'excludeMetadata: $excludeMetadata, excludeComputed: $excludeComputed, '
        'excludeRelated: $excludeRelated, excludeTranslations: $excludeTranslations, '
        'customExcludePatterns: $customExcludePatterns, customIncludePatterns: $customIncludePatterns)';
  }
}
