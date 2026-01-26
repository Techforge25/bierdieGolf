import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class GameDetailView extends GetView<ManageClubsController> {
  final GameModel game;
  final VoidCallback onBack;

  GameDetailView({super.key, required this.game, required this.onBack});

  bool showTeams = true;
  // Toggle Teams / Leaderboard
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('games')
              .doc(game.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.data() ?? {};
            final gameName = (data['name'] ?? game.name).toString();
            final statusStr = (data['status'] ?? game.status.name).toString();
            final status = GameStatus.values.firstWhere(
              (s) => s.name == statusStr,
              orElse: () => game.status,
            );
            final totalHoles =
                (data['totalHoles'] ?? game.totalHoles) as int? ?? 18;
            final currentHole =
                (data['currentHole'] ?? game.currentHole) as int? ?? 1;
            final par = (data['par'] ?? game.par) as int? ?? 3;
            final teams = _asTeams(data['teams']);
            final totalTeams = teams.length;
            final totalPlayers = teams.fold<int>(
              0,
              (sum, t) => sum + (t.members?.length ?? 0),
            );
            final totalTeamBirdies = teams.fold<int>(
              0,
              (sum, t) => sum + (t.birdies ?? 0),
            );
            final matchProgress = totalHoles == 0
                ? 0.0
                : (totalTeamBirdies / totalHoles).clamp(0.0, 1.0);
            final teamRank = [...teams]
              ..sort((a, b) => (b.birdies ?? 0).compareTo(a.birdies ?? 0));
            final playerRank = _buildPlayerRank(teams);

            return SingleChildScrollView(
              child: Column(
                children: [
                  /// ===================
                  /// TOP GREEN HEADER
                  /// ===================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onBack,
                          child: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          gameName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Hole $currentHole of $totalHoles • Par $par",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statusChip(status),
                            Row(
                              children: const [
                                Icon(Icons.timer, color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "02:14:30",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ===================
                  /// END GAME BUTTON
                  /// ===================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.darkRed),
                          backgroundColor: AppColors.flashyRed,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.exit_to_app, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              "End Game",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ===================
                  /// TEAMS / LEADERBOARD TOGGLE
                  /// ===================
                  Obx(() {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          _primaryTab(
                            title: "Teams",
                            index: 0,
                            selectedIndex: controller.selectedGameTab.value,
                            onChanged: controller.changeGameTab,
                          ),
                          _primaryTab(
                            title: "Leaderboard",
                            index: 1,
                            selectedIndex: controller.selectedGameTab.value,
                            onChanged: controller.changeGameTab,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  Obx(() {
                    if (controller.selectedGameTab.value == 0) {
                      return ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _statCard("Teams", totalTeams.toString()),
                                _statCard("Players", totalPlayers.toString()),
                                _statCard(
                                  "Team Birdied",
                                  "$totalTeamBirdies / $totalHoles",
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// MATCH PROGRESS
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Match Progress",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      LinearProgressIndicator(
                                        value: matchProgress,
                                        backgroundColor: Colors.green.shade100,
                                        color: Colors.green,
                                        minHeight: 8,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "Teams are working to birdie all $totalHoles holes.",
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            "${(matchProgress * 100).round()}%",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// TEAM PROGRESS LIST
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: teamRank.map((team) {
                                return _teamProgressCard(team, totalHoles);
                              }).toList(),
                            ),
                          ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _secondaryTab(
                                title: "Team Rank",
                                index: 0,
                                onChanged: controller.changeLeaderboardTab,
                                selectedIndex:
                                    controller.selectedLeaderboardTab.value,
                              ),
                              SizedBox(width: 20.w),
                              _secondaryTab(
                                title: "Players Rank",
                                index: 1,
                                onChanged: controller.changeLeaderboardTab,
                                selectedIndex:
                                    controller.selectedLeaderboardTab.value,
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          Obx(() {
                            if (controller.selectedLeaderboardTab.value == 0) {
                              return Column(
                                children:
                                    teamRank.asMap().entries.map((entry) {
                                  return _teamRankCard(
                                    rank: entry.key + 1,
                                    team: entry.value,
                                  );
                                }).toList(),
                              );
                            }
                            return Column(
                              children:
                                  playerRank.asMap().entries.map((entry) {
                                return _playerRankCard(
                                  rank: entry.key + 1,
                                  player: entry.value,
                                );
                              }).toList(),
                            );
                          }),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// =====================================
  /// STATUS BADGE
  /// =====================================
  Widget _statusChip(GameStatus status) {
    switch (status) {
      case GameStatus.active:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.flashyGreen,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary),
          ),
          child: Text(
            "Live",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case GameStatus.draft:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.flashyYellow,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Text(
            "Draft",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case GameStatus.completed:
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.borderColorLight,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderColorLight),
          ),
          child: Text(
            "Completed",
            style: AppTextStyles.body.copyWith(
              fontSize: 12,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
    }
  }

  /// =====================================
  /// STAT CARD
  /// =====================================
  Widget _statCard(String title, String value) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// =====================================
  /// TEAM PROGRESS CARD
  /// =====================================
  Widget _teamProgressCard(_TeamData team, int totalHoles) {
    final progress = totalHoles == 0
        ? 0.0
        : ((team.birdies ?? 0) / totalHoles).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                team.name ?? "Team",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${team.birdies ?? 0} Birdies",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text("Players: ${team.members?.length ?? team.playersCount ?? 0}"),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Progress: ${(totalHoles - (team.holesRemaining ?? (totalHoles - (team.birdies ?? 0))))} / $totalHoles",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                "${(progress * 100).round()}%",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${team.holesRemaining ?? (totalHoles - (team.birdies ?? 0))} Holes Remaining",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _primaryTab({
    required String title,
    required int index,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final isSelected = index == selectedIndex;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _secondaryTab({
    required String title,
    required int index,
    required int selectedIndex,
    required ValueChanged<int> onChanged,
  }) {
    final isSelected = index == selectedIndex;
    return GestureDetector(
      onTap: () => onChanged(index),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.primary : Colors.black87,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 2,
            width: 80.w,
            color: isSelected ? AppColors.primary : Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _teamRankCard({required int rank, required _TeamData team}) {
    final color = rank == 1
        ? AppColors.flashyGreen
        : (rank == 2 ? AppColors.flashyYellow : AppColors.flashyblue);
    final border = rank == 1
        ? AppColors.primary
        : (rank == 2 ? AppColors.secondary : AppColors.darkBlue);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name ?? "Team",
                  style: AppTextStyles.bodyMedium2,
                ),
                Text(
                  "${team.members?.length ?? 0} Players",
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${team.birdies ?? 0}",
                style: AppTextStyles.bodyMedium2,
              ),
              Text(
                "${team.holesRemaining ?? ''} Holes Left",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.borderColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _playerRankCard({required int rank, required _PlayerData player}) {
    final color = rank == 1
        ? AppColors.flashyGreen
        : (rank == 2 ? AppColors.flashyYellow : AppColors.flashyblue);
    final border = rank == 1
        ? AppColors.primary
        : (rank == 2 ? AppColors.secondary : AppColors.darkBlue);
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  style: AppTextStyles.bodyMedium2,
                ),
                Text(
                  player.teamName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.borderColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${player.birdies} B",
            style: AppTextStyles.bodyMedium2,
          ),
        ],
      ),
    );
  }

  List<_TeamData> _asTeams(dynamic raw) {
    if (raw is! List) return [];
    return raw.whereType<Map<String, dynamic>>().map((team) {
      final members = team['members'];
      final memberList = <_PlayerData>[];
      if (members is List) {
        for (final member in members) {
          if (member is Map<String, dynamic>) {
            memberList.add(
              _PlayerData(
                uid: (member['uid'] ?? '').toString(),
                name: (member['name'] ?? 'Player').toString(),
                teamName: (team['name'] ?? 'Team').toString(),
                birdies: (member['birdies'] ?? 0) as int? ?? 0,
              ),
            );
          }
        }
      }
      return _TeamData(
        name: (team['name'] ?? 'Team').toString(),
        birdies: (team['teamBirdies'] ?? team['birdies'] ?? 0) as int? ?? 0,
        holesRemaining: (team['holesRemaining'] ?? 0) as int? ?? 0,
        members: memberList,
      );
    }).toList();
  }

  List<_PlayerData> _buildPlayerRank(List<_TeamData> teams) {
    final players = <_PlayerData>[];
    for (final team in teams) {
      if (team.members != null) {
        players.addAll(team.members!);
      }
    }
    players.sort((a, b) => b.birdies.compareTo(a.birdies));
    return players;
  }
}

class _TeamData {
  final String? name;
  final int? birdies;
  final int? holesRemaining;
  final List<_PlayerData>? members;
  final int? playersCount;

  _TeamData({
    this.name,
    this.birdies,
    this.holesRemaining,
    this.members,
    this.playersCount,
  });
}

class _PlayerData {
  final String uid;
  final String name;
  final String teamName;
  final int birdies;

  _PlayerData({
    required this.uid,
    required this.name,
    required this.teamName,
    required this.birdies,
  });
}
