import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/modules/superAdmin/notifications/widgets/notification_tab_bar.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
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
    return Obx(() {
      return Scaffold(
        backgroundColor: Colors.grey.shade100,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                /// ===================
                /// TOP GREEN HEADER
                /// ===================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
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
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        game.name,
                        style: AppTextStyles.miniHeadings.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Hole ${game.currentHole} of ${game.totalHoles} • Par ${game.par}",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statusChip(game.status),
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
                        side: const BorderSide(color: Colors.red),
                        backgroundColor: Colors.red.withOpacity(0.05),
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
                NotificationTabBar(
                  title1: "Teams",
                  title2: "LeaderBoard",
                  selectedIndex: controller.selectedGameTab.value,
                  onChanged: controller.changeGameTab,
                ),

                const SizedBox(height: 16),

                /// STATS CARDS
                if (controller.selectedGameTab.value == 0)
                  ListView(
                    shrinkWrap: true,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _statCard("Teams", game.totalTeams.toString()),
                            _statCard("Players", game.totalPlayers.toString()),
                            _statCard(
                              "Team Birdied",
                              "${game.birdiedTeams} / ${game.totalHoles}",
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
                            LinearProgressIndicator(
                              value: game.matchProgress,
                              backgroundColor: Colors.green.shade100,
                              color: Colors.green,
                              minHeight: 8,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Teams are working to birdie all ${game.totalHoles} holes.",
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// TEAM PROGRESS LIST
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: game.teams.map((team) {
                            return _teamProgressCard(team);
                          }).toList(),
                        ),
                      ),
                    ],
                  ),

                if (controller.selectedGameTab.value == 1)
                  Container(child: Text("LeaderBoard")),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      );
    });
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
  Widget _teamProgressCard(TeamModel team) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            team.name ?? "Babi",
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text("Players: ${team.playersCount}"),
          const SizedBox(height: 4),
          Text(
            "${team.birdies} Birdies",
            style: TextStyle(color: Colors.green),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: team.progress,
            color: Colors.green,
            backgroundColor: Colors.green.shade100,
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            "${team.holesRemaining} Holes Remaining",
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
