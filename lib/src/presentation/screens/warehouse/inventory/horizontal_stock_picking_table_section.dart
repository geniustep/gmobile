// lib/src/presentation/screens/inventory/stock_picking_sections/horizontal_stock_picking_table_section.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/inventory/stock_picking_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_picking/stock_picking_model.dart';

enum QuickFilter { today, last7Days, last30Days, custom }

class HorizontalStockPickingTableSection extends StatefulWidget {
  final RxList<StockPickingModel> stockPickings;
  const HorizontalStockPickingTableSection({
    required this.stockPickings,
    super.key,
  });

  @override
  State<HorizontalStockPickingTableSection> createState() =>
      _HorizontalStockPickingTableSectionState();
}

class _HorizontalStockPickingTableSectionState
    extends State<HorizontalStockPickingTableSection> {
  final TextEditingController _searchController = TextEditingController();
  final RxList<StockPickingModel> filteredStockPickings =
      <StockPickingModel>[].obs;
  final RxBool isLoading = false.obs;

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedStatus = 'All';
  QuickFilter _selectedQuickFilter = QuickFilter.last30Days;

  final List<String> _statusFilters = [
    'All',
    'Brouillon',
    'Confirmé',
    'Assigné',
    'Terminé',
    'Annulé',
  ];
  @override
  void initState() {
    super.initState();
    filteredStockPickings.assignAll(widget.stockPickings);

    // ✅ الاستماع للتغييرات
    ever(widget.stockPickings, (_) {
      _applyAllFilters();
    });

    // ✅ تطبيق الفلتر الافتراضي
    _applyQuickFilter(_selectedQuickFilter);
  }

  void _applyQuickFilter(QuickFilter filter) {
    final now = DateTime.now();

    setState(() {
      _selectedQuickFilter = filter;

      switch (filter) {
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

  void _applyAllFilters() {
    if (!mounted) return;

    isLoading.value = true;

    final query = _searchController.text.trim().toLowerCase();

    List<StockPickingModel> result = widget.stockPickings.toList();

    // 🔍 فلتر البحث
    if (query.isNotEmpty) {
      result = result.where((picking) {
        final name = picking.name?.toLowerCase() ?? '';
        final origin = picking.origin?.toString().toLowerCase() ?? '';
        final state = _getPickingStateLabel(picking.state ?? '').toLowerCase();

        String partnerInfo = '';
        if (picking.partnerId != null) {
          if (picking.partnerId is Map) {
            partnerInfo =
                picking.partnerId['display_name']?.toString().toLowerCase() ??
                '';
          } else if (picking.partnerId is List &&
              picking.partnerId.length > 1) {
            partnerInfo = picking.partnerId[1].toString().toLowerCase();
          }
        }

        return name.contains(query) ||
            origin.contains(query) ||
            state.contains(query) ||
            partnerInfo.contains(query);
      }).toList();
    }

    // 📅 فلتر التاريخ
    if (_startDate != null || _endDate != null) {
      result = result.where((picking) {
        final pickingDate = _parsePickingDate(picking);
        if (pickingDate == null) return false;

        final matchesStart =
            _startDate == null ||
            pickingDate.isAfter(_startDate!.subtract(const Duration(days: 1)));
        final matchesEnd =
            _endDate == null ||
            pickingDate.isBefore(_endDate!.add(const Duration(days: 1)));

        return matchesStart && matchesEnd;
      }).toList();
    }

    // 📊 فلتر الحالة
    if (_selectedStatus != 'All') {
      result = result.where((picking) {
        final statusLabel = _getPickingStateLabel(picking.state ?? '');
        return statusLabel == _selectedStatus;
      }).toList();
    }

    // ✅ ترتيب النتائج حسب التاريخ (الأحدث أولاً)
    result.sort((a, b) {
      final dateA = _parsePickingDate(a);
      final dateB = _parsePickingDate(b);

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    filteredStockPickings.assignAll(result);
    isLoading.value = false;

    // ✅ تحديث الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  DateTime? _parsePickingDate(StockPickingModel picking) {
    try {
      if (picking.scheduledDate != null) {
        return DateTime.parse(picking.scheduledDate!);
      }
      return null;
    } catch (e) {
      debugPrint('Error parsing date for ${picking.name}: $e');
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
          _buildStatisticsCards(),
          const SizedBox(height: 16),

          _buildStockPickingList(),
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
              hintText: "Rechercher des transferts...",
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
              labelText: "Statut",
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
          _buildCompactFilterChip(
            label: "Aujourd'hui",
            filter: QuickFilter.today,
          ),
          const SizedBox(width: 8),
          _buildCompactFilterChip(label: "7J", filter: QuickFilter.last7Days),
          const SizedBox(width: 8),
          _buildCompactFilterChip(label: "30J", filter: QuickFilter.last30Days),
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
              "Personnalisé",
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
              ? (isStart ? "Date de début" : "Date de fin")
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
          "Effacer les filtres",
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

  Widget _buildStatisticsCards() {
    return Obx(() {
      final totalPickings = filteredStockPickings.length;
      final completedPickings = filteredStockPickings
          .where((picking) => picking.state == 'done')
          .length;
      final pendingPickings = filteredStockPickings
          .where(
            (picking) =>
                picking.state == 'confirmed' || picking.state == 'assigned',
          )
          .length;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              "Total Transferts",
              "$totalPickings",
              Icons.inventory_2_outlined,
              AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "Terminés",
              "$completedPickings",
              Icons.check_circle_outlined,
              Color(0xFF059669),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              "En Attente",
              "$pendingPickings",
              Icons.pending_actions_outlined,
              Color(0xFFF59E0B),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.raleway(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockPickingList() {
    return Expanded(
      child: Obx(() {
        if (isLoading.value && filteredStockPickings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  "Chargement des transferts...",
                  style: GoogleFonts.raleway(color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }

        if (filteredStockPickings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 64,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  _searchController.text.isEmpty
                      ? "Aucun transfert trouvé"
                      : "Aucun résultat trouvé",
                  style: GoogleFonts.raleway(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchController.text.isEmpty
                      ? "Les transferts apparaîtront ici"
                      : "Essayez d'autres termes de recherche",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredStockPickings.length,
          padding: const EdgeInsets.only(bottom: 20),
          itemBuilder: (context, index) {
            final picking = filteredStockPickings[index];
            return _buildStockPickingCard(picking);
          },
        );
      }),
    );
  }

  Widget _buildStockPickingCard(StockPickingModel picking) {
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
        onTap: () =>
            Get.to(() => StockPickingDetailScreen(stockPicking: picking)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      picking.name ?? 'Transfert',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  _buildEnhancedStateBadge(picking.state ?? 'draft'),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      picking.partnerId["display_name"]?.toString() ?? 'Client',
                      style: GoogleFonts.raleway(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 14,
                    color: FunctionalColors.iconSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      picking.origin?.toString() ?? 'Sans origine',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: FunctionalColors.iconSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatDate(picking.scheduledDate) ?? 'Date non définie',
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedStateBadge(String state) {
    final colors = _getPickingStatusColors(state);
    final label = _getPickingStateLabel(state);
    final icon = _getPickingStatusIcon(state);

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

  // ========== HELPER METHODS ==========

  String _getPickingStateLabel(String state) {
    switch (state) {
      case 'draft':
        return 'Brouillon';
      case 'confirmed':
        return 'Confirmé';
      case 'assigned':
        return 'Assigné';
      case 'done':
        return 'Terminé';
      case 'cancel':
        return 'Annulé';
      default:
        return state;
    }
  }

  Map<String, Color> _getPickingStatusColors(String state) {
    const Color doneColor = Color(0xFF059669);
    const Color doneBgColor = Color(0xFFD1FAE5);
    const Color assignedColor = Color(0xFFF59E0B);
    const Color assignedBgColor = Color(0xFFFEF3C7);

    switch (state) {
      case 'draft':
        return {'color': StatusColors.draft, 'bg': StatusColors.draftBg};
      case 'confirmed':
        return {'color': StatusColors.sent, 'bg': StatusColors.sentBg};
      case 'assigned':
        return {'color': assignedColor, 'bg': assignedBgColor};
      case 'done':
        return {'color': doneColor, 'bg': doneBgColor};
      case 'cancel':
        return {'color': StatusColors.cancel, 'bg': StatusColors.cancelBg};
      default:
        return {'color': AppColors.textSecondary, 'bg': AppColors.background};
    }
  }

  IconData _getPickingStatusIcon(String state) {
    switch (state) {
      case 'draft':
        return Icons.edit_outlined;
      case 'confirmed':
        return Icons.checklist_outlined;
      case 'assigned':
        return Icons.inventory_2_outlined;
      case 'done':
        return Icons.check_circle_outlined;
      case 'cancel':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String? _formatDate(String? date) {
    if (date == null) return null;
    try {
      final dateTime = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
