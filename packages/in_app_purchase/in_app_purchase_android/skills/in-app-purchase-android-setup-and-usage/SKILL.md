---
name: in-app-purchase-android-setup-and-usage
description: Set up and use in_app_purchase_android for Google Play Billing features including subscription upgrades/downgrades, replacement modes, and alternative billing.
---

# Setting Up and Using in_app_purchase_android

`in_app_purchase_android` is the Android implementation of the Flutter [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) plugin using Google Play BillingClient APIs.

## 1. Installation and Setup

Because this package is endorsed, adding `in_app_purchase` to your `pubspec.yaml` automatically includes it. However, if you import `in_app_purchase_android` directly to access Google Play-specific APIs (such as `GooglePlayPurchaseParam`, `GooglePlayProductDetails`, or alternative billing), add it to your `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase: ^3.3.0
  in_app_purchase_android: ^0.5.3
```

## 2. Platform-Specific Configuration

- **Android SDK Requirements**: Minimum Android SDK 24.
- **Gradle Configuration**: Do not manually add `com.android.billingclient:billing` to `android/app/build.gradle`. The plugin bundles its own version of the Play Billing library, and overriding it can lead to conflicts.
- **Alternative / User Choice Billing**: To use Alternative Billing Only or User Choice Billing, configure your app in the Google Play Console and ensure your account is approved for alternative billing programs.

## 3. Usage and API Examples

### Upgrading or Downgrading Subscriptions on Google Play
When migrating a user between subscription plans on Android, construct a `GooglePlayPurchaseParam` with a `ChangeSubscriptionParam` specifying the old purchase details and a `ReplacementMode`.

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

Future<void> changeSubscription({
  required ProductDetails newProductDetails,
  required PurchaseDetails oldPurchaseDetails,
}) async {
  final PurchaseParam purchaseParam = GooglePlayPurchaseParam(
    productDetails: newProductDetails,
    changeSubscriptionParam: ChangeSubscriptionParam(
      oldPurchaseDetails: oldPurchaseDetails as GooglePlayPurchaseDetails,
      replacementMode: ReplacementMode.withTimeProration,
    ),
  );

  await InAppPurchase.instance.buyNonConsumable(
    purchaseParam: purchaseParam,
  );
}
```

### Accessing Android-Specific Product and Purchase Details
Cast `ProductDetails` to `GooglePlayProductDetails` or `PurchaseDetails` to `GooglePlayPurchaseDetails` to inspect underlying Google Play Billing fields such as `originalJson`, `purchaseToken`, or subscription offer details.

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

void inspectAndroidPurchase(PurchaseDetails purchaseDetails) {
  if (purchaseDetails is GooglePlayPurchaseDetails) {
    final String originalJson =
        purchaseDetails.billingClientPurchase.originalJson;
    final String purchaseToken =
        purchaseDetails.billingClientPurchase.purchaseToken;
    // Send purchaseToken and originalJson to your backend for verification
  }
}
```

### Using Google Play Platform Additions (Alternative Billing)
Use `InAppPurchaseAndroidPlatformAddition` to access Google Play-specific flows such as checking alternative billing availability and displaying the information dialog.

```dart
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

Future<void> setupAlternativeBilling() async {
  final InAppPurchaseAndroidPlatformAddition androidAddition = InAppPurchase
      .instance
      .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();

  final BillingResultWrapper availabilityResult =
      await androidAddition.isAlternativeBillingOnlyAvailable();
  if (availabilityResult.responseCode == BillingResponse.ok) {
    await androidAddition.showAlternativeBillingOnlyInformationDialog();
  }
}
```
