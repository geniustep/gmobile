/// Form validators with Arabic error messages
/// Provides comprehensive validation for all form fields
class FormValidators {
  /// Validate required field
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'الرجاء إدخال $fieldName'
          : 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// Validate email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'الرجاء إدخال بريد إلكتروني صحيح';
    }

    return null;
  }

  /// Validate phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الهاتف';
    }

    // Remove spaces and special characters
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleanedValue.length < 10) {
      return 'رقم الهاتف يجب أن يكون 10 أرقام على الأقل';
    }

    if (!RegExp(r'^[0-9+]+$').hasMatch(cleanedValue)) {
      return 'رقم الهاتف غير صحيح';
    }

    return null;
  }

  /// Validate password
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    if (value.length < minLength) {
      return 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'الرجاء تأكيد كلمة المرور';
    }

    if (value != password) {
      return 'كلمة المرور غير متطابقة';
    }

    return null;
  }

  /// Validate number
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'الرجاء إدخال $fieldName'
          : 'الرجاء إدخال رقم';
    }

    if (double.tryParse(value) == null) {
      return 'الرجاء إدخال رقم صحيح';
    }

    return null;
  }

  /// Validate positive number
  static String? positiveNumber(String? value, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final numValue = double.parse(value!);
    if (numValue <= 0) {
      return 'الرقم يجب أن يكون أكبر من صفر';
    }

    return null;
  }

  /// Validate amount
  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال المبلغ';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'المبلغ غير صحيح';
    }

    if (amount < 0) {
      return 'المبلغ لا يمكن أن يكون سالباً';
    }

    if (amount == 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }

    return null;
  }

  /// Validate minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return fieldName != null
          ? 'الرجاء إدخال $fieldName'
          : 'هذا الحقل مطلوب';
    }

    if (value.length < min) {
      return fieldName != null
          ? '$fieldName يجب أن يكون $min أحرف على الأقل'
          : 'يجب إدخال $min أحرف على الأقل';
    }

    return null;
  }

  /// Validate maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > max) {
      return fieldName != null
          ? '$fieldName يجب أن لا يتجاوز $max حرف'
          : 'لا يجب أن يتجاوز $max حرف';
    }

    return null;
  }

  /// Validate range
  static String? range(String? value, double min, double max, {String? fieldName}) {
    final numberError = number(value, fieldName: fieldName);
    if (numberError != null) return numberError;

    final numValue = double.parse(value!);
    if (numValue < min || numValue > max) {
      return fieldName != null
          ? '$fieldName يجب أن يكون بين $min و $max'
          : 'القيمة يجب أن تكون بين $min و $max';
    }

    return null;
  }

  /// Validate date
  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء اختيار التاريخ';
    }

    try {
      DateTime.parse(value);
      return null;
    } catch (e) {
      return 'التاريخ غير صحيح';
    }
  }

  /// Validate future date
  static String? futureDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;

    final selectedDate = DateTime.parse(value!);
    final now = DateTime.now();

    if (selectedDate.isBefore(DateTime(now.year, now.month, now.day))) {
      return 'التاريخ يجب أن يكون في المستقبل';
    }

    return null;
  }

  /// Validate past date
  static String? pastDate(String? value) {
    final dateError = date(value);
    if (dateError != null) return dateError;

    final selectedDate = DateTime.parse(value!);
    final now = DateTime.now();

    if (selectedDate.isAfter(DateTime(now.year, now.month, now.day))) {
      return 'التاريخ يجب أن يكون في الماضي';
    }

    return null;
  }

  /// Validate URL
  static String? url(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الرابط';
    }

    final urlRegex = RegExp(
      r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    );

    if (!urlRegex.hasMatch(value.trim())) {
      return 'الرابط غير صحيح';
    }

    return null;
  }

  /// Validate dropdown selection
  static String? dropdown(dynamic value, {String? fieldName}) {
    if (value == null) {
      return fieldName != null
          ? 'الرجاء اختيار $fieldName'
          : 'الرجاء الاختيار من القائمة';
    }
    return null;
  }

  /// Validate Arabic text
  static String? arabicText(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'الرجاء إدخال $fieldName'
          : 'هذا الحقل مطلوب';
    }

    if (!RegExp(r'[\u0600-\u06FF]').hasMatch(value)) {
      return 'الرجاء إدخال نص عربي';
    }

    return null;
  }

  /// Validate English text
  static String? englishText(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'Please enter $fieldName'
          : 'This field is required';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Please enter English text only';
    }

    return null;
  }

  /// Validate alphanumeric
  static String? alphanumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return fieldName != null
          ? 'الرجاء إدخال $fieldName'
          : 'هذا الحقل مطلوب';
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
      return 'يجب أن يحتوي على أحرف وأرقام فقط';
    }

    return null;
  }

  /// Compose multiple validators
  static String? Function(String?) compose(List<String? Function(String?)> validators) {
    return (value) {
      for (var validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Validate tax number (example for specific format)
  static String? taxNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال الرقم الضريبي';
    }

    // Example: Tax number should be 15 digits
    final cleanedValue = value.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanedValue.length != 15) {
      return 'الرقم الضريبي يجب أن يكون 15 رقماً';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(cleanedValue)) {
      return 'الرقم الضريبي غير صحيح';
    }

    return null;
  }

  /// Validate IBAN
  static String? iban(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الرجاء إدخال رقم الآيبان';
    }

    final cleanedValue = value.replaceAll(RegExp(r'[\s]'), '').toUpperCase();

    // IBAN length varies by country, typically 15-34 characters
    if (cleanedValue.length < 15 || cleanedValue.length > 34) {
      return 'رقم الآيبان غير صحيح';
    }

    if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z0-9]+$').hasMatch(cleanedValue)) {
      return 'صيغة رقم الآيبان غير صحيحة';
    }

    return null;
  }
}
