import 'dart:math';

import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/widgets/counter_widget.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/widgets/team_card.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:bierdygame/app/theme/app_text_styles.dart';
import 'package:bierdygame/app/widgets/custom_elevated_button.dart';
import 'package:bierdygame/app/widgets/custom_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewGameView extends StatefulWidget {
  const NewGameView({super.key});

  @override
  State<NewGameView> createState() => _NewGameViewState();
}

class _NewGameViewState extends State<NewGameView> {
  final TextEditingController nameController = TextEditingController();

  int teams = 4;
  int playersPerTeam = 2;

  bool showTeams = false;
  List<TeamModel> generatedTeams = [];

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),

              /// TITLE
              Center(
                child: Text(
                  "Create a Game",
                  style: AppTextStyles.miniHeadings,
                ),
              ),

              SizedBox(height: 20.h),

              /// GAME NAME
              CustomFormField(
                controller: nameController,
                hint: "Enter Game Name",
                label: "Game name",
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColorLight),
                bgcolor: AppColors.white,
              ),

              SizedBox(height: 20.h),

              /// COUNTER BOX
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.borderColorLight),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    CounterSettingTile(
                      title: "Number of Teams",
                      subtitle: "Total teams playing",
                      value: teams,
                      minValue: 2,
                      maxValue: 8,
                      icon: Icons.groups,
                      iconBgColor: Colors.green,
                      onIncrement: () {
                        if (teams < 8) {
                          setState(() => teams++);
                        }
                      },
                      onDecrement: () {
                        if (teams > 2) {
                          setState(() => teams--);
                        }
                      },
                    ),

                    SizedBox(height: 12.h),

                    CounterSettingTile(
                      title: "Players per Team",
                      subtitle: "Size of each team",
                      value: playersPerTeam,
                      minValue: 2,
                      maxValue: 4,
                      icon: Icons.person,
                      iconBgColor: Colors.blue,
                      onIncrement: () {
                        if (playersPerTeam < 4) {
                          setState(() => playersPerTeam++);
                        }
                      },
                      onDecrement: () {
                        if (playersPerTeam > 2) {
                          setState(() => playersPerTeam--);
                        }
                      },
                    ),

                    SizedBox(height: 16.h),

                    /// SAVE TEAMS
                    CustomElevatedButton(
                      btnName: "Save",
                      onPressed: _generateTeams,
                    ),
                  ],
                ),
              ),

              /// GENERATED TEAMS
              if (showTeams) ...[
                SizedBox(height: 25.h),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: generatedTeams.length,
                  itemBuilder: (context, index) {
                    return TeamCard(
                      team: generatedTeams[index],
                      teamIndex: index,
                    );
                  },
                ),
              ],

              SizedBox(height: 30.h),

              /// CREATE GAME
              CustomElevatedButton(
                btnName: "Create Game",
                onPressed: _confirmCreateGame,
              ),

              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }

  /// ==========================
  /// GENERATE TEAMS
  /// ==========================
  void _generateTeams() {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    if (nameController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter a game name first",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      generatedTeams = List.generate(
        teams,
        (index) => TeamModel(
          name: "Team ${index + 1}",
          playersPerTeam: playersPerTeam,
          joinedPlayers: 0,
        ),
      );
      showTeams = true;
    });
  }

  /// ==========================
  /// CONFIRM CREATE GAME
  /// ==========================
  void _confirmCreateGame() {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    if (!showTeams) {
      Get.snackbar(
        "Error",
        "Please save teams first",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text("Confirm Game Creation"),
        content: Text(
          "Are you sure you want to create game\n\n"
          "${nameController.text}\n"
          "with $teams teams?",
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _createGame();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// ==========================
  /// CREATE GAME
  /// ==========================
  void _createGame() {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    final game = GameModel(
      name: nameController.text,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      passkey: generatePasskey(),
      status: GameStatus.active,
    );

    Get.find<ManageClubsController>().createGame(game).then((_) {
      nav.changeTab(1);
    });
  }

  /// ==========================
  /// PASSKEY
  /// ==========================
  String generatePasskey({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();

    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }
}
