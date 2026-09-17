---
name: in-app-purchase-storekit
description: Set up and use in_app_purchase_storekit for Apple App Store features including StoreKit 2 parameters, offer code redemption, and payment queue delegates on iOS and macOS.
---

# Setting Up and Using in_app_purchase_storekit

`in_app_purchase_storekit` is the iOS and macOS implementation of the Flutter [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) plugin using Apple's StoreKit framework (supporting StoreKit 2 by default and StoreKit 1 fallback).

## 1. Installation and Setup

Because this package is endorsed, adding `in_app_purchase` to your `pubspec.yaml` automatically includes it. However, if you import `in_app_purchase_storekit` directly to use Apple-specific APIs (such as `Sk2PurchaseParam`, `InAppPurchaseStoreKitPlatformAddition`, or payment queue delegates), add it to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase: ^3.3.0
  in_app_purchase_storekit: ^0.4.13
```

## 2. Platform-Specific Configuration

- **Minimum OS Versions**: iOS 13.0+ and macOS 10.15+.
- **Xcode Capability**: Open your Xcode workspace (`ios/Runner.xcworkspace` or `macos/Runner.xcworkspace`) and add the **In-App Purchase** capability under **Signing & Capabilities**.
- **StoreKit 2 vs. StoreKit 1**: StoreKit 2 is enabled by default. If your app relies on legacy StoreKit 1 behavior, call `InAppPurchaseStoreKitPlatform.enableStoreKit1()` before using `InAppPurchase.instance`.

## 3. Usage and API Examples

### Purchasing with StoreKit 2 Specific Parameters
When StoreKit 2 is enabled, use `Sk2PurchaseParam` to pass win-back offer IDs or promotional offer signatures:

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

Future<void> buyWithWinBackOffer(ProductDetails productDetails) async {
  final Sk2PurchaseParam purchaseParam = Sk2PurchaseParam(
    productDetails: productDetails,
    winBackOfferId: 'win_back_offer_2026',
  );

  await InAppPurchase.instance.buyNonConsumable(
    purchaseParam: purchaseParam,
  );
}
```

### Presenting the Offer Code Redemption Sheet (iOS 14+)
Use `InAppPurchaseStoreKitPlatformAddition` to display the native App Store sheet for redeeming subscription offer codes:

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';

Future<void> presentRedemptionSheet() async {
  final InAppPurchaseStoreKitPlatformAddition iosAddition = InAppPurchase
      .instance
      .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
  await iosAddition.presentCodeRedemptionSheet();
}
```

### Handling Subscription Price Consent Dialogs (StoreKit 1)
Register an `SKPaymentQueueDelegateWrapper` via `InAppPurchaseStoreKitPlatformAddition` to intercept StoreKit price consent prompts and control when they are shown:

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class CustomPaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    // Return false to defer showing the price consent dialog until later
    return false;
  }
}

Future<void> registerDelegateAndShowConsentLater() async {
  final InAppPurchaseStoreKitPlatformAddition iosAddition = InAppPurchase
      .instance
      .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

  await iosAddition.setDelegate(CustomPaymentQueueDelegate());

  // Later, when ready to prompt the user:
  await iosAddition.showPriceConsentIfNeeded();
}
```
