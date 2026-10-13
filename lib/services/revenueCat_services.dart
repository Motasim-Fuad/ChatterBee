import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String _entitlementId = 'ChaterBee_Pro';

  RevenueCatService._();
  static final RevenueCatService instance = RevenueCatService._();

  bool _configured = false;
  bool get isConfigured => _configured;

  Future<void> init() async {
    final androidKey = dotenv.env['RC_ANDROID_PUBLIC_KEY'] ?? '';
    final iosKey = dotenv.env['RC_IOS_PUBLIC_KEY'] ?? '';
    final apiKey = Platform.isAndroid ? androidKey : iosKey;

    if (apiKey.isEmpty) {
      debugPrint('[RC] API key is empty in .env. Purchases will stay off.');
      return;
    }
    await Purchases.setLogLevel(
      kDebugMode ? LogLevel.debug : LogLevel.error,
    );

    await Purchases.configure(PurchasesConfiguration(apiKey));
    _configured = true;
  }

  Future<List<Package>> getOfferings() async {
    if (!_configured) return [];
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.current?.availablePackages ?? [];
    } catch (e) {
      debugPrint('[RC] getOfferings error: $e');
      return [];
    }
  }

  
  Future<bool> purchase(Package package) async {
    if (!_configured) return false;
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

  
  Future<bool> restorePurchases() async {
    if (!_configured) return false;
    try {
      final info = await Purchases.restorePurchases();
      return _isPro(info);
    } catch (e) {
      debugPrint('[RC] Restore error: $e');
      return false;
    }
  }

  
  Future<bool> isProUser() async {
    if (!_configured) return false;
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
