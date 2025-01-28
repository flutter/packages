## 0.4.0

* Updates Google Play Billing Library from 6.2.0 to 7.1.1.
* **BREAKING CHANGES**:
  * Removes the deprecated `ProrationMode` enum. `ReplacementMode` should be used instead.
  * Removes the deprecated `BillingClientWrapper.enablePendingPurchases` method.
  * Removes JSON serialization from Dart wrapper classes.
  * Removes `subscriptionsOnVR` and `inAppItemsOnVR` from `BillingClientFeature`.
* Adds `installmentPlanDetails` to `SubscriptionOfferDetailsWrapper`.
* Adds APIs to support pending transactions for subscription prepaid plans (`PendingPurchasesParams`).

## 0.3.6+13

* Updates androidx.annotation:annotation to 1.9.1.

## 0.3.6+12

* Updates README to remove contributor-focused documentation.

## 0.3.6+11

* Bumps androidx.annotation:annotation from 1.8.2 to 1.9.0.

## 0.3.6+10

* Updates Pigeon for non-nullable collection type support.

## 0.3.6+9

* Updates Java compatibility version to 11.

## 0.3.6+8

* Removes dependency on org.jetbrains.kotlin:kotlin-bom.
* Updates minimum supported SDK version to Flutter 3.24/Dart 3.5.

## 0.3.6+7

* Sets `android.buildFeatures.buildConfig` to true for compatibility with AGP 8.0+.

## 0.3.6+6

* Bumps androidx.annotation:annotation from 1.8.1 to 1.8.2.

## 0.3.6+5

* Bumps com.android.billingclient:billing from 6.1.0 to 6.2.0.

## 0.3.6+4

* Bumps androidx.annotation:annotation from 1.8.0 to 1.8.1.

## 0.3.6+3

* Updates lint checks to ignore NewerVersionAvailable.

## 0.3.6+2

* Updates Android Gradle Plugin to 8.5.1.

## 0.3.6+1

* Updates minimum supported SDK version to Flutter 3.22/Dart 3.4.
* Removes support for apps using the v1 Android embedding.

## 0.3.6

* Introduces new `ReplacementMode` for Android's billing client as `ProrationMode` is being deprecated.

## 0.3.5+2

* Bumps androidx.annotation:annotation from 1.7.1 to 1.8.0.
* Updates minimum supported SDK version to Flutter 3.16/Dart 3.2.

## 0.3.5+1

* Updates example to use `countryCode` instead of deprecated `getCountryCode`.

## 0.3.5

* Replaces `getCountryCode` with `countryCode`.

## 0.3.4+1

* Adds documentation for UserChoice and Alternative Billing.

## 0.3.4

* Adds `countryCode` API.

## 0.3.3+1

* Moves alternative billing listener creation to BillingClientFactoryImpl.

## 0.3.3

* Converts data objects in internal platform communication to Pigeon.
* Deprecates JSON serialization and deserialization for Billing Client wrapper
  objects.

## 0.3.2+1

* Converts internal platform communication to Pigeon.

## 0.3.2

* Adds UserChoiceBilling APIs to platform addition.
* Updates minimum supported SDK version to Flutter 3.13/Dart 3.1.

## 0.3.1

* Adds alternative-billing-only APIs to InAppPurchaseAndroidPlatformAddition.

## 0.3.0+18

* Adds new getCountryCode() method to InAppPurchaseAndroidPlatformAddition to get a customer's country code.
* Updates compileSdk version to 34.

## 0.3.0+17

* Bumps androidx.annotation:annotation from 1.7.0 to 1.7.1.

## 0.3.0+16

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 0.3.0+15

* Adds missing network error response code to BillingResponse enum.

## 0.3.0+14

* Updates annotations lib to 1.7.0.

## 0.3.0+13

* Updates example code for current versions of Flutter.

## 0.3.0+12

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 0.3.0+11

* Migrates `styleFrom` usage in examples off of deprecated `primary` and `onPrimary` parameters.

## 0.3.0+10

* Bumps com.android.billingclient:billing from 6.0.0 to 6.0.1.

## 0.3.0+9

* Bumps com.android.billingclient:billing from 5.2.0 to 6.0.0.

## 0.3.0+8

* Adds a [guide for migrating](migration_guide.md) to [0.3.0](#0.3.0).

## 0.3.0+7

* Bumps org.mockito:mockito-core from 4.7.0 to 5.3.1.

## 0.3.0+6

* Bumps org.jetbrains.kotlin:kotlin-bom from 1.8.21 to 1.8.22.

## 0.3.0+5

* Bumps org.jetbrains.kotlin:kotlin-bom from 1.8.0 to 1.8.21.

## 0.3.0+4

* Fixes unawaited_futures violations.

## 0.3.0+3

* Fixes Java lint issues.

## 0.3.0+2

* Removes obsolete null checks on non-nullable values.

## 0.3.0+1

* Fixes misaligned method signature strings.

## 0.3.0

* **BREAKING CHANGE**: Removes `launchPriceChangeConfirmationFlow` from `InAppPurchaseAndroidPlatform`. Price changes are now [handled by Google Play](https://developer.android.com/google/play/billing/subscriptions#price-change).
* Returns both base plans and offers when `queryProductDetailsAsync` is called.

## 0.2.5+5

* Updates gradle, AGP and fixes some lint errors.

## 0.2.5+4

* Fixes compatibility with AGP versions older than 4.2.

## 0.2.5+3

* Updates com.android.billingclient:billing from 5.1.0 to 5.2.0.

## 0.2.5+2

* Updates androidx.annotation:annotation from 1.5.0 to 1.6.0.

## 0.2.5+1

* Adds a namespace for compatibility with AGP 8.0.

## 0.2.5

* Fixes the management of `BillingClient` connection by handling `BillingResponse.serviceDisconnected`.
* Introduces `BillingClientManager`.
* Updates minimum Flutter version to 3.3.

## 0.2.4+3

* Clarifies explanation of endorsement in README.
* Aligns Dart and Flutter SDK constraints.
* Updates compileSdkVersion to 33.

## 0.2.4+2

* Updates links for the merge of flutter/plugins into flutter/packages.

## 0.2.4+1

* Updates Google Play Billing Library to 5.1.0.
* Updates androidx.annotation to 1.5.0.

## 0.2.4

* Updates minimum Flutter version to 3.0.
* Ignores a lint in the example app for backwards compatibility.

## 0.2.3+9

* Updates `androidx.test.espresso:espresso-core` to 3.5.1.

## 0.2.3+8

* Updates code for stricter lint checks.

## 0.2.3+7

* Updates code for new analysis options.

## 0.2.3+6

* Updates android gradle plugin to 7.3.1.

## 0.2.3+5

* Updates imports for `prefer_relative_imports`.

## 0.2.3+4

* Updates minimum Flutter version to 2.10.
* Adds IMMEDIATE_AND_CHARGE_FULL_PRICE to the `ProrationMode`.

## 0.2.3+3

* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 0.2.3+2

* Fixes incorrect json key in `queryPurchasesAsync` that fixes restore purchases functionality.

## 0.2.3+1

* Updates `json_serializable` to fix warnings in generated code.

## 0.2.3

* Upgrades Google Play Billing Library to 5.0
* Migrates APIs to support breaking changes in new Google Play Billing API
* `PurchaseWrapper` and `PurchaseHistoryRecordWrapper` now handles `skus` a list of sku strings. `sku` is deprecated.

## 0.2.2+8

* Ignores deprecation warnings for upcoming styleFrom button API changes.

## 0.2.2+7

* Updates references to the obsolete master branch.

## 0.2.2+6

* Enables mocking models by changing overridden operator == parameter type from `dynamic` to `Object`.

## 0.2.2+5

* Minor fixes for new analysis options.

## 0.2.2+4

* Removes unnecessary imports.
* Fixes library_private_types_in_public_api, sort_child_properties_last and use_key_in_widget_constructors
  lint warnings.

## 0.2.2+3

* Migrates from `ui.hash*` to `Object.hash*`.
* Updates minimum Flutter version to 2.5.0.

## 0.2.2+2

* Internal code cleanup for stricter analysis options.

## 0.2.2+1

* Removes the dependency on `meta`.

## 0.2.2

* Fixes the `purchaseStream` incorrectly reporting `PurchaseStatus.error` when user upgrades subscription by deferred proration mode.

## 0.2.1

* Deprecated the `InAppPurchaseAndroidPlatformAddition.enablePendingPurchases()` method and `InAppPurchaseAndroidPlatformAddition.enablePendingPurchase` property. Since Google Play no longer accepts App submissions that don't support pending purchases it is no longer necessary to acknowledge this through code.
* Updates example app Android compileSdkVersion to 31.

## 0.2.0

* BREAKING CHANGE : Refactor to handle new `PurchaseStatus` named `canceled`. This means developers
  can distinguish between an error and user cancellation.

## 0.1.6

* Require Dart SDK >= 2.14.
* Update `json_annotation` dependency to `^4.3.0`.

## 0.1.5+1

* Fix a broken link in the README.

## 0.1.5

* Introduced the `SkuDetailsWrapper.introductoryPriceAmountMicros` field of the correct type (`int`) and deprecated the `SkuDetailsWrapper.introductoryPriceMicros` field.
* Update dev_dependency `build_runner` to ^2.0.0 and `json_serializable` to ^5.0.2.

## 0.1.4+7

* Ensure that the `SkuDetailsWrapper.introductoryPriceMicros` is populated correctly.

## 0.1.4+6

* Ensure that purchases correctly indicate whether they are acknowledged or not. The `PurchaseDetails.pendingCompletePurchase` field now correctly indicates if the purchase still needs to be completed.

## 0.1.4+5

* Add `implements` to pubspec.
* Updated Android lint settings.

## 0.1.4+4

* Removed dependency on the `test` package.

## 0.1.4+3

* Updated installation instructions in README.

## 0.1.4+2

* Added price currency symbol to SkuDetailsWrapper.

## 0.1.4+1

* Fixed typos.

## 0.1.4

* Added support for launchPriceChangeConfirmationFlow in the BillingClientWrapper and in InAppPurchaseAndroidPlatformAddition.

## 0.1.3+1

* Add payment proxy.

## 0.1.3

* Added support for isFeatureSupported in the BillingClientWrapper and in InAppPurchaseAndroidPlatformAddition.

## 0.1.2

* Added support for the obfuscatedAccountId and obfuscatedProfileId in the PurchaseWrapper.

## 0.1.1

* Added support to request a list of active subscriptions and non-consumed one-time purchases on Android, through the `InAppPurchaseAndroidPlatformAddition.queryPastPurchases` method.

## 0.1.0+1

* Migrate maven repository from jcenter to mavenCentral.

## 0.1.0

* Initial open-source release.
