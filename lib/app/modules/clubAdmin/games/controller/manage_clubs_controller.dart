import 'dart:async';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ManageClubsController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxInt selectedGameTab = 0.obs;
  Rx<String?> selectedClub = Rx<String?>(null);
  final searchQuery = ''.obs;
  final searchController = TextEditingController();

  RxList<GameModel> games = <GameModel>[].obs;
  final RxnString _clubId = RxnString();
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _gamesSub;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  RxBool showGameDetail = false.obs;
  Rx<GameModel?> selectedGame = Rx<GameModel?>(null);

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text.trim().toLowerCase();
    });
    _loadClubIdAndListen();
  }

  @override
  void onClose() {
    _gamesSub?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadClubIdAndListen() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc =
        await _firestore.collection('users').doc(user.uid).get();
    _clubId.value = userDoc.data()?['clubId']?.toString();
    final clubId = _clubId.value;
    if (clubId == null || clubId.isEmpty) return;
    _gamesSub = _firestore
        .collection('games')
        .where('clubId', isEqualTo: clubId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      games.value = snapshot.docs
          .map((doc) => GameModel.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> createGame(GameModel game) async {
    final clubId = _clubId.value;
    if (clubId == null || clubId.isEmpty) {
      Get.snackbar("Error", "Missing club id");
      return;
    }
    await _firestore.collection('games').add({
      ...game.toMap(),
      'clubId': clubId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  void changeTab(int index) {
    selectedTab.value = index;
    selectedClub.value = null;
  }
void changeGameTab(int index) {
    selectedGameTab.value = index;
  }
  void addGame(GameModel game) {
    games.insert(0, game); // latest on top
  }

  void removeGame(GameModel game) {
    if (game.id.isNotEmpty) {
      _firestore.collection('games').doc(game.id).delete();
    } else {
      games.remove(game);
    }
  }

  void openGame(GameModel game) {
    selectedGame.value = game;
    showGameDetail.value = true;
  }

  void backToGames() {
    showGameDetail.value = false;
    selectedGame.value = null;
  }

  List<GameModel> get filteredGames {
    final query = searchQuery.value;
    Iterable<GameModel> source = games;
    if (query.isNotEmpty) {
      source = source.where(
        (g) => g.name.toLowerCase().contains(query),
      );
    }
    switch (selectedTab.value) {
      case 1:
        return source.where((g) => g.status == GameStatus.active).toList();
      case 2:
        return source.where((g) => g.status == GameStatus.draft).toList();
      case 3:
        return source.where((g) => g.status == GameStatus.completed).toList();
      default:
        return source.toList();
    }
  }
}
