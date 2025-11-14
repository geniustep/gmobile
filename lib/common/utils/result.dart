// ════════════════════════════════════════════════════════════
// Result Type - للتعامل مع النجاح والفشل بشكل موحد
// ════════════════════════════════════════════════════════════

class Result<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;
  final bool isLoading;

  const Result._({
    this.data,
    this.error,
    required this.isSuccess,
    this.isLoading = false,
  });

  // ════════════════════════════════════════════════════════════
  // Constructors
  // ════════════════════════════════════════════════════════════

  factory Result.success(T data) {
    return Result._(
      data: data,
      isSuccess: true,
    );
  }

  factory Result.error(AppError error) {
    return Result._(
      error: error,
      isSuccess: false,
    );
  }

  factory Result.loading() {
    return Result._(
      isSuccess: false,
      isLoading: true,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Getters
  // ════════════════════════════════════════════════════════════

  bool get isError => !isSuccess && !isLoading;
  bool get hasData => data != null;

  // ════════════════════════════════════════════════════════════
  // Methods
  // ════════════════════════════════════════════════════════════

  /// استخدم when للتعامل مع جميع الحالات
  R when<R>({
    required R Function(T data) success,
    required R Function(AppError error) error,
    required R Function() loading,
  }) {
    if (isLoading) {
      return loading();
    } else if (isSuccess && data != null) {
      return success(data as T);
    } else {
      return error(this.error ?? AppError.unknown());
    }
  }

  /// استخدم map لتحويل البيانات
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess && data != null) {
      return Result.success(transform(data as T));
    } else if (isLoading) {
      return Result.loading();
    } else {
      return Result.error(error ?? AppError.unknown());
    }
  }

  @override
  String toString() {
    if (isLoading) {
      return 'Result.loading()';
    } else if (isSuccess) {
      return 'Result.success($data)';
    } else {
      return 'Result.error($error)';
    }
  }
}

// ════════════════════════════════════════════════════════════
// AppError - نموذج موحد للأخطاء
// ════════════════════════════════════════════════════════════

class AppError {
  final String message;
  final String? code;
  final ErrorType type;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    required this.type,
    this.originalError,
  });

  // ════════════════════════════════════════════════════════════
  // Factory Constructors
  // ════════════════════════════════════════════════════════════

  factory AppError.network(String message, [dynamic original]) {
    return AppError(
      message: message,
      type: ErrorType.network,
      originalError: original,
    );
  }

  factory AppError.server(String message, [String? code, dynamic original]) {
    return AppError(
      message: message,
      code: code,
      type: ErrorType.server,
      originalError: original,
    );
  }

  factory AppError.cache(String message, [dynamic original]) {
    return AppError(
      message: message,
      type: ErrorType.cache,
      originalError: original,
    );
  }

  factory AppError.validation(String message) {
    return AppError(
      message: message,
      type: ErrorType.validation,
    );
  }

  factory AppError.auth(String message) {
    return AppError(
      message: message,
      type: ErrorType.auth,
    );
  }

  factory AppError.unknown([String? message]) {
    return AppError(
      message: message ?? 'حدث خطأ غير متوقع',
      type: ErrorType.unknown,
    );
  }

  // ════════════════════════════════════════════════════════════
  // Helper Methods
  // ════════════════════════════════════════════════════════════

  bool get isNetworkError => type == ErrorType.network;
  bool get isServerError => type == ErrorType.server;
  bool get isAuthError => type == ErrorType.auth;

  @override
  String toString() => 'AppError($type): $message';
}

// ════════════════════════════════════════════════════════════
// ErrorType - أنواع الأخطاء
// ════════════════════════════════════════════════════════════

enum ErrorType {
  network,    // لا يوجد اتصال بالإنترنت
  server,     // خطأ من السيرفر
  cache,      // خطأ في القراءة من الـ Cache
  validation, // خطأ في التحقق من البيانات
  auth,       // خطأ في المصادقة
  unknown,    // خطأ غير معروف
}
