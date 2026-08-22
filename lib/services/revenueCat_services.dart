import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _entitlementId = 'ChaterBee_Pro';

  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  // Init (call once in main.dart)
  Future<void> init() async {
    final androidKey = const String.fromEnvironment('RC_ANDROID_PUBLIC_KEY');
    final iosKey = const String.fromEnvironment('RC_IOS_PUBLIC_KEY');

    final apiKey = Platform.isAndroid ? androidKey : iosKey;

    if (apiKey.isEmpty) {
      debugPrint('[RC] ❌ API key is empty! Use --dart-define to pass it.');
      return;
    }
    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.debug : LogLevel.error,
    );

    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  // Get available packages
  Future<List<Package>> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('[RC] getOfferings error: $e');
      return [];
    }
  }

  // Purchase
  Future<bool> purchase(Package package) async {
    try {
      final result = await Purchases.purchasePackage(package);
      return _isPro(result.customerInfo);
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) return false;
      debugPrint('[RC] Purchase error: $e');
      return false;
    } catch (e) {
      debugPrint('[RC] Unexpected: $e');
      return false;
    }
  }

  // Restore
  Future<bool> restorePurchases() async {
    try {
      final info = await Purchases.restorePurchases();
      return _isPro(info);
    } catch (e) {
      debugPrint('[RC] Restore error: $e');
      return false;
    }
  }

  // Check pro status
  Future<bool> isProUser() async {
    try {
      final info = await Purchases.getCustomerInfo();
      return _isPro(info);
    } catch (e) {
      debugPrint('[RC] isProUser error: $e');
      return false;
    }
  }

  bool _isPro(CustomerInfo info) =>
      info.entitlements.active.containsKey(_entitlementId);
}
