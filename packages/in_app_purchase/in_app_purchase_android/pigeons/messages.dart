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
}
