class AppUrls {
  static const String baseUrl = 'http://192.168.1.20:8000/api';

  // Auth Endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';

  // User Endpoints
  static const String completeProfile = '$baseUrl/user/complete-profile';
  static const String updateProfile = '$baseUrl/user/update-profile';
  static const String deleteAccount = '$baseUrl/user/delete-account';
  static const String userProfile = '$baseUrl/user/profile';

  // Match Endpoints
  static const String matches = '$baseUrl/matches';
  static const String liveMatches = '$baseUrl/matches/live';
  static const String teams = '$baseUrl/teams';
  static const String series = '$baseUrl/series';
  static String toggleFollowSeries(String id) => '$baseUrl/series/$id/follow';
  static const String followedSeries = '$baseUrl/series/followed';

  // Channel Endpoints
  static const String liveChannels = '$baseUrl/channels/live';

  // Legal Endpoints
  static const String privacyPolicy = '$baseUrl/legal/privacy-policy';
  static const String aboutUs = '$baseUrl/legal/about-us';
  static const String refundPolicy = '$baseUrl/legal/refund-policy';
  static const String termsConditions = '$baseUrl/legal/terms-conditions';

  // Plan Endpoints
  static const String plans = '$baseUrl/plans';
  static const String mySubscription = '$baseUrl/subscriptions/my';
  static const String subscriptionHistory = '$baseUrl/subscriptions/history';
  static const String checkAccess = '$baseUrl/subscriptions/check-access';
  static String cancelSubscription(String id) => '$baseUrl/subscriptions/cancel/$id';
  static String deleteSubscription(String id) => '$baseUrl/subscriptions/delete/$id';

  // Player Endpoints
  static const String players = '$baseUrl/players';
  static String toggleFollowPlayer(String id) => '$baseUrl/players/$id/toggle-follow';
  static const String followedPlayers = '$baseUrl/players/following/me';

  // Notification Endpoints
  static const String notifications = '$baseUrl/notifications';
  static const String readAllNotifications = '$baseUrl/notifications/read-all';
  static const String notificationReadCount = '$baseUrl/notifications/read-count';
  static String readNotification(String id) => '$baseUrl/notifications/$id/read';
  static String deleteNotification(String id) => '$baseUrl/notifications/$id';

  // Payment Endpoints
  static const String createOrder = '$baseUrl/payment/create-order';
  static const String verifyPayment = '$baseUrl/payment/verify';
}
