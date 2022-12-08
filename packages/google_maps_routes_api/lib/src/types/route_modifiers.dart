// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';

/// Encapsulates a set of optional conditions to satisfy when calculating the
/// routes.
class RouteModifiers {
  /// Creates a [RouteModifiers] object.
  const RouteModifiers({
    this.avoidTolls,
    this.avoidHighways,
    this.avoidFerries,
    this.avoidIndoor,
    this.vehicleInfo,
    this.tollPasses,
  });

  /// Specifies whether to avoid toll roads where reasonable. Preference will
  /// be given to routes not containing toll roads. Applies only to the
  /// [RouteTravelMode.DRIVE] and [RouteTravelMode.TWO_WHEELER] travel modes.
  final bool? avoidTolls;

  /// Specifies whether to avoid highways where reasonable. Preference will
  /// be given to routes not containing highways. Applies only to the
  /// [RouteTravelMode.DRIVE] and [RouteTravelMode.TWO_WHEELER] travel modes.
  final bool? avoidHighways;

  /// Specifies whether to avoid ferries where reasonable. Preference will be
  /// given to routes not containing highways. Applies only to the
  /// [RouteTravelMode.DRIVE] and [RouteTravelMode.TWO_WHEELER] travel modes.
  final bool? avoidFerries;

  /// Specifies whether to avoid navigating indoors where reasonable.
  /// Preference will be given to routes not containing indoor navigation.
  /// Applies only to the [RouteTravelMode.WALK] travel mode.
  final bool? avoidIndoor;

  /// Specifies the vehicle information.
  final VehicleInfo? vehicleInfo;

  /// Encapsulates information about toll passes. If toll passes are provided,
  /// the API tries to return the pass price. If toll passes are not provided,
  /// the API treats the toll pass as unknown and tries to return the cash
  /// price. Applies only to the [RouteTravelMode.DRIVE] and
  /// [RouteTravelMode.TWO_WHEELER] travel modes.
  final List<TollPass>? tollPasses;

  /// Returns a JSON representation of the [RouteModifiers].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'avoidTolls': avoidTolls,
      'avoidHighways': avoidHighways,
      'avoidFerries': avoidFerries,
      'avoidIndoor': avoidIndoor,
      'vehicleInfo': vehicleInfo?.toJson(),
      'tollPasses': tollPasses?.map((TollPass tollPass) => tollPass.name),
    };
    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}

/// Encapsulates the vehicle information, such as the license plate last
/// character.
class VehicleInfo {
  /// Creates a [VehicleInfo] object.
  const VehicleInfo({required this.emissionType});

  /// Describes the vehicle's emission type. Applies only to the
  /// [RouteTravelMode.DRIVE] travel mode.
  final VehicleEmissionType emissionType;

  /// Returns a JSON representation of the [VehicleInfo].
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'emissionType': emissionType.name};
  }
}
