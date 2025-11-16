# GS Solution Mobile (GMobile)

<div dir="rtl">

تطبيق Flutter متكامل لإدارة المبيعات والمخزون والشركاء - متصل مع Odoo ERP عبر BridgeCore

[![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red)]()

</div>

---

## 📱 نظرة عامة

**GMobile** هو تطبيق جوال متقدم مبني باستخدام Flutter لإدارة عمليات المبيعات والمخزون والشركاء. التطبيق متكامل بشكل كامل مع نظام Odoo ERP من خلال **BridgeCore** - نظام middleware يوفر واجهة API موحدة وأمان محسّن.

### المميزات الرئيسية

- 🔐 **نظام مصادقة متقدم** - BridgeCore JWT Authentication مع Auto-login
- 📦 **إدارة المنتجات والمخزون** - عرض، بحث، وتحديث المنتجات في الوقت الفعلي
- 💰 **إدارة المبيعات والطلبات** - إنشاء وتتبع الطلبات والفواتير
- 👥 **إدارة الشركاء والعملاء** - قاعدة بيانات شاملة للعملاء والموردين
- 📊 **لوحات معلومات وتحليلات** - إحصائيات ومخططات تفاعلية
- 🗺️ **دعم الخرائط والموقع الجغرافي** - Google Maps integration
- 📄 **طباعة الفواتير والوثائق** - PDF generation و printing
- 📸 **مسح الباركود** - Mobile Scanner integration
- 🔄 **WebSocket Integration** - تحديثات في الوقت الفعلي
- 📴 **دعم العمل بدون إنترنت** - Offline queue و cache management
- ⚡ **Optimistic Updates** - تحديثات فورية للواجهة مع rollback تلقائي

---

## 🛠️ التقنيات المستخدمة

### Core Framework
- **Flutter** `^3.8.0` - إطار عمل التطوير متعدد المنصات
- **Dart** `^3.8.0` - لغة البرمجة

### State Management & Navigation
- **GetX** `^4.6.6` - إدارة الحالة والتنقل والتبعيات

### Networking & API
- **Dio** `^5.7.0` - HTTP client للطلبات
- **WebSocket Channel** `^2.4.0` - اتصالات WebSocket
- **BridgeCore Integration** - نظام middleware للاتصال مع Odoo

### Storage & Caching
- **SharedPreferences** `^2.3.2` - التخزين المحلي البسيط
- **Hive** `^2.2.3` + **Hive Flutter** `^1.1.0` - قاعدة بيانات محلية سريعة
- **Flutter Secure Storage** `^9.2.2` - تخزين آمن للتوكنات

### UI Components
- **Google Fonts** `^6.2.1` - خطوط مخصصة
- **Flutter SVG** `^2.0.9` - عرض ملفات SVG
- **Cached Network Image** `^3.4.1` - تحميل وتخزين الصور
- **FL Chart** `^1.1.1` - مخططات ورسوم بيانية
- **Carousel Slider** `^5.0.0` - عرض شرائحي

### Maps & Location
- **Google Maps Flutter** `^2.10.0` - خرائط Google
- **Geolocator** `^14.0.2` - تحديد الموقع الجغرافي
- **Geocoding** `^4.0.0` - تحويل الإحداثيات إلى عناوين

### Utilities
- **Mobile Scanner** `^7.0.1` - مسح الباركود والQR codes
- **Image Picker** `^1.1.2` - اختيار الصور من المعرض
- **PDF** `^3.10.8` + **Printing** `^5.12.0` - إنشاء وطباعة PDF
- **Connectivity Plus** `^6.0.5` - فحص حالة الاتصال
- **Logger** `^2.4.0` - نظام logging متقدم

### Development Tools
- **Build Runner** `^2.4.13` - code generation
- **Mocktail** `^1.0.4` - testing utilities
- **Flutter Lints** `^6.0.0` - linting rules

---

## 📋 المتطلبات

### متطلبات النظام
- **Flutter SDK** `^3.8.0` أو أحدث
- **Dart SDK** `^3.8.0` أو أحدث
- **Android Studio** / **VS Code** مع Flutter extensions
- **Git** لإدارة الإصدارات

### متطلبات التشغيل
- **Android**: API Level 21+ (Android 5.0+)
- **iOS**: iOS 12.0+ (إذا كان التطبيق يدعم iOS)
- **حساب Odoo ERP** مع تفعيل BridgeCore
- **اتصال بالإنترنت** (للعمليات الأساسية)

---

## 🚀 التثبيت والتشغيل

### 1. استنساخ المستودع

```bash
git clone https://github.com/geniustep/gmobile.git
cd gmobile
```

### 2. تثبيت التبعيات

```bash
flutter pub get
```

### 3. إعداد التكوين

قبل تشغيل التطبيق، قم بتعديل إعدادات الاتصال:

**ملف الإعدادات**: `lib/common/config/config.dart`

```dart
// BridgeCore Configuration
static const String bridgeCoreBaseUrl = 'https://your-bridgecore-url.com';
static const String odooBaseUrl = 'https://your-odoo-instance.com';

// API Configuration
static const String apiVersion = 'v1';
```

### 4. تشغيل التطبيق

```bash
# تشغيل على جهاز متصل أو محاكي
flutter run

# تشغيل في وضع التطوير مع hot reload
flutter run --debug

# بناء نسخة release
flutter build apk --release
```

### 5. تشغيل الاختبارات

```bash
# تشغيل جميع الاختبارات
flutter test

# تشغيل اختبارات التكامل
flutter test integration_test/
```

---

## ⚙️ الإعدادات والتكوين

### BridgeCore vs Odoo Direct

التطبيق يدعم وضعين للاتصال:

1. **BridgeCore Mode** (افتراضي) - الاتصال عبر BridgeCore middleware
2. **Odoo Direct Mode** - الاتصال المباشر مع Odoo

يمكن التبديل بين الوضعين من:
```
الإعدادات → Developer Settings → API Mode
```

### Developer Settings

يمكن الوصول إلى إعدادات المطور من:
```
الإعدادات → Developer Settings
```

المميزات المتاحة:
- 🔄 تبديل بين BridgeCore و Odoo Direct
- 📊 عرض إحصائيات الأداء والاتصال
- 🔌 التحكم في WebSocket connections
- 🗑️ مسح الكاش والبيانات المخزنة محلياً
- 📈 عرض معلومات الجلسة والـ tokens

---

## 📁 هيكل المشروع

```
lib/
├── main.dart                    # نقطة البداية الرئيسية
├── routes.dart                  # تعريف المسارات
│
├── common/                      # المكونات المشتركة
│   ├── api_factory/             # إعدادات API والطلبات
│   │   ├── bridgecore/          # BridgeCore integration
│   │   │   ├── clients/         # API clients
│   │   │   ├── websocket/       # WebSocket handlers
│   │   │   ├── resilience/      # Circuit breaker, retry logic
│   │   │   └── deduplication/   # Request deduplication
│   │   ├── modules/             # API modules
│   │   │   ├── authentication_bridgecore_module.dart
│   │   │   └── authentication_module.dart
│   │   ├── interceptors/        # Request/Response interceptors
│   │   └── models/              # Data models
│   │
│   ├── config/                  # إعدادات التطبيق
│   │   ├── config.dart          # إعدادات API و URLs
│   │   ├── app_colors.dart      # ألوان التطبيق
│   │   ├── app_fonts.dart       # الخطوط
│   │   ├── app_theme.dart       # الثيم
│   │   └── localization/        # الترجمة
│   │
│   ├── storage/                 # نظام التخزين
│   │   ├── storage_service.dart # Hybrid storage (Prefs + Hive)
│   │   ├── migration_service.dart
│   │   └── hive/                # Hive adapters
│   │
│   ├── repositories/            # Data repositories
│   │   ├── product_repository.dart
│   │   ├── partner_repository.dart
│   │   ├── invoice_repository.dart
│   │   └── base/                # Base repository classes
│   │
│   ├── controllers/             # Business logic controllers
│   │   ├── products_controllers.dart
│   │   ├── signin_controller.dart
│   │   ├── home_controller.dart
│   │   └── mixins/              # Controller mixins
│   │       └── websocket_mixin.dart
│   │
│   ├── services/                # Services
│   │   ├── api/                  # API services
│   │   ├── cache/               # Caching services
│   │   ├── pdf/                 # PDF generation
│   │   └── sync/                # Sync services
│   │
│   ├── offline/                 # Offline support
│   │   └── offline_queue_manager.dart
│   │
│   ├── error/                   # Error handling
│   │   └── error_handler.dart
│   │
│   ├── session/                  # Session management
│   │   └── session_manager.dart
│   │
│   ├── cache/                    # Cache management
│   │   └── cache_manager.dart
│   │
│   ├── widgets/                  # Widgets مشتركة
│   │   ├── loading/             # Loading indicators
│   │   ├── empty_state/         # Empty state widgets
│   │   └── search/               # Search widgets
│   │
│   └── utils/                    # Utilities
│       ├── validators/           # Form validators
│       └── pagination_helper.dart
│
└── src/                          # Source code
    ├── presentation/             # UI Layer
    │   ├── screens/              # Application screens
    │   │   ├── authentication/  # Login, Signup
    │   │   ├── dashboard/        # Dashboard
    │   │   ├── products/         # Products management
    │   │   ├── sales/            # Sales orders
    │   │   ├── customer/         # Customers/Partners
    │   │   ├── stock/            # Inventory management
    │   │   ├── settings/         # Settings screens
    │   │   └── splash_screen/    # Smart SplashScreen
    │   │
    │   └── widgets/              # Screen-specific widgets
    │
    └── routes/                   # Route definitions
        └── app_routes.dart
```

---

## 🔒 الأمان

### Authentication & Authorization
- ✅ **JWT Tokens** - استخدام JWT tokens من BridgeCore
- ✅ **Secure Token Storage** - تخزين آمن للتوكنات باستخدام Flutter Secure Storage
- ✅ **Auto-login** - تسجيل دخول تلقائي مع التحقق من صحة الـ token
- ✅ **Session Management** - إدارة الجلسات بشكل آمن

### Network Security
- ✅ **HTTPS Only** - جميع الاتصالات تتم عبر HTTPS
- ✅ **Certificate Pinning** - (اختياري) يمكن تفعيله
- ✅ **Request Interceptors** - إضافة headers آمنة تلقائياً

### Data Security
- ✅ **No Password Storage** - لا يتم تخزين كلمات المرور
- ✅ **Encrypted Storage** - التخزين المشفر للبيانات الحساسة
- ✅ **Secure Logout** - مسح آمن للبيانات عند تسجيل الخروج

---

## 🎯 المميزات المتقدمة

### Smart SplashScreen
- Auto-login مع التحقق من الـ token
- تحميل موازي للبيانات الأساسية
- Offline mode مع cache fallback
- تحسين تجربة المستخدم

### WebSocket Integration
- تحديثات في الوقت الفعلي للمنتجات والمخزون
- إشعارات فورية للطلبات الجديدة
- مزامنة تلقائية للبيانات

### Offline Support
- Queue manager للطلبات أثناء عدم الاتصال
- Cache-first strategy للبيانات
- Auto-sync عند عودة الاتصال

### Optimistic Updates
- تحديثات فورية للواجهة
- Rollback تلقائي عند فشل الطلب
- تحسين تجربة المستخدم

### Performance Optimizations
- Circuit breaker pattern
- Request deduplication
- Response compression
- Pagination للقوائم الكبيرة

---

## 🧪 الاختبار

### تشغيل الاختبارات

```bash
# جميع الاختبارات
flutter test

# اختبارات محددة
flutter test test/common/repositories/product_repository_test.dart

# اختبارات التكامل
flutter test integration_test/
```

### تغطية الاختبارات

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## 📚 التوثيق الإضافي

- [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) - دليل البدء السريع
- [GMOBILE_IMPROVEMENTS_COMPLETE.md](GMOBILE_IMPROVEMENTS_COMPLETE.md) - قائمة التحسينات الكاملة
- [BRIDGECORE_INTEGRATION_REPORT.md](BRIDGECORE_INTEGRATION_REPORT.md) - تقرير تكامل BridgeCore
- [ODOO_WEBHOOK_ANALYSIS.md](ODOO_WEBHOOK_ANALYSIS.md) - تحليل Odoo Webhooks
- [lib/common/storage/README.md](lib/common/storage/README.md) - توثيق نظام التخزين

---

## 🤝 المساهمة

هذا المشروع خاص بشركة **Genius Step**. للمساهمة:

1. إنشاء فرع جديد من `dev`
2. إجراء التعديلات المطلوبة
3. كتابة الاختبارات للتعديلات الجديدة
4. إنشاء Pull Request إلى `dev`

---

## 📝 الترخيص

هذا المشروع خاص بشركة **Genius Step** - جميع الحقوق محفوظة.

---

## 📞 الدعم والاتصال

للحصول على الدعم أو الإبلاغ عن مشاكل:

- **فريق التطوير**: Genius Step Development Team
- **المستودع**: [https://github.com/geniustep/gmobile](https://github.com/geniustep/gmobile)

---

## 🗺️ خارطة الطريق

### الإصدارات القادمة
- [ ] دعم iOS الكامل
- [ ] تحسينات إضافية للأداء
- [ ] ميزات جديدة لإدارة المخزون
- [ ] تحسينات في واجهة المستخدم
- [ ] دعم اللغات الإضافية

---

<div dir="ltr">

**Made with ❤️ by Genius Step Team**

</div>
