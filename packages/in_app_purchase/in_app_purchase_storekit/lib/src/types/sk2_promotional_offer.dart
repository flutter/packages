// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'sk2_subscription_offer_signature.dart';

/// A wrapper class representing a promotional offer.
///
/// This class contains the promotional offer identifier and its associated
/// cryptographic signature.
class SK2PromotionalOffer {
  /// Creates a new [SK2PromotionalOffer] object.
  SK2PromotionalOffer({
    required this.offerId,
    required this.signature,
  });

  /// The promotional offer identifier.
  final String offerId;

  /// The cryptographic signature of the promotional offer.
  ///
  /// This must include metadata such as the `keyID`, `nonce`, `timestamp`,
  /// and the Base64-encoded signature.
  final SK2SubscriptionOfferSignature signature;
}
