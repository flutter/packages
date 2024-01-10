// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/sk_storefront_wrapper.g.dart',
  objcHeaderOut: 'darwin/Classes/messages.g.h',
  objcSourceOut: 'darwin/Classes/messages.g.m',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Contains the location and unique identifier of an Apple App Store storefront.
///
/// Dart wrapper around StoreKit's
/// [SKStorefront](https://developer.apple.com/documentation/storekit/skstorefront?language=objc).
class SKStorefrontWrapper {
  /// Creates a new [SKStorefrontWrapper] with the provided information.
  // TODO(stuartmorgan): Temporarily ignore const warning in other parts of the
  // federated package, and remove this.
  // ignore: prefer_const_constructors_in_immutables
  SKStorefrontWrapper({
    required this.countryCode,
    required this.identifier,
  });

  /// The three-letter code representing the country or region associated with
  /// the App Store storefront.
  final String countryCode;

  /// A value defined by Apple that uniquely identifies an App Store storefront.
  final String identifier;

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SKStorefrontWrapper &&
        other.countryCode == countryCode &&
        other.identifier == identifier;
  }

  @override
  int get hashCode => Object.hash(
    countryCode,
    identifier,
  );
}
