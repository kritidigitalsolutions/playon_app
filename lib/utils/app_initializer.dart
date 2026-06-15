import 'dart:async';

/// Tracks when heavy app initialization (Firebase, Notifications) is complete.
/// SplashScreen awaits this before navigating to prevent black screen on iOS.
class AppInitializer {
  AppInitializer._(); // prevent instantiation

  static final Completer<void> _completer = Completer<void>();

  /// Await this in SplashScreen before navigating
  static Future<void> get initFuture => _completer.future;

  /// Check if init is already done
  static bool get isComplete => _completer.isCompleted;

  /// Call this once heavy services finish (or fail) in main.dart
  static void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }
}