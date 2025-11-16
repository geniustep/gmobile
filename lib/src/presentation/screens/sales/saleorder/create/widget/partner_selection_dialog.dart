// lib/src/presentation/screens/sales/saleorder/create/widget/partner_selection_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class PartnerSelectionDialog extends StatefulWidget {
  final List<PartnerModel> partners;
  final dynamic selectedPartnerId;
  final Function(PartnerModel) onPartnerSelected;

  const PartnerSelectionDialog({
    Key? key,
    required this.partners,
    this.selectedPartnerId,
    required this.onPartnerSelected,
  }) : super(key: key);

  @override
  State<PartnerSelectionDialog> createState() => _PartnerSelectionDialogState();
}

class _PartnerSelectionDialogState extends State<PartnerSelectionDialog> {
  List<PartnerModel> _filteredPartners = [];
  final TextEditingController _searchController = TextEditingController();
  final bool _isAdmin = PrefUtils.user.value.isAdmin ?? false;

  @override
  void initState() {
    super.initState();
    _filteredPartners = _getFilteredPartners();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PartnerModel> _getFilteredPartners() {
    if (_isAdmin) {
      return widget.partners;
    } else {
      return widget.partners
          .where((partner) => (partner.customerRank ?? 0) > 0)
          .toList();
    }
  }

  void _filterPartners(String query) {
    setState(() {
      final basePartners = _getFilteredPartners();

      if (query.isEmpty) {
        _filteredPartners = basePartners;
      } else {
        _filteredPartners = basePartners.where((partner) {
          return partner.name.toLowerCase().contains(query.toLowerCase()) ||
              (partner.email?.toString().toLowerCase().contains(
                    query.toLowerCase(),
                  ) ??
                  false) ||
              (partner.phone?.toString().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildSearchBar(),
          _buildPartnerCount(),
          Expanded(child: _buildPartnersList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.person_outline, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'اختر العميل',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Get.back(),
            tooltip: 'إغلاق',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن العميل بالاسم أو البريد أو الهاتف...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterPartners('');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        onChanged: _filterPartners,
      ),
    );
  }

  Widget _buildPartnerCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'النتائج: ${_filteredPartners.length}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (widget.selectedPartnerId != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'محدد',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPartnersList() {
    if (_filteredPartners.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد نتائج',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرب البحث بكلمة أخرى',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredPartners.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final partner = _filteredPartners[index];
        final isSelected = widget.selectedPartnerId == partner.id;

        return _buildPartnerItem(partner, isSelected);
      },
    );
  }

  Widget _buildPartnerItem(PartnerModel partner, bool isSelected) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.blue, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          widget.onPartnerSelected(partner);
          Get.back();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _buildPartnerAvatar(partner),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partner.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (partner.email != null && partner.email != false) ...[
                      Row(
                        children: [
                          Icon(Icons.email, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              partner.email.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                    ],
                    if (partner.phone != null && partner.phone != false) ...[
                      Row(
                        children: [
                          Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            partner.phone.toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                    if (partner.customerRank != null &&
                        partner.customerRank != false) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'رتبة: ${partner.customerRank}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailingIcon(isSelected),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerAvatar(PartnerModel partner) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          partner.name.isNotEmpty ? partner.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }

  Widget _buildTrailingIcon(bool isSelected) {
    if (isSelected) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 20),
      );
    }

    return const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16);
  }
}

// Helper function لعرض الـ Dialog
void showPartnerSelectionDialog({
  BuildContext? context,
  required List<PartnerModel> partners,
  dynamic selectedPartnerId,
  required Function(PartnerModel) onPartnerSelected,
}) {
  Get.bottomSheet(
    PartnerSelectionDialog(
      partners: partners,
      selectedPartnerId: selectedPartnerId,
      onPartnerSelected: onPartnerSelected,
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
