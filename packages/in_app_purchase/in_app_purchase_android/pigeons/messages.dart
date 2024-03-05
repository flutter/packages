// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  javaOptions: JavaOptions(package: 'io.flutter.plugins.inapppurchase'),
  javaOut:
      'android/src/main/java/io/flutter/plugins/inapppurchase/Messages.java',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon version of Java BillingResult.
class PlatformBillingResult {
  PlatformBillingResult(
      {required this.responseCode, required this.debugMessage});
  final int responseCode;
  final String debugMessage;
}

/// Pigeon version of Java BillingFlowParams.
class PlatformBillingFlowParams {
  PlatformBillingFlowParams({
    required this.product,
    required this.prorationMode,
    required this.offerToken,
    required this.accountId,
    required this.obfuscatedProfileId,
    required this.oldProduct,
    required this.purchaseToken,
  });

  final String product;
  // Ideally this would be replaced with an enum on the dart side that maps
  // to constants on the Java side, but it's deprecated anyway so that will be
  // resolved during the update to the new API.
  final int prorationMode;
  final String? offerToken;
  final String? accountId;
  final String? obfuscatedProfileId;
  final String? oldProduct;
  final String? purchaseToken;
}

/// Pigeon version of billing_client_wrapper.dart's BillingChoiceMode.
enum PlatformBillingChoiceMode {
  /// Billing through google play.
  ///
  /// Default state.
  playBillingOnly,

  /// Billing through app provided flow.
  alternativeBillingOnly,
}

@HostApi()
abstract class InAppPurchaseApi {
  /// Wraps BillingClient#isReady.
  bool isReady();

  /// Wraps BillingClient#startConnection(BillingClientStateListener).
  @async
  PlatformBillingResult startConnection(
      int callbackHandle, PlatformBillingChoiceMode billingMode);

  /// Wraps BillingClient#endConnection(BillingClientStateListener).
  void endConnection();

  /// Wraps BillingClient#launchBillingFlow(Activity, BillingFlowParams).
  PlatformBillingResult launchBillingFlow(PlatformBillingFlowParams params);

  /// Wraps BillingClient#acknowledgePurchase(AcknowledgePurchaseParams, AcknowledgePurchaseResponseListener).
  @async
  PlatformBillingResult acknowledgePurchase(String purchaseToken);

  /// Wraps BillingClient#consumeAsync(ConsumeParams, ConsumeResponseListener).
  @async
  PlatformBillingResult consumeAsync(String purchaseToken);

  /// Wraps BillingClient#isFeatureSupported(String).
  // TODO(stuartmorgan): Consider making this take a enum, and converting the
  // enum value to string constants on the native side, so that magic strings
  // from the Play Billing API aren't duplicated in Dart code.
  bool isFeatureSupported(String feature);

  /// Wraps BillingClient#isAlternativeBillingOnlyAvailableAsync().
  @async
  PlatformBillingResult isAlternativeBillingOnlyAvailableAsync();

  /// Wraps BillingClient#showAlternativeBillingOnlyInformationDialog().
  @async
  PlatformBillingResult showAlternativeBillingOnlyInformationDialog();
}
