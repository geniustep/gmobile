import 'package:gsloution_mobile/common/api_factory/api.dart';
import 'package:gsloution_mobile/common/api_factory/dio_factory.dart';
import 'package:gsloution_mobile/common/api_factory/modules/settings_odoo_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';

class SettingsOdooModule {
  SettingsOdooModule._();

  // read settings odoo
  static onchangeSettingsOdoo({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    try {
      var args = [
        [],
        {},
        [],
        {"default_invoice_policy": {}},
      ];

      ResConfigSettingModel fromJson(Map<String, dynamic> json) {
        final value = json['value'];
        if (value != null) {
          return ResConfigSettingModel(
            default_invoice_policy: value['default_invoice_policy'],
          );
        }
        throw Exception("Value is null or invalid response format");
      }

      await Api.onChange(
        model: 'res.config.settings',
        args: args,
        onResponse: (response) {
          if (response != null) {
            try {
              final configSetting = fromJson(response);
              onResponse!(configSetting);
            } catch (e) {
              print("Error parsing response: $e");
              handleApiError(e.toString());
            }
          }
        },
        onError: (error, data) {
          handleApiError(error);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error extracting 'value': $e"); // في حالة حدوث استثناء
      handleApiError(e.toString());
    }
  }

  // change default invoice policy to delivery
  static deliverySettings({
    required OnResponse onResponse,
    bool? showGlobalLoading,
  }) async {
    await Api.callKW(
      model: 'res.config.settings',
      method: "web_save",
      args: [
        [],
        {"default_invoice_policy": "delivery"},
      ],
      kwargs: {
        "specification": {"default_invoice_policy": {}},
      },
      onResponse: (response) {
        if (response is List &&
            response.isNotEmpty &&
            response[0] is Map<String, dynamic>) {
          final map = response[0] as Map<String, dynamic>;
          try {
            int id = map['id'] as int;

            // استدعاء API باستخدام ID المستخرج
            Api.execute(
              model: "res.config.settings",
              ids: [id],
              onResponse: (res) {
                onResponse(res); // تمرير الاستجابة بنجاح
              },
              onError: (error, data) {
                handleApiError(error); // التعامل مع الخطأ
              },
              showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
            );
          } catch (e) {
            print("Error extracting 'id': $e"); // في حالة حدوث استثناء
            handleApiError(e.toString());
          }
        } else {
          print("Invalid response format or missing 'id' key.");
          handleApiError("Invalid response format or missing 'id' key.");
        }
      },
      onError: (error, data) {
        handleApiError(error);
      },
      showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
    );
  }

  // add user to group account (readonly, user) comptablité complete
  // داخل SettingsOdooModule
  static Future<dynamic> getGroupIdByXmlId({
    OnResponse? onResponse,
    bool? showGlobalLoading,
  }) async {
    // التحقق من صلاحيات المستخدم أولاً
    try {
      // محاولة الوصول إلى نموذج بسيط للتحقق من الصلاحيات
      await Api.callKW(
        model: 'res.users',
        method: 'read',
        args: [PrefUtils.user.value.uid],
        kwargs: {
          "fields": ["groups_id"],
        },
        onResponse: (response) {
          print("✅ User has basic access permissions");
          if (response != null && response is List && response.isNotEmpty) {
            final userData = response[0];
            if (userData is Map<String, dynamic> &&
                userData.containsKey('groups_id')) {
              final List<dynamic> userGroups = userData['groups_id'];
              print("👤 User groups: $userGroups");

              // التحقق من وجود مجموعات المحاسبة
              if (userGroups.contains(8) || userGroups.contains(17)) {
                print(
                  "✅ User already has accounting groups - skipping assignment",
                );
                onResponse!(8); // إرجاع معرف مجموعة موجودة
                return;
              }
            }
          }

          // إذا لم يكن لديه مجموعات المحاسبة، نستمر بدون تعيين
          print(
            "⚠️ User doesn't have accounting groups - continuing without assignment",
          );
          onResponse!(null);
        },
        onError: (error, data) {
          print("❌ User doesn't have basic access: $error");
          onResponse!(null);
        },
        showGlobalLoading: false,
      );
    } catch (e) {
      print("⚠️ Could not verify user permissions: $e");
      onResponse!(null);
    }
    // إذا كان المستخدم لديه مجموعات المحاسبة بالفعل، لا نحتاج للبحث
    // (سيتم التعامل مع هذا في onResponse)

    dynamic result;
    try {
      // محاولة الوصول المباشر إلى المجموعات بدلاً من ir.model.data
      await Api.callKW(
        model: 'res.groups',
        method: 'search_read',
        args: [
          [
            ["name", "ilike", "account"],
            ["category_id.name", "=", "Accounting"],
          ],
          ["id", "name"],
        ],
        kwargs: {"limit": 10},
        onResponse: (response) async {
          try {
            print("📋 Group ID response: $response");

            if (response != null && response is List && response.isNotEmpty) {
              dynamic userId = int.tryParse(
                PrefUtils.user.value.uid.toString(),
              );
              print("👤 User ID: $userId");

              // إضافة المستخدم لكل المجموعات المطلوبة
              for (var rec in response) {
                if (rec is Map<String, dynamic> &&
                    rec.containsKey("id") &&
                    rec.containsKey("name")) {
                  final int groupId = rec["id"];
                  final String name = rec["name"];
                  print("✅ Found $name with ID: $groupId");

                  if (userId != null) {
                    await saveUsersToGroup(
                      groupId: groupId,
                      userIds: userId,
                      onResponse: (res) {
                        print("✅ User $userId added to group $groupId");
                      },
                    );
                  }
                } else {
                  print("⚠️ Invalid record format: $rec");
                }
              }

              // ✅ استدعاء onResponse مرة واحدة فقط بعد إنهاء الحلقة
              result = response.first["id"];
              onResponse!(result);
            } else {
              print(
                "⚠️ Group not found or empty response - user may not have access to accounting groups",
              );
              print(
                "✅ Continuing without group assignment - this is normal for non-admin users",
              );
              result = null;
              onResponse!(null); // استدعاء onResponse مع null للاستمرار
            }
          } catch (e, stackTrace) {
            print("❌ Error processing group response: $e");
            print("📍 Stack trace: $stackTrace");
            result = null;
            onResponse!(null); // استدعاء onResponse مع null للاستمرار
          }
        },
        onError: (error, data) {
          print("❌ Group ID API Error: $error");
          print("📋 Error data: $data");
          print(
            "⚠️ User doesn't have access to ir.model.data - skipping group assignment",
          );
          // لا نستدعي handleApiError هنا، بل نستمر بدون تعيين المجموعات
          result = null;
          onResponse!(null); // استدعاء onResponse مع null للاستمرار
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e, stackTrace) {
      print("❌ Error fetching group ID: $e");
      print("📍 Stack trace: $stackTrace");
      print("🔍 Error type: ${e.runtimeType}");
      print("🔧 Available user: ${PrefUtils.user.value.uid}");
      print("🔧 User ID type: ${PrefUtils.user.value.uid.runtimeType}");
      print("🔧 User ID string: ${PrefUtils.user.value.uid.toString()}");
      print(
        "🔧 User ID parsed: ${int.tryParse(PrefUtils.user.value.uid.toString())}",
      );
      print("🔧 User ID is null: ${PrefUtils.user.value.uid == null}");
      print(
        "🔧 User ID is empty: ${PrefUtils.user.value.uid.toString().isEmpty}",
      );
      result = null;
    }
    return result;
  }

  static Future<void> saveUsersToGroup({
    OnResponse? onResponse,
    required int groupId,
    required int userIds,
    String mode = 'add', // replace (6), add (4), unlink (3)
    bool? showGlobalLoading, // ✅ parameter جديد
  }) async {
    try {
      int command = 6; // replace
      if (mode == 'add') command = 4;
      if (mode == 'unlink') command = 3;

      await Api.webSave(
        model: 'res.groups',
        ids: [groupId],
        values: {
          "users": [
            [command, userIds],
          ],
        },
        specification: {"users": {}},
        onResponse: (res) {
          if (res != null) {
            onResponse!(res);
          }
        },
        onError: (error, data) {
          handleApiError(error);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error saving users to group: $e");
    }
  }
}
