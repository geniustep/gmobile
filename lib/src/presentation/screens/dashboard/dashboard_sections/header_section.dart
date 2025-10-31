import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/common/config/app_colors.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/common/utils/utils.dart';
import 'package:gsloution_mobile/src/presentation/widgets/draft_indicators/draft_app_bar_badge.dart';
import 'package:gsloution_mobile/src/routes/app_routes.dart';
import 'package:gsloution_mobile/src/utils/contstants.dart';

class DashboardHeaderSection extends StatelessWidget {
  final Function openDrawer;

  const DashboardHeaderSection({super.key, required this.openDrawer});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 50, left: 10, right: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    openDrawer();
                  },
                  child: Image.asset(
                    "assets/images/avatar/user_profile.png",
                    width: 60,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      PrefUtils.user.value.name.toString(),
                      style: GoogleFonts.raleway(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ColorSchema.titleTextColor,
                        ),
                      ),
                    ),
                    Text(
                      PrefUtils.user.value.isAdmin! ? "Admin" : "Vendor",
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                          color: ColorSchema.subTitleTextColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                DraftAppBarBadge(
                  showOnlyWhenHasDrafts: true,
                  iconColor: FunctionalColors.iconPrimary,
                  badgeColor: Colors.orange,
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    Get.toNamed(AppRoutes.notification);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.blue.shade50.withOpacity(0.5),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: ColorSchema.primaryColor,
                          size: 30,
                        ),
                      ),
                      Positioned(
                        right: 14,
                        top: 14,
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.blue.shade50.withOpacity(0.5),
                  ),
                  child: IconButton(
                    onPressed: () {
                      showLogoutDialog();
                    },
                    icon: const Icon(Icons.logout, color: Colors.red, size: 30),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
