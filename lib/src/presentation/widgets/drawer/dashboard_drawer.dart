import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:sidebarx/sidebarx.dart';

class DashboardDrawer extends StatefulWidget {
  final String routeName;
  final SidebarXController controller;

  const DashboardDrawer({
    super.key,
    required this.routeName,
    required this.controller,
  });

  @override
  State<DashboardDrawer> createState() => _DashboardDrawerState();
}

class _DashboardDrawerState extends State<DashboardDrawer> {
  late List<Map<String, dynamic>> items;

  @override
  void initState() {
    super.initState();

    // TODO: استبدال هذا بقوائم من Odoo عندما تكون نماذج route متاحة
    switch (widget.routeName) {
      case "Dashboard":
        items = [
          {
            'icon': "assets/icons/icon_svg/dashboard_icon.svg",
            'label': 'Dashboard',
            'route': AppRoutes.dashboard,
          },
          {
            'icon': "assets/icons/icon_svg/log-out.svg",
            'label': 'Log Out',
            'route': AppRoutes.login,
          },
        ];
        break;
      case "Products":
        items = [
          {
            'icon': "assets/icons/icon_svg/products_icon.svg",
            'label': 'Products',
            'route': AppRoutes.products,
          },
        ];
        break;
      case "Reports":
        items = [
          {
            'icon': "assets/icons/icon_svg/reports_icon.svg",
            'label': 'Reports',
            'route': AppRoutes.report,
          },
        ];
        break;
      case "Expense":
        items = [
          {
            'icon': "assets/icons/icon_svg/expense_icon.svg",
            'label': 'Expense',
            'route': AppRoutes.expense,
          },
        ];
        break;
      case "Customer":
        items = [
          {
            'icon': "assets/icons/icon_svg/customer_icon.svg",
            'label': 'Customer',
            'route': AppRoutes.customer,
          },
        ];
        break;
      case "Trading":
        items = [
          {
            'icon': "assets/icons/icon_svg/trading_icon.svg",
            'label': 'Trading',
            'route': AppRoutes.sales,
          },
        ];
        break;
      case "Invoice":
        items = [
          {
            'icon': "assets/icons/icon_svg/invoice_icon.svg",
            'label': 'Invoice',
            'route': AppRoutes.invoice,
          },
        ];
        break;
      default:
        items = [
          {
            'icon': "assets/icons/icon_svg/dashboard_icon.svg",
            'label': 'Dashboard',
            'route': AppRoutes.dashboard,
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SidebarX(
      controller: widget.controller,
      theme: SidebarXTheme(
        selectedItemPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 8,
        ),
        textStyle: GoogleFonts.nunito(
          textStyle: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        selectedTextStyle: const TextStyle(
          color: Color(0xFF333333),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.blue.shade50,
        ),
        iconTheme: IconThemeData(
          color: Colors.black.withOpacity(0.7),
          size: 20,
        ),
      ),
      extendedTheme: const SidebarXTheme(
        width: 300,
        padding: EdgeInsets.symmetric(horizontal: 12),
      ),
      showToggleButton: false,
      headerBuilder: (context, extended) {
        if (widget.routeName == "Dashboard") {
          return Column(
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                radius: 65,
                child: CircleAvatar(
                  radius: 60,
                  child: Image.asset("assets/images/avatar/user_profile.png"),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Admin@gmail.com",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  textStyle: const TextStyle(color: Colors.grey),
                ),
              ),
              Text(
                "Admin",
                textAlign: TextAlign.center,
                style: GoogleFonts.raleway(
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox(height: 20);
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
