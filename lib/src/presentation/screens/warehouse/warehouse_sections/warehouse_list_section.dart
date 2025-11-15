import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_warehouse/stock_warehouse_model.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/warehouse_sections/update_warehouse_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/toast/delete_toast.dart';

class WarehouseListSection extends StatefulWidget {
  const WarehouseListSection({
    Key? key,
  }) : super(key: key);

  @override
  State<WarehouseListSection> createState() => _WarehouseListSectionState();
}

class _WarehouseListSectionState extends State<WarehouseListSection> {
  @override
  void initState() {
    super.initState();
    _loadWarehouses();
  }

  Future<void> _loadWarehouses() async {
    await PrefUtils.getWarehouses();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final warehouses = PrefUtils.warehouses;
      final hasWarehouses = warehouses.isNotEmpty;

      if (!hasWarehouses) {
        // إذا لم تكن هناك مستودعات من السيرفر، عرض رسالة فارغة
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warehouse_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "No Warehouses Found",
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _loadWarehouses,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: warehouses.length,
        itemBuilder: (context, index) {
          final warehouse = warehouses[index];
          return _buildWarehouseCardFromModel(warehouse, index);
        },
      );
    });
  }

  Widget _buildWarehouseCardFromModel(StockWarehouseModel warehouse, int index) {
    final name = warehouse.name?.toString() ?? warehouse.displayName?.toString() ?? "Unknown Warehouse";
    final code = warehouse.code?.toString() ?? "";
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.store_mall_directory, color: Colors.blue.shade300, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.raleway(
                          color: const Color(0xFF5D6571),
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (code.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.blue.shade300, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "Code: $code",
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFA0A0A3),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.blue.shade50.withOpacity(0.5),
                ),
                child: IconButton(
                  icon: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SvgPicture.asset(
                      "assets/icons/icon_svg/edit_icon.svg",
                      color: Colors.blue,
                    ),
                  ),
                  onPressed: () {
                    buildModalBottomSheetForModel(context, warehouse);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void buildModalBottomSheetForModel(BuildContext context, StockWarehouseModel warehouse) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 0,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      context: context,
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: UpdateWarehouseSection(warehouse: warehouse),
        );
      },
    );
  }
}
