// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'pending_purchases_params_wrapper.g.dart';

/// Dart wrapper around [`com.android.billingclient.api.PendingPurchasesParams`](https://developer.android.com/reference/com/android/billingclient/api/PendingPurchasesParams).
///
/// Represents the parameters to enable pending purchases.
@JsonSerializable()
@immutable
class PendingPurchasesParamsWrapper {
  /// Creates a [PendingPurchasesParamsWrapper].
  const PendingPurchasesParamsWrapper({
    required this.enablePrepaidPlans,
  });

  /// Factory for creating a [PendingPurchasesParamsWrapper] from a [Map].
  @Deprecated('JSON serialization is not intended for public use, and will '
      'be removed in a future version.')
  factory PendingPurchasesParamsWrapper.fromJson(Map<String, dynamic> map) =>
      _$PendingPurchasesParamsWrapperFromJson(map);

  /// Enables pending purchase for prepaid plans.
  ///
  /// Handling pending purchases for prepaid plans is different from one-time products.
  /// Your application will need to be updated to ensure subscription entitlements are
  /// managed correctly with pending transactions.
  /// To learn more see https://developer.android.com/google/play/billing/subscriptions#pending.
  @JsonKey(defaultValue: false)
  final bool enablePrepaidPlans;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is PendingPurchasesParamsWrapper &&
        other.enablePrepaidPlans == enablePrepaidPlans;
  }

  @override
  int get hashCode {
    return enablePrepaidPlans.hashCode;
  }
}
