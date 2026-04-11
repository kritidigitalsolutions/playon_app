import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, dynamic>> notifications = List.generate(
    15,
    (index) => {
      "id": index,
      "title": index % 3 == 0
          ? "Match Started: India vs Australia"
          : index % 3 == 1
          ? "Welcome back! Your favorite team is playing live"
          : "New Reward: 50% off on IPL Pass",
      "subtitle": "Star Sports • Just now",
      "time": index == 0 ? "12:30 PM" : "${11 - index}:45 AM",
      "isRead": index > 5, // First few are unread
      "fullMessage":
          "India vs Australia T20 match has started at Wankhede Stadium. "
          "Virat Kohli is on strike. Don't miss the live action! "
          "Get exclusive commentary and match stats only on PlayOn.",
    },
  );

  void _showNotificationDetail(Map<String, dynamic> notif) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.secPrimary,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.12),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.white.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(notif['title'], style: text20(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Time & Source
              Text(
                "${notif['subtitle']} • ${notif['time']}",
                style: text13(color: AppColors.white70),
              ),

              const SizedBox(height: 24),

              // Full Message
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    notif['fullMessage'],
                    style: text15(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      title: "Close",
                      onTap: () => Navigator.pop(context),
                      color: AppColors.white.withValues(alpha: 0.15),
                      textStyle: text15(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      title: "Mark as Read",
                      onTap: () {
                        // TODO: Mark this notification as read in your list
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Marked as read")),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _deleteNotification(int id) {
    setState(() {
      notifications.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Notification deleted")));
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in notifications) {
        notif['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("All notifications marked as read")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWithOutImg(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      "Notifications",
                      style: text20(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _markAllAsRead,
                      icon: const Icon(Icons.done_all, size: 20),
                      label: const Text("Mark all read"),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.white70,
                      ),
                    ),
                    AppIconButton(
                      icon: Icons.notifications,
                      color: AppColors.warning,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Notification List
                Expanded(
                  child: notifications.isEmpty
                      ? const Center(
                          child: Text(
                            "No notifications yet",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (context, index) {
                            final notif = notifications[index];
                            final bool isRead = notif['isRead'] ?? false;

                            return Dismissible(
                              key: Key(notif['id'].toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.redAccent,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              onDismissed: (_) =>
                                  _deleteNotification(notif['id']),
                              child: GestureDetector(
                                onTap: () => _showNotificationDetail(notif),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 18,
                                        sigmaY: 18,
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.white.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: AppColors.white.withValues(
                                              alpha: 0.22,
                                            ),
                                            width: 1,
                                          ),
                                        ),
                                        child: ListTile(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                          leading: !isRead
                                              ? Container(
                                                  width: 10,
                                                  height: 10,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            Colors.blueAccent,
                                                        shape: BoxShape.circle,
                                                      ),
                                                )
                                              : null,
                                          title: Text(
                                            notif['title'],
                                            style: text15(
                                              fontWeight: isRead
                                                  ? FontWeight.w500
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                          subtitle: Text(
                                            notif['subtitle'],
                                            style: text13(
                                              color: AppColors.white70,
                                            ),
                                          ),
                                          trailing: Text(
                                            notif['time'],
                                            style: text12(
                                              color: AppColors.white60,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
