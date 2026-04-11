import 'package:get/get.dart';
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
import 'package:play_on_app/views/after_login/account_pages/select_tour_screen.dart';
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
import 'app_routes.dart';

class AppPages {
  static final routes = [
    // auth
    GetPage(name: AppRoutes.splashScreen, page: () => const SplashScreen()),
    GetPage(name: AppRoutes.login, page: () => LoginScreen()),
    GetPage(name: AppRoutes.otpVerify, page: () => OtpVerifyScreen()),
    GetPage(name: AppRoutes.fullnameEnter, page: () => FullNameScreen()),
    GetPage(
      name: AppRoutes.sportInterrestScreen,
      page: () => SportsInterestScreen(),
    ),

    // home
    GetPage(
      name: AppRoutes.myHomePage,
      page: () => MyHomePage(),
      binding: HomeBinding(),
    ),
    GetPage(name: AppRoutes.channelPlay, page: () => ChannelPlayScreen()),

    GetPage(name: AppRoutes.notification, page: () => NotificationScreen()),

    // account page
    GetPage(name: AppRoutes.profilePage, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.accessPlan, page: () => AccessPlansScreen()),
    GetPage(name: AppRoutes.findPlayer, page: () => SearchPlayersScreen()),
    GetPage(name: AppRoutes.selectTour, page: () => SelectTourScreen()),
    GetPage(name: AppRoutes.followedPage, page: () => FollowingScreen()),
    GetPage(name: AppRoutes.activateTV, page: () => ActivateTvScreen()),
    GetPage(name: AppRoutes.referScreen, page: () => ReferralScreen()),
    GetPage(name: AppRoutes.chooseMatch, page: () => ChooseMatchPage()),
    GetPage(name: AppRoutes.accountDelete, page: () => DeleteAccountScreen()),

    // match details
    GetPage(name: AppRoutes.matchDetails, page: () => MatchDetailScreen()),
    GetPage(name: AppRoutes.matchPlay, page: () => MatchPlayScreen()),
    GetPage(name: AppRoutes.recapMatch, page: () => RecapMatchScreen()),
  ];
}
