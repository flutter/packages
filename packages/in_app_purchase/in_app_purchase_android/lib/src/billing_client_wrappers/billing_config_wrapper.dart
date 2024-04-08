// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../billing_client_wrappers.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'billing_config_wrapper.g.dart';

/// The error message shown when the map represents billing config is invalid from method channel.
///
/// This usually indicates a serious underlining code issue in the plugin.
@visibleForTesting
const String kInvalidBillingConfigErrorMessage =
    'Invalid billing config map from method channel.';

/// Params containing the response code and the debug message from the Play Billing API response.
@JsonSerializable()
@BillingResponseConverter()
@immutable
class BillingConfigWrapper implements HasBillingResponse {
  /// Constructs the object with [responseCode] and [debugMessage].
  const BillingConfigWrapper(
      {required this.responseCode, this.debugMessage, this.countryCode = ''});

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  @Deprecated('JSON serialization is not intended for public use, and will '
      'be removed in a future version.')
  factory BillingConfigWrapper.fromJson(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const BillingConfigWrapper(
        responseCode: BillingResponse.error,
        debugMessage: kInvalidBillingConfigErrorMessage,
      );
    }
    return _$BillingConfigWrapperFromJson(map);
  }

  /// Response code returned in the Play Billing API calls.
  @override
  final BillingResponse responseCode;

  /// Debug message returned in the Play Billing API calls.
  ///
  /// Defaults to `null`.
  /// This message uses an en-US locale and should not be shown to users.
  @JsonKey(defaultValue: '')
  final String? debugMessage;

  /// https://developer.android.com/reference/com/android/billingclient/api/BillingConfig#getCountryCode()
  @JsonKey(defaultValue: '')
  final String countryCode;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is BillingConfigWrapper &&
        other.responseCode == responseCode &&
        other.debugMessage == debugMessage &&
        other.countryCode == countryCode;
  }

  @override
  int get hashCode => Object.hash(responseCode, debugMessage, countryCode);
}
