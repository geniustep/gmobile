# دليل الاستخدام السريع - BridgeCore Integration

## 🚀 البدء السريع

### 1. الوصول لإعدادات المطورين

```dart
import 'package:gsloution_mobile/src/presentation/screens/settings/developer_settings_page.dart';

// في أي مكان في التطبيق
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DeveloperSettingsPage(),
  ),
);
```

### 2. التبديل بين النظامين

#### من الكود:
```dart
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';

// التبديل إلى BridgeCore
await ApiClientFactory.switchMode(ApiMode.bridgeCore);

// التبديل إلى Odoo Direct
await ApiClientFactory.switchMode(ApiMode.odooDirect);
```

#### من الواجهة:
1. افتح Developer Settings Page
2. اختر الوضع المطلوب من Radio Buttons
3. التبديل فوري!

---

## 📊 استخدام Performance Tracker

### تتبع عملية:

```dart
import 'package:gsloution_mobile/common/api_factory/bridgecore/analytics/performance_tracker.dart';

// Method 1: تتبع async function
final partners = await PerformanceTracker.track(
  operation: 'fetch_partners',
  function: () => partnerService.getPartners(),
);

// Method 2: تتبع يدوي
final stopwatch = Stopwatch()..start();
try {
  final result = await someOperation();
  stopwatch.stop();
  // تم النجاح
} catch (e) {
  stopwatch.stop();
  // فشلت العملية
}
```

### الحصول على إحصائيات:

```dart
// إحصائيات عملية محددة
final stats = PerformanceTracker.instance.getOperationStats('fetch_partners');
print('Average: ${stats['avgMs']}ms');
print('Success Rate: ${(stats['successRate'] * 100).toStringAsFixed(1)}%');

// مقارنة بين النظامين
final comparison = PerformanceTracker.instance.comparePerformance();
print('Improvement: ${comparison['improvement']['speedImprovement']}');

// تقرير كامل
PerformanceTracker.instance.printReport();

// تصدير JSON
final json = PerformanceTracker.instance.exportToJson();
```

---

## 🔄 استخدام ApiClientFactory

### الاستخدام الأساسي:

```dart
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';

// الحصول على Client الحالي
final client = ApiClientFactory.instance;

// استخدام العمليات
await client.searchRead(
  model: 'res.partner',
  domain: [['customer', '=', true]],
  fields: ['name', 'email', 'phone'],
  limit: 50,
  onResponse: (partners) {
    print('Fetched ${partners.length} partners');
  },
  onError: (error, data) {
    print('Error: $error');
  },
);
```

### جميع العمليات المتاحة:

```dart
// البحث والقراءة
await client.searchRead(model: 'product.product', ...);
await client.read(model: 'sale.order', ids: [1, 2, 3], ...);

// الإنشاء والتحديث والحذف
await client.create(model: 'res.partner', values: {...}, ...);
await client.write(model: 'res.partner', ids: [1], values: {...}, ...);
await client.unlink(model: 'res.partner', ids: [1], ...);

// Web Methods
await client.webSearchRead(model: 'sale.order', specification: {...}, ...);
await client.webRead(model: 'sale.order', ids: [1], specification: {...}, ...);
await client.webSave(model: 'sale.order', ids: [1], values: {...}, ...);

// عمليات متقدمة
await client.callKW(model: 'sale.order', method: 'action_confirm', ...);
await client.searchCount(model: 'res.partner', domain: [], ...);
await client.fieldsGet(model: 'product.product', ...);
```

---

## 🧪 A/B Testing

### الإعداد:

```dart
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';

// تفعيل A/B Testing
await ApiModeConfig.instance.setABTesting(true);

// تحديد النسبة (20% مثلاً)
await ApiModeConfig.instance.setBridgeCorePercentage(0.2);
```

### التطبيق على المستخدمين:

```dart
// عند تسجيل الدخول أو في splash screen
final userId = currentUser.value?.uid.toString() ?? '';

// سيتم تعيين النظام بناءً على hash الـ user ID
await ApiModeConfig.instance.setModeForUser(userId);

// الآن المستخدم إما على odooDirect أو bridgeCore
print('Current mode: ${ApiModeConfig.instance.currentMode.name}');
```

---

## 🛠️ أمثلة عملية

### مثال 1: جلب المنتجات

```dart
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/analytics/performance_tracker.dart';

Future<void> fetchProducts() async {
  final client = ApiClientFactory.instance;

  final products = await PerformanceTracker.track(
    operation: 'fetch_products',
    function: () async {
      final completer = Completer<List<dynamic>>();

      await client.searchRead(
        model: 'product.product',
        domain: [['sale_ok', '=', true]],
        fields: ['name', 'list_price', 'default_code', 'barcode'],
        limit: 100,
        onResponse: (result) => completer.complete(result),
        onError: (error, data) => completer.completeError(error),
        showGlobalLoading: true,
      );

      return await completer.future;
    },
  );

  print('Fetched ${products.length} products');
  return products;
}
```

### مثال 2: إنشاء طلب بيع

```dart
Future<int> createSaleOrder(Map<String, dynamic> orderData) async {
  final client = ApiClientFactory.instance;

  return await PerformanceTracker.track(
    operation: 'create_sale_order',
    function: () async {
      final completer = Completer<int>();

      await client.create(
        model: 'sale.order',
        values: orderData,
        onResponse: (id) => completer.complete(id),
        onError: (error, data) => completer.completeError(error),
        showGlobalLoading: true,
      );

      return await completer.future;
    },
  );
}
```

### مثال 3: التبديل مع إشعار

```dart
Future<void> switchWithNotification(ApiMode mode) async {
  try {
    await ApiClientFactory.switchMode(mode);

    Get.snackbar(
      'تم التبديل',
      'الآن يتم استخدام ${mode.name}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
    );
  } catch (e) {
    Get.snackbar(
      'خطأ',
      'فشل التبديل: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
```

---

## 🔧 التكوين المتقدم

### تخصيص BridgeCore URL:

```dart
// في api_mode_config.dart
String get bridgeCoreUrl {
  if (kDebugMode) {
    return 'http://localhost:8000'; // Development
  } else {
    return 'https://api.bridgecore.yourcompany.com'; // Production
  }
}
```

### تعطيل Performance Tracking:

```dart
PerformanceTracker.instance.setEnabled(false);
```

### مسح البيانات:

```dart
// مسح جميع القياسات
PerformanceTracker.instance.clearAll();

// مسح قياسات عملية محددة
PerformanceTracker.instance.clearOperation('fetch_products');

// مسح قياسات نظام محدد
PerformanceTracker.instance.clearMode('bridgeCore');
```

---

## 🚨 Rollback السريع

إذا حدثت مشكلة:

```dart
// 1. التبديل الفوري لجميع المستخدمين
await ApiModeConfig.instance.setMode(ApiMode.odooDirect);
await ApiModeConfig.instance.setABTesting(false);

// 2. إعادة إنشاء Client
ApiClientFactory.recreate();

// 3. إشعار المستخدمين
Get.snackbar(
  'تنبيه',
  'تم التبديل للنظام القديم مؤقتاً',
  backgroundColor: Colors.orange,
  colorText: Colors.white,
);

// 4. جمع تقرير
PerformanceTracker.instance.printReport();
```

---

## 📝 Notes مهمة

### ✅ Do's:
- استخدم PerformanceTracker لقياس جميع العمليات الهامة
- راقب metrics باستمرار
- ابدأ بنسبة صغيرة في A/B Testing
- احتفظ بالنظام القديم كـ fallback

### ❌ Don'ts:
- لا تنتقل فوراً إلى 100% BridgeCore
- لا تحذف النظام القديم قبل 3-6 أشهر من الاستقرار
- لا تتجاهل Performance metrics
- لا تطلق للـ production بدون اختبار شامل

---

## 🔗 روابط مفيدة

- [التقرير الشامل](../BRIDGECORE_INTEGRATION_REPORT.md)
- [الكود المصدري](../lib/common/api_factory/bridgecore/)
- [Developer Settings Page](../lib/src/presentation/screens/settings/developer_settings_page.dart)

---

**آخر تحديث**: 2025-11-15
