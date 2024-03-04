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

/// Pigeon version of BillingChoiceMode.
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

  // XXX half converted; should return an object.
  @async
  Map<String?, Object?> startConnection(
      int callbackHandle, PlatformBillingChoiceMode billingMode);
}
