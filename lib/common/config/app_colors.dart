import 'package:flutter/material.dart';

/// نظام الألوان الموحد للتطبيق
class AppColors {
  AppColors._();

  // ========== الألوان الموجودة مسبقاً (محفوظة للتوافق) ==========
  static Color black = HexColor("#212121");
  static const homeBlack = Color(0xFF323643);
  static const subTitle = Color(0xFF707070);
  static const hintColor = Color(0xFFbabbbf);
  static const blue = Color(0xFF3277D8);
  static Color grey = HexColor("#757575");
  static Color lightGrey = HexColor("#9E9E9E");
  static Color greenColor = HexColor("#1BC500");
  static Color blueBgColor = HexColor("#2C5BDC");
  static Color textFieldBackgroundColor = HexColor("#FAFAFA");
  static Color backgroundColor = HexColor("#F5F5F5");
  static Color blueDotColor = HexColor("#2081FF");
  static Color greyDotColor = HexColor("#E0E0E0");
  static Color blueButtonColor = HexColor("#2081FF");
  static Color orange = HexColor("#F57C51");
  static Color dropDownArrowColor = HexColor("#424242");

  static Color homeProposalSentBg = HexColor("#FFF3DA");
  static Color homeCandidateLikeBg = HexColor("#DDEEFF");
  static Color blueTextColor = HexColor("#2C5BDC");
  static Color borderColor = HexColor("#EEEEEE");
  static Color borderColorSingleLine = HexColor("#E0E0E0");

  static Color iconColor = HexColor("#2E3A59");
  static Color progressBackColor = HexColor("#D5FCDA");
  static Color longTermBackColor = HexColor("#FFF3DA");
  static Color badgeColor = HexColor("#FF7C70");

  static Color statusAccept = HexColor("#189A75");
  static Color statusNotAccept = HexColor("#DB5251");
  static Color statusAcceptBg = HexColor("#D4FCD9");
  static Color statusNotAcceptBg = HexColor("#FFEEE2");

  static MaterialColor orangeThemeColor =
      const MaterialColor(0xFFF57C51, <int, Color>{
        50: Color(0xFFF57C51),
        100: Color(0xFFF57C51),
        200: Color(0xFFF57C51),
        300: Color(0xFFF57C51),
        400: Color(0xFFF57C51),
        500: Color(0xFFF57C51),
        600: Color(0xFFF57C51),
        700: Color(0xFFF57C51),
        800: Color(0xFFF57C51),
        900: Color(0xFFF57C51),
      });

  // ========== الألوان الجديدة للـ Sales Screen (نظام موحد) ==========

  // الألوان الأساسية
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFFDCE8FF);
  static const Color primaryDark = Color(0xFF1E40AF);

  // الخلفيات
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF1F5F9);

  // النصوص
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // الحدود والفواصل
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
}

class StatusColors {
  StatusColors._();

  // ========== الألوان الأساسية ==========// في ملف StatusColors.dart
  static const Color done = Color(0xFF059669); // أخضر
  static const Color doneBg = Color(0xFFD1FAE5); // أخضر فاتح

  // Draft (Devis - عرض سعر)
  static const Color draft = Color(0xFF3B82F6);
  static const Color draftBg = Color(0xFFEFF6FF);

  // Sent (Envoyé - مُرسل)
  static const Color sent = Color(0xFF8B5CF6);
  static const Color sentBg = Color(0xFFF5F3FF);

  // Sale (Bon de commande - أمر شراء)
  static const Color sale = Color(0xFF10B981);
  static const Color saleBg = Color(0xFFECFDF5);

  // Cancel (Annulé - ملغي)
  static const Color cancel = Color(0xFFEF4444);
  static const Color cancelBg = Color(0xFFFEF2F2);

  // Warning (تحذير)
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0xFFFEF3C7);

  // Info (معلومات)
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoBg = Color(0xFFE0F2FE);

  // ========== الدوال المساعدة ==========

  /// الحصول على ألوان الحالة (اللون + الخلفية)
  ///
  /// الاستخدام:
  /// ```dart
  /// final colors = StatusColors.getColors('draft');
  /// Color mainColor = colors['color'];  // #3B82F6
  /// Color bgColor = colors['bg'];       // #EFF6FF
  /// ```
  static Map<String, Color> getColors(String state) {
    switch (state.toLowerCase()) {
      case 'draft':
        return {'color': draft, 'bg': draftBg};
      case 'sent':
        return {'color': sent, 'bg': sentBg};
      case 'sale':
        return {'color': sale, 'bg': saleBg};
      case 'cancel':
        return {'color': cancel, 'bg': cancelBg};
      default:
        return {'color': info, 'bg': infoBg};
    }
  }

  // في ملف StatusColors، أضف هذه الدوال:
  static Color getPickingColor(String state) {
    switch (state) {
      case 'draft':
        return StatusColors.draft;
      case 'confirmed':
        return StatusColors.sent;
      case 'assigned':
        return StatusColors.sale;
      case 'done':
        return StatusColors.sale;
      case 'cancel':
        return StatusColors.cancel;
      default:
        return AppColors.textSecondary;
    }
  }

  /// الحصول على النص الفرنسي للحالة
  ///
  /// الاستخدام:
  /// ```dart
  /// String label = StatusColors.getLabel('draft');  // "Devis"
  /// ```
  static String getLabel(String state) {
    switch (state.toLowerCase()) {
      case 'draft':
        return 'Devis';
      case 'sent':
        return 'Envoyé';
      case 'sale':
        return 'Bon de commande';
      case 'cancel':
        return 'Annulé';
      default:
        return state.toUpperCase();
    }
  }

  /// الحصول على الأيقونة المناسبة للحالة
  ///
  /// الاستخدام:
  /// ```dart
  /// IconData icon = StatusColors.getIcon('draft');  // Icons.description_outlined
  /// ```
  static IconData getIcon(String state) {
    switch (state.toLowerCase()) {
      case 'draft':
        return Icons.description_outlined; // 📄
      case 'sent':
        return Icons.send_outlined; // ✉️
      case 'sale':
        return Icons.shopping_cart_outlined; // 🛒
      case 'cancel':
        return Icons.cancel_outlined; // ❌
      default:
        return Icons.info_outline; // ℹ️
    }
  }

  /// الحصول على جميع معلومات الحالة دفعة واحدة
  ///
  /// الاستخدام:
  /// ```dart
  /// final info = StatusColors.getFullInfo('draft');
  /// print(info['label']);    // "Devis"
  /// print(info['color']);    // Color(0xFF3B82F6)
  /// print(info['bg']);       // Color(0xFFEFF6FF)
  /// print(info['icon']);     // Icons.description_outlined
  /// ```
  static Map<String, dynamic> getFullInfo(String state) {
    final colors = getColors(state);
    return {
      'label': getLabel(state),
      'color': colors['color'],
      'bg': colors['bg'],
      'icon': getIcon(state),
      'state': state.toLowerCase(),
    };
  }

  /// التحقق من صحة الحالة
  ///
  /// الاستخدام:
  /// ```dart
  /// bool isValid = StatusColors.isValidState('draft');  // true
  /// bool isValid = StatusColors.isValidState('unknown');  // false
  /// ```
  static bool isValidState(String state) {
    return ['draft', 'sent', 'sale', 'cancel'].contains(state.toLowerCase());
  }

  /// الحصول على قائمة جميع الحالات المتاحة
  ///
  /// الاستخدام:
  /// ```dart
  /// List<String> states = StatusColors.getAllStates();
  /// // ['draft', 'sent', 'sale', 'cancel']
  /// ```
  static List<String> getAllStates() {
    return ['draft', 'sent', 'sale', 'cancel'];
  }

  /// الحصول على قائمة الحالات بالفرنسية
  ///
  /// الاستخدام:
  /// ```dart
  /// List<String> labels = StatusColors.getAllLabels();
  /// // ['Devis', 'Envoyé', 'Bon de commande', 'Annulé']
  /// ```
  static List<String> getAllLabels() {
    return ['Devis', 'Envoyé', 'Bon de commande', 'Annulé'];
  }

  /// تحويل من النص الفرنسي إلى الحالة الأصلية
  ///
  /// الاستخدام:
  /// ```dart
  /// String state = StatusColors.labelToState('Devis');  // 'draft'
  /// ```
  static String? labelToState(String label) {
    switch (label.toLowerCase()) {
      case 'devis':
        return 'draft';
      case 'envoyé':
        return 'sent';
      case 'bon de commande':
        return 'sale';
      case 'annulé':
        return 'cancel';
      default:
        return null;
    }
  }
}

/// الألوان الوظيفية
class FunctionalColors {
  FunctionalColors._();

  // الأزرار
  static const Color buttonPrimary = Color(0xFF2563EB);
  static const Color buttonPrimaryHover = Color(0xFF1E40AF);
  static const Color buttonSecondary = Color(0xFFF1F5F9);
  static const Color buttonDanger = Color(0xFFEF4444);

  // الأيقونات
  static const Color iconPrimary = Color(0xFF64748B);
  static const Color iconSecondary = Color(0xFF94A3B8);
  static const Color iconActive = Color(0xFF2563EB);

  // التأثيرات
  static const Color shadow = Color(0x0A000000);
  static const Color overlay = Color(0x1A000000);
  static const Color ripple = Color(0x1F2563EB);
}

/// فئة مساعدة لتحويل HexColor
class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
