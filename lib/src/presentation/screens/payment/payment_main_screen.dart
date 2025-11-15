import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/controllers/payment_controller.dart';
import 'package:gsloution_mobile/src/presentation/screens/payment/sections/payment_list_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/drawer/dashboard_drawer.dart';
import 'package:gsloution_mobile/src/presentation/widgets/floating_aciton_button/custom_floating_action_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/search_field/custom_search_Field.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:sidebarx/sidebarx.dart';

class PaymentMainScreen extends StatefulWidget {
  const PaymentMainScreen({super.key});

  @override
  State<PaymentMainScreen> createState() => _PaymentMainScreenState();
}

class _PaymentMainScreenState extends State<PaymentMainScreen> {
  final controller = SidebarXController(selectedIndex: 1, extended: true);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final PaymentController paymentController = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      endDrawer: DashboardDrawer(routeName: "Payment", controller: controller),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white70,
        automaticallyImplyLeading: true,
        centerTitle: true,
        surfaceTintColor: Colors.white,
        title: Text(
          "Payments",
          style: GoogleFonts.raleway(
            textStyle: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.keyboard_arrow_left,
            size: 30,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!Platform.isAndroid && !Platform.isIOS) {
                controller.setExtended(true);
              }
              if (_key.currentState != null) {
                _key.currentState?.openEndDrawer();
              }
            },
            icon: const Icon(
              Icons.menu,
              size: 30,
            ),
          )
        ],
      ),
      body: Container(
        color: Colors.white70,
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomSearchField(
                hintText: "Search Payments",
                onChanged: (value) {
                  paymentController.search(value);
                },
              ),
            ),
            const SizedBox(height: 10),
            _buildFilterChips(),
            const SizedBox(height: 10),
            const Expanded(child: PaymentListSection())
          ],
        ),
      ),
      floatingActionButton: const CustomFloatingActionButton(
        buttonName: "Add Payment",
        routeName: AppRoutes.createPayment,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _filterChip('All', 'all'),
              const SizedBox(width: 8),
              _filterChip('Draft', 'draft'),
              const SizedBox(width: 8),
              _filterChip('Posted', 'posted'),
              const SizedBox(width: 8),
              _filterChip('Reconciled', 'reconciled'),
            ],
          ),
        ));
  }

  Widget _filterChip(String label, String value) {
    final isSelected = paymentController.selectedFilter.value == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          paymentController.setFilter(value);
        }
      },
      selectedColor: Colors.blue.shade100,
      checkmarkColor: Colors.blue,
    );
  }
}
