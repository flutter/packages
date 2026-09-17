---
name: in-app-purchase-setup-and-usage
description: Set up and use the in_app_purchase plugin to handle consumables, non-consumables, and subscriptions on Android (Google Play) and iOS/macOS (App Store).
---

# Setting Up and Using in_app_purchase

`in_app_purchase` provides a storefront-independent API for making in-app purchases in Flutter apps through the App Store (iOS and macOS) and Google Play (Android).

## 1. Installation and Setup

Add `in_app_purchase` to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase: ^3.3.0
```

If you need access to platform-specific APIs (such as subscription replacement modes on Android or StoreKit 2 parameters on Apple platforms), also depend on the endorsed platform implementation packages directly:

```yaml
dependencies:
  in_app_purchase: ^3.3.0
  in_app_purchase_android: ^0.5.3
  in_app_purchase_storekit: ^0.4.13
```

## 2. Platform-Specific Configuration

### Android (Google Play)
- **SDK Requirements**: Android SDK 24 or higher.
- **Billing Library**: Do not manually add `com.android.billingclient:billing` to your app's `android/app/build.gradle`, as the plugin manages the billing client version and manual entries can cause version conflicts.
- **Google Play Console**: Upload a signed build to an internal test track and configure your in-app products and subscriptions in the Google Play Console before testing.

### iOS and macOS (App Store)
- **Minimum Versions**: iOS 13.0+ / macOS 10.15+.
- **Xcode Capabilities**: Enable the **In-App Purchase** capability in Xcode under **Signing & Capabilities**.
- **StoreKit Version**: On iOS and macOS, the plugin uses StoreKit 2 by default. If you need to fall back to StoreKit 1, call `InAppPurchaseStoreKitPlatform.enableStoreKit1()` before registering the platform.
- **App Store Connect**: Configure your products in App Store Connect and set up a Sandbox test account or StoreKit configuration file in Xcode for local testing.

## 3. Usage and API Examples

### Listening to Purchase Updates
Always subscribe to `InAppPurchase.instance.purchaseStream` as early as possible (such as in `initState`) to receive purchase updates from the underlying store, including pending or unfinished transactions from previous sessions. Always call `completePurchase` after verifying and delivering a purchase.

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = <ProductDetails>[];

  @override
  void initState() {
    super.initState();
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (Object error) {
        // Handle stream errors
      },
    );
    _initializeStore();
  }

  Future<void> _initializeStore() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      return;
    }

    const Set<String> productIds = <String>{'consumable_coin', 'premium_upgrade'};
    final ProductDetailsResponse response =
        await _iap.queryProductDetails(productIds);
    if (response.error == null) {
      setState(() {
        _products = response.productDetails;
      });
    }
  }

  Future<void> _onPurchaseUpdate(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show pending UI
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // Handle error: purchaseDetails.error
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            await _deliverProduct(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Verify purchase receipt with your backend server
    return true;
  }

  Future<void> _deliverProduct(PurchaseDetails purchaseDetails) async {
    // Grant entitlement or consumable items to the user
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (BuildContext context, int index) {
          final ProductDetails product = _products[index];
          return ListTile(
            title: Text(product.title),
            subtitle: Text(product.description),
            trailing: ElevatedButton(
              onPressed: () => _buyProduct(product),
              child: Text(product.price),
            ),
          );
        },
      ),
    );
  }

  void _buyProduct(ProductDetails productDetails) {
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    if (productDetails.id == 'consumable_coin') {
      _iap.buyConsumable(purchaseParam: purchaseParam);
    } else {
      _iap.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }
}
```

### Restoring Previous Purchases
To restore non-consumable purchases and active subscriptions, call `restorePurchases()`. Restored items are emitted on `purchaseStream` with `PurchaseStatus.restored`.

```dart
await InAppPurchase.instance.restorePurchases();
```
