import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class ProStatusController extends GetxController {
  // Shared controller instance
  static ProStatusController get to => Get.find();

  static const String _entitlementId = 'ChaterBee_Pro';

  final isProUser    = false.obs;
  final isChecking   = true.obs;

  // On Init
  @override
  void onInit() {
    super.onInit();
    _initStatus();
    _listenToStream();
  }

  // Fetch current status once on app launch
  Future<void> _initStatus() async {
    isChecking.value = true;
    try {
      final info = await Purchases.getCustomerInfo();
      _updateStatus(info, source: 'INIT');
    } catch (e) {
      debugPrint('[PRO] Init check failed: $e');
    } finally {
      isChecking.value = false;
    }
  }

  // RevenueCat calls this listener when a subscription expires
  void _listenToStream() {
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    debugPrint('[PRO] Stream listener attached');
  }

  void _onCustomerInfoUpdated(CustomerInfo info) {
    _updateStatus(info, source: 'STREAM');
  }

  // Update Status
  void _updateStatus(CustomerInfo info, {required String source}) {
    final active = info.entitlements.active.containsKey(_entitlementId);
    isProUser.value = active;

    debugPrint('');
    debugPrint('┌────────────────────────────────────────┐');
    debugPrint('│  [PRO STATUS] source: $source');
    debugPrint('│  isProUser   → $active');
    debugPrint('│  Entitlement → $_entitlementId');
    if (info.entitlements.active.isNotEmpty) {
      info.entitlements.active.forEach((key, value) {
        debugPrint('│   $key');
        debugPrint('│     expires : ${value.expirationDate ?? 'lifetime'}');
        debugPrint('│     store   : ${value.store.name}');
      });
    } else {
      debugPrint('│    No active entitlements');
    }
    debugPrint('└────────────────────────────────────────┘');
    debugPrint('');
  }

  // Manual refresh (pull-to-refresh or debug)
  Future<void> refresh() => _initStatus();

  // With permanent: true this is rarely called; kept as a safety net
  @override
  void onClose() {
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
    super.onClose();
  }
}
