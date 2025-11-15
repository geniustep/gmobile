import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/controllers/invoice_controller.dart';
import 'package:gsloution_mobile/src/presentation/screens/invoice/invoice_sections/sale_invoice_list_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/drawer/dashboard_drawer.dart';
import 'package:gsloution_mobile/src/presentation/widgets/floating_aciton_button/custom_floating_action_button.dart';
import 'package:gsloution_mobile/src/presentation/widgets/search_field/custom_search_Field.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:sidebarx/sidebarx.dart';

class InvoiceMainScreen extends StatefulWidget {
  const InvoiceMainScreen({super.key});

  @override
  State<InvoiceMainScreen> createState() => _InvoiceMainScreenState();
}

class _InvoiceMainScreenState extends State<InvoiceMainScreen> {
  final controller = SidebarXController(selectedIndex: 1, extended: true);
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final InvoiceController invoiceController = Get.find<InvoiceController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        endDrawer:
            DashboardDrawer(routeName: "Invoice", controller: controller),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white70,
          automaticallyImplyLeading: true,
          centerTitle: true,
          surfaceTintColor: Colors.white,
          title: Text(
            "Sale Invoice",
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
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomSearchField(
                  hintText: "Search Sale Invoice",
                  onChanged: (value) {
                    invoiceController.search(value);
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Expanded(child: SaleInvoiceListSection())
            ],
          ),
        ),
        floatingActionButton: const CustomFloatingActionButton(
            buttonName: "Add Sale Invoice",
            routeName: AppRoutes.addSaleInvoice));
  }
}
