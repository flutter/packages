// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'route.dart';
import 'route_leg.dart';

/// Encapsulates toll information on a [Route] or on a [RouteLeg].
class TollInfo {
  /// Creates a [TollInfo].
  const TollInfo({required this.estimatedPrice});

  /// The monetary amount of tolls for the corresponding [Route] or [RouteLeg].
  /// This list contains a money amount for each currency that is expected to
  /// be charged by the toll stations. Typically this list will contain only
  /// one item for routes with tolls in one currency. For international trips,
  /// this list may contain multiple items to reflect tolls in different
  /// currencies.
  final List<Money> estimatedPrice;

  /// Decodes a JSON object to a [TollInfo].
  ///
  /// Returns null if [json] is null.
  static TollInfo? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;
    final List<Money> estimatedPrice = List<Money>.from(
      (data['estimatedPrice'] as List<dynamic>).map(
        (dynamic model) => Money.fromJson(model),
      ),
    );

    return TollInfo(estimatedPrice: estimatedPrice);
  }

  /// Returns a JSON representation of the [TollInfo].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'estimatedPrice':
          estimatedPrice.map((Money price) => price.toJson()).toList(),
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// Represents an amount of money with its currency type.
class Money {
  /// Creates a [Money].
  const Money(
      {required this.currencyCode, required this.units, required this.nanos});

  /// The three-letter currency code defined in ISO 4217.
  final String currencyCode;

  /// The whole units of the amount. For example if [currencyCode] is "USD",
  /// then 1 unit is one US dollar.
  final String units;

  /// Number of nano (10^-9) units of the amount. The value must be between
  /// -999,999,999 and +999,999,999 inclusive. If units is positive, [nanos]
  /// must be positive or zero. If [units] is zero, [nanos] can be positive,
  /// zero, or negative. If [units] is negative, [nanos] must be negative or
  /// zero.
  ///
  /// For example $-1.75 is represented as units=-1 and nanos=-750,000,000.
  final int nanos;

  /// Decodes a JSON object to a [Money].
  ///
  /// Returns null if [json] is null.
  static Money? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return Money(
      currencyCode: data['currencyCode'],
      units: data['units'],
      nanos: data['nanos'],
    );
  }

  /// Returns a JSON representation of the [Money].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'currencyCode': currencyCode,
      'units': units,
      'nanos': nanos,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
