import 'package:equatable/equatable.dart';

// Subscription plan types
enum SubscriptionPlan {
  free,
  proMonthly,
  proYearly,
}

// Subscription feature identifiers
enum SubscriptionFeature {
  maxProjects,
  maxCanvasSize,
  exportFormats,
  advancedTools,
  cloudBackup,
  noWatermark,
  prioritySupport,
}

// Feature limits for each subscription plan
class SubscriptionFeatureConfig {
  // Maximum number of projects
  static const Map<SubscriptionPlan, int> maxProjects = {
    SubscriptionPlan.free: 10,
    SubscriptionPlan.proMonthly: 999,
    SubscriptionPlan.proYearly: 999,
  };

  // Maximum canvas size (width/height in pixels)
  static const Map<SubscriptionPlan, int> maxCanvasSize = {
    SubscriptionPlan.free: 64,
    SubscriptionPlan.proMonthly: 512,
    SubscriptionPlan.proYearly: 1024,
  };

  // Available export formats
  static const Map<SubscriptionPlan, List<String>> exportFormats = {
    SubscriptionPlan.free: ['PNG', 'JPEG'],
    SubscriptionPlan.proMonthly: ['PNG', 'JPEG', 'SVG', 'GIF'],
    SubscriptionPlan.proYearly: ['PNG', 'JPEG', 'SVG', 'GIF', 'WEBP', 'MP4'],
  };

  // Advanced tools access
  static const Map<SubscriptionPlan, bool> advancedTools = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proMonthly: true,
    SubscriptionPlan.proYearly: true,
  };

  // Cloud backup access
  static const Map<SubscriptionPlan, bool> cloudBackup = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proMonthly: true,
    SubscriptionPlan.proYearly: true,
  };

  // No watermark on exports
  static const Map<SubscriptionPlan, bool> noWatermark = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proMonthly: true,
    SubscriptionPlan.proYearly: true,
  };

  // Priority support
  static const Map<SubscriptionPlan, bool> prioritySupport = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proMonthly: false,
    SubscriptionPlan.proYearly: true,
  };

  // Get feature value by plan
  static T getFeatureValue<T>(
      SubscriptionFeature feature, SubscriptionPlan plan) {
    switch (feature) {
      case SubscriptionFeature.maxProjects:
        return maxProjects[plan] as T;
      case SubscriptionFeature.maxCanvasSize:
        return maxCanvasSize[plan] as T;
      case SubscriptionFeature.exportFormats:
        return exportFormats[plan] as T;
      case SubscriptionFeature.advancedTools:
        return advancedTools[plan] as T;
      case SubscriptionFeature.cloudBackup:
        return cloudBackup[plan] as T;
      case SubscriptionFeature.noWatermark:
        return noWatermark[plan] as T;
      case SubscriptionFeature.prioritySupport:
        return prioritySupport[plan] as T;
    }
  }
}

// Subscription product identifiers
class SubscriptionProductIds {
  // Replace these with your actual product IDs from the stores
  static const String proMonthly = 'com.pixelverse.app.pro.monthly';
  static const String proYearly = 'com.pixelverse.app.pro.yearly';

  static String planToProductId(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.proMonthly:
        return proMonthly;
      case SubscriptionPlan.proYearly:
        return proYearly;
      case SubscriptionPlan.free:
        return '';
    }
  }

  static SubscriptionPlan productIdToPlan(String productId) {
    switch (productId) {
      case proMonthly:
        return SubscriptionPlan.proMonthly;
      case proYearly:
        return SubscriptionPlan.proYearly;
      default:
        return SubscriptionPlan.free;
    }
  }
}

// Model representing a subscription plan offer
class SubscriptionOffer extends Equatable {
  final SubscriptionPlan plan;
  final String title;
  final String description;
  final String price;
  final String period;
  final String saveText;
  final bool isMostPopular;
  final List<String> features;

  const SubscriptionOffer({
    required this.plan,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    this.saveText = '',
    this.isMostPopular = false,
    required this.features,
  });

  @override
  List<Object?> get props => [plan, title, price, period, features];
}

// Status of a subscription
enum SubscriptionStatus {
  notPurchased,
  active,
  expired,
  gracePeriod,
  pendingPurchase,
}

// Model to track the user's current subscription
class UserSubscription extends Equatable {
  final SubscriptionPlan plan;
  final SubscriptionStatus status;
  final DateTime? expiryDate;
  final String? purchaseId;
  final DateTime? purchaseDate;

  const UserSubscription({
    required this.plan,
    required this.status,
    this.expiryDate,
    this.purchaseId,
    this.purchaseDate,
  });

  const UserSubscription.free()
      : plan = SubscriptionPlan.free,
        status = SubscriptionStatus.notPurchased,
        expiryDate = null,
        purchaseId = null,
        purchaseDate = null;

  UserSubscription copyWith({
    SubscriptionPlan? plan,
    SubscriptionStatus? status,
    DateTime? expiryDate,
    String? purchaseId,
    DateTime? purchaseDate,
  }) {
    return UserSubscription(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      purchaseId: purchaseId ?? this.purchaseId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
    );
  }

  bool get isActive =>
      status == SubscriptionStatus.active ||
      status == SubscriptionStatus.gracePeriod;
  bool get isProPlan =>
      plan == SubscriptionPlan.proMonthly || plan == SubscriptionPlan.proYearly;
  bool get isPro => isProPlan && isActive;

  // Check if user has access to a specific feature
  bool hasFeatureAccess(SubscriptionFeature feature) {
    switch (feature) {
      case SubscriptionFeature.maxProjects:
      case SubscriptionFeature.maxCanvasSize:
        return true; // These features are always available but with different limits
      case SubscriptionFeature.exportFormats:
        return true; // Always available but with limited formats for free users
      case SubscriptionFeature.advancedTools:
      case SubscriptionFeature.cloudBackup:
      case SubscriptionFeature.noWatermark:
      case SubscriptionFeature.prioritySupport:
        if (!isPro) return false;
        return SubscriptionFeatureConfig.getFeatureValue<bool>(
          feature,
          plan,
        );
    }
  }

  @override
  List<Object?> get props =>
      [plan, status, expiryDate, purchaseId, purchaseDate];
}
