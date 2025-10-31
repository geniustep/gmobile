import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/customer_route_model.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/dashboar_route_model.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/expense_route_model.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/invoice_route_model.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/products_route_model.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/reports_route_model.dart';
import 'package:gsloution_mobile/src/data/models/route_item_model/trading_route_model.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:sidebarx/sidebarx.dart';

class DashboardDrawer extends StatefulWidget {
  final String routeName;
  final SidebarXController controller;

  const DashboardDrawer(
      {super.key, required this.routeName, required this.controller});

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();

    switch (widget.routeName) {
      case "Dashboard":
        items = [
          ...DashboardRouteModel,
          {
            'icon': "assets/icons/icon_svg/log-out.svg",
            'label': 'Log Out',
            'route': AppRoutes.login
          }
        ];
        break;
      case "Products":
        items = ProductsRouteModel;
        break;
      case "Reports":
        items = reportsRouteModel;
        break;
      case "Expense":
        items = expenseRouteModel;
        break;
      case "Customer":
        items = customerRouteModel;
        break;
      case "Trading":
        items = tradingRouteModel;
        break;
      case "Invoice":
        items = invoiceRouteModel;
        break;
      default:
        items = DashboardRouteModel;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget.controller,
      theme: SidebarXTheme(
        selectedItemPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        textStyle: GoogleFonts.nunito(
            textStyle: const TextStyle(
                color: Color(0xFF333333),
                fontSize: 17,
                fontWeight: FontWeight.w500)),
        selectedTextStyle: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 16,
            fontWeight: FontWeight.w600),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8), color: Colors.blue.shade50),
        iconTheme: IconThemeData(
          color: Colors.black.withOpacity(0.7),
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
          width: 300, padding: EdgeInsets.symmetric(horizontal: 12)),
      showToggleButton: false,
      headerBuilder: (context, extended) {
        if (widget.routeName == "Dashboard") {
          return Column(
            children: [
              const SizedBox(
                height: 50,
              ),
              CircleAvatar(
                radius: 65,
                child: CircleAvatar(
                  radius: 60,
                  child: Image.asset("assets/images/avatar/user_profile.png"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Admin@gmail.com",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                    textStyle: const TextStyle(color: Colors.grey)),
              ),
              Text(
                "Admin",
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                    textStyle: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                )),
              ),
            ],
          );
        } else {
          return const SizedBox(
            height: 20,
          );
        }
      },
      items: items.map((item) {
        return SidebarXItem(
          iconWidget: SvgPicture.asset(
            item['icon'],
            height: 20,
            color: const Color(0xFF333333),
          ),
          label: item['label'],
          onTap: () {
            Get.toNamed(item['route']);
          },
        );
      }).toList(),
    );
  }
}
