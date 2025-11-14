# 🚀 إعداد نظام التخزين الهجين (Hybrid Storage)

## ✅ ما تم إنجازه

تم تطبيق **الحل الهجين** بنجاح:
- ✅ SharedPreferences للبيانات الصغيرة (token, isLoggedIn, user, location)
- ✅ Hive للبيانات الكبيرة (products, partners, sales, etc.)
- ✅ StorageService موحد للتعامل مع كلا النظامين
- ✅ MigrationService لنقل البيانات القديمة تلقائياً
- ✅ Hive Entities لـ Products, Partners, Sales

## 📋 الخطوات المطلوبة لإكمال الإعداد

### 1. تنزيل Dependencies

```bash
flutter pub get
```

### 2. توليد Hive Adapters

يجب تشغيل build_runner لتوليد الـ `.g.dart` files:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**ملاحظة**: قد تستغرق هذه العملية 1-2 دقيقة.

### 3. التحقق من التوليد الناجح

تأكد من إنشاء الملفات التالية:

```
lib/common/storage/hive/entities/
├── product_entity.g.dart
├── partner_entity.g.dart
└── sale_order_entity.g.dart
```

### 4. تشغيل التطبيق

```bash
flutter run
```

## 🔍 ماذا يحدث عند أول تشغيل؟

عند تشغيل التطبيق لأول مرة بعد التحديث:

1. **التهيئة**: يتم تهيئة SharedPreferences و Hive
2. **Migration**: يكتشف النظام البيانات القديمة في SharedPreferences
3. **النقل**: ينقل البيانات الكبيرة إلى Hive تلقائياً
4. **التنظيف**: يحذف البيانات المنقولة من SharedPreferences
5. **العلامة**: يضع علامة "Migration مكتمل" لتجنب التكرار

## 📊 الملفات الجديدة

```
lib/common/storage/
├── hive/
│   ├── entities/
│   │   ├── product_entity.dart         ✅ جديد
│   │   ├── product_entity.g.dart       🔄 سيتم توليده
│   │   ├── partner_entity.dart         ✅ جديد
│   │   ├── partner_entity.g.dart       🔄 سيتم توليده
│   │   ├── sale_order_entity.dart      ✅ جديد
│   │   └── sale_order_entity.g.dart    🔄 سيتم توليده
│   └── hive_service.dart               ✅ جديد
├── storage_service.dart                ✅ جديد
├── migration_service.dart              ✅ جديد
└── README.md                           ✅ جديد

المعدّل:
├── main.dart                           ✅ محدّث
├── pubspec.yaml                        ✅ محدّث
└── build.yaml                          ✅ جديد
```

## 🎯 الاستخدام

### بدلاً من PrefUtils القديم:

```dart
// ❌ القديم
await PrefUtils.setProducts(products);
final products = await PrefUtils.getProducts();

// ✅ الجديد
await StorageService.instance.setProducts(products);
final products = await StorageService.instance.getProducts();
```

### مع Pagination:

```dart
// جلب 50 منتج فقط
final products = await StorageService.instance.getProducts(
  limit: 50,
  offset: 0,
);
```

### مع البحث:

```dart
// البحث عن منتجات
final products = await StorageService.instance.getProducts(
  searchQuery: 'laptop',
);
```

## 🔧 إذا واجهت مشاكل

### مشكلة 1: خطأ في build_runner

```bash
# امسح cache وأعد المحاولة
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### مشكلة 2: خطأ في Hive Adapters

تأكد من:
- تم تشغيل build_runner
- ملفات `.g.dart` موجودة
- لا يوجد تعارض في typeId

### مشكلة 3: البيانات لم تنتقل

```dart
// التحقق من حالة Migration
final status = await MigrationService.instance.getMigrationStatus();
print(status);

// إعادة Migration
await MigrationService.instance.resetMigration();
await MigrationService.instance.migrate();
```

## 📈 الفوائد المتوقعة

### قبل (SharedPreferences فقط):
- ⏱️ تحميل 1000 منتج: ~500ms
- 💾 حجم JSON: ~2MB
- ⚠️ احتمالية فقدان البيانات عند تجاوز الحد

### بعد (Hybrid Storage):
- ⚡ تحميل 1000 منتج: ~50ms (أسرع 10x)
- 💾 حجم Hive: ~1MB (ضغط أفضل)
- ✅ Pagination مدمج
- ✅ Type-safe
- ✅ بحث مدمج

## 🧪 الاختبار

### اختبار أساسي:

```dart
void testStorage() async {
  // تهيئة
  await StorageService.instance.init();

  // حفظ
  await StorageService.instance.setProducts(testProducts);

  // استرجاع
  final products = await StorageService.instance.getProducts();

  print('✅ Products count: ${products.length}');
  print('✅ Storage info: ${StorageService.instance.getStorageInfo()}');
}
```

## 📞 الدعم

للمزيد من المعلومات، راجع:
- `lib/common/storage/README.md` - توثيق شامل
- `lib/common/storage/storage_service.dart` - الكود الرئيسي
- [Hive Documentation](https://docs.hivedb.dev/)

---

**ملاحظة مهمة**: بعد تشغيل build_runner بنجاح، لن تحتاج لتشغيله مرة أخرى إلا إذا عدّلت الـ entities.
