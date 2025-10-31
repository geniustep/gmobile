import 'package:flutter/material.dart';

class AppTheme {
  // ------------------------------------------------
  // 🎨 1. الألوان الأساسية
  // ------------------------------------------------
  static const Color primaryColor = Color(0xFF0057FF); // الأزرق من شعارك
  static const Color secondaryColor = Color(0xFF0A1931); // أزرق غامق أنيق
  static const Color accentColor = Color(0xFFFFA726); // برتقالي للطاقة
  static const Color backgroundColor = Color(0xFFF9FAFB); // رمادي أبيض للخلفية
  static const Color surfaceColor = Color(0xFFFFFFFF); // أبيض للكروت والعناصر

  // ------------------------------------------------
  // 🖋️ 2. ألوان النصوص
  // ------------------------------------------------
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textInverse = Colors.white;

  // ------------------------------------------------
  // 🟢🔴 3. ألوان الحالة
  // ------------------------------------------------
  static const Color success = Color(0xFF43A047);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF0288D1);

  // ------------------------------------------------
  // 🧩 4. ظلال وألوان حدود
  // ------------------------------------------------
  static Color shadow = Colors.black.withOpacity(0.05);
  static Color divider = Colors.grey.shade300;
  static const Color cardBorder = Color(0xFFE0E0E0);

  // ------------------------------------------------
  // 🧱 5. ThemeData - الوضع الفاتح
  // ------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardColor: surfaceColor,
      dividerColor: divider,
      shadowColor: shadow,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: textSecondary, fontSize: 12),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
        labelLarge: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: error,
      ),
    );
  }

  // ------------------------------------------------
  // 🌙 6. ThemeData - الوضع الداكن
  // ------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: const Color(0xFF0D1117),
      cardColor: const Color(0xFF161B22),
      dividerColor: Colors.grey.shade800,
      shadowColor: Colors.black.withOpacity(0.4),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0D47A1),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white70, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        bodySmall: TextStyle(color: Colors.white54, fontSize: 12),
        titleLarge: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        surface: Color(0xFF161B22),
        error: error,
      ),
    );
  }
}
