import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:play_on_app/model/response_model/match_model.dart' as model;
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/plan_controller.dart';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import '../../../routes/app_routes.dart';

class MatchScheduleScreen extends StatefulWidget {
  const MatchScheduleScreen({super.key});

  @override
  State<MatchScheduleScreen> createState() => _MatchScheduleScreenState();
}

class _MatchScheduleScreenState extends State<MatchScheduleScreen> {
  final HomeController ctr = Get.find();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchMatches();
  }

  void _fetchMatches() {
    String dateStr = _selectedDay.toIso8601String().split('T')[0];

    String? sport =
    ctr.sportsList[ctr.selectedTabIndex.value] == "Home" ||
        ctr.sportsList[ctr.selectedTabIndex.value] == "All Sports"
        ? null
        : ctr.sportsList[ctr.selectedTabIndex.value];

    ctr.fetchScheduledMatches(date: dateStr, sport: sport);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWithOutImg(
      child: SafeArea(
        child: Column(
          children: [
            /// 🔹 Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                  const Text(
                    "Match Schedule",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔥 FULL SCROLL AREA
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    /// 🔹 Category Tabs
                    Obx(
                          () => SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: List.generate(
                            ctr.sportsList.length,
                                (index) => GestureDetector(
                              onTap: () {
                                ctr.selectedTabIndex.value = index;
                                _fetchMatches();
                              },
                              child: _buildCategoryTab(
                                ctr.sportsList[index] == "Home"
                                    ? "All Sports"
                                    : ctr.sportsList[index],
                                ctr.selectedTabIndex.value == index,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// 🔹 Calendar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildCalendar(),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 Match List
                    Obx(() {
                      if (ctr.isScheduleLoading.value) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (ctr.scheduledMatches.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(
                            child: Text(
                              "No matches scheduled for this date",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: ctr.scheduledMatches.length,
                        itemBuilder: (context, index) {
                          final match = ctr.scheduledMatches[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildMatchCard(match: match),
                          );
                        },
                      );
                    }),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Calendar Widget
  Widget _buildCalendar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: TableCalendar(
            firstDay: DateTime(2024, 1, 1),
            lastDay: DateTime(2028, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _fetchMatches();
            },

            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white70),
              weekendTextStyle: const TextStyle(color: Colors.white70),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              todayTextStyle: const TextStyle(color: Colors.white),
              selectedDecoration: const BoxDecoration(
                color: Color(0xFF2196F3),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),

            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              leftChevronIcon:
              Icon(Icons.chevron_left, color: Colors.white70),
              rightChevronIcon:
              Icon(Icons.chevron_right, color: Colors.white70),
            ),

            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.white60),
              weekendStyle: TextStyle(color: Colors.white60),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Category Tab
  Widget _buildCategoryTab(String text, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 14,
          fontWeight:
          isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  /// 🔹 Match Card
  Widget _buildMatchCard({required model.Match match}) {
    bool isLive = match.status?.toLowerCase() == 'live';

    String time = match.matchDate != null
        ? match.matchDate!.split('T')[1].substring(0, 5)
        : "TBA";

    return Obx(() {
      final canWatch = Get.find<PlanController>().canWatchMatch(match);
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              image: match.thumbnail != null && match.thumbnail!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(match.thumbnail!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.7),
                        BlendMode.darken,
                      ),
                    )
                  : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Series info row
                Row(
                  children: [
                    Builder(builder: (context) {
                      final homeController = Get.find<HomeController>();
                      final seriesLogo = homeController.getSeriesLogo(match.seriesId);

                      return Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: seriesLogo.isNotEmpty
                            ? Image.network(
                                seriesLogo,
                                height: 14,
                                width: 14,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.emoji_events, color: Colors.blue, size: 14),
                              )
                            : const Icon(Icons.emoji_events, color: Colors.blue, size: 14),
                      );
                    }),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final homeController = Get.find<HomeController>();
                          final seriesName = homeController.getSeriesName(match.seriesId);
                          return Text(
                            (seriesName.isNotEmpty ? seriesName : (match.tournament ?? "SERIES")).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          );
                        }
                      ),
                    ),
                    if (isLive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "LIVE",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _team(match.teamA, match.teamALogo)),
                    Column(
                      children: [
                        const Text("VS",
                            style: TextStyle(
                              color: Colors.white24,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 4),
                        Text(time,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Expanded(child: _team(match.teamB, match.teamBLogo)),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  height: 40,
                  title: isLive ? "Watch Now" : "View Details",
                  onTap: () {
                    if (isLive) {
                      if (canWatch) {
                        Get.toNamed(AppRoutes.matchPlay, arguments: match);
                      } else {
                        ctr.handleProtectedAction(() {
                          Get.toNamed(AppRoutes.matchPlay, arguments: match);
                        });
                      }
                    } else {
                      Get.toNamed(AppRoutes.matchDetails, arguments: match);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _team(String? name, String? logo) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: logo != null && logo.isNotEmpty
              ? Image.network(logo, fit: BoxFit.contain)
              : const Icon(Icons.shield, color: Colors.white38, size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          name ?? "Team",
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
