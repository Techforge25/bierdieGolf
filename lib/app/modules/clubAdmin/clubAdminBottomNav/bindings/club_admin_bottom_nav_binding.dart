import 'package:bierdygame/app/modules/clubAdmin/clubAdminBottomNav/controller/club_admin_bot_nav_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/scores/controller/scores_controller.dart';
import 'package:bierdygame/app/modules/golfClub/controller/golf_club_controller.dart';
import 'package:get/get.dart';

class ClubAdminBottomNavBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ClubAdminBottomNavController(), permanent: true);
    Get.lazyPut<ManageClubsController>(() => ManageClubsController());
    Get.lazyPut<ScoresController>(() => ScoresController());
    Get.lazyPut<GolfClubController>(() => GolfClubController());
  }
}
