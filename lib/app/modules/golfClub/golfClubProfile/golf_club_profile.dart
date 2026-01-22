import 'package:bierdygame/app/modules/golfClub/components/custom_club_profile_card.dart';
import 'package:bierdygame/app/modules/golfClub/controller/golf_club_controller.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class GolfClubProfilePage extends StatelessWidget {
  final String clubId;
  final String nameOfClub;
  final String? clubLocation;
  const GolfClubProfilePage({
    super.key,
    this.clubId = '',
    required this.nameOfClub,
    this.clubLocation,
  });

  @override
  Widget build(BuildContext context) {
    final GolfClubController controller =
        Get.isRegistered<GolfClubController>()
            ? Get.find<GolfClubController>()
            : Get.put(GolfClubController(), permanent: true);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 20,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        title: Row(
          
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Icon(
                Icons.arrow_back_ios,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 100.w),
            Text("Club Information", style: AppTextStyles.miniHeadings),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
          child: ListView(
            children: [
              clubId.isEmpty
                  ? customProfileContainer(
                      nameOfClub: nameOfClub,
                      clubId: clubId,
                      clubLocation: clubLocation,
                    )
                  : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: controller.clubStream(clubId),
                      builder: (context, snapshot) {
                        final data = snapshot.data?.data();
                        final logoPath = data?['logoPath']?.toString();
                        final logoBase64 = data?['logoBase64']?.toString();
                        final clubName =
                            (data?['name'] ?? nameOfClub).toString();
                        final location =
                            (data?['location'] ?? clubLocation).toString();
                        return customProfileContainer(
                          nameOfClub: clubName,
                          clubId: clubId,
                          clubLocation: location,
                          clubLogoPath: logoPath,
                          clubLogoBase64: logoBase64,
                        );
                      },
                    ),
              SizedBox(height: 16.h),
              Text("Status", style: AppTextStyles.bodyMedium),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: clubId.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        child: Text("Club Status"),
                      )
                    : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: controller.clubStream(clubId),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data();
                          final status =
                              (data?['status'] ?? 'active').toString();
                          final isActive = status == 'active';
                          return Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                                child: Container(
                                  height: 14.h,
                                  width: 14.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isActive
                                        ? AppColors.primary
                                        : AppColors.darkRed,
                                  ),
                                ),
                              ),
                              Text("Club Status"),
                              Spacer(),
                              Switch(
                                value: isActive,
                                onChanged: (value) {
                                  controller.setClubStatus(clubId, value);
                                },
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                trackColor: WidgetStateProperty.resolveWith(
                                  (states) {
                                    return isActive
                                        ? AppColors.primary
                                        : AppColors.scaffoldBackground;
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Club Admins",
                style: AppTextStyles.subHeading.copyWith(fontSize: 20.w),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: AppColors.flashyGreen,
                ),
                child: clubId.isEmpty
                    ? Padding(
                        padding: EdgeInsets.all(12.r),
                        child: Text(
                          "No admins available",
                          style: AppTextStyles.bodySmall,
                        ),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .where('clubId', isEqualTo: clubId)
                            .where('role', isEqualTo: 'club_admin')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.all(12.r),
                              child: Text(
                                "No admins available",
                                style: AppTextStyles.bodySmall,
                              ),
                            );
                          }
                          final admins = snapshot.data!.docs;
                          return ListView.separated(
                            separatorBuilder: (context, index) =>
                                Divider(indent: 20, endIndent: 20),
                            shrinkWrap: true,
                            itemCount: admins.length,
                            itemBuilder: (context, index) {
                              final data = admins[index].data();
                              final name =
                                  (data['displayName'] ?? 'Admin').toString();
                              final email =
                                  (data['email'] ?? '').toString();
                              final photoBase64 =
                                  (data['photoBase64'] ?? '').toString();
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: photoBase64.isNotEmpty
                                        ? MemoryImage(
                                            base64Decode(photoBase64),
                                          )
                                        : null,
                                  ),
                                  title: Text(
                                    name,
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  subtitle: Text(email),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Club Information",
                style: AppTextStyles.subHeading.copyWith(fontSize: 20.w),
              ),
              SizedBox(height: 16.h),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  color: AppColors.flashyGreen,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("location", style: AppTextStyles.bodySmall),
                              Text(
                                clubLocation ?? "Unknown",
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Joined Date",
                                style: AppTextStyles.bodySmall,
                              ),
                              Text(
                                DateFormat(
                                  'dd-MM-yyyy',
                                ).format(DateTime.now()).toString(),
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Games",
                                style: AppTextStyles.bodySmall,
                              ),
                              Text("1,124", style: AppTextStyles.bodyMedium),
                            ],
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Player",
                                style: AppTextStyles.bodySmall,
                              ),
                              Text("225", style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Actions",
                style: AppTextStyles.subHeading.copyWith(fontSize: 20.w),
              ),
              SizedBox(height: 16.h),
              Column(
                spacing: 10.5.h,
                children: [
                  CustomElevatedButton(
                    icon: Icon(Icons.save, color: AppColors.white),
                    onPressed: () {},
                    btnName: "Save",
                    backColor: AppColors.primary,
                  ),
                  CustomElevatedButton(
                    icon: Icon(Icons.block, color: AppColors.white),
                    onPressed: controller.blockClub,
                    btnName: "Block Club",
                    backColor: AppColors.secondary,
                  ),
                  CustomElevatedButton(
                    icon: Icon(Icons.delete, color: AppColors.white),
                    onPressed: controller.removeClub,
                    btnName: "Remove Club",
                    backColor: AppColors.darkRed,
                  ),
                  CustomElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    btnName: "Cancel",
                    textColor: AppColors.primary,
                    backColor: Colors.transparent,
                    borderColor: AppColors.primary,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  
}
