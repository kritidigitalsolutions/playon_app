import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:play_on_app/data/network/notification_service.dart';
import 'package:play_on_app/routes/app_pages.dart';
import 'package:play_on_app/routes/app_routes.dart';
import 'package:play_on_app/utils/ad_navigator_observer.dart';
import 'package:play_on_app/utils/hive_service/userdetail.dart';
import 'package:play_on_app/view_model/after_controller/ad_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/after_login/channel_page/sport_channel_list.dart';
import 'package:play_on_app/views/after_login/home_pages/home_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/schedules_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/series_list_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/all_highlights_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'data/network/firebase_options.dart';

// ─────────────────────────────────────────────
//  MAIN
// ─────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  debugPrint("🚀 [CORE] Flutter Initialized");

  // ── 1. Storage ───────────────────────────────
  try {
    await GetStorage.init();
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserDetailsAdapter());
    }
    await Hive.openBox<UserDetails>('userBox');
    debugPrint("📦 [CORE] Storage Ready");
  } catch (e) {
    debugPrint("❌ [CORE] Storage Error: $e");
  }

  // ── 2. Firebase — runApp se pehle zaroori hai ─
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    debugPrint("🔥 [SVC] Firebase Ready");
  } catch (e) {
    debugPrint("❌ [SVC] Firebase Error: $e");
  }

  // ── 3. runApp — PEHLE render karo ───────────
  //
  //  iOS Rule:
  //  Koi bhi system dialog (notification permission,
  //  tracking permission) runApp ke BAAD hona chahiye.
  //  Pehle hone se iOS ka display layer confuse hota
  //  hai aur Flutter kuch render nahi kar paata.
  //
  runApp(const MyApp());

  // ── 4. Pehle frame ke baad services init karo ─
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // Notification — yahan iOS permission dialog aayega
    // Flutter pehle render ho chuka hoga, safe hai
    try {
      await NotificationService.init();
      debugPrint("🔔 [SVC] Notifications Ready");
    } catch (e) {
      debugPrint("❌ [SVC] Notification Error: $e");
    }

    // Wakelock
    try {
      WakelockPlus.enable();
    } catch (_) {}
  });

  // ── 5. Ads — 3 second delay ──────────────────
  Future.delayed(const Duration(seconds: 3), () async {
    try {
      await MobileAds.instance.initialize();
      debugPrint("📢 [SVC] Ads Ready");
      if (Get.isRegistered<AdController>()) {
        Get.find<AdController>().isMobileAdsInitialized.value = true;
      }
    } catch (e) {
      debugPrint("⚠️ [SVC] Ads Init Error: $e");
    }
  });
}

// ─────────────────────────────────────────────
//  ROOT APP
// ─────────────────────────────────────────────
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("🏗️ [UI] Building MyApp");
    return GetMaterialApp(
      title: 'PlayOn',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splashScreen,
      getPages: AppPages.routes,
      navigatorObservers: [AdNavigatorObserver()],
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF040B23),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HOME PAGE
// ─────────────────────────────────────────────
class MyHomePage extends StatefulWidget {
  final int? index;
  const MyHomePage({super.key, this.index = 0});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HomeController controller;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();

    // ✅ Controller initState mein — build() mein KABHI NAHI
    try {
      controller = Get.find<HomeController>();
    } catch (e) {
      controller = Get.put(HomeController());
    }

    // ✅ Screens sirf ek baar — har build pe recreate NAHI
    screens = [
      HomeScreen(),
      const SportChannelList(),
      const SeriesListScreen(),
      const AllHighlightsScreen(),
      MatchScheduleScreen(),
    ];

    if (widget.index != null && widget.index! > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.changeIndex(widget.index!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏠 [UI] MyHomePage Build");
    return Scaffold(
      backgroundColor: const Color(0xFF040B23),
      body: Obx(
            () => IndexedStack(
          index: controller.currentIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Obx(
            () => _buildBottomBar(controller.currentIndex.value),
      ),
    );
  }

  Widget _buildBottomBar(int currentIndex) {
    return Container(
      color: const Color(0xFF081029),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, 'Home', 0, currentIndex),
            _navItem(Icons.live_tv, 'Live', 1, currentIndex),
            _navItem(Icons.list_alt, 'Series', 2, currentIndex),
            _navItem(Icons.video_library, 'Highlights', 3, currentIndex),
            _navItem(Icons.calendar_today, 'Events', 4, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index >= 2) {
          controller.handleProtectedAction(
                () => controller.changeIndex(index),
          );
        } else {
          controller.changeIndex(index);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.white54,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.blue : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}