import 'dart:async';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/subscription_model.dart';

class SubscriptionService {
  // Singleton instance
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // In-App Purchase plugin
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Stream controllers
  final _subscriptionController = StreamController<UserSubscription>.broadcast();
  final _productsController = StreamController<List<ProductDetails>>.broadcast();
  final _purchaseUpdatedController = StreamController<List<PurchaseDetails>>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Stream subscriptions
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  Timer? _temporaryAccessTimer;

  // State
  bool _isInitialized = false;
  UserSubscription _currentSubscription = const UserSubscription.free();
  List<ProductDetails> _products = [];

  // Streams
  Stream<UserSubscription> get subscriptionStream => _subscriptionController.stream;
  Stream<List<ProductDetails>> get productsStream => _productsController.stream;
  Stream<List<PurchaseDetails>> get purchaseUpdatedStream => _purchaseUpdatedController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Getters
  bool get isInitialized => _isInitialized;
  UserSubscription get currentSubscription => _currentSubscription;
  List<ProductDetails> get products => _products;
  bool get isProUser => _currentSubscription.isPro;

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load saved subscription data
      await _loadSubscriptionData();

      // Start timer to check temporary access expiry
      _startTemporaryAccessTimer();

      // Initialize the IAP plugin
      final isAvailable = await _inAppPurchase.isAvailable();
      if (!isAvailable) {
        _errorController.add('In-app purchases are not available on this device.');
        return;
      }

      // Set up purchase listener
      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: (error) {
          _errorController.add('Purchase error: $error');
        },
      );

      // Fetch available products
      await loadProducts();

      // Verify existing purchases
      await _verifyPreviousPurchases();

      _isInitialized = true;
    } catch (e) {
      _errorController.add('Initialization error: $e');
    }
  }

  // Load products from the store
  Future<void> loadProducts() async {
    try {
      final productIds = <String>{
        SubscriptionProductIds.proPurchase,
      };

      final response = await _inAppPurchase.queryProductDetails(productIds);
      if (response.error != null) {
        _errorController.add('Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      _productsController.add(_products);
    } catch (e) {
      _errorController.add('Error loading products: $e');
    }
  }

  // Purchase the pro version
  Future<void> purchasePro(ProductDetails product) async {
    try {
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: null,
      );

      // Start the purchase flow
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      // Set status to pending
      _updateSubscription(
        _currentSubscription.copyWith(
          status: AppPurchaseStatus.pendingPurchase,
        ),
      );
    } catch (e) {
      _errorController.add('Purchase error: $e');
    }
  }

  // Grant temporary pro access from watching ads
  void grantTemporaryProAccess({Duration duration = const Duration(minutes: 45)}) {
    final temporaryAccess = TemporaryProAccess(
      startTime: DateTime.now(),
      duration: duration,
    );

    _updateSubscription(
      _currentSubscription.copyWith(
        plan: SubscriptionPlan.proPurchase,
        status: AppPurchaseStatus.purchased,
        temporaryProAccess: temporaryAccess,
      ),
    );

    // Restart the timer to check for expiry
    _startTemporaryAccessTimer();
  }

  // Start timer to monitor temporary access expiry
  void _startTemporaryAccessTimer() {
    _temporaryAccessTimer?.cancel();

    if (_currentSubscription.hasTemporaryPro) {
      final remainingTime = _currentSubscription.temporaryProAccess!.remainingTime;

      if (remainingTime > Duration.zero) {
        _temporaryAccessTimer = Timer(remainingTime, () {
          // Clear temporary access when it expires
          _updateSubscription(_currentSubscription.clearTemporaryAccess());
        });
      } else {
        // Access has already expired
        _updateSubscription(_currentSubscription.clearTemporaryAccess());
      }
    }
  }

  // Restore purchases
  Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _errorController.add('Restore error: $e');
    }
  }

  // Process purchase updates from the store
  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    _purchaseUpdatedController.add(purchaseDetailsList);

    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
        _updateSubscription(
          _currentSubscription.copyWith(
            status: AppPurchaseStatus.pendingPurchase,
          ),
        );
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _errorController.add('Purchase error: ${purchaseDetails.error?.message}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          // Grant entitlement to user
          _handleSuccessfulPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          // Restore previous status
          _updateSubscription(
            _currentSubscription.copyWith(
              status: _currentSubscription.plan == SubscriptionPlan.proPurchase
                  ? AppPurchaseStatus.purchased
                  : AppPurchaseStatus.notPurchased,
            ),
          );
        }

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Process a successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    // Verify the purchase on server (simplified for example)
    final bool isValidPurchase = _verifyPurchase(purchaseDetails);

    if (isValidPurchase) {
      final plan = SubscriptionProductIds.productIdToPlan(purchaseDetails.productID);

      final subscription = UserSubscription(
        plan: plan,
        status: AppPurchaseStatus.purchased,
        purchaseId: purchaseDetails.purchaseID,
        purchaseDate: DateTime.now(),
        temporaryProAccess: _currentSubscription.temporaryProAccess, // Preserve any existing temporary access
      );

      _updateSubscription(subscription);
    } else {
      _errorController.add('Invalid purchase');
    }
  }

  // Simple verification (replace with real verification logic)
  bool _verifyPurchase(PurchaseDetails purchaseDetails) {
    // In a real app, verify with server and store's API
    return purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored;
  }

  // Verify previous purchases on startup
  Future<void> _verifyPreviousPurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      _errorController.add('Error verifying purchases: $e');
    }
  }

  // Update subscription and save data
  void _updateSubscription(UserSubscription subscription) {
    _currentSubscription = subscription;
    _subscriptionController.add(_currentSubscription);
    _saveSubscriptionData();
  }

  // Load subscription data from storage
  Future<void> _loadSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('user_subscription');

      if (jsonData != null) {
        final Map<String, dynamic> data = jsonDecode(jsonData);

        debugPrint('Loaded subscription data: $data');

        TemporaryProAccess? temporaryAccess;
        if (data['temporaryProAccess'] != null) {
          temporaryAccess = TemporaryProAccess.fromJson(data['temporaryProAccess'] as Map<String, dynamic>);

          // Check if temporary access has expired
          if (!temporaryAccess.isActive) {
            temporaryAccess = null;
          }
        }

        _currentSubscription = UserSubscription(
          plan: SubscriptionPlan.values.byName(data['plan']),
          status: AppPurchaseStatus.values.byName(data['status']),
          purchaseId: data['purchaseId'],
          purchaseDate: data['purchaseDate'] != null ? DateTime.parse(data['purchaseDate']) : null,
          temporaryProAccess: temporaryAccess,
        );

        _subscriptionController.add(_currentSubscription);
      }
    } catch (e) {
      _errorController.add('Error loading subscription data: $e');
    }
  }

  // Save subscription data to storage
  Future<void> _saveSubscriptionData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final data = {
        'plan': _currentSubscription.plan.name,
        'status': _currentSubscription.status.name,
        'purchaseId': _currentSubscription.purchaseId,
        'purchaseDate': _currentSubscription.purchaseDate?.toIso8601String(),
        'temporaryProAccess': _currentSubscription.temporaryProAccess?.toJson(),
      };

      await prefs.setString('user_subscription', jsonEncode(data));
    } catch (e) {
      _errorController.add('Error saving subscription data: $e');
    }
  }

  // Clean up resources
  void dispose() {
    _purchaseSubscription?.cancel();
    _temporaryAccessTimer?.cancel();
    _subscriptionController.close();
    _productsController.close();
    _purchaseUpdatedController.close();
    _errorController.close();
  }

  // Get the details of the pro purchase
  ProductDetails? getProProductDetails() {
    return _products.firstWhereOrNull(
      (product) => product.id == SubscriptionProductIds.proPurchase,
    );
  }
}
