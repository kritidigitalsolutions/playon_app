import 'package:flutter/material.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'dart:ui';

import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class FollowingScreen extends StatefulWidget {
  const FollowingScreen({super.key});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
  int _selectedTab = 0; // 0 = Tours, 1 = Players

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: SafeArea(
          child: Column(
            children: [
              // Header with Back Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Following",
                      style: text20(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              // Tabs: Tours | Players
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _buildTab("Tours", 0),
                    const SizedBox(width: 8),
                    _buildTab("Players", 1),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content Area
              Expanded(
                child: _selectedTab == 0
                    ? _buildToursList()
                    : _buildPlayersList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tab Button
  Widget _buildTab(String title, int index) {
    final bool isSelected = _selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            border: isSelected
                ? Border.all(color: Colors.white.withOpacity(0.3))
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ====================== TOURS LIST ======================
  Widget _buildToursList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildTourCard();
      },
    );
  }

  Widget _buildTourCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              // Trophy Icon
              Image.asset(
                'assets/images/cup.png', // Replace with your actual trophy image
                width: 48,
                height: 48,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 48,
                ),
              ),
              const SizedBox(width: 16),

              // Tour Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "India Tour of Australia 2026",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "15 Apr, 2026",
                      style: TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),

              // Green Check
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================== PLAYERS LIST ======================
  Widget _buildPlayersList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 6,
      itemBuilder: (context, index) {
        return _buildPlayerCard();
      },
    );
  }

  Widget _buildPlayerCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              // Player Avatar
              ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  'assets/images/virat.png', // Replace with your player image
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 52,
                    height: 52,
                    color: Colors.blueGrey.shade800,
                    child: const Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Player Name
              const Expanded(
                child: Text(
                  "Virat Kohli",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Green Check
              const Icon(
                Icons.check_circle,
                color: Color(0xFF4CAF50),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
