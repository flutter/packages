// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import '../billing_client_wrappers.dart';
import 'messages.g.dart';

/// Converts a [BillingChoiceMode] to the Pigeon equivalent.
PlatformBillingChoiceMode platformBillingChoiceMode(BillingChoiceMode mode) {
  return switch (mode) {
    BillingChoiceMode.playBillingOnly =>
      PlatformBillingChoiceMode.playBillingOnly,
    BillingChoiceMode.alternativeBillingOnly =>
      PlatformBillingChoiceMode.alternativeBillingOnly,
  };
}

/// Converts a [BillingResultWrapper] to the Pigeon equivalent.
BillingResultWrapper resultWrapperFromPlatform(PlatformBillingResult result) {
  return BillingResultWrapper(
      responseCode:
          const BillingResponseConverter().fromJson(result.responseCode),
      debugMessage: result.debugMessage);
}
