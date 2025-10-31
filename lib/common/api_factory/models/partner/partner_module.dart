import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/customer_main_screen.dart';

class PartnerModule {
  PartnerModule._();

  static readPartners({
    required List<int> ids,
    required OnResponse<List<PartnerModel>> onResponse,
  }) {
    // ✅ Smart Fallback: حقول آمنة لجميع المستخدمين
    List<String> safeFields = [
      "id",
      "name",
      "active",
      "is_company",
      "company_type",
      "type",
      "street",
      "street2",
      "city",
      "zip",
      "country_id",
      "partner_latitude",
      "partner_longitude",
      "email",
      "phone",
      "mobile",
      "website",
      "title",
      "function",
      "vat",
      "company_registry",
      "customer_rank",
      "supplier_rank",
      "child_ids",
      "user_id",
      "ref",
      "barcode",
      "image_512",
      "image_1920",
      "display_name",
    ];

    // ✅ حقول إضافية للمديرين فقط
    List<String> adminFields = [
      "purchase_order_count",
      "supplier_invoice_count",
      "purchase_warn",
      "purchase_warn_msg",
      "buyer_id",
      "purchase_line_ids",
      "sale_order_count",
      "sale_order_ids",
      "sale_warn",
      "sale_warn_msg",
      "total_invoiced",
      "credit",
      "invoice_warn",
      "invoice_warn_msg",
      "bank_ids",
      "employee",
      "parent_id",
      "parent_name",
    ];

    final bool isAdmin = PrefUtils.user.value.isAdmin ?? false;
    List<String> fields = isAdmin
        ? [...safeFields, ...adminFields]
        : safeFields;

    print(
      '🔍 Reading partners with ${fields.length} fields for ${isAdmin ? "Admin" : "Regular"} user',
    );

    Api.read(
      model: "res.partner",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        print("✅ Partners read successfully: ${response.length} partners");
        List<PartnerModel> partners = [];
        for (var element in response) {
          partners.add(PartnerModel.fromJson(element));
        }
        onResponse(partners);
      },
      onError: (error, data) {
        print("❌ Error reading partners: $error");
        print("📊 Error data: $data");

        // ✅ Smart Fallback: إذا فشل مع الحقول الكاملة، جرب الحقول الآمنة فقط
        if (fields.length > safeFields.length) {
          print('🔄 Retrying with safe fields only...');
          Api.read(
            model: "res.partner",
            ids: ids,
            fields: safeFields,
            onResponse: (response) {
              print(
                "✅ Partners read with safe fields: ${response.length} partners",
              );
              List<PartnerModel> partners = [];
              for (var element in response) {
                partners.add(PartnerModel.fromJson(element));
              }
              onResponse(partners);
            },
            onError: (fallbackError, fallbackData) {
              print("❌ Fallback also failed: $fallbackError");
              handleApiError(fallbackError);
            },
          );
        } else {
          handleApiError(error);
        }
      },
    );
  }

  static searchReadPartners({
    required OnResponse onResponse,
    dynamic domain,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    // ✅ Smart Fallback: حقول آمنة لجميع المستخدمين
    List<String> safeFields = [
      "id",
      "name",
      "active",
      "is_company",
      "company_type",
      "type",
      "street",
      "street2",
      "city",
      "zip",
      "country_id",
      "partner_latitude",
      "partner_longitude",
      "email",
      "phone",
      "mobile",
      "website",
      "title",
      "function",
      "vat",
      "company_registry",
      "customer_rank",
      "supplier_rank",
      "child_ids",
      "user_id",
      "ref",
      "barcode",
      "image_512",
      "image_1920",
      "display_name",
    ];

    // ✅ حقول إضافية للمديرين فقط
    List<String> adminFields = [
      "purchase_order_count",
      "supplier_invoice_count",
      "purchase_warn",
      "purchase_warn_msg",
      "buyer_id",
      "purchase_line_ids",
      "sale_order_count",
      "sale_order_ids",
      "sale_warn",
      "sale_warn_msg",
      "property_product_pricelist",
      "total_invoiced",
      "credit",
      "invoice_warn",
      "invoice_warn_msg",
      "bank_ids",
      "employee",
      "parent_id",
      "parent_name",
    ];

    final bool isAdmin = PrefUtils.user.value.isAdmin ?? false;
    List<String> fields = isAdmin
        ? [...safeFields, ...adminFields]
        : safeFields;

    print(
      '🔍 Partner fields for user: ${isAdmin ? "Admin" : "Regular"} - ${fields.length} fields',
    );
    print(
      '📋 Safe fields: ${safeFields.length}, Admin fields: ${adminFields.length}',
    );

    domain = [];
    if (isAdmin) {
      // للمستخدمين العاديين: جلب جميع الشركاء حيث name ليس false
      domain = [
        ['name', '!=', false],
      ];
    } else {
      // للمسؤولين: جلب الشركاء المرتبطين بالمستخدم الحالي فقط
      domain = [
        ['user_id', '=', PrefUtils.user.value.uid],
        ['name', '!=', false],
      ];
    }
    try {
      print('🔍 Attempting to load partners with ${fields.length} fields...');
      await Module.getRecordsController<PartnerModel>(
        model: "res.partner",
        fields: fields,
        domain: domain,
        fromJson: (data) => PartnerModel.fromJson(data),
        onResponse: (response) {
          print("✅ Partners loaded successfully: ${response.length} partners");
          onResponse(response);
        },
        showGlobalLoading: showGlobalLoading,
      );
    } catch (e) {
      print("❌ Error loading partners: $e");

      // ✅ Smart Fallback: إذا فشل مع الحقول الكاملة، جرب الحقول الآمنة فقط
      if (fields.length > safeFields.length) {
        print('🔄 Retrying with safe fields only...');
        try {
          await Module.getRecordsController<PartnerModel>(
            model: "res.partner",
            fields: safeFields,
            domain: domain,
            fromJson: (data) => PartnerModel.fromJson(data),
            onResponse: (response) {
              print(
                "✅ Partners loaded with safe fields: ${response.length} partners",
              );
              onResponse(response);
            },
            showGlobalLoading: showGlobalLoading,
          );
        } catch (fallbackError) {
          print("❌ Fallback also failed: $fallbackError");
          handleApiError(fallbackError);
        }
      } else {
        handleApiError(e);
      }
    }
  }

  static createPartners({
    required Map<String, dynamic>? maps,
    required OnResponse<int> onResponse,
  }) {
    print('🔍 Creating partner with data: $maps');

    Api.create(
      model: "res.partner",
      values: maps!,
      onResponse: (response) {
        print('✅ Partner created successfully with ID: $response');
        onResponse(response);
      },
      onError: (String error, Map<String, dynamic> data) {
        print('❌ Error creating partner: $error');
        print('📊 Error data: $data');

        // ✅ تحليل نوع الخطأ
        if (error.toLowerCase().contains('access') ||
            error.toLowerCase().contains('permission') ||
            error.toLowerCase().contains('droits')) {
          print('🔒 Access permission error detected');
          // يمكن إضافة معالجة خاصة لأخطاء الصلاحيات هنا
        }

        handleApiError(error);
      },
    );
  }

  static updateResPartner({
    required PartnerModel partner,
    required Map<String, dynamic>? maps,
    required OnResponse onResponse,
  }) {
    print(PrefUtils.partners.length);
    PrefUtils.partners.removeWhere((p) => p.id == partner.id);
    Api.webSave(
      model: "res.partner",
      ids: [partner.id!],
      values: maps!,
      specification: {},
      onResponse: (response) {
        print("Update successful: $response");
        try {
          print(PrefUtils.partners.length);
          PartnerModule.readPartners(
            ids: [partner.id],
            onResponse: (resPartner) async {
              onResponse(resPartner);
              await PrefUtils.updatePartner(resPartner[0]);
              print(PrefUtils.partners.length);
              Get.off(() => CustomerMainScreen());
            },
          );
        } catch (e) {
          print(e.toString());
        }
      },
      onError: (error, data) {
        print("Error: $error");
      },
    );
  }
}
