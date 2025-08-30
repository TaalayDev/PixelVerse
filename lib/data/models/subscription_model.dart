import 'package:equatable/equatable.dart';

// Subscription plan types
enum SubscriptionPlan {
  free,
  proPurchase; // One-time purchase

  bool get isPro => this == SubscriptionPlan.proPurchase;
}

enum SubscriptionFeature {
  maxProjects,
  maxCanvasSize,
  exportFormats,
  advancedTools,
  cloudBackup,
  noWatermark,
  effects,
  templates,
  proTheme,
  prioritySupport,
}

class SubscriptionFeatureConfig {
  static const Map<SubscriptionPlan, int> maxProjects = {
    SubscriptionPlan.free: 10,
    SubscriptionPlan.proPurchase: 999,
  };

  static const Map<SubscriptionPlan, int> maxCanvasSize = {
    SubscriptionPlan.free: 64,
    SubscriptionPlan.proPurchase: 1024,
  };

  static const Map<SubscriptionPlan, List<String>> exportFormats = {
    SubscriptionPlan.free: ['PNG', 'JPEG'],
    SubscriptionPlan.proPurchase: ['PNG', 'JPEG', 'SVG', 'GIF', 'WEBP', 'MP4'],
  };

  static const Map<SubscriptionPlan, bool> advancedTools = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static const Map<SubscriptionPlan, bool> cloudBackup = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static const Map<SubscriptionPlan, bool> noWatermark = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static const Map<SubscriptionPlan, bool> prioritySupport = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static const Map<SubscriptionPlan, bool> templates = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static const Map<SubscriptionPlan, bool> effects = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static const Map<SubscriptionPlan, bool> proTheme = {
    SubscriptionPlan.free: false,
    SubscriptionPlan.proPurchase: true,
  };

  static T getFeatureValue<T>(SubscriptionFeature feature, SubscriptionPlan plan) {
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
      case SubscriptionFeature.effects:
        return effects[plan] as T;
      case SubscriptionFeature.templates:
        return templates[plan] as T;
      case SubscriptionFeature.proTheme:
        return proTheme[plan] as T;
    }
  }
}

class SubscriptionProductIds {
  static const String proPurchase = 'com.pixelverse.app.pro.purchase';

  static String planToProductId(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.proPurchase:
        return proPurchase;
      case SubscriptionPlan.free:
        return '';
    }
  }

  static SubscriptionPlan productIdToPlan(String productId) {
    switch (productId) {
      case proPurchase:
        return SubscriptionPlan.proPurchase;
      default:
        return SubscriptionPlan.free;
    }
  }
}

// Model representing a purchase offer
class PurchaseOffer extends Equatable {
  final SubscriptionPlan plan;
  final String title;
  final String description;
  final String price;
  final bool isMostPopular;
  final List<String> features;

  const PurchaseOffer({
    required this.plan,
    required this.title,
    required this.description,
    required this.price,
    this.isMostPopular = false,
    required this.features,
  });

  @override
  List<Object?> get props => [plan, title, price, features];
}

// Status of a purchase
enum AppPurchaseStatus {
  notPurchased,
  purchased,
  pendingPurchase,
}

// Temporary pro access from ads
class TemporaryProAccess extends Equatable {
  final DateTime startTime;
  final Duration duration;

  const TemporaryProAccess({
    required this.startTime,
    required this.duration,
  });

  DateTime get endTime => startTime.add(duration);
  bool get isActive => DateTime.now().isBefore(endTime);
  Duration get remainingTime => isActive ? endTime.difference(DateTime.now()) : Duration.zero;

  @override
  List<Object?> get props => [startTime, duration];

  factory TemporaryProAccess.fromJson(Map<String, dynamic> json) {
    return TemporaryProAccess(
      startTime: DateTime.parse(json['startTime'] as String),
      duration: Duration(milliseconds: json['duration'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime.toIso8601String(),
      'duration': duration.inMilliseconds,
    };
  }
}

// Model to track the user's current purchase and temporary access
class UserSubscription extends Equatable {
  final SubscriptionPlan plan;
  final AppPurchaseStatus status;
  final String? purchaseId;
  final DateTime? purchaseDate;
  final TemporaryProAccess? temporaryProAccess;

  const UserSubscription({
    required this.plan,
    required this.status,
    this.purchaseId,
    this.purchaseDate,
    this.temporaryProAccess,
  });

  const UserSubscription.free()
      : plan = SubscriptionPlan.free,
        status = AppPurchaseStatus.notPurchased,
        purchaseId = null,
        purchaseDate = null,
        temporaryProAccess = null;

  UserSubscription copyWith({
    SubscriptionPlan? plan,
    AppPurchaseStatus? status,
    String? purchaseId,
    DateTime? purchaseDate,
    TemporaryProAccess? temporaryProAccess,
  }) {
    return UserSubscription(
      plan: plan ?? this.plan,
      status: status ?? this.status,
      purchaseId: purchaseId ?? this.purchaseId,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      temporaryProAccess: temporaryProAccess ?? this.temporaryProAccess,
    );
  }

  UserSubscription clearTemporaryAccess() {
    return copyWith(
      plan: SubscriptionPlan.free,
      status: AppPurchaseStatus.notPurchased,
      temporaryProAccess: TemporaryProAccess(
        startTime: DateTime.now(),
        duration: Duration.zero,
      ),
    );
  }

  bool get isPermanentPro => plan == SubscriptionPlan.proPurchase && status == AppPurchaseStatus.purchased;
  bool get hasTemporaryPro => temporaryProAccess?.isActive ?? false;
  bool get isPro => isPermanentPro || hasTemporaryPro;

  // Check if user has access to a specific feature
  bool hasFeatureAccess(SubscriptionFeature feature) {
    // If user has temporary pro access, grant all pro features
    if (hasTemporaryPro) {
      switch (feature) {
        case SubscriptionFeature.maxProjects:
        case SubscriptionFeature.maxCanvasSize:
        case SubscriptionFeature.exportFormats:
          return true;
        case SubscriptionFeature.advancedTools:
        case SubscriptionFeature.noWatermark:
        case SubscriptionFeature.prioritySupport:
          return true;
        case SubscriptionFeature.proTheme:
        case SubscriptionFeature.effects:
        case SubscriptionFeature.templates:
        case SubscriptionFeature.cloudBackup:
          return false;
      }
    }

    // Otherwise check permanent purchase status
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
      case SubscriptionFeature.proTheme:
      case SubscriptionFeature.effects:
      case SubscriptionFeature.templates:
        if (!isPermanentPro) return false;
        return SubscriptionFeatureConfig.getFeatureValue<bool>(
          feature,
          plan,
        );
    }
  }

  // Get feature limit based on current access level
  T getFeatureLimit<T>(SubscriptionFeature feature) {
    final effectivePlan = isPro ? SubscriptionPlan.proPurchase : SubscriptionPlan.free;
    return SubscriptionFeatureConfig.getFeatureValue<T>(feature, effectivePlan);
  }

  @override
  List<Object?> get props => [plan, status, purchaseId, purchaseDate, temporaryProAccess];
}
