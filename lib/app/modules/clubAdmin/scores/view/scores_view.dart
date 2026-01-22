import 'package:bierdygame/app/modules/clubAdmin/clubAdminProfile/view/club_profile_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/scores/controller/scores_controller.dart';
import 'package:bierdygame/app/modules/player/playerStats/view/player_stats_view.dart';
import 'package:bierdygame/app/modules/superAdmin/notifications/widgets/notification_tab_bar.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ScoresView extends GetView<ScoresController> {
  ScoresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showGameDetail.value) {
        return TeamProfileView(onBack: controller.backToGames);
      }
      if (controller.showPlayerRank.value) {
        return PlayerStatsView(onBack: controller.backToGames, color: AppColors.primary,);
      }
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            children: [
              Center(
                child: Text(
                  "LeaderBoard",
                  style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                ),
              ),
              SizedBox(height: 10.h),
              NotificationTabBar(
                title1: "Team Rank",
                title2: "Player Rank",
                selectedIndex: controller.selectedTab.value,
                onChanged: controller.changeTab,
              ),
              SizedBox(height: 15.h),
              Obx(() {
                final clubId = controller.clubId.value;
                if (clubId == null || clubId.isEmpty) {
                  return Center(child: Text("No club assigned"));
                }
                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('games')
                      .where('clubId', isEqualTo: clubId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final games = snapshot.data?.docs ?? [];
                    if (games.isEmpty) {
                      return Center(child: Text("No games found"));
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: games.length,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        final data = games[index].data();
                        final name = (data['name'] ?? 'Game').toString();
                        final status = (data['status'] ?? 'active').toString();
                        final date = (data['date'] ?? '').toString();
                        return GestureDetector(
                          onTap: controller.selectedTab.value == 0
                              ? controller.openTeamRank
                              : controller.openPlayerRank,
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.flashyGreen,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary),
                            ),
                            child: Row(
                              children: [
                                Text("${index + 1}"),
                                SizedBox(width: 20.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name),
                                    Text(
                                      controller.selectedTab.value == 0
                                          ? "Status: $status"
                                          : "Date: $date",
                                    ),
                                  ],
                                ),
                                Spacer(),
                                Text(
                                  controller.selectedTab.value == 0
                                      ? status
                                      : "View",
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              }),
            ],
          ),
        ),
      );
    });
  }
}
