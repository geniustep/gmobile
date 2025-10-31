import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gsloution_mobile/common/api_factory/controllers/controller.dart';
import 'package:gsloution_mobile/common/config/field_presets/fallback_level.dart';
import 'package:gsloution_mobile/common/config/import.dart';

class AccountJournalModule {
  AccountJournalModule._();
  static final Controller _apiController = Get.put(Controller());

  static List<String> _getDebugFields() {
    return [
      'id',
      'name',
      'type',
      'company_id',
      'company_partner_id',
      'bank_account_id',
      'bank_id',
      'bank_statements_source',
      'code',
      'account_control_ids',
      'restrict_mode_hash_table',
      'message_follower_ids',
      'activity_ids',
      'message_ids',
      'message_attachment_count',
      'display_name',
      'inbound_payment_method_line_ids',
      'outbound_payment_method_line_ids',
    ];
  }

  static List<String> _getReleaseFields() {
    return [
      'id',
      'name',
      'active',
      'type',
      'company_id',
      'company_partner_id',
      'bank_account_id',
      'bank_id',
      'bank_statements_source',
      'code',
      'sequence_number_next',
      'sequence_id',
      'refund_sequence',
      'refund_sequence_number_next',
      'refund_sequence_id',
      'default_debit_account_id',
      'default_credit_account_id',
      'currency_id',
      'invoice_reference_type',
      'invoice_reference_model',
      'alias_id',
      'alias_name',
      'alias_domain',
      'profit_account_id',
      'loss_account_id',
      'post_at',
      'type_control_ids',
      'account_control_ids',
      'restrict_mode_hash_table',
      'message_follower_ids',
      'activity_ids',
      'message_ids',
      'message_attachment_count',
      'display_name',
      'inbound_payment_method_line_ids',
      'outbound_payment_method_line_ids',
    ];
  }

  static List<String> _getDefaultFields() {
    return kReleaseMode ? _getReleaseFields() : _getDebugFields();
  }

  // ────────────────────────────────────────────────────────
  // ✅ Search Read مع Smart Fallback
  // ────────────────────────────────────────────────────────

  static Future<void> searchReadAccountJournal({
    OnResponse<List<AccountJournalModel>>? onResponse,
    List<dynamic>? domain,
    bool showGlobalLoading = true,
    List<String>? customFields,
  }) async {
    final fields = customFields ?? _getDefaultFields();

    print('📚 Loading account journals...');
    print('   Mode: ${kReleaseMode ? "Release" : "Debug"}');
    print('   Initial fields: ${fields.length}');

    // إنشاء Strategy
    final strategy = FieldFallbackStrategy(
      model: 'account.journal',
      onFieldsGet: (model) async {
        final completer = Completer<Map<String, dynamic>>();

        Api.fieldsGetWithInfo(
          model: model,
          onResponse: (fieldsInfo) {
            completer.complete(fieldsInfo);
          },
          onError: (error, data) {
            completer.completeError(error);
          },
          showGlobalLoading: false,
        );

        return await completer.future;
      },
    );

    strategy.initialize(fields);

    await _attemptSearchRead(
      strategy: strategy,
      domain: domain ?? [],
      onResponse: onResponse,
      showGlobalLoading: showGlobalLoading,
    );
  }

  // ────────────────────────────────────────────────────────
  // محاولة Search Read مع معالجة الأخطاء
  // ────────────────────────────────────────────────────────

  static Future<void> _attemptSearchRead({
    required FieldFallbackStrategy strategy,
    required List<dynamic> domain,
    required OnResponse<List<AccountJournalModel>>? onResponse,
    required bool showGlobalLoading,
  }) async {
    try {
      final currentFields = strategy.getCurrentFields();

      await Module.getRecordsController<AccountJournalModel>(
        model: "account.journal",
        fields: currentFields,
        domain: domain,
        fromJson: (data) => AccountJournalModel.fromJson(data),
        onResponse: (response) {
          print("✅ Account journals loaded: ${response.length}");
          print(
            "   Level used: ${strategy.currentLevel.toString().split('.').last}",
          );
          print("   Fields count: ${currentFields?.length ?? 'ALL'}");

          final status = strategy.getStatus();
          if (status['retry_count'] > 0) {
            print("   Retries: ${status['retry_count']}");
            print(
              "   Invalid fields removed: ${status['cached_invalid_fields']}",
            );
          }

          onResponse?.call(response);
        },
        showGlobalLoading: showGlobalLoading,
      );
    } catch (e) {
      final errorStr = e.toString();

      if (errorStr.contains('Invalid field')) {
        print("⚠️  Invalid field error detected");

        try {
          final newFields = await strategy.handleInvalidField(errorStr);

          if (newFields != null && newFields.isNotEmpty) {
            print("🔄 Retrying with new fields...");

            await _attemptSearchRead(
              strategy: strategy,
              domain: domain,
              onResponse: onResponse,
              showGlobalLoading: false,
            );
            return;
          }
        } catch (strategyError) {
          print("❌ Strategy error: $strategyError");
          onResponse?.call([]);
          return;
        }
      }

      print("❌ Error loading account journals: $e");
      onResponse?.call([]);
    }
  }

  static readAccountJournal({
    required List<int> ids,
    required OnResponse<List<AccountJournalModel>> onResponse,
  }) {
    List<String> fields = [
      "id",
      "name",
      "active",
      "type",
      "company_id",
      "company_partner_id",
      "bank_account_id",
      "bank_id",
      "bank_statements_source",
      "code",
      "sequence_number_next",
      "sequence_id",
      "refund_sequence",
      "refund_sequence_number_next",
      "refund_sequence_id",
      "default_debit_account_id",
      "default_credit_account_id",
      "currency_id",
      "invoice_reference_type",
      "invoice_reference_model",
      "alias_id",
      "alias_name",
      "alias_domain",
      "profit_account_id",
      "loss_account_id",
      "post_at",
      "type_control_ids",
      "account_control_ids",
      "restrict_mode_hash_table",
      "inbound_payment_method_ids",
      "outbound_payment_method_ids",
      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
      "display_name",
    ];
    Api.read(
      model: "account.journal",
      ids: ids,
      fields: fields,
      onResponse: (response) {
        List<AccountJournalModel> accountJournal = [];
        for (var element in response) {
          accountJournal.add(
            AccountJournalModel.fromJson(element as Map<String, dynamic>),
          );
        }
        onResponse(accountJournal);
      },
      onError: (error, data) {
        handleApiError(error);
      },
    );
  }

  static searchReadAccountJournalold<T>({
    OnResponse? onResponse,
    required List<dynamic> domain,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    List<String> fieldsDebug = [
      "id",
      "name",

      "type",
      "company_id",
      "company_partner_id",
      "bank_account_id",
      "bank_id",
      "bank_statements_source",
      "code",

      "account_control_ids",
      "restrict_mode_hash_table",

      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
      "display_name",
      "inbound_payment_method_line_ids",
      "outbound_payment_method_line_ids",
    ];
    List<String> fields = [
      "inbound_payment_method_line_ids",
      "outbound_payment_method_line_ids",
      "id",
      "name",
      "active",
      "type",
      "company_id",
      "company_partner_id",
      "bank_account_id",
      "bank_id",
      "bank_statements_source",
      "code",
      "sequence_number_next",
      "sequence_id",
      "refund_sequence",
      "refund_sequence_number_next",
      "refund_sequence_id",
      "default_debit_account_id",
      "default_credit_account_id",
      "currency_id",
      "invoice_reference_type",
      "invoice_reference_model",
      "alias_id",
      "alias_name",
      "alias_domain",
      "profit_account_id",
      "loss_account_id",
      "post_at",
      "type_control_ids",
      "account_control_ids",
      "restrict_mode_hash_table",

      "message_follower_ids",
      "activity_ids",
      "message_ids",
      "message_attachment_count",
      "display_name",
    ];

    try {
      await Module.getRecordsController<AccountJournalModel>(
        model: "account.journal",
        fields: kReleaseMode ? fields : fieldsDebug,
        domain: domain,
        fromJson: (data) => AccountJournalModel.fromJson(data),
        onResponse: (response) {
          print("response: ${response.length}");
          onResponse!(response);
        },
        showGlobalLoading: showGlobalLoading, // ✅ تمرير parameter
      );
    } catch (e) {
      print("Error obteniendo productos: $e");
    }
  }

  static bool _isUpdating = false;

  /// 1️⃣ جلب تفاصيل البنك والكاش
  static Future<void> getBankAndCashDetails({
    required OnResponse onResponse,
    required OnError onError,
  }) async {
    print("🔍 [getBankAndCashDetails] Starting...");

    try {
      Api.callKW(
        model: "account.journal",
        method: "search_read",
        args: [
          [
            [
              "type",
              "in",
              ["bank", "cash"],
            ],
          ],
          ["id", "type", "default_account_id"],
        ],
        kwargs: {},
        onResponse: (response) {
          print("✅ [getBankAndCashDetails] Response: $response");

          Map<String, Map<String, dynamic>> details = {};

          for (var journal in response) {
            int journalId = journal["id"];
            dynamic accountId = journal["default_account_id"]?[0];

            details[journal["type"]] = {
              "journal_id": journalId,
              "payment_account_id": accountId,
            };
          }

          print("📦 [getBankAndCashDetails] Final details: $details");
          onResponse(details);
        },
        onError: (err, e) {
          print("❌ [getBankAndCashDetails] Error: $e");
          onError(err, e);
        },
      );
    } catch (e) {
      print("🚨 [getBankAndCashDetails] Exception: $e");
    }
  }

  static Future<void> changeJournalDetails({
    OnResponse? onResponse,
    bool showGlobalLoading = true, // ✅ parameter جديد
  }) async {
    if (_isUpdating) {
      print(
        "⚠️ [changeJournalDetails] Already running, skipping duplicate call.",
      );
      return;
    }

    _isUpdating = true;
    print("🔁 [changeJournalDetails] Starting process...");

    try {
      await getBankAndCashDetails(
        onResponse: (details) async {
          print("📥 [changeJournalDetails] Received details: $details");

          await updateJournalsAutomatically(
            details: Map<String, Map<String, dynamic>>.from(details),
            onResponse: (res) {
              print("✅ [changeJournalDetails] Update completed successfully!");
              if (res != null) {
                onResponse!(res);
              }
            },
          );
        },
        onError: (err, e) {
          print("❌ [changeJournalDetails] Error fetching details: $e");
        },
      );
    } catch (e) {
      print("🚨 [changeJournalDetails] Exception: $e");
    } finally {
      _isUpdating = false;
      print("🏁 [changeJournalDetails] Process finished.");
    }
  }

  /// 3️⃣ إدراج الأسطر (inbound + outbound) للبنك والكاش
  static Future<void> updateJournalsAutomatically({
    required Map<String, Map<String, dynamic>> details,
    void Function(dynamic)? onResponse,
  }) async {
    print("🧩 [updateJournalsAutomatically] Preparing webSave...");

    try {
      for (var entry in details.entries) {
        final type = entry.key;
        final journal = entry.value;

        dynamic journalId = journal["journal_id"];
        dynamic accountId = journal["payment_account_id"];

        if (journalId == null || accountId == null) {
          print("⚠️ Missing IDs for $type, skipping...");
          continue;
        }

        // التحقق من وجود الأسطر
        bool linesExist = await checkIfPaymentLinesExist(journalId);

        if (linesExist) {
          print(
            "⚠️ Payment lines already exist for $type (journal $journalId), skipping...",
          );
          continue;
        }

        print(
          "➡️ Updating $type | journal_id=$journalId | account_id=$accountId",
        );

        final values = {
          "inbound_payment_method_line_ids": [
            [
              0,
              "virtual_${journalId}_in",
              {
                "sequence": 11,
                "payment_method_id": 1,
                "name": "Paiement manuel ",
                "payment_account_id": accountId,
                "payment_provider_id": false,
              },
            ],
          ],
          "outbound_payment_method_line_ids": [
            [
              0,
              "virtual_${journalId}_out",
              {
                "sequence": 11,
                "payment_method_id": 2,
                "name": "Paiement manuel ",
                "payment_account_id": accountId,
              },
            ],
          ],
        };

        print("📤 Sending payload for $type: $values");

        // استخدام webSave
        await Api.webSave(
          model: "account.journal",
          ids: [journalId],
          values: values,
          specification: {},
          onResponse: (res) {
            onResponse!(res);
          },
          onError: (err, e) {
            print("❌ Error updating $type: $err | $e");
          },
        );
      }

      print("🏁 All journals processed successfully.");
      onResponse!(true);
    } catch (e) {
      print("🚨 Exception: $e");
    }
  }

  /// 4️⃣ دالة للتحقق من وجود الأسطر
  static Future<bool> checkIfPaymentLinesExist(int journalId) async {
    final completer = Completer<bool>();

    Api.callKW(
      model: "account.payment.method.line",
      method: "search_count",
      args: [
        [
          ["journal_id", "=", journalId],
          ["name", "=", "Paiement manuel "],
        ],
      ],
      kwargs: {},
      onResponse: (count) {
        print("🔍 Found $count existing lines for journal $journalId");
        completer.complete(count > 0);
      },
      onError: (err, e) {
        print("❌ Error checking lines: $e");
        completer.complete(false);
      },
    );

    return completer.future;
  }
}
