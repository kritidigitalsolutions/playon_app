import 'package:flutter/material.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'dart:ui';
import 'package:table_calendar/table_calendar.dart';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class MatchScheduleScreen extends StatefulWidget {
  const MatchScheduleScreen({super.key});

  @override
  State<MatchScheduleScreen> createState() => _MatchScheduleScreenState();
}

class _MatchScheduleScreenState extends State<MatchScheduleScreen> {
  DateTime _focusedDay = DateTime(2026, 4, 7);
  DateTime _selectedDay = DateTime(
    2026,
    4,
    7,
  ); // Default selected like your image

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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryTab("All Sports", true),
                  _buildCategoryTab("Cricket", false),
                  _buildCategoryTab("Football", false),
                  _buildCategoryTab("Tennis", false),
                  _buildCategoryTab("Basketball", false),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const SizedBox(height: 20),

            // Matches List (You can filter this based on _selectedDay later)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ClipRRect(
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
                          firstDay: DateTime(2026, 1, 1),
                          lastDay: DateTime(2028, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            // TODO: Filter matches based on selected date
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
                  SizedBox(height: 10),
                  _buildMatchCard(
                    team1: "England",
                    team2: "South Africa",
                    flag1: "🇬🇧",
                    flag2: "🇿🇦",
                    time: "Today at 7:30 PM",
                    isLive: false,
                  ),
                  const SizedBox(height: 16),
                  _buildMatchCard(
                    team1: "Brazil",
                    team2: "Argentina",
                    flag1: "🇧🇷",
                    flag2: "🇦🇷",
                    time: "Today at 7:30 PM",
                    isLive: true,
                  ),
                  const SizedBox(height: 16),
                  _buildMatchCard(
                    team1: "England",
                    team2: "South Africa",
                    flag1: "🇬🇧",
                    flag2: "🇿🇦",
                    time: "Tomorrow at 3:00 PM",
                    isLive: false,
                  ),
                ],
              ),
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

  // Match Card (keep your existing one)
  Widget _buildMatchCard({
    required String team1,
    required String team2,
    required String flag1,
    required String flag2,
    required String time,
    required bool isLive,
  }) {
    // ... (same as your previous code)
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
                        Text(flag1, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Text(
                          team1,
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
                        Text(flag2, style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 6),
                        Text(
                          team2,
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
              AppButton(title: "View Details", onTap: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
