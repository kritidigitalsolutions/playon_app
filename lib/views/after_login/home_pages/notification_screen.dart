import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:play_on_app/model/response_model/notification_model.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';
import 'package:play_on_app/utils/custom_button.dart';
import 'package:play_on_app/view_model/after_controller/notification_controller.dart';
import 'package:play_on_app/views/custom_background.dart/custom_widget.dart';
import 'package:intl/intl.dart';

import '../../../data/api_responce_data.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController controller = Get.put(NotificationController());
  NotificationData? recentlyDeleted;
  int? recentlyDeletedIndex;
  Timer? deleteTimer;


  void _showNotificationDetail(NotificationData notif) {
    if (notif.isRead == false) {
      controller.markAsRead(notif.id!);
    }
    
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
              if (notif.image != null && notif.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: notif.image!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: AppColors.white.withValues(alpha: 0.05),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: AppColors.white.withValues(alpha: 0.05),
                      child: const Icon(Icons.error),
                    ),
                  ),
                )
              else if (notif.metadata?.image != null &&
                  notif.metadata!.image!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: notif.metadata!.image!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 180,
                      color: AppColors.white.withValues(alpha: 0.05),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 180,
                      color: AppColors.white.withValues(alpha: 0.05),
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
              Text(notif.title ?? "", style: text20(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                "${notif.type} • ${_formatDate(notif.sentAt)}",
                style: text13(color: AppColors.white70),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    notif.message ?? "",
                    style: text15(
                      color: AppColors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      title: "Delete",
                      color: AppColors.error,
                      onTap: () {
                        controller.deleteNotification(notif.id!);
                        Navigator.pop(context);
                      },
                      textStyle: text15(color: Colors.white),
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

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
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
                Row(
                  children: [
                    Text(
                      "Notifications",
                      style: text20(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Obx(() {
                      final notifications =
                          controller.notificationList.value.data?.notifications ?? [];

                      final hasUnread = notifications.any((n) => n.isRead == false);

                      return TextButton.icon(
                        onPressed: hasUnread ? () => controller.markAllAsRead() : null,
                        icon: Icon(
                          Icons.done_all,
                          size: 20,
                          color: hasUnread ? AppColors.success : AppColors.white, // 👈 color change
                        ),
                        label: Text(
                          "Mark all read",
                          style: text13(
                            color: hasUnread ? AppColors.success : AppColors.white,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    switch (controller.notificationList.value.status) {
                      case Status.loading:
                        return const Center(child: CircularProgressIndicator());
                      case Status.error:
                        return Center(
                          child: Text(
                            controller.notificationList.value.message.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      case Status.completed:
                        final notifications =
                            controller.notificationList.value.data?.notifications ?? [];
                        if (notifications.isEmpty) {
                          return const Center(
                            child: Text(
                              "No notifications yet",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async {
                            controller.fetchNotifications();
                            controller.fetchReadCount();
                          },
                          child: ListView.builder(
                            itemCount: notifications.length,
                            itemBuilder: (context, index) {
                              final notif = notifications[index];
                              final bool isRead = notif.isRead ?? false;

                              return Dismissible(
                                key: Key(notif.id.toString()),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                onDismissed: (_) {
                                  final list = controller.notificationList.value.data?.notifications;

                                  if (list == null) return;

                                  recentlyDeleted = notif;
                                  recentlyDeletedIndex = index;

                                  list.removeAt(index);
                                  controller.notificationList.refresh();

                                  // Show UNDO snackbar
                                  Get.snackbar(
                                    "",
                                    "",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.transparent,
                                    margin: const EdgeInsets.all(12),
                                      padding: EdgeInsets.zero,
                                    duration: const Duration(seconds: 5),

                                    messageText: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: AppColors.secPrimary.withValues(alpha: 0.95),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AppColors.white.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),

                                          const SizedBox(width: 12),

                                          Expanded(
                                            child: Text(
                                              "Notification removed",
                                              style: text14(
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),

                                          GestureDetector(
                                            onTap: () {
                                              deleteTimer?.cancel();

                                              if (recentlyDeleted != null && recentlyDeletedIndex != null) {
                                                list.insert(recentlyDeletedIndex!, recentlyDeleted!);
                                                controller.notificationList.refresh();
                                              }

                                              Get.closeCurrentSnackbar(); // 👈 close after undo
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "UNDO",
                                                style: text12(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );

                                  // Delay API call
                                  deleteTimer = Timer(const Duration(seconds: 5), () {
                                    if (recentlyDeleted != null) {
                                      controller.deleteNotification(recentlyDeleted!.id!);
                                      recentlyDeleted = null;
                                      recentlyDeletedIndex = null;
                                    }
                                  });
                                },
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
                                            color: isRead
                                                ? AppColors.white.withValues(alpha: 0.05)
                                                : AppColors.white.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: AppColors.white.withValues(
                                                alpha: isRead ? 0.1 : 0.22,
                                              ),
                                              width: 1,
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            leading: SizedBox(
                                              width: 50,
                                              height: 50,
                                              child: Stack(
                                                children: [
                                                  if (notif.image != null &&
                                                      notif.image!.isNotEmpty)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                      child: CachedNetworkImage(
                                                        imageUrl: notif.image!,
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Container(
                                                          color: AppColors.white.withValues(alpha: 0.05),
                                                        ),
                                                        errorWidget: (context,
                                                                url,
                                                                error) =>
                                                            _defaultIcon(isRead),
                                                      ),
                                                    )
                                                  else if (notif.metadata?.image !=
                                                          null &&
                                                      notif.metadata!.image!
                                                          .isNotEmpty)
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(8),
                                                      child: CachedNetworkImage(
                                                        imageUrl: notif.metadata!.image!,
                                                        width: 50,
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                        placeholder: (context, url) => Container(
                                                          color: AppColors.white.withValues(alpha: 0.05),
                                                        ),
                                                        errorWidget: (context,
                                                                url,
                                                                error) =>
                                                            _defaultIcon(isRead),
                                                      ),
                                                    )
                                                  else
                                                    _defaultIcon(isRead),
                                                  if (!isRead)
                                                    Positioned(
                                                      top: 0,
                                                      right: 0,
                                                      child: Container(
                                                        width: 10,
                                                        height: 10,
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Colors.blueAccent,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            title: Text(
                                              notif.title ?? "",
                                              style: text15(
                                                fontWeight: isRead
                                                    ? FontWeight.w500
                                                    : FontWeight.w600,
                                              ),
                                            ),
                                            subtitle: Text(
                                              notif.message ?? "",
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: text13(color: AppColors.white70),
                                            ),
                                            trailing: Text(
                                              _formatDate(notif.sentAt),
                                              style: text12(color: AppColors.white60),
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
                        );
                      default:
                        return const SizedBox();
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultIcon(bool isRead) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isRead
            ? AppColors.white.withValues(alpha: 0.1)
            : AppColors.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.notifications_outlined,
        color: isRead ? AppColors.white70 : AppColors.primary,
        size: 26,
      ),
    );
  }
}
