// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:google_maps_routes_api/src/types/enums.dart';
import 'package:google_maps_routes_api/src/types/navigation_instruction.dart';
import 'package:test/test.dart';

void main() {
  group('NavigationInstruction', () {
    test(
        'fromJson() correctly decodes a JSON object to a NavigationInstruction',
        () {
      final Map<String, dynamic> json = <String, dynamic>{
        'maneuver': 'MERGE',
        'instructions': 'merge onto the highway',
      };

      final NavigationInstruction? instruction =
          NavigationInstruction.fromJson(json);
      expect(instruction?.maneuver, equals(Maneuver.MERGE));
      expect(instruction?.instructions, equals('merge onto the highway'));
    });

    test('toJson() encodes NavigationInstruction to JSON', () {
      const NavigationInstruction instruction = NavigationInstruction(
        maneuver: Maneuver.TURN_RIGHT,
        instructions: 'turn right onto Main Street',
      );

      final Map<String, dynamic> expectedJson = <String, dynamic>{
        'maneuver': 'TURN_RIGHT',
        'instructions': 'turn right onto Main Street',
      };

      expect(instruction.toJson(), equals(expectedJson));
    });
  });
}
