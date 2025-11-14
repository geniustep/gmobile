import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/models/stock/stock_warehouse/stock_warehouse_module.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/warehouse/warehouse_sections/warehouse_list_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/floating_aciton_button/custom_floating_action_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/search_field/custom_search_Field.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';

class WarehouseMainScreen extends StatefulWidget {
  const WarehouseMainScreen({super.key});

  @override
  State<WarehouseMainScreen> createState() => _WarehouseMainScreenState();
}

class _WarehouseMainScreenState extends State<WarehouseMainScreen> {
  bool _isSyncing = false;

  Future<void> _syncWarehouses() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    try {
      if (kDebugMode) {
        print('🔄 Syncing warehouses from server...');
      }

      StockWarehouseModule.searchStockWarehouse(
        domain: [
          ["active", "=", true]
        ],
        onResponse: (response) {
          if (response.isNotEmpty) {
            final warehouses = response.values.first;
            PrefUtils.setWarehouses(warehouses.obs);
            
            if (kDebugMode) {
              print('✅ Synced ${warehouses.length} warehouses');
            }

            Get.snackbar(
              "Success",
              "تم مزامنة ${warehouses.length} مستودع بنجاح",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          } else {
            if (kDebugMode) {
              print('⚠️ No warehouses found');
            }
            Get.snackbar(
              "Warning",
              "لم يتم العثور على مستودعات",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange,
              colorText: Colors.white,
            );
          }

          setState(() {
            _isSyncing = false;
          });
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error syncing warehouses: $e');
      }
      Get.snackbar(
        "Error",
        "حدث خطأ أثناء مزامنة المستودعات: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isSyncing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          title: const Text("Warehouse"),
          actions: [
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.sync),
              onPressed: _isSyncing ? null : _syncWarehouses,
              tooltip: "مزامنة المستودعات",
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white70,
        child: const Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomSearchField(hintText: "Search Warehouse"),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(child: WarehouseListSection()),
          ],
        ),
      ),
      floatingActionButton: const CustomFloatingActionButton(
        buttonName: "Add Warehouse",
        routeName: AppRoutes.addWarehouse,
      ),
    );
  }
}
