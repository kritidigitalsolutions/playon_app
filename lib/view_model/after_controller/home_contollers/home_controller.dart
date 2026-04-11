import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/views/after_login/channel_page/sport_channel_list.dart';
import 'package:play_on_app/views/after_login/home_pages/home_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/schedules_screen.dart';
import 'package:play_on_app/views/after_login/home_pages/watch_list_screen.dart';

class HomeController extends GetxController {
  final RxInt currentIndex = 0.obs;

  final List<Widget> screens = [
    const HomeScreen(), // Your full scrolling home screen
    const SportChannelList(),
    CreateWatchlistScreen(),
    MatchScheduleScreen(),
  ];

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}
