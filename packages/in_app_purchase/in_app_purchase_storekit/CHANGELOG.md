## 0.3.13+1

* Handle translation of errors nested in dictionaries.

## 0.3.13

* Added new native tests for more complete test coverage.

## 0.3.12+1

* Fixes type of error code returned from native code in SKReceiptManager.retrieveReceiptData.

## 0.3.12

* Converts `refreshReceipt()`, `startObservingPaymentQueue()`, `stopObservingPaymentQueue()`, 
`registerPaymentQueueDelegate()`, `removePaymentQueueDelegate()`, `showPriceConsentIfNeeded()` to pigeon.

## 0.3.11

* Fixes SKError.userInfo not being nullable.

## 0.3.10

* Converts `startProductRequest()`, `finishTransaction()`, `restoreTransactions()`, `presentCodeRedemptionSheet()` to pigeon.

## 0.3.9

* Converts `storefront()`, `transactions()`, `addPayment()`, `canMakePayment` to pigeon.
* Updates minimum iOS version to 12.0 and minimum Flutter version to 3.16.6.

## 0.3.8+1

* Adds privacy manifest.

## 0.3.8

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 0.3.7

* Adds `Future<SKStorefrontWrapper?> storefront()` in SKPaymentQueueWrapper class. 

## 0.3.6+7

* Updates example code for current versions of Flutter.

## 0.3.6+6

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.3.6+5

* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.

## 0.3.6+4

* Removes obsolete null checks on non-nullable values.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.

## 0.3.6+3

* Adds a null check, to prevent a new diagnostic.

## 0.3.6+2

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.

## 0.3.6+1

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.3.6

* Updates minimum Flutter version to 3.3 and iOS 11.

## 0.3.5+2

* Fixes a crash when `appStoreReceiptURL` is nil.

## 0.3.5+1

* Uses the new `sharedDarwinSource` flag when available.

## 0.3.5

* Updates minimum Flutter version to 3.0.
* Ignores a lint in the example app for backwards compatibility.

## 0.3.4+1

* Updates code for stricter lint checks.

## 0.3.4

* Adds macOS as a supported platform.

## 0.3.3

* Supports adding discount information to AppStorePurchaseParam.
* Fixes iOS Promotional Offers bug which prevents them from working.

## 0.3.2+2

* Updates imports for `prefer_relative_imports`.

## 0.3.2+1

* Updates minimum Flutter version to 2.10.
* Replaces deprecated ThemeData.primaryColor.

## 0.3.2

* Adds the `identifier` and `type` fields to the `SKProductDiscountWrapper` to reflect the changes in the [SKProductDiscount](https://developer.apple.com/documentation/storekit/skproductdiscount?language=objc) in iOS 12.2.

## 0.3.1+1

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.3.1

* Adds ability to purchase more than one of a product.

## 0.3.0+10

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.3.0+9

* Updates references to the obsolete master branch.

## 0.3.0+8

* Fixes a memory leak on iOS.

## 0.3.0+7

* Minor fixes for new analysis options.

## 0.3.0+6

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.3.0+5

* Migrates from `ui.hash*` to `Object.hash*`.

## 0.3.0+4

* Ensures that `NSError` instances with an unexpected value for the `userInfo` field don't crash the app, but send an explanatory message instead.

## 0.3.0+3

* Implements transaction caching for StoreKit ensuring transactions are delivered to the Flutter client.

## 0.3.0+2

* Internal code cleanup for stricter analysis options.

## 0.3.0+1

* Removes dependency on `meta`.

## 0.3.0

* **BREAKING CHANGE:** `InAppPurchaseStoreKitPlatform.restorePurchase()` emits an empty instance of `List<ProductDetails>` when there were no transactions to restore, indicating that the restore procedure has finished.

## 0.2.1

* Renames `in_app_purchase_ios` to `in_app_purchase_storekit` to facilitate
  future macOS support.
