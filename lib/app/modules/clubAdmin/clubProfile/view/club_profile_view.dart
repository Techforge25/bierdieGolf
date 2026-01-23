import 'package:bierdygame/app/modules/player/playerStats/widgets/performance_overview_container.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_club_detail_grid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TeamProfileView extends StatelessWidget {
  final VoidCallback onBack;

  const TeamProfileView({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.scaffoldBackground,
        leading: IconButton(
          onPressed: onBack,
          icon: Icon(Icons.arrow_back_ios, size: 18, color: AppColors.primary),
        ),
        title: Text(
          "Team Stats",
          style: AppTextStyles.bodyMedium2.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: ListView(
          children: [
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
                  .snapshots(),
              builder: (context, userSnapshot) {
                final userData = userSnapshot.data?.data() ?? {};
                final clubName = (userData['clubName'] ?? 'Club').toString();
                final clubId = (userData['clubId'] ?? '').toString();
                return Center(
                  child: Column(
                    children: [
                      CircleAvatar(radius: 50),
                      Text(
                        "Team Stats",
                        style: AppTextStyles.bodyLarge.copyWith(fontSize: 18),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xffCFE8DC),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          clubName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: clubId.isEmpty
                            ? Stream.empty()
                            : FirebaseFirestore.instance
                                .collection('games')
                                .where('clubId', isEqualTo: clubId)
                                .snapshots(),
                        builder: (context, gamesSnapshot) {
                          final gamesCount =
                              gamesSnapshot.data?.docs.length ?? 0;
                          return Text(
                            "Total Games: $gamesCount",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textBlack,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 10.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Performance Overview",
                style: AppTextStyles.bodyMedium2,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xffCFE8DC), Color(0xffDCEDC8)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Team Birdies",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkGreen,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "315",
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "All Time",
                        style: AppTextStyles.bodyMedium2.copyWith(
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            ClubsDetailGrid(
              value1: 0.toString(),
              value2: 0.toString(),
              value3: 0.toString(),
              value4: "N/A",
              color: AppColors.darkGreen,
              icon1: Icons.sports_golf_outlined,
              icon2: Icons.trending_up_outlined,
              icon3: FontAwesomeIcons.trophy,
              icon4: Icons.star_border_outlined,
              title1: "Total Games",
              title2: "Avg Birdies",
              title3: "Total Wins",
              title4: "Top Scorer",
              textColor: AppColors.textBlack,
            ),
            SizedBox(height: 15.h),
            PerformanceOverviewContainer(),
            SizedBox(height: 15.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary,
                  ),
                  child: Icon(Icons.star, color: AppColors.white, size: 12),
                ),
                SizedBox(width: 10.w),
                Text(
                  "Team Highlights",
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.flashyGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt, color: AppColors.primary),
                      SizedBox(width: 8.w),
                      Text(
                        "Best : 9 Birdies",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.flashyGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Best : 9 Birdies",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              "Team Members",
              style: AppTextStyles.bodyMedium2.copyWith(
                color: AppColors.textBlack,
                fontSize: 18,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
