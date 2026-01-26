import 'package:bierdygame/app/modules/clubAdmin/clubProfile/view/club_profile_view.dart';
import 'package:bierdygame/app/modules/clubAdmin/scores/controller/scores_controller.dart';
import 'package:bierdygame/app/modules/player/playerStats/view/player_stats_view.dart';
import 'package:bierdygame/app/modules/superAdmin/notifications/widgets/notification_tab_bar.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ScoresView extends GetView<ScoresController> {
  ScoresView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.showGameDetail.value) {
        return TeamProfileView(
          onBack: controller.backToGames,
          teamData: controller.selectedTeam.value,
        );
      }
      if (controller.showPlayerRank.value) {
        return PlayerStatsView(
          onBack: controller.backToGames,
          color: AppColors.primary,
          playerData: controller.selectedPlayer.value,
        );
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
              Expanded(
                child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser?.uid ?? 'missing')
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final userData = userSnapshot.data?.data() ?? {};
                    final clubId = (userData['clubId'] ?? '').toString();
                    if (clubId.isEmpty) {
                      return Center(child: Text("No club assigned"));
                    }
                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('games')
                          .where('clubId', isEqualTo: clubId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text("Failed to load games"));
                        }
                        final games = snapshot.data?.docs ?? [];
                        if (games.isEmpty) {
                          return Center(child: Text("No games found"));
                        }

                        if (controller.selectedTab.value == 0) {
                          final teams = <Map<String, dynamic>>[];
                          for (final doc in games) {
                            final data = doc.data();
                          final gameName =
                              (data['name'] ?? 'Game').toString();
                          final status =
                              (data['status'] ?? 'active').toString();
                          final date = (data['date'] ?? '').toString();
                          final rawTeams = data['teams'];
                          if (rawTeams is List) {
                            for (final team in rawTeams) {
                              if (team is Map<String, dynamic>) {
                                teams.add({
                                  ...team,
                                  'gameName': gameName,
                                  'gameStatus': status,
                                  'gameDate': date,
                                  'gameId': doc.id,
                                });
                              }
                            }
                          }
                        }
                        teams.sort((a, b) {
                          final aBirdies =
                              (a['teamBirdies'] ?? 0) as num? ?? 0;
                          final bBirdies =
                              (b['teamBirdies'] ?? 0) as num? ?? 0;
                          return bBirdies.compareTo(aBirdies);
                        });
                        if (teams.isEmpty) {
                          return Center(child: Text("No teams found"));
                        }
                        return ListView.separated(
                          padding: EdgeInsets.only(top: 10.h),
                          itemCount: teams.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final team = teams[index];
                            final name =
                                (team['name'] ?? 'Team').toString();
                            final status =
                                (team['gameStatus'] ?? 'active').toString();
                            return GestureDetector(
                              onTap: () {
                                controller.openTeamRank(
                                  name: (team['gameName'] ?? '').toString(),
                                  status: status,
                                  date: (team['gameDate'] ?? '').toString(),
                                  teamData: team,
                                );
                              },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name),
                                        Text("Status: $status"),
                                      ],
                                    ),
                                    Spacer(),
                                    Text(status),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      final players = <Map<String, dynamic>>[];
                      for (final doc in games) {
                        final data = doc.data();
                        final gameName = (data['name'] ?? 'Game').toString();
                        final status = (data['status'] ?? 'active').toString();
                        final date = (data['date'] ?? '').toString();
                        final rawTeams = data['teams'];
                        if (rawTeams is List) {
                          for (final team in rawTeams) {
                            if (team is Map<String, dynamic>) {
                              final members = team['members'];
                              if (members is List) {
                                for (final member in members) {
                                  if (member is Map<String, dynamic>) {
                                    players.add({
                                      ...member,
                                      'teamName':
                                          (team['name'] ?? 'Team').toString(),
                                      'gameName': gameName,
                                      'gameStatus': status,
                                      'gameDate': date,
                                      'gameId': doc.id,
                                    });
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                        if (players.isEmpty) {
                          return Center(child: Text("No players found"));
                        }
                        return ListView.separated(
                          padding: EdgeInsets.only(top: 10.h),
                          itemCount: players.length,
                          separatorBuilder: (_, __) => SizedBox(height: 10.h),
                          itemBuilder: (context, index) {
                            final player = players[index];
                            final name =
                                (player['name'] ?? 'Player').toString();
                            final email =
                                (player['email'] ?? '').toString();
                            return GestureDetector(
                              onTap: () {
                                controller.openPlayerRank(
                                  name: (player['gameName'] ?? '').toString(),
                                  status:
                                      (player['gameStatus'] ?? '').toString(),
                                  date: (player['gameDate'] ?? '').toString(),
                                  playerData: player,
                                );
                              },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(name),
                                        if (email.isNotEmpty)
                                          Text(email),
                                      ],
                                    ),
                                    Spacer(),
                                    Text("View"),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
