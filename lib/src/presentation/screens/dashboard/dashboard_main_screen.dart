import 'dart:io';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/partner_map.dart';
import 'package:gsloution_mobile/src/presentation/screens/dashboard/dashboard_sections/header_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/dashboard/dashboard_sections/services_section.dart';
import 'package:gsloution_mobile/src/presentation/screens/dashboard/dashboard_sections/today_reports_section.dart';
import 'package:gsloution_mobile/src/presentation/widgets/drawer/dashboard_drawer.dart';
import 'package:sidebarx/sidebarx.dart';

class DashboardMainScreen extends StatefulWidget {
  const DashboardMainScreen({super.key});

  @override
  State<DashboardMainScreen> createState() => _DashboardMainScreenState();
}

class _DashboardMainScreenState extends State<DashboardMainScreen> {
  final controller = SidebarXController(selectedIndex: 0, extended: true);
  final _key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    return Scaffold(
      key: _key,
      drawer: DashboardDrawer(routeName: "Dashboard", controller: controller),
      body: Container(
        color: Colors.white70,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const TodayReportsSection(),
            const ServicesSection(),
            ElevatedButton(
              onPressed: () {
                Get.dialog(
                  Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.zero,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * .8,
                      height: MediaQuery.of(context).size.height * .6,
                      child: GoogleMapsPartners(
                        partners: PrefUtils.partners,
                        isSearch: false,
                      ),
                    ),
                  ),
                );
              },
              child: const Text('Nearby Customers'),
            ),
          ],
        ),
      ),
      appBar: isSmallScreen
          ? PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: DashboardHeaderSection(
                openDrawer: () {
                  if (!Platform.isAndroid && !Platform.isIOS) {
                    controller.setExtended(true);
                  }
                  _key.currentState?.openDrawer();
                },
              ),
            )
          : null,
    );
  }
}
