// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This class encapsulates the metadata required to validate a promotional offer,
/// as specified in the Apple StoreKit documentation:
/// https://developer.apple.com/documentation/storekit/product/subscriptionoffer/signature
class SK2SubscriptionOfferSignature {
  /// Creates a new [SK2SubscriptionOfferSignature] object.
  SK2SubscriptionOfferSignature({
    required this.keyID,
    required this.nonce,
    required this.timestamp,
    required this.signature,
  });

  /// The key ID of the private key used to generate the signature.
  final String keyID;

  /// The nonce used in the signature (a UUID).
  final String nonce;

  /// The timestamp when the signature was generated, in milliseconds since 1970.
  final int timestamp;

  /// The cryptographic signature of the offer parameters (Base64-encoded string).
  final String signature;
}

/// A wrapper class representing a promotional offer.
///
/// This class contains the promotional offer identifier and its associated
/// cryptographic signature.
final class SK2PromotionalOffer {
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
