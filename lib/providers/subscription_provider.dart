import 'package:collection/collection.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/subscription_model.dart';
import '../core/services/subscription_service.dart';

part 'subscription_provider.g.dart';

// Provider for the Subscription Service
final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final service = SubscriptionService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

// Provider for current subscription state
@riverpod
class SubscriptionState extends _$SubscriptionState {
  @override
  UserSubscription build() {
    final service = ref.watch(subscriptionServiceProvider);

    // Initialize service if needed
    if (!service.isInitialized) {
      service.initialize();
    }

    // Listen to subscription changes
    ref.listenSelf((previous, next) {
      // Handle subscription state changes
      if (previous?.plan != next.plan || previous?.status != next.status) {
        // You could perform actions when subscription changes, like analytics tracking
      }
    });

    // Listen to the service's subscription stream
    final subscription = ref.listen(
      subscriptionStreamProvider,
      (previous, next) {
        if (next.valueOrNull != null) {
          state = UserSubscription(
            plan: SubscriptionPlan.proYearly,
            status: SubscriptionStatus.active,
            expiryDate: DateTime.now().add(const Duration(days: 30)),
            purchaseId: '123456',
            purchaseDate: DateTime.now(),
          );
          // state = next.value!;
        }
      },
    );

    // Return current subscription state
    return service.currentSubscription;
  }

  // Initiate a purchase
  Future<void> purchase(SubscriptionPlan plan) async {
    final service = ref.read(subscriptionServiceProvider);

    try {
      final productDetails = service.getProductDetails(plan);
      if (productDetails != null) {
        await service.purchaseSubscription(productDetails);
      } else {
        throw Exception('Product not available');
      }
    } catch (e, s) {
      print('Error purchasing subscription: $e');
      print(s);
      // Handle purchase error
      rethrow;
    }
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    final service = ref.read(subscriptionServiceProvider);
    await service.restorePurchases();
  }

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
        if (!state.isPro) return false;
        return SubscriptionFeatureConfig.getFeatureValue<bool>(
          feature,
          state.plan,
        );
    }
  }

  // Get feature limit value
  T getFeatureLimit<T>(SubscriptionFeature feature) {
    return SubscriptionFeatureConfig.getFeatureValue<T>(feature, state.plan);
  }
}

// Provider for subscription stream
@riverpod
Stream<UserSubscription> subscriptionStream(SubscriptionStreamRef ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.subscriptionStream;
}

// Provider for available products
@riverpod
Stream<List<ProductDetails>> productsStream(ProductsStreamRef ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.productsStream;
}

// Provider for purchase updates
@riverpod
Stream<List<PurchaseDetails>> purchaseUpdatesStream(
  PurchaseUpdatesStreamRef ref,
) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.purchaseUpdatedStream;
}

// Provider for subscription errors
@riverpod
Stream<String> subscriptionErrorsStream(SubscriptionErrorsStreamRef ref) {
  final service = ref.watch(subscriptionServiceProvider);
  return service.errorStream;
}

// Provider to check if features are locked
@riverpod
bool isFeatureLocked(IsFeatureLockedRef ref, SubscriptionFeature feature) {
  final subscriptionState = ref.watch(subscriptionStateProvider);

  switch (feature) {
    case SubscriptionFeature.advancedTools:
    case SubscriptionFeature.cloudBackup:
    case SubscriptionFeature.noWatermark:
    case SubscriptionFeature.prioritySupport:
      return !ref
          .read(subscriptionStateProvider.notifier)
          .hasFeatureAccess(feature);
    case SubscriptionFeature.maxProjects:
    case SubscriptionFeature.maxCanvasSize:
    case SubscriptionFeature.exportFormats:
      return false; // These features are never fully locked, just limited
  }
}

// Provider that generates offers based on available products
@riverpod
List<SubscriptionOffer> subscriptionOffers(SubscriptionOffersRef ref) {
  final service = ref.watch(subscriptionServiceProvider);
  final products = service.products;

  // Add offers from available products

  // Default offers with placeholder prices
  final List<SubscriptionOffer> offers = [
    const SubscriptionOffer(
      plan: SubscriptionPlan.free,
      title: 'Free',
      description: 'Basic pixel art creation',
      price: 'Free',
      period: 'Forever',
      features: [
        '3 projects',
        'Basic tools',
        'Canvas up to 64x64 pixels',
        'PNG & JPEG export'
      ],
    ),
  ];

  for (final product in products) {
    if (product.id == SubscriptionProductIds.proMonthly) {
      offers.add(SubscriptionOffer(
        plan: SubscriptionPlan.proMonthly,
        title: 'Pro Monthly',
        description: 'Full pixel art creation suite',
        price: product.price,
        period: 'per month',
        features: const [
          'Unlimited projects',
          'Advanced tools & effects',
          'Canvas up to 512x512 pixels',
          'Export to PNG, JPEG, SVG, GIF',
          'Cloud backup (coming soon)',
        ],
      ));
    } else if (product.id == SubscriptionProductIds.proYearly) {
      // Calculate savings compared to monthly plan
      final monthlyProduct = products.firstWhereOrNull(
        (p) => p.id == SubscriptionProductIds.proMonthly,
      );

      String saveText = '';
      if (monthlyProduct != null) {
        try {
          // Extract price values (this is a simplification)
          final monthlyPrice = double.parse(monthlyProduct.rawPrice.toString());
          final yearlyPrice = double.parse(product.rawPrice.toString());

          // Calculate yearly cost of monthly plan
          final yearlyViaMonthly = monthlyPrice * 12;
          final savings = yearlyViaMonthly - yearlyPrice;
          final savingsPercent = (savings / yearlyViaMonthly * 100).round();

          if (savingsPercent > 0) {
            saveText = 'Save ${savingsPercent}%';
          }
        } catch (e) {
          // Ignore price calculation errors
        }
      }

      offers.add(SubscriptionOffer(
        plan: SubscriptionPlan.proYearly,
        title: 'Pro Yearly',
        description: 'Best value for pixel artists',
        price: product.price,
        period: 'per year',
        saveText: saveText,
        isMostPopular: true,
        features: const [
          'Unlimited projects',
          'Advanced tools & effects',
          'Canvas up to 1024x1024 pixels',
          'Export to all formats including video',
          'Cloud backup (coming soon)',
          'Priority support',
        ],
      ));
    }
  }
  return offers;
}
