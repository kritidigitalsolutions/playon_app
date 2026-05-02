import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:play_on_app/data/network/notification_service.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/routes/app_pages.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/hive_service/userdetail.dart';
import 'package:play_on_app/utils/hive_service/userdetail.g.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/after_login/channel_page/sport_channel_list.dart';
import 'package:play_on_app/views/after_login/home_pages/home_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/schedules_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/watch_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // 1. Firebase Initialization with Timeout
    try {
      await Firebase.initializeApp().timeout(const Duration(seconds: 8));
    } catch (e) {
      debugPrint("Firebase init failed: $e");
    }

    await GetStorage.init();
    
    // 2. Timezone Initialization
    String timeZoneName = 'UTC';
    try {
      const channel = MethodChannel('com.playon.app/timezone');
      timeZoneName = await channel.invokeMethod<String>('getLocalTimezone') ?? 'UTC';
    } catch (e) {
      debugPrint("Native timezone channel error: $e");
    }

    tz.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 3. Hive Initialization
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) { // UserDetailsAdapter ID
      Hive.registerAdapter(UserDetailsAdapter());
    }
    
    try {
      await Hive.openBox<UserDetails>('userBox');
    } catch (e) {
      await Hive.deleteBoxFromDisk('userBox');
      await Hive.openBox<UserDetails>('userBox');
    }
    
    // 4. Notification Service
    try {
      await NotificationService.init();
      FirebaseMessaging.onBackgroundMessage(NotificationService.backgroundHandler);
    } catch (e) {
      debugPrint("Notification init failed: $e");
    }

    // UI Configuration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.secPrimary,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  } catch (e) {
    debugPrint("Critical app initialization error: $e");
  }

  // 5. Ensure runApp is ALWAYS called
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PlayOn',

      debugShowCheckedModeBanner: false,

      // 🔥 Initial Route
      initialRoute: AppRoutes.splashScreen,

      // 🔥 All Routes
      getPages: AppPages.routes,

      // 🔥 Theme (dark style)
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.secPrimary,
        fontFamily: "Poppins",
        useMaterial3: true,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final int? index;
  const MyHomePage({super.key, this.index = 0});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    final List<Widget> screens = [
      HomeScreen(),
      const SportChannelList(),
      // CreateWatchlistScreen(),
      MatchScheduleScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        /// If not on Home → go to Home
        if (controller.currentIndex.value != 0) {
          controller.changeIndex(0);
          return;
        }

        /// 🔥 Show Exit Popup
        Get.dialog(
          Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secPrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.white.withOpacity(0.1)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.exit_to_app, size: 40, color: AppColors.button),
                  const SizedBox(height: 12),

                  Text(
                    "Exit App?",
                    style: text16(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Are you sure you want to exit?",
                    textAlign: TextAlign.center,
                    style: text12(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      /// ❌ Cancel
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.back(); // close dialog only
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: AppColors.white.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: text12(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      /// ✅ Exit
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            SystemNavigator.pop(); // exit app here only
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.button,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Exit",
                            style: text12(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false, // 🔥 prevents accidental close
        );
      },
      child: Scaffold(
        body: Obx(
          () => IndexedStack(
            index: controller.currentIndex.value,
            children: screens,
          ),
        ),
        bottomNavigationBar: Obx(
          () => SafeArea(child: _customBottomBar(controller.currentIndex.value)),
        ),
      ),
    );
  }

  Widget _customBottomBar(int currentIndex) {
    return SafeArea(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Strong glass blur
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              12,
              8,
              12,
              12,
            ), // Added margin for floating effect
            //padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              //color: AppColors.secPrimary.withAlpha(50),
              color: AppColors.white.withOpacity(
                0.05,
              ), // Semi-transparent for crystal look
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: AppColors.white.withOpacity(
                  0.25,
                ), // Crystal shine border
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _navItem(Icons.home, 'Home', 0, currentIndex),
                _navItem(Icons.live_tv, 'Live TV', 1, currentIndex),
                // _navItem(Icons.bookmark_border, 'Watchlist', 2, currentIndex),
                _navItem(Icons.calendar_today, 'Schedules', 2, currentIndex),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () {
          if (currentIndex == index) return;
          Get.find<HomeController>().changeIndex(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: isSelected ? 20 : 18,
                color: isSelected
                    ? AppColors.button
                    : Colors.white.withOpacity(0.85),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: text11(
                  color: isSelected
                      ? AppColors.button
                      : AppColors.white.withOpacity(0.75),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              // if (isSelected)
              //   Container(
              //     height: 2,
              //     width: 30, // 👈 control width here
              //     margin: const EdgeInsets.only(bottom: 4),
              //     decoration: BoxDecoration(
              //       color: AppColors.button,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}

// class CustomBottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   const CustomBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.secPrimary,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: currentIndex,
//         onTap: onTap,
//         backgroundColor: Colors.transparent,
//         selectedItemColor: AppColors.primary,
//         unselectedItemColor: Colors.white70,
//         type: BottomNavigationBarType.fixed,
//         elevation: 0,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.live_tv), label: 'Live TV'),
//           BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Watchlist'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_today),
//             label: 'Schedules',
//           ),
//         ],
//       ),
//     );
//   }
// }
