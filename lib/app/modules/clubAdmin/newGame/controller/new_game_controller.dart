
import 'dart:math';

import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NewGameController extends GetxController {
  final TextEditingController nameController = TextEditingController();

  int teams = 4;
  int playersPerTeam = 2;

  bool showTeams = false;
  List<TeamModel> generatedTeams = [];
  List<List<TeamPlayer>> teamPlayers = [];

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void incrementTeams() {
    if (teams < 8) {
      teams++;
      update();
    }
  }

  void decrementTeams() {
    if (teams > 2) {
      teams--;
      update();
    }
  }

  void incrementPlayersPerTeam() {
    if (playersPerTeam < 4) {
      playersPerTeam++;
      update();
    }
  }

  void decrementPlayersPerTeam() {
    if (playersPerTeam > 2) {
      playersPerTeam--;
      update();
    }
  }

  void generateTeams() {
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

    generatedTeams = List.generate(
      teams,
      (index) => TeamModel(
        name: "Team ${index + 1}",
        playersCount: playersPerTeam,
        playersPerTeam: playersPerTeam,
        joinedPlayers: 0,
      ),
    );
    teamPlayers = List.generate(teams, (_) => <TeamPlayer>[]);
    showTeams = true;
    update();
  }

  void confirmCreateGame() {
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
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.flashyGreen,
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.flashyGreen,
                radius: 40,
                child: Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Confirm Game Creation",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textBlack,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                "Are you sure you want to create game\n\n"
                "${nameController.text}\n"
                "with $teams teams?",
                style: TextStyle(color: AppColors.textBlack),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  createGame();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Create Game",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10),
              OutlinedButton(
                onPressed: Get.back,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary),
                  minimumSize: Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createGame() {
    final nav = Get.find<ClubAdminBottomNavController>();
    if (!nav.guardClubAccess()) return;
    final game = GameModel(
      name: nameController.text,
      date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      passkey: generatePasskey(),
      status: GameStatus.active,
    );

    final teamsPayload = List.generate(generatedTeams.length, (index) {
      final team = generatedTeams[index];
      final players = teamPlayers[index];
      return {
        'name': team.name ?? "Team ${index + 1}",
        'players': players.map((p) => p.toMap()).toList(),
      };
    });

    final clubGamePayload = {
      'name': game.name,
      'teamsCount': generatedTeams.length,
      'playersPerTeam': playersPerTeam,
      'teams': teamsPayload,
    };

    Get.find<ManageClubsController>()
        .createGame(game, clubGame: clubGamePayload)
        .then((_) {
      nav.changeTab(1);
    });
  }

  String generatePasskey({int length = 6}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();

    return List.generate(
      length,
      (_) => chars[rand.nextInt(chars.length)],
    ).join();
  }

  void removeTeam(int index) {
    generatedTeams.removeAt(index);
    teamPlayers.removeAt(index);
    teams = generatedTeams.length;
    showTeams = generatedTeams.isNotEmpty;
    update();
  }

  Future<void> addPlayersToTeam(
    int teamIndex,
    List<TextEditingController> controllers, {
    VoidCallback? onClose,
  }) async {
    final rawEmails = controllers
        .map((c) => c.text.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    if (rawEmails.isEmpty) {
      Get.snackbar("Missing email", "Please enter at least one email");
      return;
    }

    final existingEmails =
        teamPlayers[teamIndex].map((p) => p.email.toLowerCase()).toSet();
    for (final email in rawEmails) {
      if (existingEmails.contains(email)) {
        Get.snackbar("Duplicate", "Player already added to this team");
        return;
      }
    }

    final playersToAdd = <TeamPlayer>[];
    for (final email in rawEmails) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (snapshot.docs.isEmpty) {
        Get.snackbar("Player did not sign up", "No user found for $email");
        return;
      }
      final doc = snapshot.docs.first;
      final data = doc.data();
      final name = (data['displayName'] ?? data['name'] ?? '').toString();
      playersToAdd.add(
        TeamPlayer(
          uid: doc.id,
          name: name.isEmpty ? email : name,
          email: email,
        ),
      );
    }

    teamPlayers[teamIndex].addAll(playersToAdd);
    final team = generatedTeams[teamIndex];
    generatedTeams[teamIndex] = TeamModel(
      name: team.name,
      playersCount: team.playersCount ?? team.playersPerTeam,
      birdies: team.birdies,
      holesRemaining: team.holesRemaining,
      progress: team.progress,
      joinedPlayers: teamPlayers[teamIndex].length,
      playersPerTeam: team.playersPerTeam,
    );
    update();
    if (onClose != null) {
      onClose();
    } else if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }
}

class TeamPlayer {
  final String uid;
  final String name;
  final String email;

  TeamPlayer({
    required this.uid,
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }
}
