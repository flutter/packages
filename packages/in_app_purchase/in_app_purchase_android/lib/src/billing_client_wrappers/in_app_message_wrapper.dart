import 'package:flutter/foundation.dart';

/// Response code for the in-app messaging API call.
enum InAppMessageResponse {
  /// The flow has finished and there is no action needed from developers.
  ///
  /// Note: The API callback won't indicate whether message is dismissed by the
  /// user or there is no message available to the user.
  noActionNeeded,

  /// The subscription status changed.
  ///
  /// For example, a subscription has been rec-
  /// overed from a suspended state. Developers should expect the purchase token
  /// to be returned with this response code and use the purchase token with the
  /// Google Play Developer API.
  subscriptionStatusUpdated,
}

/// Results related to in-app messaging.
///
/// Wraps [`com.android.billingclient.api.InAppMessageResult`](https://developer.android.com/reference/com/android/billingclient/api/InAppMessageResult).
@immutable
class InAppMessageResultWrapper {
  /// Creates a [InAppMessageResultWrapper]
  const InAppMessageResultWrapper({
    required this.responseCode,
    this.purchaseToken,
  });

  /// Returns response code for the in-app messaging API call.
  final InAppMessageResponse responseCode;

  /// Returns token that identifies the purchase to be acknowledged, if any.
  final String? purchaseToken;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InAppMessageResultWrapper &&
          runtimeType == other.runtimeType &&
          responseCode == other.responseCode &&
          purchaseToken == other.purchaseToken;

  @override
  int get hashCode => Object.hash(responseCode, purchaseToken);
}
