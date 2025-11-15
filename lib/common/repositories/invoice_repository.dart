import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/invoice/account_move/account_move_module.dart';
import 'package:gsloution_mobile/common/repositories/base_repository.dart';
import 'package:gsloution_mobile/common/services/audit/audit_log_service.dart';

/// Invoice repository implementing the repository pattern
/// Handles all invoice-related data operations
class InvoiceRepository extends BaseRepository<AccountMoveModel> {
  InvoiceRepository() : super('invoice');

  @override
  Future<List<AccountMoveModel>> fetchAll({
    List<dynamic>? domain,
    bool showLoading = true,
  }) async {
    List<AccountMoveModel> invoices = [];

    await AccountMoveModule.searchReadAccountMove(
      onResponse: (response) {
        if (response != null && response.isNotEmpty) {
          invoices = response;
        }
      },
      domain: domain ?? [],
      showGlobalLoading: showLoading,
    );

    // Log audit
    await AuditLogService.log(
      action: AuditAction.view,
      entityType: entityName,
      description: 'عرض قائمة الفواتير',
    );

    return invoices;
  }

  @override
  Future<AccountMoveModel> fetchById(int id) async {
    AccountMoveModel? invoice;

    await AccountMoveModule.readInvoice(
      ids: [id],
      onResponse: (response) {
        if (response.isNotEmpty) {
          invoice = response.first;
        }
      },
    );

    if (invoice == null) {
      throw Exception('Invoice not found');
    }

    // Log audit
    await AuditLogService.log(
      action: AuditAction.view,
      entityType: entityName,
      entityId: id.toString(),
      description: 'عرض تفاصيل الفاتورة',
    );

    return invoice!;
  }

  @override
  Future<AccountMoveModel> performCreate(Map<String, dynamic> data) async {
    AccountMoveModel? createdInvoice;

    await AccountMoveModule.createInvoicePurchaseCall(
      invoiceData: data,
      onResponse: (response) {
        createdInvoice = response;
      },
    );

    if (createdInvoice == null) {
      throw Exception('Failed to create invoice');
    }

    return createdInvoice!;
  }

  @override
  Future<AccountMoveModel> performUpdate(int id, Map<String, dynamic> data) async {
    // Implementation would depend on your API
    // For now, throw not implemented
    throw UnimplementedError('Update invoice not implemented');
  }

  @override
  Future<bool> performDelete(int id) async {
    // Implementation would depend on your API
    // For now, throw not implemented
    throw UnimplementedError('Delete invoice not implemented');
  }

  @override
  Future<List<AccountMoveModel>> performSearch(String query) async {
    final domain = [
      '|',
      ['name', 'ilike', query],
      ['ref', 'ilike', query],
    ];

    return await fetchAll(domain: domain, showLoading: false);
  }

  @override
  Future<List<AccountMoveModel>> performFilter(Map<String, dynamic> filters) async {
    List<dynamic> domain = [];

    // Invoice number filter
    if (filters['invoice_number'] != null) {
      domain.add(['name', 'ilike', filters['invoice_number']]);
    }

    // Customer name filter
    if (filters['customer_name'] != null) {
      domain.add(['partner_id', 'ilike', filters['customer_name']]);
    }

    // State filter
    if (filters['state'] != null) {
      domain.add(['state', '=', filters['state']]);
    }

    // Payment state filter
    if (filters['payment_state'] != null) {
      domain.add(['invoice_payment_state', '=', filters['payment_state']]);
    }

    // Amount range filter
    if (filters['min_amount'] != null) {
      domain.add(['amount_total', '>=', filters['min_amount']]);
    }
    if (filters['max_amount'] != null) {
      domain.add(['amount_total', '<=', filters['max_amount']]);
    }

    // Date range filter
    if (filters['start_date'] != null) {
      domain.add(['invoice_date', '>=', filters['start_date']]);
    }
    if (filters['end_date'] != null) {
      domain.add(['invoice_date', '<=', filters['end_date']]);
    }

    return await fetchAll(domain: domain, showLoading: false);
  }

  /// Confirm/Post invoice
  Future<bool> confirmInvoice(int id) async {
    bool success = false;

    await AccountMoveModule.comptabliseInvoiceSales(
      args: [id],
      onResponse: (response) {
        success = response == true;
      },
    );

    if (success) {
      // Log audit
      await AuditLogService.log(
        action: AuditAction.confirm,
        entityType: entityName,
        entityId: id.toString(),
        description: 'تأكيد الفاتورة',
      );
    }

    return success;
  }

  /// Get unpaid invoices
  Future<List<AccountMoveModel>> getUnpaidInvoices() async {
    final domain = [
      '|',
      ['invoice_payment_state', '=', 'not_paid'],
      ['invoice_payment_state', '=', 'partial'],
    ];

    return await fetchAll(domain: domain, showLoading: false);
  }

  /// Get overdue invoices
  Future<List<AccountMoveModel>> getOverdueInvoices() async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final domain = [
      ['invoice_date_due', '<', today],
      ['invoice_payment_state', '!=', 'paid'],
      ['state', '=', 'posted'],
    ];

    return await fetchAll(domain: domain, showLoading: false);
  }

  /// Get invoices by customer
  Future<List<AccountMoveModel>> getInvoicesByCustomer(int partnerId) async {
    final domain = [
      ['partner_id', '=', partnerId],
    ];

    return await fetchAll(domain: domain, showLoading: false);
  }

  /// Get draft invoices
  Future<List<AccountMoveModel>> getDraftInvoices() async {
    final domain = [
      ['state', '=', 'draft'],
    ];

    return await fetchAll(domain: domain, showLoading: false);
  }

  @override
  String getCreateEndpoint() => '/api/invoices/create';

  @override
  String getUpdateEndpoint(int id) => '/api/invoices/$id/update';

  @override
  String getDeleteEndpoint(int id) => '/api/invoices/$id/delete';
}
