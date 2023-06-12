// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../billing_client_wrappers.dart';
import '../channel.dart';

part 'billing_client_wrapper.g.dart';

/// Method identifier for the OnPurchaseUpdated method channel method.
@visibleForTesting
const String kOnPurchasesUpdated =
    'PurchasesUpdatedListener#onPurchasesUpdated(BillingResult, List<Purchase>)';
const String _kOnBillingServiceDisconnected =
    'BillingClientStateListener#onBillingServiceDisconnected()';

/// Callback triggered by Play in response to purchase activity.
///
/// This callback is triggered in response to all purchase activity while an
/// instance of `BillingClient` is active. This includes purchases initiated by
/// the app ([BillingClient.launchBillingFlow]) as well as purchases made in
/// Play itself while this app is open.
///
/// This does not provide any hooks for purchases made in the past. See
/// [BillingClient.queryPurchases] and [BillingClient.queryPurchaseHistory].
///
/// All purchase information should also be verified manually, with your server
/// if at all possible. See ["Verify a
/// purchase"](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
///
/// Wraps a
/// [`PurchasesUpdatedListener`](https://developer.android.com/reference/com/android/billingclient/api/PurchasesUpdatedListener.html).
typedef PurchasesUpdatedListener = void Function(
    PurchasesResultWrapper purchasesResult);

/// This class can be used directly instead of [InAppPurchaseConnection] to call
/// Play-specific billing APIs.
///
/// Wraps a
/// [`com.android.billingclient.api.BillingClient`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient)
/// instance.
///
///
/// In general this API conforms to the Java
/// `com.android.billingclient.api.BillingClient` API as much as possible, with
/// some minor changes to account for language differences. Callbacks have been
/// converted to futures where appropriate.
///
/// Connection to [BillingClient] may be lost at any time (see
/// `onBillingServiceDisconnected` param of [startConnection] and
/// [BillingResponse.serviceDisconnected]).
/// Consider using [BillingClientManager] that handles these disconnections
/// transparently.
class BillingClient {
  /// Creates a billing client.
  BillingClient(PurchasesUpdatedListener onPurchasesUpdated) {
    channel.setMethodCallHandler(callHandler);
    _callbacks[kOnPurchasesUpdated] = <PurchasesUpdatedListener>[
      onPurchasesUpdated
    ];
  }

  // Occasionally methods in the native layer require a Dart callback to be
  // triggered in response to a Java callback. For example,
  // [startConnection] registers an [OnBillingServiceDisconnected] callback.
  // This list of names to callbacks is used to trigger Dart callbacks in
  // response to those Java callbacks. Dart sends the Java layer a handle to the
  // matching callback here to remember, and then once its twin is triggered it
  // sends the handle back over the platform channel. We then access that handle
  // in this array and call it in Dart code. See also [_callHandler].
  final Map<String, List<Function>> _callbacks = <String, List<Function>>{};

  /// Calls
  /// [`BillingClient#isReady()`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#isReady())
  /// to get the ready status of the BillingClient instance.
  Future<bool> isReady() async {
    final bool? ready =
        await channel.invokeMethod<bool>('BillingClient#isReady()');
    return ready ?? false;
  }

  /// Enable the [BillingClientWrapper] to handle pending purchases.
  ///
  /// **Deprecation warning:** it is no longer required to call
  /// [enablePendingPurchases] when initializing your application.
  @Deprecated(
      'The requirement to call `enablePendingPurchases()` has become obsolete '
      "since Google Play no longer accepts app submissions that don't support "
      'pending purchases.')
  void enablePendingPurchases() {
    // No-op, until it is time to completely remove this method from the API.
  }

  /// Calls
  /// [`BillingClient#startConnection(BillingClientStateListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#startconnection)
  /// to create and connect a `BillingClient` instance.
  ///
  /// [onBillingServiceConnected] has been converted from a callback parameter
  /// to the Future result returned by this function. This returns the
  /// `BillingClient.BillingResultWrapper` describing the connection result.
  ///
  /// This triggers the creation of a new `BillingClient` instance in Java if
  /// one doesn't already exist.
  Future<BillingResultWrapper> startConnection(
      {required OnBillingServiceDisconnected
          onBillingServiceDisconnected}) async {
    final List<Function> disconnectCallbacks =
        _callbacks[_kOnBillingServiceDisconnected] ??= <Function>[];
    disconnectCallbacks.add(onBillingServiceDisconnected);
    return BillingResultWrapper.fromJson((await channel
            .invokeMapMethod<String, dynamic>(
                'BillingClient#startConnection(BillingClientStateListener)',
                <String, dynamic>{
              'handle': disconnectCallbacks.length - 1,
            })) ??
        <String, dynamic>{});
  }

  /// Calls
  /// [`BillingClient#endConnection(BillingClientStateListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#endconnect
  /// to disconnect a `BillingClient` instance.
  ///
  /// Will trigger the [OnBillingServiceDisconnected] callback passed to [startConnection].
  ///
  /// This triggers the destruction of the `BillingClient` instance in Java.
  Future<void> endConnection() async {
    return channel.invokeMethod<void>('BillingClient#endConnection()');
  }

  /// Returns a list of [ProductDetailsResponseWrapper]s that have
  /// [ProductDetailsWrapper.productId] and [ProductDetailsWrapper.productType]
  /// in `productList`.
  ///
  /// Calls through to
  /// [`BillingClient#queryProductDetailsAsync(QueryProductDetailsParams, ProductDetailsResponseListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient#queryProductDetailsAsync(com.android.billingclient.api.QueryProductDetailsParams,%20com.android.billingclient.api.ProductDetailsResponseListener).
  /// Instead of taking a callback parameter, it returns a Future
  /// [ProductDetailsResponseWrapper]. It also takes the values of
  /// `ProductDetailsParams` as direct arguments instead of requiring it
  /// constructed and passed in as a class.
  Future<ProductDetailsResponseWrapper> queryProductDetails({
    required List<ProductWrapper> productList,
  }) async {
    final Map<String, dynamic> arguments = <String, dynamic>{
      'productList':
          productList.map((ProductWrapper product) => product.toJson()).toList()
    };
    return ProductDetailsResponseWrapper.fromJson(
        (await channel.invokeMapMethod<String, dynamic>(
              'BillingClient#queryProductDetailsAsync(QueryProductDetailsParams, ProductDetailsResponseListener)',
              arguments,
            )) ??
            <String, dynamic>{});
  }

  /// Attempt to launch the Play Billing Flow for a given [productDetails].
  ///
  /// The [productDetails] needs to have already been fetched in a [queryProductDetails]
  /// call. The [accountId] is an optional hashed string associated with the user
  /// that's unique to your app. It's used by Google to detect unusual behavior.
  /// Do not pass in a cleartext [accountId], and do not use this field to store any Personally Identifiable Information (PII)
  /// such as emails in cleartext. Attempting to store PII in this field will result in purchases being blocked.
  /// Google Play recommends that you use either encryption or a one-way hash to generate an obfuscated identifier to send to Google Play.
  ///
  /// Specifies an optional [obfuscatedProfileId] that is uniquely associated with the user's profile in your app.
  /// Some applications allow users to have multiple profiles within a single account. Use this method to send the user's profile identifier to Google.
  /// Setting this field requests the user's obfuscated account id.
  ///
  /// Calling this attemps to show the Google Play purchase UI. The user is free
  /// to complete the transaction there.
  ///
  /// This method returns a [BillingResultWrapper] representing the initial attempt
  /// to show the Google Play billing flow. Actual purchase updates are
  /// delivered via the [PurchasesUpdatedListener].
  ///
  /// This method calls through to
  /// [`BillingClient#launchBillingFlow`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient#launchbillingflow).
  /// It constructs a
  /// [`BillingFlowParams`](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams)
  /// instance by [setting the given productDetails](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.Builder#setProductDetailsParamsList(java.util.List%3Ccom.android.billingclient.api.BillingFlowParams.ProductDetailsParams%3E)),
  /// [the given accountId](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.Builder#setObfuscatedAccountId(java.lang.String))
  /// and the [obfuscatedProfileId] (https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.Builder#setobfuscatedprofileid).
  ///
  /// When this method is called to purchase a subscription through an offer, an
  /// [`offerToken` can be passed in](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProductDetailsParams.Builder#setOfferToken(java.lang.String)).
  ///
  /// When this method is called to purchase a subscription, an optional
  /// `oldProduct` can be passed in. This will tell Google Play that rather than
  /// purchasing a new subscription, the user needs to upgrade/downgrade the
  /// existing subscription.
  /// The [oldProduct](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.SubscriptionUpdateParams.Builder#setOldPurchaseToken(java.lang.String)) and [purchaseToken] are the product id and purchase token that the user is upgrading or downgrading from.
  /// [purchaseToken] must not be `null` if [oldProduct] is not `null`.
  /// The [prorationMode](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.SubscriptionUpdateParams.Builder#setReplaceProrationMode(int)) is the mode of proration during subscription upgrade/downgrade.
  /// This value will only be effective if the `oldProduct` is also set.
  Future<BillingResultWrapper> launchBillingFlow(
      {required String product,
      String? offerToken,
      String? accountId,
      String? obfuscatedProfileId,
      String? oldProduct,
      String? purchaseToken,
      ProrationMode? prorationMode}) async {
    assert((oldProduct == null) == (purchaseToken == null),
        'oldProduct and purchaseToken must both be set, or both be null.');
    final Map<String, dynamic> arguments = <String, dynamic>{
      'product': product,
      'offerToken': offerToken,
      'accountId': accountId,
      'obfuscatedProfileId': obfuscatedProfileId,
      'oldProduct': oldProduct,
      'purchaseToken': purchaseToken,
      'prorationMode': const ProrationModeConverter().toJson(prorationMode ??
          ProrationMode.unknownSubscriptionUpgradeDowngradePolicy)
    };
    return BillingResultWrapper.fromJson(
        (await channel.invokeMapMethod<String, dynamic>(
                'BillingClient#launchBillingFlow(Activity, BillingFlowParams)',
                arguments)) ??
            <String, dynamic>{});
  }

  /// Fetches recent purchases for the given [ProductType].
  ///
  /// Unlike [queryPurchaseHistory], This does not make a network request and
  /// does not return items that are no longer owned.
  ///
  /// All purchase information should also be verified manually, with your
  /// server if at all possible. See ["Verify a
  /// purchase"](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
  ///
  /// This wraps
  /// [`BillingClient#queryPurchasesAsync(QueryPurchaseParams, PurchaseResponseListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient#queryPurchasesAsync(com.android.billingclient.api.QueryPurchasesParams,%20com.android.billingclient.api.PurchasesResponseListener)).
  Future<PurchasesResultWrapper> queryPurchases(ProductType productType) async {
    return PurchasesResultWrapper.fromJson(
        (await channel.invokeMapMethod<String, dynamic>(
              'BillingClient#queryPurchasesAsync(QueryPurchaseParams, PurchaseResponseListener)',
              <String, dynamic>{
                'productType': const ProductTypeConverter().toJson(productType)
              },
            )) ??
            <String, dynamic>{});
  }

  /// Fetches purchase history for the given [ProductType].
  ///
  /// Unlike [queryPurchases], this makes a network request via Play and returns
  /// the most recent purchase for each [ProductDetailsWrapper] of the given
  /// [ProductType] even if the item is no longer owned.
  ///
  /// All purchase information should also be verified manually, with your
  /// server if at all possible. See ["Verify a
  /// purchase"](https://developer.android.com/google/play/billing/billing_library_overview#Verify).
  ///
  /// This wraps
  /// [`BillingClient#queryPurchaseHistoryAsync(QueryPurchaseHistoryParams, PurchaseHistoryResponseListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient#queryPurchaseHistoryAsync(com.android.billingclient.api.QueryPurchaseHistoryParams,%20com.android.billingclient.api.PurchaseHistoryResponseListener)).
  Future<PurchasesHistoryResult> queryPurchaseHistory(
      ProductType productType) async {
    return PurchasesHistoryResult.fromJson((await channel.invokeMapMethod<
                String, dynamic>(
            'BillingClient#queryPurchaseHistoryAsync(QueryPurchaseHistoryParams, PurchaseHistoryResponseListener)',
            <String, dynamic>{
              'productType': const ProductTypeConverter().toJson(productType)
            })) ??
        <String, dynamic>{});
  }

  /// Consumes a given in-app product.
  ///
  /// Consuming can only be done on an item that's owned, and as a result of consumption, the user will no longer own it.
  /// Consumption is done asynchronously. The method returns a Future containing a [BillingResultWrapper].
  ///
  /// This wraps
  /// [`BillingClient#consumeAsync(ConsumeParams, ConsumeResponseListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#consumeAsync(java.lang.String,%20com.android.billingclient.api.ConsumeResponseListener))
  Future<BillingResultWrapper> consumeAsync(String purchaseToken) async {
    return BillingResultWrapper.fromJson((await channel.invokeMapMethod<String,
                dynamic>(
            'BillingClient#consumeAsync(ConsumeParams, ConsumeResponseListener)',
            <String, dynamic>{
              'purchaseToken': purchaseToken,
            })) ??
        <String, dynamic>{});
  }

  /// Acknowledge an in-app purchase.
  ///
  /// The developer must acknowledge all in-app purchases after they have been granted to the user.
  /// If this doesn't happen within three days of the purchase, the purchase will be refunded.
  ///
  /// Consumables are already implicitly acknowledged by calls to [consumeAsync] and
  /// do not need to be explicitly acknowledged by using this method.
  /// However this method can be called for them in order to explicitly acknowledge them if desired.
  ///
  /// Be sure to only acknowledge a purchase after it has been granted to the user.
  /// [PurchaseWrapper.purchaseState] should be [PurchaseStateWrapper.purchased] and
  /// the purchase should be validated. See [Verify a purchase](https://developer.android.com/google/play/billing/billing_library_overview#Verify) on verifying purchases.
  ///
  /// Please refer to [acknowledge](https://developer.android.com/google/play/billing/billing_library_overview#acknowledge) for more
  /// details.
  ///
  /// This wraps
  /// [`BillingClient#acknowledgePurchase(AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener)`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.html#acknowledgePurchase(com.android.billingclient.api.AcknowledgePurchaseParams,%20com.android.billingclient.api.AcknowledgePurchaseResponseListener))
  Future<BillingResultWrapper> acknowledgePurchase(String purchaseToken) async {
    return BillingResultWrapper.fromJson((await channel.invokeMapMethod<String,
                dynamic>(
            'BillingClient#acknowledgePurchase(AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener)',
            <String, dynamic>{
              'purchaseToken': purchaseToken,
            })) ??
        <String, dynamic>{});
  }

  /// Checks if the specified feature or capability is supported by the Play Store.
  /// Call this to check if a [BillingClientFeature] is supported by the device.
  Future<bool> isFeatureSupported(BillingClientFeature feature) async {
    final bool? result = await channel.invokeMethod<bool>(
        'BillingClient#isFeatureSupported(String)', <String, dynamic>{
      'feature': const BillingClientFeatureConverter().toJson(feature),
    });
    return result ?? false;
  }

  /// The method call handler for [channel].
  @visibleForTesting
  Future<void> callHandler(MethodCall call) async {
    switch (call.method) {
      case kOnPurchasesUpdated:
        // The purchases updated listener is a singleton.
        assert(_callbacks[kOnPurchasesUpdated]!.length == 1);
        final PurchasesUpdatedListener listener =
            _callbacks[kOnPurchasesUpdated]!.first as PurchasesUpdatedListener;
        listener(PurchasesResultWrapper.fromJson(
            (call.arguments as Map<dynamic, dynamic>).cast<String, dynamic>()));
        break;
      case _kOnBillingServiceDisconnected:
        final int handle =
            (call.arguments as Map<Object?, Object?>)['handle']! as int;
        final List<OnBillingServiceDisconnected> onDisconnected =
            _callbacks[_kOnBillingServiceDisconnected]!
                .cast<OnBillingServiceDisconnected>();
        onDisconnected[handle]();
        break;
    }
  }
}

/// Callback triggered when the [BillingClientWrapper] is disconnected.
///
/// Wraps
/// [`com.android.billingclient.api.BillingClientStateListener.onServiceDisconnected()`](https://developer.android.com/reference/com/android/billingclient/api/BillingClientStateListener.html#onBillingServiceDisconnected())
/// to call back on `BillingClient` disconnect.
typedef OnBillingServiceDisconnected = void Function();

/// Possible `BillingClient` response statuses.
///
/// Wraps
/// [`BillingClient.BillingResponse`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.BillingResponse).
/// See the `BillingResponse` docs for more explanation of the different
/// constants.
@JsonEnum(alwaysCreate: true)
enum BillingResponse {
  // WARNING: Changes to this class need to be reflected in our generated code.
  // Run `flutter packages pub run build_runner watch` to rebuild and watch for
  // further changes.

  /// The request has reached the maximum timeout before Google Play responds.
  @JsonValue(-3)
  serviceTimeout,

  /// The requested feature is not supported by Play Store on the current device.
  @JsonValue(-2)
  featureNotSupported,

  /// The play Store service is not connected now - potentially transient state.
  @JsonValue(-1)
  serviceDisconnected,

  /// Success.
  @JsonValue(0)
  ok,

  /// The user pressed back or canceled a dialog.
  @JsonValue(1)
  userCanceled,

  /// The network connection is down.
  @JsonValue(2)
  serviceUnavailable,

  /// The billing API version is not supported for the type requested.
  @JsonValue(3)
  billingUnavailable,

  /// The requested product is not available for purchase.
  @JsonValue(4)
  itemUnavailable,

  /// Invalid arguments provided to the API.
  @JsonValue(5)
  developerError,

  /// Fatal error during the API action.
  @JsonValue(6)
  error,

  /// Failure to purchase since item is already owned.
  @JsonValue(7)
  itemAlreadyOwned,

  /// Failure to consume since item is not owned.
  @JsonValue(8)
  itemNotOwned,
}

/// Serializer for [BillingResponse].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@BillingResponseConverter()`.
class BillingResponseConverter implements JsonConverter<BillingResponse, int?> {
  /// Default const constructor.
  const BillingResponseConverter();

  @override
  BillingResponse fromJson(int? json) {
    if (json == null) {
      return BillingResponse.error;
    }
    return $enumDecode(_$BillingResponseEnumMap, json);
  }

  @override
  int toJson(BillingResponse object) => _$BillingResponseEnumMap[object]!;
}

/// Enum representing potential [ProductDetailsWrapper.productType]s.
///
/// Wraps
/// [`BillingClient.ProductType`](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.ProductType)
/// See the linked documentation for an explanation of the different constants.
@JsonEnum(alwaysCreate: true)
enum ProductType {
  // WARNING: Changes to this class need to be reflected in our generated code.
  // Run `flutter packages pub run build_runner watch` to rebuild and watch for
  // further changes.

  /// A one time product. Acquired in a single transaction.
  @JsonValue('inapp')
  inapp,

  /// A product requiring a recurring charge over time.
  @JsonValue('subs')
  subs,
}

/// Serializer for [ProductType].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@ProductTypeConverter()`.
class ProductTypeConverter implements JsonConverter<ProductType, String?> {
  /// Default const constructor.
  const ProductTypeConverter();

  @override
  ProductType fromJson(String? json) {
    if (json == null) {
      return ProductType.inapp;
    }
    return $enumDecode(_$ProductTypeEnumMap, json);
  }

  @override
  String toJson(ProductType object) => _$ProductTypeEnumMap[object]!;
}

/// Enum representing the proration mode.
///
/// When upgrading or downgrading a subscription, set this mode to provide details
/// about the proration that will be applied when the subscription changes.
///
/// Wraps [`BillingFlowParams.ProrationMode`](https://developer.android.com/reference/com/android/billingclient/api/BillingFlowParams.ProrationMode)
/// See the linked documentation for an explanation of the different constants.
@JsonEnum(alwaysCreate: true)
enum ProrationMode {
// WARNING: Changes to this class need to be reflected in our generated code.
// Run `flutter packages pub run build_runner watch` to rebuild and watch for
// further changes.

  /// Unknown upgrade or downgrade policy.
  @JsonValue(0)
  unknownSubscriptionUpgradeDowngradePolicy,

  /// Replacement takes effect immediately, and the remaining time will be prorated
  /// and credited to the user.
  ///
  /// This is the current default behavior.
  @JsonValue(1)
  immediateWithTimeProration,

  /// Replacement takes effect immediately, and the billing cycle remains the same.
  ///
  /// The price for the remaining period will be charged.
  /// This option is only available for subscription upgrade.
  @JsonValue(2)
  immediateAndChargeProratedPrice,

  /// Replacement takes effect immediately, and the new price will be charged on next
  /// recurrence time.
  ///
  /// The billing cycle stays the same.
  @JsonValue(3)
  immediateWithoutProration,

  /// Replacement takes effect when the old plan expires, and the new price will
  /// be charged at the same time.
  @JsonValue(4)
  deferred,

  /// Replacement takes effect immediately, and the user is charged full price
  /// of new plan and is given a full billing cycle of subscription, plus
  /// remaining prorated time from the old plan.
  @JsonValue(5)
  immediateAndChargeFullPrice,
}

/// Serializer for [ProrationMode].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@ProrationModeConverter()`.
class ProrationModeConverter implements JsonConverter<ProrationMode, int?> {
  /// Default const constructor.
  const ProrationModeConverter();

  @override
  ProrationMode fromJson(int? json) {
    if (json == null) {
      return ProrationMode.unknownSubscriptionUpgradeDowngradePolicy;
    }
    return $enumDecode(_$ProrationModeEnumMap, json);
  }

  @override
  int toJson(ProrationMode object) => _$ProrationModeEnumMap[object]!;
}

/// Features/capabilities supported by [BillingClient.isFeatureSupported()](https://developer.android.com/reference/com/android/billingclient/api/BillingClient.FeatureType).
@JsonEnum(alwaysCreate: true)
enum BillingClientFeature {
  // WARNING: Changes to this class need to be reflected in our generated code.
  // Run `flutter packages pub run build_runner watch` to rebuild and watch for
  // further changes.
  //
  // JsonValues need to match constant values defined in https://developer.android.com/reference/com/android/billingclient/api/BillingClient.FeatureType#summary

  /// Purchase/query for in-app items on VR.
  @JsonValue('inAppItemsOnVr')
  inAppItemsOnVR,

  /// Launch a price change confirmation flow.
  @JsonValue('priceChangeConfirmation')
  priceChangeConfirmation,

  /// Play billing library support for querying and purchasing with ProductDetails.
  @JsonValue('fff')
  productDetails,

  /// Purchase/query for subscriptions.
  @JsonValue('subscriptions')
  subscriptions,

  /// Purchase/query for subscriptions on VR.
  @JsonValue('subscriptionsOnVr')
  subscriptionsOnVR,

  /// Subscriptions update/replace.
  @JsonValue('subscriptionsUpdate')
  subscriptionsUpdate
}

/// Serializer for [BillingClientFeature].
///
/// Use these in `@JsonSerializable()` classes by annotating them with
/// `@BillingClientFeatureConverter()`.
class BillingClientFeatureConverter
    implements JsonConverter<BillingClientFeature, String> {
  /// Default const constructor.
  const BillingClientFeatureConverter();

  @override
  BillingClientFeature fromJson(String json) {
    return $enumDecode<BillingClientFeature, dynamic>(
        _$BillingClientFeatureEnumMap.cast<BillingClientFeature, dynamic>(),
        json);
  }

  @override
  String toJson(BillingClientFeature object) =>
      _$BillingClientFeatureEnumMap[object]!;
}
