import 'package:bierdygame/app/routes/app_pages.dart';
import 'package:bierdygame/app/routes/app_routes.dart';
import 'package:bierdygame/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}
//
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,  
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.scaffoldBackground,
            primaryColor: AppColors.primary,
            textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
            elevatedButtonTheme: elevatedButtonTheme,
          ),
          
          initialRoute: Routes.splash, // App welcome screen se shuru hogi
          getPages: AppPages.routes,
        );
      },
    );
  }
}

// CREATE GAME BUTTON
              // CustomElevatedButton(
              //   btnName: "Create Game",
              //   onPressed: () {
              //     if (nameController.text.isEmpty) {
              //       Get.snackbar(
              //         "Error",
              //         "Please enter a game name",
              //         backgroundColor: Colors.redAccent,
              //         colorText: Colors.white,
              //       );
              //       return;
              //     }

              //     final newGame = GameModel(
              //       name: nameController.text,
              //       date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              //       passkey: generatePasskey(length: 6),
              //       status: GameStatus.active,
              //       totalTeams: teams,
              //       totalPlayers: teams * playersPerTeam,
              //       teams: List.generate(
              //         teams,
              //         (i) => TeamModel(
              //           name: 'Team ${i + 1}',
              //           playersCount: playersPerTeam,
              //           birdies: 0,
              //           holesRemaining: 9,
              //           progress: 0.0,
              //         ),
              //       ),
              //     );

              //     // ADD GAME TO CONTROLLER
              //     Get.find<ManageClubsController>().addGame(newGame);
// https://www.figma.com/design/bZeW9fZoHrB8Knk3Mh3bj4/Birdie-Game?node-id=0-1&p=f&t=wl7Wuh5WLXzjOv4c-0
              //     // NAVIGATE BACK TO MANAGE GAMES TAB
              //     Get.find<ClubAdminBottomNavController>().changeTab(1);
              //   },
              // ),