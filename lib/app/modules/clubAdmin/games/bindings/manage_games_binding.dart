import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:get/get.dart';

class ManageGamesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageClubsController>(() => ManageClubsController());
  }
}
