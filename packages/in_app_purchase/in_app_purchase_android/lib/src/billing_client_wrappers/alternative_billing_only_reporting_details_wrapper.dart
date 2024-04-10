// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../billing_client_wrappers.dart';

// WARNING: Changes to `@JsonSerializable` classes need to be reflected in the
// below generated file. Run `flutter packages pub run build_runner watch` to
// rebuild and watch for further changes.
part 'alternative_billing_only_reporting_details_wrapper.g.dart';

/// The error message shown when the map representing details is invalid from method channel.
///
/// This usually indicates a serious underlying code issue in the plugin.
@visibleForTesting
const String kInvalidAlternativeBillingReportingDetailsErrorMessage =
    'Invalid AlternativeBillingReportingDetails map from method channel.';

/// Params containing the response code and the debug message from the Play Billing API response.
@JsonSerializable()
@BillingResponseConverter()
@immutable
class AlternativeBillingOnlyReportingDetailsWrapper
    implements HasBillingResponse {
  /// Constructs the object with [responseCode] and [debugMessage].
  const AlternativeBillingOnlyReportingDetailsWrapper(
      {required this.responseCode,
      this.debugMessage,
      this.externalTransactionToken = ''});

  /// Constructs an instance of this from a key value map of data.
  ///
  /// The map needs to have named string keys with values matching the names and
  /// types of all of the members on this class.
  @Deprecated('JSON serialization is not intended for public use, and will '
      'be removed in a future version.')
  factory AlternativeBillingOnlyReportingDetailsWrapper.fromJson(
      Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) {
      return const AlternativeBillingOnlyReportingDetailsWrapper(
        responseCode: BillingResponse.error,
        debugMessage: kInvalidAlternativeBillingReportingDetailsErrorMessage,
      );
    }
    return _$AlternativeBillingOnlyReportingDetailsWrapperFromJson(map);
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

  /// https://developer.android.com/reference/com/android/billingclient/api/AlternativeBillingOnlyReportingDetails#getExternalTransactionToken()
  @JsonKey(defaultValue: '')
  final String externalTransactionToken;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }

    return other is AlternativeBillingOnlyReportingDetailsWrapper &&
        other.responseCode == responseCode &&
        other.debugMessage == debugMessage &&
        other.externalTransactionToken == externalTransactionToken;
  }

  @override
  int get hashCode =>
      Object.hash(responseCode, debugMessage, externalTransactionToken);
}
