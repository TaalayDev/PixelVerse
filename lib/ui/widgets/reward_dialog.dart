import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../providers/ad/reward_video_ad_controller.dart';
import '../screens/subscription_screen.dart';

class RewardDialog extends HookConsumerWidget {
  const RewardDialog({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRewardEarned,
  });

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String subtitle,
    VoidCallback? onRewardEarned,
  }) {
    return showDialog(
      context: context,
      builder: (context) => RewardDialog(
        title: title,
        subtitle: subtitle,
        onRewardEarned: onRewardEarned,
      ),
    );
  }

  final String title;
  final String subtitle;
  final VoidCallback? onRewardEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardAdState = ref.watch(rewardVideoAdProvider);

    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Premium upgrade option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Upgrade to Premium',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '• Unlimited downloads\n• Export to all formats\n• No ads\n• Priority support',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Reward video option
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.play_circle_fill, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Watch Video',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  rewardAdState
                      ? '• Watch a short video ad\n• Support the app\n• Earn rewards for watching'
                      : '• Video ad is loading...\n• Please try again in a moment',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SubscriptionOfferScreen(),
              ),
            );
          },
          child: const Text('Upgrade'),
        ),
        ElevatedButton(
          onPressed: rewardAdState
              ? () async {
                  Navigator.of(context).pop();
                  await _watchVideoAndDownload(context, ref);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: Text(rewardAdState ? 'Watch Video' : 'Loading...'),
        ),
      ],
    );
  }

  Future<void> _watchVideoAndDownload(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Loading video ad...'),
            ],
          ),
        ),
      );

      // Load reward video ad
      final rewardController = ref.read(rewardVideoAdProvider.notifier);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show reward video
      final rewardEarned = await rewardController.showAdIfLoaded();

      if (!context.mounted) return;

      if (rewardEarned) {
        onRewardEarned?.call();
      } else {
        // User didn't complete the video or ad failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video ad was not completed. Please try again or upgrade to Premium.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        // Close loading dialog if it's still open
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load video ad: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
