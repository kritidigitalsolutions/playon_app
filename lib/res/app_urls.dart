class AppUrls {
  static const String baseUrl = 'http://192.168.1.20:8000/api';

  // Auth Endpoints
  static const String sendOtp = '$baseUrl/auth/send-otp';
  static const String verifyOtp = '$baseUrl/auth/verify-otp';

  // User Endpoints
  static const String completeProfile = '$baseUrl/user/complete-profile';
  static const String deleteAccount = '$baseUrl/user/delete-account';
  static const String userProfile = '$baseUrl/user/profile';

  // Match Endpoints
  static const String matches = '$baseUrl/matches';
  static const String liveMatches = '$baseUrl/matches/live';

  // Channel Endpoints
  static const String liveChannels = '$baseUrl/channels/live';

  // Legal Endpoints
  static const String privacyPolicy = '$baseUrl/legal/privacy-policy';
  static const String aboutUs = '$baseUrl/legal/about-us';
  static const String refundPolicy = '$baseUrl/legal/refund-policy';
  static const String termsConditions = '$baseUrl/legal/terms-conditions';
}
