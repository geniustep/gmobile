import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/create/create_new_order_form.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/saleOrderDetail/sale_order_new_detail_screen.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/saleorder/update/update_order_form.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/api_factory/models/order/sale_order_model.dart';
import 'package:gsloution_mobile/common/api_factory/models/order_line/order_line_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/purchase/purchase_sections/add_payment_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/salesSections/sale_generate_invoice-section.dart';
import 'package:gsloution_mobile/src/presentation/screens/sales/salesSections/sale_view_payment_card_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/delete_toast.dart';
import 'package:gsloution_mobile/common/services/draft/draft_sale_service.dart';

import '../saleorder/create/controllers/controllers.dart';

enum QuickFilter { all, today, last7Days, last30Days, custom }

class HorizontalSalesTableSection extends StatefulWidget {
  final RxList<OrderModel> sales;
  const HorizontalSalesTableSection({required this.sales, super.key});

  @override
  State<HorizontalSalesTableSection> createState() =>
      _HorizontalSalesTableSectionState();
}

class _HorizontalSalesTableSectionState
    extends State<HorizontalSalesTableSection> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<OrderModel> filteredSales = <OrderModel>[].obs;
  final RxList<Map<String, dynamic>> filteredDrafts =
      <Map<String, dynamic>>[].obs;
  final RxList<dynamic> combinedResults = <dynamic>[].obs;
  final RxBool isLoading = false.obs;

  // ✅ إضافة متغيرات الـ StreamSubscription
  StreamSubscription<int>? _draftCountSubscription;

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'All';
  QuickFilter _selectedQuickFilter = QuickFilter.last30Days;

  final List<String> _statusFilters = [
    'All',
    'Devis',
    'Envoyé',
    'Bon de commande',
    'Annulé',
  ];

  final DraftSaleService _draftService = DraftSaleService.instance;
  final RxList<Map<String, dynamic>> _allDrafts = <Map<String, dynamic>>[].obs;

  @override
  void initState() {
    super.initState();
    filteredSales.assignAll(widget.sales);

    // ✅ تم تهيئة الجدول

    // ✅ الاستماع لتغييرات widget.sales
    ever(widget.sales, (List<OrderModel> newSales) {
      filteredSales.assignAll(newSales);
      _applyAllFilters();
      filteredSales.refresh();
    });

    // ✅ تحميل المسودات أولاً
    _loadDrafts();

    _applyQuickFilter(_selectedQuickFilter);

    ever(widget.sales, (_) => _applyAllFilters());
    ever(_allDrafts, (_) => _applyAllFilters());

    // ✅ الاستماع لتحديثات عدد المسودات
    _setupDraftStreamListeners();
  }

  @override
  void didUpdateWidget(HorizontalSalesTableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // ✅ تحديث البيانات عند تحديث الويدجت
    filteredSales.assignAll(widget.sales);
    _applyAllFilters();
  }

  // ✅ دالة جديدة لإعداد مستمعي الـ Stream
  void _setupDraftStreamListeners() {
    // الاستماع لتغييرات عدد المسودات
    _draftCountSubscription = DraftSaleService.draftCountStream.listen((
      newCount,
    ) {
      if (mounted) {
        print('🔄 Draft count updated: $newCount - Refreshing drafts...');
        _loadDrafts(); // إعادة تحميل المسودات عند أي تغيير
      }
    });
  }

  Future<void> _loadDrafts() async {
    if (!mounted) return;

    try {
      print('🔄 Loading drafts from service...');
      isLoading.value = true;

      final drafts = await _draftService.getAllDrafts();
      print('📥 Loaded ${drafts.length} drafts from storage');

      // ✅ ترتيب المسودات حسب التاريخ (الأحدث أولاً)
      drafts.sort((a, b) {
        final dateA = DateTime.parse(a['lastModified'] ?? '2000-01-01');
        final dateB = DateTime.parse(b['lastModified'] ?? '2000-01-01');
        return dateB.compareTo(dateA);
      });

      _allDrafts.assignAll(drafts);

      // ✅ إعادة تطبيق الفلاتر فوراً
      _applyAllFilters();

      print('✅ Drafts loaded and filters applied: ${_allDrafts.length} drafts');
    } catch (e) {
      debugPrint('❌ Error loading drafts: $e');
      // ✅ حتى في حالة الخطأ، تأكد من إخفاء loading وتطبيق الفلاتر
      _applyAllFilters();
    } finally {
      isLoading.value = false;
    }
  }

  void _applyQuickFilter(QuickFilter filter) {
    final now = DateTime.now();

    setState(() {
      _selectedQuickFilter = filter;

      switch (filter) {
        case QuickFilter.all:
          _startDate = null;
          _endDate = null;
          break;

        case QuickFilter.today:
          _startDate = DateTime(now.year, now.month, now.day);
          _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;

        case QuickFilter.last7Days:
          _startDate = now.subtract(const Duration(days: 7));
          _endDate = now;
          break;

        case QuickFilter.last30Days:
          _startDate = now.subtract(const Duration(days: 30));
          _endDate = now;
          break;

        case QuickFilter.custom:
          break;
      }
    });

    _applyAllFilters();
  }

  void _openDraft(Map<String, dynamic> draft) async {
    print('🔍 Loading draft from banner: ${draft['id']}');
    print('📋 Draft data: $draft');

    // إغلاق جميع الـ controllers الحالية بنفس طريقة DraftSalesScreen
    await Get.delete<OrderController>(force: true);
    await Get.delete<DraftController>(force: true);
    await Get.delete<PartnerController>(force: true);

    await Future.delayed(const Duration(milliseconds: 100));

    // فتح صفحة CreateNewOrder مع المسودة مباشرة
    final result = await Get.to(() => CreateNewOrder(draft: draft));

    // إذا تم حفظ المسودة بنجاح، قم بتحديث القائمة
    if (result == true) {
      _loadDrafts();
    }
  }

  void _applyAllFilters() {
    if (!mounted) return;

    isLoading.value = true;

    final query = _searchController.text.trim().toLowerCase();

    // 🔍 فلتر طلبات المبيعات
    List<OrderModel> salesResult = widget.sales.toList();

    if (query.isNotEmpty) {
      salesResult = salesResult.where((sale) {
        final name = sale.name.toLowerCase();
        final partner = sale.partnerId[1].toLowerCase();
        final state = sale.state.toLowerCase();
        return name.contains(query) ||
            partner.contains(query) ||
            state.contains(query);
      }).toList();
    }

    // 📅 فلتر التاريخ للمبيعات
    if (_startDate != null || _endDate != null) {
      salesResult = salesResult.where((sale) {
        final saleDate = _parseSaleDate(sale);
        if (saleDate == null) return false;

        final matchesStart =
            _startDate == null ||
            saleDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
        final matchesEnd =
            _endDate == null ||
            saleDate.isBefore(_endDate!.add(const Duration(days: 1)));

        return matchesStart && matchesEnd;
      }).toList();
    }

    // 📊 فلتر الحالة للمبيعات
    if (_selectedStatus != 'All') {
      salesResult = salesResult.where((sale) {
        final statusLabel = StatusColors.getLabel(sale.state);
        return statusLabel.toLowerCase() == _selectedStatus.toLowerCase();
      }).toList();
    }

    filteredSales.assignAll(salesResult);

    // 🔍 فلتر المسودات (بنفس كلمة البحث)
    List<Map<String, dynamic>> draftResult = _allDrafts.toList();

    if (query.isNotEmpty) {
      draftResult = draftResult.where((draft) {
        final customerName = (draft['customer'] ?? '').toString().toLowerCase();
        final products = draft['products'] as List? ?? [];

        // البحث في اسم العميل
        if (customerName.contains(query)) {
          return true;
        }

        // البحث في أسماء المنتجات
        for (var product in products) {
          final productName = (product['name'] ?? '').toString().toLowerCase();
          if (productName.contains(query)) {
            return true;
          }
        }

        return false;
      }).toList();
    }

    filteredDrafts.assignAll(draftResult);

    // ✅ دمج النتائج في قائمة واحدة
    _combineResults();

    isLoading.value = false;

    // ✅ إرسال تحديث نهائي للواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _combineResults() {
    final List<dynamic> combined = [];
    combined.addAll(filteredDrafts);
    combined.addAll(filteredSales);
    combinedResults.assignAll(combined);

    // ✅ تم دمج النتائج بنجاح

    // ✅ إجبار تحديث الواجهة
    combinedResults.refresh();

    // ✅ تم تسجيل حالة الطلبات
  }

  DateTime? _parseSaleDate(OrderModel sale) {
    try {
      return DateTime.parse(sale.dateOrder);
    } catch (e) {
      debugPrint('Error parsing date for ${sale.name}: $e');
      return null;
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
        _selectedQuickFilter = QuickFilter.custom;
      });
      _applyAllFilters();
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _startDate = null;
      _endDate = null;
      _selectedStatus = 'All';
      _selectedQuickFilter = QuickFilter.last30Days;
    });
    _applyQuickFilter(_selectedQuickFilter);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat("#,##0.00", "en_US");

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndStatusRow(),
          const SizedBox(height: 12),
          _buildCompactQuickFilters(),

          if (_selectedQuickFilter == QuickFilter.custom) ...[
            const SizedBox(height: 12),
            _buildDateFilterRow(),
          ],

          const SizedBox(height: 12),
          _buildClearFiltersButton(),
          const SizedBox(height: 16),
          _buildTotalSalesCard(currency),
          const SizedBox(height: 16),

          _buildSalesList(),
        ],
      ),
    );
  }

  Widget _buildSearchAndStatusRow() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            controller: _searchController,
            onChanged: (_) => _applyAllFilters(),
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cardBackground,
              prefixIcon: Icon(
                Icons.search,
                color: FunctionalColors.iconSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.refresh, size: 20),
                onPressed: _loadDrafts,
                tooltip: 'Refresh drafts',
              ),
              hintText: "Search sales and drafts...",
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: _selectedStatus,
            isExpanded: true,
            items: _statusFilters
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => _selectedStatus = val!);
              _applyAllFilters();
            },
            style: TextStyle(color: AppColors.textPrimary, fontSize: 12),
            decoration: InputDecoration(
              labelText: "Status",
              labelStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
              filled: true,
              fillColor: AppColors.cardBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactQuickFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildCompactFilterChip(label: "الكل", filter: QuickFilter.all),
          const SizedBox(width: 8),
          _buildCompactFilterChip(label: "Today", filter: QuickFilter.today),
          const SizedBox(width: 8),
          _buildCompactFilterChip(label: "7D", filter: QuickFilter.last7Days),
          const SizedBox(width: 8),
          _buildCompactFilterChip(label: "30D", filter: QuickFilter.last30Days),
          const SizedBox(width: 8),
          _buildCustomFilterChip(),
        ],
      ),
    );
  }

  Widget _buildCompactFilterChip({
    required String label,
    required QuickFilter filter,
  }) {
    final isSelected = _selectedQuickFilter == filter;

    return InkWell(
      onTap: () => _applyQuickFilter(filter),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.raleway(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildCustomFilterChip() {
    final isSelected = _selectedQuickFilter == QuickFilter.custom;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedQuickFilter = QuickFilter.custom;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: isSelected ? Colors.white : FunctionalColors.iconPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              "Custom",
              style: GoogleFonts.raleway(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterRow() {
    return Row(
      children: [
        Expanded(child: _buildDateField(true)),
        const SizedBox(width: 10),
        Expanded(child: _buildDateField(false)),
      ],
    );
  }

  Widget _buildDateField(bool isStart) {
    final date = isStart ? _startDate : _endDate;
    return InkWell(
      onTap: () => _pickDate(isStart),
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.cardBackground,
          prefixIcon: Icon(
            Icons.calendar_today,
            color: FunctionalColors.iconSecondary,
            size: 18,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border, width: 1.5),
          ),
        ),
        child: Text(
          date == null
              ? (isStart ? "From date" : "To date")
              : DateFormat("yyyy-MM-dd").format(date),
          style: TextStyle(
            color: date == null ? AppColors.textMuted : AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildClearFiltersButton() {
    if (_searchController.text.isEmpty &&
        _selectedStatus == 'All' &&
        _selectedQuickFilter == QuickFilter.last30Days) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton.icon(
        onPressed: _clearAllFilters,
        icon: Icon(Icons.clear_all, size: 16, color: AppColors.primary),
        label: Text(
          "Clear Filters",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTotalSalesCard(NumberFormat currency) {
    return Obx(() {
      final totalSales = filteredSales.fold<double>(
        0,
        (sum, sale) => sum + (sale.amountTotal ?? 0),
      );

      final totalDrafts = filteredDrafts.fold<double>(
        0,
        (sum, draft) => sum + (_calculateDraftTotal(draft)),
      );

      return Card(
        elevation: 0,
        color: AppColors.primaryLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.primary.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.payments_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total Sales",
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${currency.format(totalSales)} MAD",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (filteredDrafts.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        "+ ${currency.format(totalDrafts)} MAD in drafts",
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${filteredSales.length} orders",
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  if (filteredDrafts.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${filteredDrafts.length} drafts",
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSalesList() {
    return Expanded(
      child: Obx(() {
        if (isLoading.value && _allDrafts.isEmpty && filteredSales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  "Loading drafts and sales...",
                  style: GoogleFonts.raleway(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (combinedResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? "No sales or drafts found"
                      : "No results found",
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isEmpty
                      ? "Try creating a new order"
                      : "Try different search terms",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadDrafts,
                  icon: Icon(Icons.refresh, size: 18),
                  label: Text("Refresh"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: combinedResults.length,
          padding: const EdgeInsets.only(bottom: 80),
          itemBuilder: (context, index) {
            final item = combinedResults[index];

            if (item is Map<String, dynamic>) {
              return _buildDraftCard(item);
            } else if (item is OrderModel) {
              return _buildSaleCard(item);
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      }),
    );
  }

  Widget _buildDraftCard(Map<String, dynamic> draft) {
    final total = _calculateDraftTotal(draft);
    final productCount = _countProducts(draft);
    final customerName = draft['customer'] ?? 'عميل';
    final lastModified = draft['lastModified'] != null
        ? _formatDraftDate(draft['lastModified'])
        : 'غير معروف';

    return InkWell(
      onTap: () => _openDraft(draft),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.amber.shade50],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_rounded,
                            size: 16,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'مسودة',
                            style: GoogleFonts.raleway(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customerName.toString(),
                        style: GoogleFonts.raleway(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'آخر تعديل: $lastModified',
                        style: GoogleFonts.nunito(
                          color: AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    '$productCount منتج',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${NumberFormat("#,##0.00").format(total)} MAD',
                  style: GoogleFonts.nunito(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),

                Row(
                  children: [
                    _buildDraftActionButton(
                      'فتح',
                      Icons.edit_rounded,
                      Colors.orange.shade700,
                      () => _openDraft(draft),
                    ),
                    const SizedBox(width: 8),
                    _buildDraftActionButton(
                      'حذف',
                      Icons.delete_outline,
                      FunctionalColors.buttonDanger,
                      () => _showDeleteDraftConfirmation(draft),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftActionButton(
    String text,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                text,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDraftTotal(Map<String, dynamic> draft) {
    try {
      final products = draft['products'] as List? ?? [];
      double total = 0.0;

      for (var product in products) {
        final quantity = (product['quantity'] ?? 1).toDouble();
        final price = (product['price'] ?? 0).toDouble();
        total += quantity * price;
      }

      return total;
    } catch (e) {
      return 0.0;
    }
  }

  int _countProducts(Map<String, dynamic> draft) {
    try {
      final products = draft['products'] as List? ?? [];
      return products.length;
    } catch (e) {
      return 0;
    }
  }

  String _formatDraftDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('yyyy-MM-dd – HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showDeleteDraftConfirmation(Map<String, dynamic> draft) {
    final customerName = draft['customer'] ?? 'هذه المسودة';
    final draftId = draft['id']?.toString() ?? '';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBackground,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            Text(
              'تأكيد الحذف',
              style: GoogleFonts.raleway(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف مسودة $customerName؟\nلا يمكن التراجع عن هذا الإجراء.',
          style: GoogleFonts.nunito(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              'إلغاء',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _deleteDraft(draftId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FunctionalColors.buttonDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'حذف',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteDraft(String draftId) async {
    try {
      await _draftService.deleteDraft(draftId);
      // ✅ لا حاجة لاستدعاء _loadDrafts() هنا لأن الـ Stream سيتولى ذلك
      Get.snackbar(
        'تم الحذف',
        'تم حذف المسودة بنجاح',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل في حذف المسودة',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }

  Widget _buildSaleCard(OrderModel entry) {
    final productCount = entry.orderLine != null && entry.orderLine is List
        ? (entry.orderLine as List).length
        : 0;
    final sellerName =
        entry.userId != null && entry.userId is List && entry.userId.length > 1
        ? entry.userId[1].toString()
        : 'غير محدد';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      shadowColor: FunctionalColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      color: AppColors.cardBackground,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleOrderNewDetailScreen(salesOrder: entry),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              // السطر 1: رقم الطلب + القائمة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.name,
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      color: FunctionalColors.iconPrimary,
                      size: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: AppColors.cardBackground,
                    onSelected: (value) => _handleAction(value, entry),
                    itemBuilder: (context) => [
                      _buildMenuItem('Edit', Icons.edit_outlined),
                      _buildMenuItem('Invoice', Icons.receipt_long_outlined),
                      _buildMenuItem('Payment', Icons.payment_outlined),
                      _buildMenuItem('View Payment', Icons.visibility_outlined),
                      const PopupMenuDivider(),
                      _buildMenuItem(
                        'Delete',
                        Icons.delete_outline,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // السطر 2: اسم العميل + المجموع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: FunctionalColors.iconSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _getPartnerName(entry.partnerId),
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${NumberFormat("#,##0.00").format(entry.amountTotal ?? 0)} MAD',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // السطر 3: التاريخ + الحالة
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: FunctionalColors.iconSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        entry.dateOrder.split(' ').first,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  _buildEnhancedStateBadge(entry.state),
                ],
              ),

              const SizedBox(height: 10),

              // السطر 4: عدد المنتجات + البائع
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 14,
                        color: FunctionalColors.iconSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$productCount ${productCount == 1 ? 'product' : 'products'}',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 14,
                        color: FunctionalColors.iconSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        sellerName,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isDestructive
                ? FunctionalColors.buttonDanger
                : FunctionalColors.iconPrimary,
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
              color: isDestructive
                  ? FunctionalColors.buttonDanger
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedStateBadge(String state) {
    final colors = StatusColors.getColors(state);
    final label = StatusColors.getLabel(state);
    final icon = StatusColors.getIcon(state);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors['color']!.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors['color'], size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.raleway(
                color: colors['color'],
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _handleAction(String value, OrderModel entry) {
    switch (value) {
      case 'Edit':
        _editOrder(entry);
        break;
      case 'Invoice':
        _generateInvoice(entry);
        break;
      case 'Payment':
        _addPayment(entry);
        break;
      case 'View Payment':
        _viewPayment(entry);
        break;
      case 'Delete':
        _deleteOrder(entry);
        break;
    }
  }

  void _editOrder(OrderModel entry) {
    // ✅ تصحيح الدخول إلى صفحة التعديل من لائحة المبيعات
    try {
      // تحويل List<dynamic> إلى RxList<OrderLineModel>
      final orderLines = <OrderLineModel>[].obs;
      if (entry.orderLine != null && entry.orderLine is List) {
        orderLines.addAll((entry.orderLine as List).cast<OrderLineModel>());
      }

      if (kDebugMode) {
        print('📝 Opening update order: ${entry.name}');
        print('   Order lines: ${orderLines.length}');
      }

      Get.to(() => UpdateOrder(salesOrder: entry, orderLine: orderLines));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error opening update order: $e');
      }

      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء فتح صفحة التعديل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  void _generateInvoice(OrderModel entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleGenerateInvoiceSection(products: entry),
      ),
    );
  }

  void _addPayment(OrderModel entry) {
    showModalBottomSheet(
      backgroundColor: AppColors.cardBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        child: AddPaymentSection(payment: entry),
      ),
    );
  }

  void _viewPayment(OrderModel entry) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBackground,
        child: SaleViewPaymentCardSection(payment: entry),
      ),
    );
  }

  void _deleteOrder(OrderModel entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.cardBackground,
        content: Text(
          "Are you sure you want to delete order for ${_getPartnerName(entry.partnerId)}?\nThis action cannot be undone.",
          style: GoogleFonts.nunito(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: Text(
              "Cancel",
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDelete(entry);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FunctionalColors.buttonDanger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              "Delete",
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(OrderModel entry) {
    widget.sales.remove(entry);
    PrefUtils.saveSales(widget.sales);
    DeleteToast.showDeleteToast(context, _getPartnerName(entry.partnerId));
    _applyAllFilters();
  }

  /// الحصول على اسم العميل بطريقة آمنة
  String _getPartnerName(dynamic partnerId) {
    if (partnerId == null) return 'غير محدد';

    if (partnerId is List && partnerId.length > 1) {
      // إذا كان List، خذ العنصر الثاني (الاسم)
      return partnerId[1].toString();
    } else if (partnerId is int) {
      // إذا كان int، ابحث عن الاسم في قائمة العملاء
      try {
        final partner = PrefUtils.partners.firstWhere((p) => p.id == partnerId);
        return partner.name;
      } catch (e) {
        return 'عميل #$partnerId';
      }
    } else {
      return partnerId.toString();
    }
  }

  @override
  void dispose() {
    // ✅ إلغاء جميع الاشتراكات في الـ Streams
    _draftCountSubscription?.cancel();

    _searchController.dispose();
    super.dispose();
  }
}
