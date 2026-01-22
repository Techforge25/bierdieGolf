import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ScoresController extends GetxController {
  RxInt selectedTab = 0.obs;
  RxBool showGameDetail = false.obs;
  RxBool showPlayerRank = false.obs;
  final RxnString clubId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadClubId();
  }

  Future<void> _loadClubId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    clubId.value = doc.data()?['clubId']?.toString();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }
  void openTeamRank() {
    showGameDetail.value = true;
  }
   void openPlayerRank() {
    showPlayerRank.value = true;
  }

  void backToGames() {
    showGameDetail.value = false;
    showPlayerRank.value = false;
  }
}
