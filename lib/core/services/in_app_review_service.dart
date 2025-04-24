import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling app reviews.
/// This class manages when to prompt for reviews, and handles the actual review request.
class InAppReviewService {
  static const _lastReviewRequestTimeKey = 'last_review_request_time';
  static const _sessionCountKey = 'app_session_count';
  static const _projectsCountKey = 'app_projects_count';
  static const _hasRatedKey = 'user_has_rated_app';

  // Configuration settings
  // Ask after 5 sessions
  static const int _sessionsBeforeFirstRequest = 5;
  // Ask again after 20 more sessions
  static const int _sessionsBeforeReminder = 20;
  // Don't ask more than once every 60 days
  static const Duration _minIntervalBetweenRequests = Duration(days: 60);
  // Ask after first project is created
  static const int _projectsBeforeFirstRequest = 1;

  final InAppReview _inAppReview = InAppReview.instance;

  /// Increment session count when the app is opened
  Future<void> incrementSessionCount() async {
    if (kIsWeb) return; // Not available on web

    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_sessionCountKey) ?? 0;
    await prefs.setInt(_sessionCountKey, currentCount + 1);
  }

  Future<void> incrementProjectCount() async {
    if (kIsWeb) return; // Not available on web

    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_projectsCountKey) ?? 0;
    await prefs.setInt(_projectsCountKey, currentCount + 1);
  }

  /// Check if we should request a review based on sessions and time since last request
  Future<bool> shouldRequestReview() async {
    if (kIsWeb) return false; // Not available on web

    // Check if review dialog is available on this device
    final bool isAvailable = await _inAppReview.isAvailable();
    if (!isAvailable) return false;

    final prefs = await SharedPreferences.getInstance();

    // If the user has already rated the app, don't ask again
    final hasRated = prefs.getBool(_hasRatedKey) ?? false;
    if (hasRated) return false;

    final sessionCount = prefs.getInt(_sessionCountKey) ?? 0;
    final projectCount = prefs.getInt(_projectsCountKey) ?? 0;
    final lastRequestTime = prefs.getInt(_lastReviewRequestTimeKey);

    // Check if enough projects have been created
    if (projectCount < _projectsBeforeFirstRequest) {
      return false;
    } else if (lastRequestTime == null) {
      return true; // First request
    }

    // Check if enough sessions have passed
    if (sessionCount < _sessionsBeforeFirstRequest) {
      return false;
    }

    // If this is not the first request, check for minimum interval
    if (lastRequestTime != null) {
      final lastRequest = DateTime.fromMillisecondsSinceEpoch(lastRequestTime);
      final now = DateTime.now();
      final daysSinceLastRequest = now.difference(lastRequest);

      // If not enough days have passed AND not enough new sessions, don't request
      if (daysSinceLastRequest < _minIntervalBetweenRequests &&
          (sessionCount - _sessionsBeforeFirstRequest) %
                  _sessionsBeforeReminder !=
              0) {
        return false;
      }
    }

    return true;
  }

  /// Request a review from the user
  Future<void> requestReview() async {
    if (kIsWeb) return; // Not available on web

    try {
      final prefs = await SharedPreferences.getInstance();

      // If on Android or iOS, use the platform-specific review flow
      if (Platform.isAndroid || Platform.isIOS) {
        await _inAppReview.requestReview();
      } else {
        // For other platforms, open the store page directly
        await _inAppReview.openStoreListing(appStoreId: '123456789');
      }

      // Update the last request time
      await prefs.setInt(
        _lastReviewRequestTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('Error requesting review: $e');
    }
  }

  /// Mark that the user has rated the app, so we don't ask again
  Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedKey, true);
  }

  /// For debug purposes: Reset all review-related data
  Future<void> resetReviewData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastReviewRequestTimeKey);
    await prefs.remove(_sessionCountKey);
    await prefs.remove(_hasRatedKey);
  }
}
