import 'package:get/get.dart';
import 'package:play_on_app/bindings/auth_binding.dart';
import 'package:play_on_app/bindings/home_binding.dart';
import 'package:play_on_app/main.dart';
import 'package:play_on_app/views/after_login/account_pages/account_delete_screen.dart';
import 'package:play_on_app/views/after_login/account_pages/plan_pages/access_plan_screen.dart';
import 'package:play_on_app/views/after_login/account_pages/activated_tv_page.dart';
import 'package:play_on_app/views/after_login/account_pages/find_player_page.dart';
import 'package:play_on_app/views/after_login/account_pages/follow_tour_player_screen.dart';
import 'package:play_on_app/views/after_login/account_pages/plan_pages/choose_match_page.dart';
import 'package:play_on_app/views/after_login/account_pages/profile_screen.dart';
import 'package:play_on_app/views/after_login/account_pages/refer_earn_page.dart';
import 'package:play_on_app/view_model/after_controller/legal_controller.dart';
import 'package:play_on_app/views/after_login/account_pages/select_tour_screen.dart';
import 'package:play_on_app/views/after_login/legal_pages/legal_content_page.dart';
import 'package:play_on_app/views/after_login/channel_page/channel_Play_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/notification_screen.dart';
import 'package:play_on_app/views/after_login/match_pages/match_Play_screen.dart';
import 'package:play_on_app/views/after_login/match_pages/match_details_screen.dart';
import 'package:play_on_app/views/after_login/match_pages/recap_match_screen.dart';
import 'package:play_on_app/views/before_login/fullname_enter_screen.dart';
import 'package:play_on_app/views/before_login/login_screen.dart';
import 'package:play_on_app/views/before_login/otp_verify_screen.dart';
import 'package:play_on_app/views/before_login/splash_screen.dart';
import 'package:play_on_app/views/before_login/sport_interest_screen.dart';
import 'package:play_on_app/views/after_login/account_pages/plan_pages/select_series_page.dart';
import 'package:play_on_app/views/after_login/account_pages/plan_pages/select_team_page.dart';
import 'package:play_on_app/views/after_login/account_pages/plan_pages/purchased_items_page.dart';
import '../views/after_login/account_pages/followed_players_page.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    // auth
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(
      name: AppRoutes.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otpVerify,
      page: () => OtpVerifyScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.fullnameEnter,
      page: () => FullNameScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.sportInterrestScreen,
      page: () => SportsInterestScreen(),
      binding: AuthBinding(),
    ),

    // home
    GetPage(
      name: AppRoutes.myHomePage,
      page: () => MyHomePage(),
      binding: HomeBinding(),
    ),
    GetPage(name: AppRoutes.channelPlay, page: () => ChannelPlayScreen()),

    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationScreen(),
      binding: HomeBinding(),
    ),

    // account page
    GetPage(name: AppRoutes.profilePage, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.accessPlan, page: () => AccessPlansScreen()),
    GetPage(name: AppRoutes.findPlayer, page: () => SearchPlayersScreen()),
    GetPage(name: AppRoutes.selectTour, page: () => SelectTourScreen()),
    GetPage(name: AppRoutes.followedPage, page: () => FollowingScreen()),
    GetPage(name: AppRoutes.activateTV, page: () => ActivateTvScreen()),
    GetPage(name: AppRoutes.referScreen, page: () => ReferralScreen()),
    GetPage(name: AppRoutes.chooseMatch, page: () => ChooseMatchPage()),
    GetPage(name: AppRoutes.selectTeam, page: () => const SelectTeamPage()),
    GetPage(name: AppRoutes.selectSeries, page: () => const SelectSeriesPage()),
    GetPage(name: AppRoutes.purchasedItems, page: () => const PurchasedItemsPage()),
    GetPage(name: AppRoutes.accountDelete, page: () => DeleteAccountScreen()),
    GetPage(name: AppRoutes.followPlayer, page: () => FollowedPlayersScreen()),

    // legal pages
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () {
        final controller = Get.put(LegalController());
        controller.fetchPrivacyPolicy();
        return LegalContentPage(
          title: "Privacy Policy",
          apiResponse: controller.privacyPolicy,
          fetchData: controller.fetchPrivacyPolicy,
        );
      },
    ),
    GetPage(
      name: AppRoutes.aboutUs,
      page: () {
        final controller = Get.put(LegalController());
        controller.fetchAboutUs();
        return LegalContentPage(
          title: "About Us",
          apiResponse: controller.aboutUs,
          fetchData: controller.fetchAboutUs,
        );
      },
    ),
    GetPage(
      name: AppRoutes.refundPolicy,
      page: () {
        final controller = Get.put(LegalController());
        controller.fetchRefundPolicy();
        return LegalContentPage(
          title: "Refund Policy",
          apiResponse: controller.refundPolicy,
          fetchData: controller.fetchRefundPolicy,
        );
      },
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () {
        final controller = Get.put(LegalController());
        controller.fetchTermsConditions();
        return LegalContentPage(
          title: "Terms & Conditions",
          apiResponse: controller.termsConditions,
          fetchData: controller.fetchTermsConditions,
        );
      },
    ),

    // match details
    GetPage(name: AppRoutes.matchDetails, page: () => MatchDetailScreen()),
    GetPage(name: AppRoutes.matchPlay, page: () => MatchPlayScreen()),
    GetPage(name: AppRoutes.recapMatch, page: () => RecapMatchScreen()),
  ];
}
