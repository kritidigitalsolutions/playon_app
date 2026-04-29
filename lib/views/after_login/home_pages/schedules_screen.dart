import 'package:play_on_app/model/response_model/match_model.dart' as model;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';
import 'package:play_on_app/view_model/after_controller/home_contollers/home_controller.dart';
import 'package:table_calendar/table_calendar.dart';

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
    String? sport = ctr.sportsList[ctr.selectedTabIndex.value] == "Home" ||
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
            // Header
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
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Category Tabs
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
                        ctr.sportsList[index] == "Home" ? "All Sports" : ctr.sportsList[index],
                        ctr.selectedTabIndex.value == index,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Calendar Section - Moved outside of Obx to prevent full refresh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 1.2,
                      ),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime(2024, 1, 1),
                      lastDay: DateTime(2028, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _fetchMatches();
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        defaultTextStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: Colors.white70,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF2196F3),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        defaultDecoration: const BoxDecoration(
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
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Colors.white70,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Colors.white70,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(color: Colors.white60),
                        weekendStyle: TextStyle(color: Colors.white60),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Matches List
            Expanded(
              child: Obx(() {
                if (ctr.isScheduleLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (ctr.scheduledMatches.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Text(
                        "No matches scheduled for this date",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ctr.scheduledMatches.length,
                  itemBuilder: (context, index) {
                    final match = ctr.scheduledMatches[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildMatchCard(
                        match: match,
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Category Tab
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
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  // Match Card
  Widget _buildMatchCard({required model.Match match}) {
    bool isLive = match.status?.toLowerCase() == 'live';
    String time = match.matchDate != null
        ? match.matchDate!.split('T')[1].substring(0, 5)
        : "TBA";

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        if (match.teamALogo != null && match.teamALogo!.isNotEmpty)
                          Image.network(match.teamALogo!, height: 40, width: 40)
                        else
                          const Icon(Icons.shield, color: Colors.white, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          match.teamA ?? "Team A",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "LIVE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        const Text(
                          "VS",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        if (match.teamBLogo != null && match.teamBLogo!.isNotEmpty)
                          Image.network(match.teamBLogo!, height: 40, width: 40)
                        else
                          const Icon(Icons.shield, color: Colors.white, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          match.teamB ?? "Team B",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppButton(
                title: "View Details",
                onTap: () {
                  ctr.handleProtectedAction(() {
                    Get.toNamed(AppRoutes.matchDetails, arguments: match);
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
