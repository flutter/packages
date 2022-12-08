// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'enums.dart';
import 'route_leg.dart';

/// Encapsulates navigation instructions for a [RouteLegStep].
class NavigationInstruction {
  /// Creates a [NavigationInstruction].
  const NavigationInstruction({this.maneuver, this.instructions});

  /// Encapsulates the navigation instructions for the current [RouteLegStep]
  /// (e.g., turn left, merge, straight, etc.). This field determines which
  /// icon to display.
  final Maneuver? maneuver;

  /// Instructions for navigating this [RouteLegStep].
  final String? instructions;

  /// Decodes a JSON object to a [NavigationInstruction].
  ///
  /// Returns null if [json] is null.
  static NavigationInstruction? fromJson(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map<String, dynamic>);
    final Map<String, dynamic> data = json as Map<String, dynamic>;

    return NavigationInstruction(
        maneuver: data['maneuver'] != null
            ? Maneuver.values.byName(data['maneuver'])
            : null,
        instructions: data['instructions']);
  }

  /// Returns a JSON representation of the [NavigationInstruction].
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{
      'maneuver': maneuver?.name,
      'instructions': instructions,
    };

    json.removeWhere((String key, dynamic value) => value == null);
    return json;
  }
}
