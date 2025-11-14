# 📦 Hybrid Storage System

نظام تخزين هجين يجمع بين **SharedPreferences** و **Hive** لتحقيق أفضل أداء.

## 🎯 الفلسفة

### ✅ SharedPreferences
**للبيانات الصغيرة السريعة الوصول:**
- Token (التوكن)
- isLoggedIn (حالة تسجيل الدخول)
- User (بيانات المستخدم)
- Location (lat, long)

### ✅ Hive
**للبيانات الكبيرة عالية الأداء:**
- Products (المنتجات) - آلاف السجلات
- Partners (الشركاء/العملاء) - مئات السجلات
- Sales (المبيعات) - آلاف السجلات
- Categories, PriceLists, Stock, etc.

## 📁 البنية

```
lib/common/storage/
├── hive/
│   ├── entities/
│   │   ├── product_entity.dart      # Hive model للمنتجات
│   │   ├── partner_entity.dart      # Hive model للشركاء
│   │   └── sale_order_entity.dart   # Hive model للمبيعات
│   └── hive_service.dart            # إدارة Hive boxes
├── storage_service.dart             # الواجهة الموحدة
├── migration_service.dart           # نقل البيانات من SharedPreferences
└── README.md                        # هذا الملف
```

## 🚀 الاستخدام

### 1. التهيئة (في main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الـ Storage
  await StorageService.instance.init();

  // تنفيذ Migration (مرة واحدة فقط)
  await MigrationService.instance.migrate();

  runApp(MyApp());
}
```

### 2. حفظ واسترجاع البيانات

#### SharedPreferences (بيانات صغيرة)

```dart
// حفظ التوكن
await StorageService.instance.setToken('your_token');

// استرجاع التوكن
final token = await StorageService.instance.getToken();

// حالة تسجيل الدخول
await StorageService.instance.setIsLoggedIn(true);
final isLoggedIn = await StorageService.instance.getIsLoggedIn();

// بيانات المستخدم
await StorageService.instance.setUser(userModel);
final user = await StorageService.instance.getUser();
```

#### Hive (بيانات كبيرة)

```dart
// حفظ المنتجات
await StorageService.instance.setProducts(productsList);

// استرجاع جميع المنتجات
final products = await StorageService.instance.getProducts();

// استرجاع مع Pagination
final products = await StorageService.instance.getProducts(
  limit: 50,
  offset: 0,
);

// استرجاع مع البحث
final products = await StorageService.instance.getProducts(
  searchQuery: 'laptop',
);

// عدد المنتجات
final count = StorageService.instance.productsCount;
```

### 3. Cache Validity (صلاحية الـ Cache)

```dart
// التحقق من صلاحية الـ Cache
final isValid = await StorageService.instance.isCacheValid(
  'products',
  Duration(hours: 24),
);

if (!isValid) {
  // جلب البيانات من السيرفر
  final newProducts = await fetchFromServer();
  await StorageService.instance.setProducts(newProducts);
}

// آخر وقت للمزامنة
final lastSync = await StorageService.instance.getLastSync('products');
print('Last sync: $lastSync');
```

## 🔄 Migration (الترحيل)

عند تشغيل التطبيق لأول مرة بعد التحديث، سيقوم `MigrationService` بـ:

1. **الكشف التلقائي**: التحقق من وجود بيانات قديمة في SharedPreferences
2. **النقل**: نقل البيانات إلى Hive
3. **التحويل**: تحويل البيانات من JSON إلى Hive entities
4. **التنظيف**: حذف البيانات القديمة من SharedPreferences
5. **العلامة**: وضع علامة Migration مكتمل

### إعادة Migration (للاختبار)

```dart
// إعادة تعيين Migration
await MigrationService.instance.resetMigration();

// التحقق من حالة Migration
final status = await MigrationService.instance.getMigrationStatus();
print(status);
// {
//   'currentVersion': 1,
//   'targetVersion': 1,
//   'needsMigration': false,
//   'migrationKeys': [...]
// }
```

## 📊 معلومات التخزين

```dart
// معلومات شاملة عن التخزين
final info = StorageService.instance.getStorageInfo();
print(info);
// {
//   'sharedPreferences': {
//     'token': true,
//     'isLoggedIn': true,
//     'user': true
//   },
//   'hive': {
//     'products': 1234,
//     'partners': 567,
//     'sales': 890,
//     ...
//   }
// }
```

## ⚡ المزايا

### 1. **أداء عالي**
- Hive أسرع 100x من SharedPreferences للبيانات الكبيرة
- Lazy Loading و Pagination مدمج
- Memory-efficient

### 2. **Type Safety**
- استخدام Hive TypeAdapters
- تحويل تلقائي بين Model و Entity

### 3. **Flexibility**
- SharedPreferences للبيانات الصغيرة (بسيط وسريع)
- Hive للبيانات الكبيرة (قوي ومرن)

### 4. **Backward Compatible**
- Migration تلقائي من SharedPreferences
- لا حاجة لحذف البيانات الموجودة

### 5. **Search & Filter**
- بحث مدمج في الـ entities
- فلترة وترتيب

## 🔧 إضافة Entity جديد

### 1. إنشاء Entity

```dart
// lib/common/storage/hive/entities/my_entity.dart
import 'package:hive/hive.dart';

part 'my_entity.g.dart';

@HiveType(typeId: 10) // استخدم typeId جديد
class MyEntity extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  MyEntity({required this.id, required this.name});

  factory MyEntity.fromModel(MyModel model) {
    return MyEntity(
      id: model.id,
      name: model.name,
    );
  }

  MyModel toModel() {
    return MyModel(id: id, name: name);
  }
}
```

### 2. تشغيل Build Runner

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. تسجيل Adapter في HiveService

```dart
// في hive_service.dart
if (!Hive.isAdapterRegistered(10)) {
  Hive.registerAdapter(MyEntityAdapter());
}
```

### 4. فتح Box

```dart
late Box<MyEntity> myBox;
myBox = await Hive.openBox<MyEntity>('myData');
```

## 🧪 الاختبار

```dart
// test
void main() async {
  // تهيئة
  await StorageService.instance.init();

  // حفظ
  await StorageService.instance.setProducts(testProducts);

  // استرجاع
  final products = await StorageService.instance.getProducts();

  // التحقق
  expect(products.length, testProducts.length);
}
```

## 📝 ملاحظات مهمة

1. **لا تستخدم SharedPreferences للبيانات الكبيرة**
   - الحد الأقصى: ~1MB
   - للبيانات الأكبر: استخدم Hive

2. **استخدم Pagination دائماً**
   - لا تحمل جميع البيانات دفعة واحدة
   - استخدم limit و offset

3. **Cache Validity**
   - حدد صلاحية مناسبة لكل نوع بيانات
   - Products: 24 ساعة
   - Partners: 12 ساعة
   - Sales: 1 ساعة

4. **Migration**
   - يعمل تلقائياً عند أول تشغيل
   - لا يؤثر على الأداء بعد ذلك

## 🔗 المراجع

- [Hive Documentation](https://docs.hivedb.dev/)
- [SharedPreferences Documentation](https://pub.dev/packages/shared_preferences)
