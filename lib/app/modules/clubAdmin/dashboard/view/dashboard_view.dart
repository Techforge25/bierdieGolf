import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/dashboard/widgets/club_admin_main_role_container.dart';
import 'package:bierdygame/app/modules/clubAdmin/dashboard/widgets/reports_and_analytics_dashboard.dart';
import 'package:bierdygame/app/modules/clubAdmin/dashboard/widgets/stat_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_profile_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ClubAdminDashboard extends StatelessWidget {
  const ClubAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15.sp),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              children: [
                CustomProfileBar(
                  name: "Club Admin",
                  onTap: () {},
                  bgImg: "assets/images/dashboard_img.png",
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildContainerClubAdmin(
                      icon: Icons.add,
                      bgColor: AppColors.primary,
                      onTap: () {
                        final nav = Get.find<ClubAdminBottomNavController>();
                        if (!nav.guardClubAccess()) return;
                        nav.changeTab(2);
                      },
                      title: "Create Game",
                    ),
                    buildContainerClubAdmin(
                      icon: CupertinoIcons.game_controller,
                      bgColor: AppColors.darkBlue,
                      onTap: () {
                        final nav = Get.find<ClubAdminBottomNavController>();
                        if (!nav.guardClubAccess()) return;
                        nav.changeTab(1);
                      },
                      title: "Manage Game",
                    ),
                    buildContainerClubAdmin(
                      icon: Icons.list,
                      bgColor: AppColors.secondary,
                      onTap: () {
                        final nav = Get.find<ClubAdminBottomNavController>();
                        if (!nav.guardClubAccess()) return;
                        nav.changeTab(3);
                      },
                      title: "LeaderBoard",
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildCustomGrid(),
                SizedBox(height: 10),
                ReportsAndAnalyticsDashboard(),
                Text(
                  "Recent Activity",
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
