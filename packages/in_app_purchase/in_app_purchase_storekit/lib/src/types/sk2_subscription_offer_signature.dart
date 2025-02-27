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
  ///
  /// The private key and key ID can be generated in App Store Connect.
  final String keyID;

  /// The nonce used in the signature.
  ///
  /// This should be a UUID (Universally Unique Identifier).
  final String nonce;

  /// The timestamp when the signature was generated, in milliseconds since 1970.
  final int timestamp;

  /// The cryptographic signature of the offer parameters.
  ///
  /// This must be a Base64-encoded string.
  final String signature;
}
