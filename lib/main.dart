import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // Show Promo Popup every time app opens (MyHomePage is reached)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPromoDialog();
    });
  }

  void _checkAndShowPromoDialog() {
    if (controller.popupData.value != null) {
      _showPromoDialog(controller.popupData.value!);
    } else {
      // If data is still loading, wait for it
      late Worker worker;
      worker = ever(controller.popupData, (data) {
        if (data != null) {
          _showPromoDialog(data);
          worker.dispose(); // Show only once per app open
        }
      });
      
      // Safety timeout - if API fails or takes too long, don't show anything
      Future.delayed(const Duration(seconds: 5), () {
        worker.dispose();
      });
    }
  }

  void _showPromoDialog(Map<String, dynamic> data) {
    final type = data['type'] ?? "PROMO";
    final imageUrl = data['image'] ?? "";

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        if (type == "IMAGE" && imageUrl.isNotEmpty) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      padding: const EdgeInsets.all(20),
                      color: const Color(0xFF0D1535),
                      child: const Text("Failed to load image"),
                    ),
                  ),
                ),
                Positioned(
                  right: -10,
                  top: -10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2151),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Default PROMO layout
        final title = data['title'] ?? "SPECIAL OFFER";
        final description = data['description'] ?? "";
        final promo = data['promo'] ?? {};
        final code = promo['code'] ?? "NOCODE";
        final discountValue = promo['discountValue']?.toString() ?? "0";
        final discountType = promo['discountType'] == 'percent' ? "% OFF" : " OFF";

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D1535), Color(0xFF1A2151)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.3), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                      ),
                      child: const Text(
                        "LIMITED TIME OFFER",
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Promo Code Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3), style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "USE CODE",
                            style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            code,
                            style: TextStyle(
                              color: Colors.blueAccent.shade100,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                              letterSpacing: 5,
                              shadows: [
                                Shadow(
                                  color: Colors.blueAccent.withOpacity(0.5),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "SAVE ",
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "$discountValue$discountType ",
                          style: TextStyle(
                            color: Colors.orangeAccent.shade200,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        ),
                        const Text(
                          "TODAY",
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (controller.isLogin.value) {
                          Get.toNamed(AppRoutes.accessPlan);
                        } else {
                          Get.toNamed(AppRoutes.login);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.blueAccent.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                      ),
                      child: const Text(
                        "CLAIM OFFER",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
              ),
              // Close Button
              Positioned(
                right: -10,
                top: -10,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2151),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF081029),
        title: const Text('Exit App', style: TextStyle(color: Colors.white)),
        content: const Text('Are you sure you want to exit?',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No', style: TextStyle(color: Colors.blue)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🏠 [UI] MyHomePage Build");
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _showExitDialog(context);
        if (shouldPop ?? false) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
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
            _navItem(Icons.live_tv, 'Live Tv', 1, currentIndex),
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