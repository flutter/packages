---
name: in-app-purchase-platform-interface-setup-and-usage
description: Implement or extend the common platform interface for the Flutter in_app_purchase plugin across platform-specific packages.
---

# Setting Up and Using in_app_purchase_platform_interface

`in_app_purchase_platform_interface` defines the common platform interface for the [`in_app_purchase`](https://pub.dev/packages/in_app_purchase) plugin. It ensures that all platform implementations (such as Android and StoreKit) expose a consistent API and shared data models (`ProductDetails`, `PurchaseDetails`, `PurchaseParam`).

## 1. Installation and Setup

Platform implementation packages or tests that mock the platform layer should add `in_app_purchase_platform_interface` to `pubspec.yaml`:

```yaml
dependencies:
  in_app_purchase_platform_interface: ^1.4.1
```

## 2. Platform-Specific Configuration

This package contains only Dart interfaces and data models and requires no native Android, iOS, or macOS configuration.

When modifying or extending this interface, strongly prefer non-breaking changes (such as adding methods with default implementations) over breaking changes.

## 3. Usage and API Examples

### Implementing a Custom Platform Interface
To create a new platform implementation of `in_app_purchase`, extend `InAppPurchasePlatform` and register your class via `InAppPurchasePlatform.setInstance`.

```dart
import 'dart:async';
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

class CustomInAppPurchasePlatform extends InAppPurchasePlatform {
  final StreamController<List<PurchaseDetails>> _purchaseUpdatedController =
      StreamController<List<PurchaseDetails>>.broadcast();

  static void registerWith() {
    InAppPurchasePlatform.setInstance(CustomInAppPurchasePlatform());
  }

  @override
  Stream<List<PurchaseDetails>> get purchaseStream =>
      _purchaseUpdatedController.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
      Set<String> identifiers) async {
    return ProductDetailsResponse(
      productDetails: <ProductDetails>[],
      notFoundIDs: identifiers.toList(),
    );
  }

  @override
  Future<bool> buyNonConsumable({required PurchaseParam purchaseParam}) async {
    return true;
  }

  @override
  Future<bool> buyConsumable({
    required PurchaseParam purchaseParam,
    bool autoConsume = true,
  }) async {
    return true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {}

  @override
  Future<void> restorePurchases({String? applicationUserName}) async {}
}
```

### Implementing Platform-Specific Additions
To expose platform-specific functionality not covered by `InAppPurchasePlatform`, extend `InAppPurchasePlatformAddition` and set `InAppPurchasePlatformAddition.instance`.

```dart
import 'package:in_app_purchase_platform_interface/in_app_purchase_platform_interface.dart';

class CustomPlatformAddition extends InAppPurchasePlatformAddition {
  Future<void> presentCustomStoreSheet() async {
    // Custom storefront logic
  }
}

void registerCustomAddition() {
  InAppPurchasePlatformAddition.instance = CustomPlatformAddition();
}
```
